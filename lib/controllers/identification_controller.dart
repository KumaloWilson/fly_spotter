import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:specifier/utiils/logs.dart';
import '../models/fly_identification.dart';
import '../services/identification_service.dart';
import 'auth_controller.dart';

class IdentificationController extends GetxController {
  final IdentificationService _identificationService = IdentificationService();
  final ImagePicker _imagePicker = ImagePicker();
  final AuthController authController = Get.find<AuthController>();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<dynamic> identificationResults = <dynamic>[].obs;
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxList<IdentificationResult> identificationHistory = <IdentificationResult>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadIdentificationHistory();
  }

  @override
  void onClose() {
    _identificationService.disposeModel();
    super.onClose();
  }

  // Load identification history
  Future<void> loadIdentificationHistory() async {
    if (authController.userModel.value == null) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      identificationHistory.value = await _identificationService.getCachedResults(
        authController.userModel.value!.uid,
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Pick image from camera
  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        identifyFly();
      }
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  // Pick image from gallery
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        identifyFly();
      }
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  // Identify fly from selected image
  Future<void> identifyFly() async {
    if (selectedImage.value == null || authController.userModel.value == null) return;

    isLoading.value = true;
    errorMessage.value = '';
    identificationResults.clear();

    try {
      // Run identification
      List<dynamic> results = await _identificationService.identifyFromImage(selectedImage.value!);
      identificationResults.value = results;

      // Save result if we have a match
      if (results.isNotEmpty) {
        var topResult = results[0];
        String speciesId = topResult['label'].toString().split(' ')[0]; // Assuming format "id name"
        double confidence = topResult['confidence'];

        try {
          await _identificationService.saveIdentificationResult(
            userId: authController.userModel.value!.uid,
            imageFile: selectedImage.value!,
            speciesId: speciesId,
            confidenceScore: confidence,
          );

          // Refresh history
          await loadIdentificationHistory();
        } catch (saveError) {
          // Log the specific save error
          DevLogs.logError('Save identification result error: $saveError');

          // Optionally, you might want to show a more user-friendly error
          errorMessage.value = 'Could not save identification result. Please try again.';
        }
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Clear selected image
  void clearSelectedImage() {
    selectedImage.value = null;
    identificationResults.clear();
  }
}

