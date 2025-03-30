import 'dart:io';
import 'package:specifier/services/supabase_service.dart';
import 'package:specifier/utiils/logs.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tflite_v3/tflite_v3.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import '../models/fly_identification.dart';
import 'firestore_service.dart';
import 'package:image/image.dart' as img;

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
          model: 'assets/models/fly_identification_model.tflite',
          labels: 'assets/models/labels.txt',
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

  // Enhance the identifyFromImage method to provide more detailed analysis
  Future<List<dynamic>> identifyFromImage(File imageFile) async {
    try {
      await loadModel();

      // Check image quality before processing
      bool isLowQuality = await _checkImageQuality(imageFile);
      if (isLowQuality) {
        DevLogs.logWarning('Low quality image detected, proceeding with caution');
      }

      var recognitions = await Tflite.runModelOnImage(
        path: imageFile.path,
        numResults: 5,
        threshold: 0.3,
        imageMean: 127.5,
        imageStd: 127.5,
      );

      List<dynamic> processedResults = _postProcessResults(recognitions ?? []);

      return processedResults;
    } catch (e) {
      throw 'Identification failed: $e';
    }
  }

  // Save identification result with image
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
      throw 'Failed to save identification: $e';
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

  // Add this method to detect low light conditions
  Future<bool> detectLowLight(File imageFile) async {
    try {
      // Read the image file
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) return false;

      // Calculate average brightness
      int totalBrightness = 0;
      int pixelCount = 0;

      // Sample pixels (for efficiency, we'll sample every 10th pixel)
      for (int y = 0; y < image.height; y += 10) {
        for (int x = 0; x < image.width; x += 10) {
          final pixel = image.getPixel(x, y);
          // Extract RGB values - corrected to access color components properly
          final r = pixel.r;
          final g = pixel.g;
          final b = pixel.b;

          final brightness = (0.299 * r + 0.587 * g + 0.114 * b).round();
          totalBrightness += brightness;
          pixelCount++;
        }
      }

      // Calculate average brightness (0-255)
      final avgBrightness = totalBrightness / pixelCount;

      // Consider low light if average brightness is below threshold (e.g., 60)
      return avgBrightness < 60;
    } catch (e) {
      print('Error analyzing image brightness: $e');
      return false;
    }
  }

  // Add a method to check image quality
  Future<bool> _checkImageQuality(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) return true; // Assume low quality if can't decode

      // Check resolution
      bool lowResolution = image.width < 300 || image.height < 300;

      // Check blur (simplified)
      bool isBlurry = await _detectBlur(image);

      return lowResolution || isBlurry;
    } catch (e) {
      DevLogs.logError('Error checking image quality: $e');
      return false;
    }
  }

  // Helper method to convert RGB to grayscale
  int _rgbToGray(img.Pixel pixel) {
    // Access RGB values directly from pixel object
    final r = pixel.r;
    final g = pixel.g;
    final b = pixel.b;
    return (0.299 * r + 0.587 * g + 0.114 * b).round();
  }

  // Post-process results to improve accuracy
  List<dynamic> _postProcessResults(List<dynamic> results) {
    if (results.isEmpty) return results;

    // Filter out very low confidence results
    results = results.where((result) => result['confidence'] > 0.1).toList();

    // Sort by confidence
    results.sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double));

    return results;
  }

  // Add a method to detect blur
  /// Detects if an image is blurry using Laplacian variance
  /// Returns true if the image is considered blurry
  Future<bool> _detectBlur(img.Image image) async {
    try {
      // Simplified Laplacian variance calculation for blur detection
      // Sample pixels for efficiency
      int sampleSize = 100;
      int stepX = image.width ~/ 10;
      int stepY = image.height ~/ 10;

      List<int> laplacianValues = [];

      for (int y = stepY; y < image.height - stepY; y += stepY) {
        for (int x = stepX; x < image.width - stepX; x += stepX) {
          // Get surrounding pixels
          final topLeft = image.getPixel(x - stepX, y - stepY);
          final top = image.getPixel(x, y - stepY);
          final topRight = image.getPixel(x + stepX, y - stepY);
          final left = image.getPixel(x - stepX, y);
          final center = image.getPixel(x, y);
          final right = image.getPixel(x + stepX, y);
          final bottomLeft = image.getPixel(x - stepX, y + stepY);
          final bottom = image.getPixel(x, y + stepY);
          final bottomRight = image.getPixel(x + stepX, y + stepY);

          // Convert to grayscale using corrected rgbToGray method
          final grayTopLeft = _rgbToGray(topLeft);
          final grayTop = _rgbToGray(top);
          final grayTopRight = _rgbToGray(topRight);
          final grayLeft = _rgbToGray(left);
          final grayCenter = _rgbToGray(center);
          final grayRight = _rgbToGray(right);
          final grayBottomLeft = _rgbToGray(bottomLeft);
          final grayBottom = _rgbToGray(bottom);
          final grayBottomRight = _rgbToGray(bottomRight);

          // Laplacian filter (simplified)
          final laplacian = grayTopLeft + grayTop + grayTopRight +
              grayLeft + (-8 * grayCenter) + grayRight +
              grayBottomLeft + grayBottom + grayBottomRight;

          laplacianValues.add(laplacian.abs());

          if (laplacianValues.length >= sampleSize) break;
        }
        if (laplacianValues.length >= sampleSize) break;
      }

      // Calculate variance
      if (laplacianValues.isEmpty) return true;

      double mean = laplacianValues.reduce((a, b) => a + b) / laplacianValues.length;
      double variance = laplacianValues.map((v) => (v - mean) * (v - mean))
          .reduce((a, b) => a + b) / laplacianValues.length;

      // Low variance indicates blur
      return variance < 100; // Threshold for blur detection
    } catch (e) {
      DevLogs.logError('Error detecting blur: $e');
      return false;
    }
  }
}

