import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import '../../controllers/identification_controller.dart';
import '../../widgets/camera_quality_overlay.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  final IdentificationController identificationController = Get.find<IdentificationController>();

  late List<CameraDescription> cameras;
  CameraController? cameraController;
  bool isInitialized = false;
  bool isCapturing = false;
  bool isLowLight = false;
  double currentExposure = 0.0;
  bool _isAdjustingExposure = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initializeCamera();
  }

  @override
  void dispose() {
    // Stop image stream before disposing
    cameraController?.stopImageStream().then((_) {
      cameraController?.dispose();
    }).catchError((e) {
      print('Error stopping image stream: $e');
    });

    WidgetsBinding.instance.removeObserver(this);
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

  // Update the initializeCamera method to add better error handling
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

      // Dispose of any existing controller before creating a new one
      await cameraController?.dispose();

      cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      // Add a timeout to initialization
      await cameraController!.initialize().timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw 'Camera initialization timed out. Please try again.';
        },
      );

      // Reset exposure value when initializing
      currentExposure = 0.0;

      // Start image stream for real-time light detection
      // Add a small delay to ensure camera is fully initialized
      await Future.delayed(Duration(milliseconds: 500));
      if (mounted && cameraController != null && cameraController!.value.isInitialized) {
        await cameraController!.startImageStream(_processImageStream);
      }

      if (mounted) {
        setState(() {
          isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
      Get.snackbar(
        'Camera Error',
        'Failed to initialize camera: ${e.toString().split(':').last}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
    }
  }

  // Find the _processImageStream method and update it to reduce exposure adjustment frequency
  void _processImageStream(CameraImage image) {
    // Process only every 60 frames to save resources (increased from 30)
    if (image.planes[0].bytes.length % 60 != 0) return;

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



        // Add a delay before adjusting exposure to avoid rapid changes
        // and only adjust if not already adjusting
        if (!_isAdjustingExposure) {
          if (isLowLight ) {
            _adjustExposure(0.5); // Increase exposure in low light
          } else if (!isLowLight) {
            _adjustExposure(-0.5); // Reset exposure in good light
          }
        }
      }
    }
  }

  Future<void> _adjustExposure(double adjustment) async {
    try {
      // Add a debounce mechanism to prevent too frequent adjustments
      if (_isAdjustingExposure) return;
      _isAdjustingExposure = true;

      // Make sure camera is initialized and ready
      if (cameraController == null || !cameraController!.value.isInitialized) {
        _isAdjustingExposure = false;
        return;
      }

      double minExposure = await cameraController!.getMinExposureOffset();
      double maxExposure = await cameraController!.getMaxExposureOffset();

      double newExposure = currentExposure + adjustment;
      newExposure = newExposure.clamp(minExposure, maxExposure);

      // Only adjust if there's an actual change
      if (newExposure != currentExposure) {
        await cameraController!.setExposureOffset(newExposure);
        currentExposure = newExposure;
      }
    } catch (e) {
      // Log the error but don't show to user unless it's critical
      print('Error adjusting exposure: $e');
      // Only show user-facing error for critical issues
      // that aren't just timing/race condition errors
      if (e.toString().contains('camera being closed') == false) {
        Get.snackbar(
          'Camera Adjustment',
          'Unable to adjust camera exposure. This won\'t affect photo quality.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black54,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      }
    } finally {
      // Add a small delay before allowing next adjustment
      await Future.delayed(Duration(milliseconds: 500));
      _isAdjustingExposure = false;
    }
  }

  // Update the takePicture method with better error handling
  Future<void> takePicture() async {
    if (cameraController == null || !cameraController!.value.isInitialized || isCapturing) {
      return;
    }

    setState(() {
      isCapturing = true;
    });

    try {
      // Stop image stream before taking picture
      await cameraController!.stopImageStream().timeout(
        Duration(seconds: 2),
        onTimeout: () {
          print('Warning: Stopping image stream timed out, continuing anyway');
        },
      );

      // Add a small delay to ensure stream is stopped
      await Future.delayed(Duration(milliseconds: 200));

      // Take picture
      final XFile photo = await cameraController!.takePicture();

      // Process the image
      await identificationController.processImageFromCamera(File(photo.path), isLowLight);

      // Go back to previous screen
      Get.back();
    } catch (e) {
      print('Error taking picture: $e');
      Get.snackbar(
        'Error',
        'Failed to take picture. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      // Try to restart the camera if it failed
      if (mounted) {
        setState(() {
          isCapturing = false;
        });

        // Try to restart the image stream if it was stopped
        try {
          if (cameraController != null && cameraController!.value.isInitialized) {
            await cameraController!.startImageStream(_processImageStream);
          }
        } catch (streamError) {
          print('Error restarting image stream: $streamError');
        }
      }
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
