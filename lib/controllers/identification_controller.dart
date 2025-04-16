import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/fly_identification.dart';
import '../models/fly_information_model.dart';
import '../services/identification_service.dart';
import '../services/openai_service.dart';
import 'auth_controller.dart';

class IdentificationController extends GetxController {
  final IdentificationService _identificationService = IdentificationService();
  final OpenAIService _openAIService = OpenAIService();
  final ImagePicker _imagePicker = ImagePicker();
  final AuthController authController = Get.find<AuthController>();

  final RxBool isLoading = false.obs;
  final RxBool isLoadingInfo = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString infoErrorMessage = ''.obs;
  final RxList<dynamic> identificationResults = <dynamic>[].obs;
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxList<IdentificationResult> identificationHistory = <IdentificationResult>[].obs;
  final RxBool isLowLight = false.obs;
  final RxDouble confidenceThreshold = 0.8.obs; // 80% threshold
  final Rx<FlyInformation?> flyInformation = Rx<FlyInformation?>(null);

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
    isLowLight.value = false;
    flyInformation.value = null;
    infoErrorMessage.value = '';

    try {
      // Check for low light conditions
      bool lowLightDetected = await _checkLowLightCondition(selectedImage.value!);
      isLowLight.value = lowLightDetected;

      // Run identification
      List<dynamic> results = await _identificationService.identifyFromImage(selectedImage.value!);
      identificationResults.value = results;

      // Save result if we have a match with confidence above threshold
      if (results.isNotEmpty) {
        var topResult = results[0];
        String speciesId = topResult['label'].toString().split(' ')[0]; // Assuming format "id name"
        double confidence = topResult['confidence'];
        String speciesName = topResult['label'].toString().split(' ').sublist(1).join(' ');

        // Only save if confidence is above threshold
        if (confidence >= confidenceThreshold.value) {
          await _identificationService.saveIdentificationResult(
            userId: authController.userModel.value!.uid,
            imageFile: selectedImage.value!,
            speciesId: speciesId,
            confidenceScore: confidence,
          );

          // Fetch additional information about the fly
          fetchFlyInformation(speciesName);

          // Refresh history
          await loadIdentificationHistory();
        }
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch additional information about the identified fly
  Future<void> fetchFlyInformation(String speciesName) async {
    isLoadingInfo.value = true;
    infoErrorMessage.value = '';

    try {
      final info = await _openAIService.getFlyInformation(speciesName);
      flyInformation.value = info;
    } catch (e) {
      infoErrorMessage.value = 'Could not fetch additional information: $e';
      // Create a placeholder to show the UI can still function
      flyInformation.value = FlyInformation.placeholder(speciesName);
    } finally {
      isLoadingInfo.value = false;
    }
  }

  // Retry fetching fly information
  Future<void> retryFetchingInformation() async {
    if (identificationResults.isEmpty) return;

    String speciesName = identificationResults[0]['label'].toString().split(' ').sublist(1).join(' ');
    fetchFlyInformation(speciesName);
  }

  // Clear selected image
  void clearSelectedImage() {
    selectedImage.value = null;
    identificationResults.clear();
    flyInformation.value = null;
    infoErrorMessage.value = '';
  }

  // Add a method to check for low light conditions
  Future<bool> _checkLowLightCondition(File imageFile) async {
    try {
      // Use the image processing service to analyze brightness
      return await _identificationService.detectLowLight(imageFile);
    } catch (e) {
      print('Error detecting light conditions: $e');
      return false; // Default to false if detection fails
    }
  }

  // Add this method to process images from the camera screen
  Future<void> processImageFromCamera(File imageFile, bool wasLowLight) async {
    selectedImage.value = imageFile;
    isLowLight.value = wasLowLight;

    // If it was low light, don't automatically identify
    if (!wasLowLight) {
      await identifyFly();
    }
  }
}
