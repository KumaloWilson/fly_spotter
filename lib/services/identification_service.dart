import 'dart:io';
import 'package:specifier/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tflite_v3/tflite_v3.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import '../models/fly_identification.dart';
import '../utiils/logs.dart';
import 'firestore_service.dart';

class IdentificationService {
  final FirestoreService _firestoreService = FirestoreService();
  final _supabase = SupabaseManager.client;
  final Uuid _uuid = Uuid();
  bool _modelLoaded = false;

  // Initialize TFLite model
  Future<void> loadModel() async {
    try {
      if (!_modelLoaded) {
        await Tflite.loadModel(
          model: 'assets/ai_model/model_unquant.tflite',
          labels: 'assets/ai_model/labels.txt',
        );
        _modelLoaded = true;
      }
    } catch (e) {
      throw 'Failed to load model: $e';
    }
  }

  // Dispose TFLite model
  Future<void> disposeModel() async {
    if (_modelLoaded) {
      await Tflite.close();
      _modelLoaded = false;
    }
  }

  // Identify fly from image file
  Future<List<dynamic>> identifyFromImage(File imageFile) async {
    try {
      await loadModel();

      var recognitions = await Tflite.runModelOnImage(
        path: imageFile.path,
        numResults: 5,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5,
      );

      return recognitions ?? [];
    } catch (e) {
      throw 'Identification failed: $e';
    }
  }

  Future<IdentificationResult> saveIdentificationResult({
    required String userId,
    required File imageFile,
    required String speciesId,
    required double confidenceScore,
  }) async {
    try {
      // Validate inputs
      if (userId.isEmpty) {
        throw ArgumentError('User ID cannot be empty');
      }
      if (!imageFile.existsSync()) {
        throw FileSystemException('Image file does not exist');
      }
      if (imageFile.lengthSync() == 0) {
        throw FileSystemException('Image file is empty');
      }

      // Generate a unique filename
      String fileName = '${_uuid.v4()}${path.extension(imageFile.path)}';

      // Prepare the file path in Supabase Storage
      final filePath = 'identificationimages/$userId/$fileName';

      // Upload image to Supabase Storage
      String imageUrl;
      try {
        final uploadResponse = await _supabase.storage
            .from('identificationimages')
            .upload(
          filePath,
          imageFile,
          fileOptions: FileOptions(
            upsert: true,
          ),
        );

        // Verify upload success
        if (uploadResponse == null) {
          throw StorageException('Upload failed: No response from Supabase');
        }

        // Get public URL for the uploaded image
        imageUrl = _supabase.storage
            .from('identificationimages')
            .getPublicUrl(filePath);
      } on StorageException catch (storageError) {
        DevLogs.logError('Supabase Storage Error: ${storageError.message}');
        throw 'Storage upload failed: ${storageError.message}';
      }

      // Get species details with fallback
      FlySpecies species;
      try {
        species = await _firestoreService.getSpecies(speciesId);
      } catch (speciesError) {
        // Log the error but create a fallback species object
        DevLogs.logError('Failed to fetch species: $speciesError');

        species = FlySpecies(
            id: speciesId,
            name: 'Unknown Species',
            description: 'Species details could not be retrieved',
            scientificName: 'Unknown',
            imageUrl: ''
        );
      }

      // Create identification result
      IdentificationResult result = IdentificationResult(
        id: _uuid.v4(),
        timestamp: DateTime.now(),
        species: species,
        confidenceScore: confidenceScore,
        imageUrl: imageUrl,
        userId: userId,
      );

      // Save to Firestore
      try {
        await _firestoreService.saveIdentificationResult(result);
      } catch (saveError) {
        DevLogs.logError('Failed to save identification result: $saveError');
        throw 'Could not save identification result: $saveError';
      }

      return result;
    } catch (e) {
      DevLogs.logError('Identification save failed: $e');
      rethrow;
    }
  }

  // Get cached identification results for offline use
  Future<List<IdentificationResult>> getCachedResults(String userId) async {
    try {
      return await _firestoreService.getUserIdentificationHistory(userId);
    } catch (e) {
      throw 'Failed to get cached results: $e';
    }
  }
}

