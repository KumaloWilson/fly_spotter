import 'dart:io';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/user_Model.dart';
import '../services/firestore_service.dart';
import 'auth_controller.dart';

class ProfileController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();
  final Uuid _uuid = Uuid();

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
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image == null) {
        isLoading.value = false;
        return;
      }

      // Upload to Firebase Storage
      String fileName = '${_uuid.v4()}.jpg';
      Reference storageRef = _storage.ref().child('profile_pictures/${currentUser!.uid}/$fileName');

      UploadTask uploadTask = storageRef.putFile(File(image.path));
      TaskSnapshot snapshot = await uploadTask;
      String photoUrl = await snapshot.ref.getDownloadURL();

      // Update user profile
      await authController.updateProfile(photoUrl: photoUrl);
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

