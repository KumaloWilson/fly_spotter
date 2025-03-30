import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/user_Model.dart';
import '../services/firestore_service.dart';
import '../services/supabase_service.dart';
import '../utiils/logs.dart';
import 'auth_controller.dart';

class ProfileController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final ImagePicker _imagePicker = ImagePicker();
  final Uuid _uuid = Uuid();
  final _supabase = SupabaseManager.client;

  final AuthController authController = Get.find<AuthController>();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Get current user
  UserModel? get currentUser => authController.userModel.value;

  // Update user profile
  Future<void> updateProfile({String? name}) async {
    if (currentUser == null) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await authController.updateProfile(name: name);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Upload profile picture
  Future<void> uploadProfilePicture() async {
    if (currentUser == null) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Pick image
      final XFile? imageFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (imageFile == null) {
        isLoading.value = false;
        return;
      }

      String fileName = '${_uuid.v4()}.jpg';

      // Prepare the file path in Supabase Storage
      final filePath = 'profilepictures/${currentUser!.uid}/$fileName';

      // Upload image to Supabase Storage
      String imageUrl;
      try {
        final uploadResponse = await _supabase.storage
            .from('profilepictures')
            .upload(
          filePath,
          File(imageFile!.path),
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
            .from('profilepictures')
            .getPublicUrl(filePath);
      } on StorageException catch (storageError) {
        DevLogs.logError('Supabase Storage Error: ${storageError.message}');
        throw 'Storage upload failed: ${storageError.message}';
      }

      // Update user profile
      await authController.updateProfile(photoUrl: imageUrl);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Update user preferences
  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    if (currentUser == null) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      Map<String, dynamic> updatedPreferences = {
        ...currentUser!.preferences,
        ...preferences,
      };

      UserModel updatedUser = currentUser!.copyWith(
        preferences: updatedPreferences,
      );

      await _firestoreService.updateUser(updatedUser);
      authController.userModel.value = updatedUser;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}

