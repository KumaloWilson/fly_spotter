import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:specifier/utiils/logs.dart';
import '../../controllers/identification_controller.dart';
import '../../widgets/camera_quality_overlay.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  final IdentificationController identificationController = Get.find<IdentificationController>();

  late List<CameraDescription> cameras;
  CameraController? cameraController;
  bool isInitialized = false;
  bool isCapturing = false;
  bool isLowLight = false;
  double currentExposure = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      initializeCamera();
    }
  }

  Future<void> initializeCamera() async {
    try {
      cameras = await availableCameras();

      if (cameras.isEmpty) {
        Get.snackbar(
          'Error',
          'No cameras available',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Use the back camera
      final camera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await cameraController!.initialize();

      // Start image stream for real-time light detection
      await cameraController!.startImageStream(_processImageStream);

      if (mounted) {
        setState(() {
          isInitialized = true;
        });
      }
    } catch (e) {
      DevLogs.logError('Error initializing camera: $e');
      Get.snackbar(
        'Error',
        'Failed to initialize camera: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }


  void _processImageStream(CameraImage image) {
    // Process only every 30 frames to save resources
    if (image.planes[0].bytes.length % 30 != 0) return;

    // Simple brightness detection from Y plane (for YUV format)
    if (image.format.group == ImageFormatGroup.yuv420) {
      final yPlane = image.planes[0];
      final bytes = yPlane.bytes;

      // Sample pixels for efficiency
      int totalBrightness = 0;
      int sampleSize = 100;
      int step = bytes.length ~/ sampleSize;

      for (int i = 0; i < sampleSize; i++) {
        int idx = i * step;
        if (idx < bytes.length) {
          totalBrightness += bytes[idx];
        }
      }

      double avgBrightness = totalBrightness / sampleSize;
      bool newLowLight = avgBrightness < 80; // Threshold for low light

      // Only update state if changed to avoid rebuilds
      if (newLowLight != isLowLight) {
        setState(() {
          isLowLight = newLowLight;
        });

        // Instead of directly checking exposure values, just adjust based on light condition
        if (isLowLight) {
          _adjustExposure(0.5); // Increase exposure in low light
        } else {
          _adjustExposure(-0.5); // Reset exposure in good light
        }
      }
    }
  }

// Update the exposure adjustment method
  Future<void> _adjustExposure(double change) async {
    try {
      // Get the current exposure limits
      double minExposure = await cameraController!.getMinExposureOffset();
      double maxExposure = await cameraController!.getMaxExposureOffset();

      // Calculate the new value within limits
      double currentExposure = await cameraController!.getExposureOffsetStepSize();
      double newExposure = (currentExposure + change).clamp(minExposure, maxExposure);

      // Set the new exposure value
      await cameraController!.setExposureOffset(newExposure);
    } catch (e) {
      DevLogs.logError('Error adjusting exposure: $e');
    }
  }

  Future<void> takePicture() async {
    if (cameraController == null || !cameraController!.value.isInitialized || isCapturing) {
      return;
    }

    setState(() {
      isCapturing = true;
    });

    try {
      // Stop image stream before taking picture
      await cameraController!.stopImageStream();

      // Take picture
      final XFile photo = await cameraController!.takePicture();

      // Process the image
      await identificationController.processImageFromCamera(File(photo.path), isLowLight);

      // Go back to previous screen
      Get.back();
    } catch (e) {
      DevLogs.logError('Error taking picture: $e');
      Get.snackbar(
        'Error',
        'Failed to take picture: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          isCapturing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return Scaffold(
        appBar: AppBar(title: Text('Camera')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          Positioned.fill(
            child: AspectRatio(
              aspectRatio: cameraController!.value.aspectRatio,
              child: CameraPreview(cameraController!),
            ),
          ),

          // Low light warning
          CameraQualityOverlay(
            isLowLight: isLowLight,
            onTakePicture: takePicture,
          ),

          // Camera controls
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Light indicator
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isLowLight ? Icons.wb_sunny_outlined : Icons.wb_sunny,
                        color: isLowLight ? Colors.amber : Colors.green,
                      ),
                      SizedBox(width: 8),
                      Text(
                        isLowLight ? 'Low Light' : 'Good Light',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Capture button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Back button
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                      onPressed: () => Get.back(),
                    ),

                    SizedBox(width: 40),

                    // Capture button
                    GestureDetector(
                      onTap: isCapturing ? null : takePicture,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          color: isCapturing ? Colors.grey : Colors.transparent,
                        ),
                        child: Center(
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 40),

                    // Flash toggle
                    IconButton(
                      icon: Icon(
                        cameraController!.value.flashMode == FlashMode.off
                            ? Icons.flash_off
                            : Icons.flash_on,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () async {
                        final FlashMode newMode = cameraController!.value.flashMode == FlashMode.off
                            ? FlashMode.auto
                            : FlashMode.off;
                        await cameraController!.setFlashMode(newMode);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

