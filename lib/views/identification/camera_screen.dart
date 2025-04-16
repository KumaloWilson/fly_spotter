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

  // Add this flag at the top of the class with other variables
  bool _isDisposing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initializeCamera();
  }

  // Update the dispose method to be more robust with null checks and exception handling
  @override
  void dispose() {
    // First, set a flag to prevent any ongoing operations
    _isDisposing = true;

    // Safely clean up camera resources
    if (cameraController != null) {
      try {
        // Check if the camera is initialized before trying to stop the stream
        if (cameraController!.value.isInitialized) {
          // Check if image streaming is active before trying to stop it
          // This avoids the "No camera is streaming images" exception
          if (cameraController!.value.isStreamingImages) {
            cameraController!.stopImageStream().then((_) {
              disposeCamera();
            }).catchError((e) {
              print('Error stopping image stream: $e');
              disposeCamera();
            });
          } else {
            // If not streaming, just dispose the camera directly
            disposeCamera();
          }
        } else {
          // If not initialized, just dispose the camera directly
          disposeCamera();
        }
      } catch (e) {
        print('Exception during camera cleanup: $e');
        disposeCamera();
      }
    }

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

  // Update the initializeCamera method to be more robust
  Future<void> initializeCamera() async {
    try {
      if (_isDisposing) return;

      // First, safely dispose any existing camera controller
      if (cameraController != null) {
        try {
          disposeCamera();
        } catch (e) {
          print('Error disposing existing camera: $e');
        }
      }

      // Get available cameras
      cameras = await availableCameras();

      if (cameras.isEmpty) {
        if (mounted && !_isDisposing) {
          Get.snackbar(
            'Error',
            'No cameras available',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
        return;
      }

      // Use the back camera
      final camera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      if (_isDisposing) return;

      // Create a new camera controller
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

      if (_isDisposing) {
        // If we're disposing, clean up the controller we just created
        await cameraController!.dispose();
        return;
      }

      // Reset exposure value when initializing
      currentExposure = 0.0;

      // Start image stream for real-time light detection
      // Add a small delay to ensure camera is fully initialized
      await Future.delayed(Duration(milliseconds: 500));
      if (mounted && cameraController != null && cameraController!.value.isInitialized &&
          !_isDisposing && !cameraController!.value.isStreamingImages) {
        await cameraController!.startImageStream(_processImageStream);
      }

      if (mounted && !_isDisposing) {
        setState(() {
          isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
      if (!_isDisposing && mounted) {
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
  }


  // Add a helper method to dispose the camera controller
  void disposeCamera() async{
    try {
      if (cameraController != null) {
        await cameraController!.dispose().then((_) {
          print('Camera controller disposed successfully');
          // Set to null after successful disposal
          if (mounted && !_isDisposing) {
            setState(() {
              cameraController = null;
            });
          } else {
            cameraController = null;
          }
        }).catchError((e) {
          print('Error disposing camera controller: $e');
          cameraController = null;
        });
      }
    } catch (e) {
      print('Exception during camera disposal: $e');
      cameraController = null;
    }
  }


  // Update the _processImageStream method to check for disposal
  void _processImageStream(CameraImage image) {
    // Skip processing if we're disposing or controller is null
    if (_isDisposing || cameraController == null) return;

    try {
      // Process only every 60 frames to save resources
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

        // Only update state if changed to avoid rebuilds and if not disposing
        if (newLowLight != isLowLight && !_isDisposing && mounted) {
          setState(() {
            isLowLight = newLowLight;
          });

          // Add a delay before adjusting exposure to avoid rapid changes
          // and only adjust if not already adjusting and not disposing
          if (!_isAdjustingExposure && !_isDisposing && cameraController != null &&
              cameraController!.value.isInitialized) {
            if (isLowLight) {
              _adjustExposure(0.5); // Increase exposure in low light
            } else if (!isLowLight) {
              _adjustExposure(-0.5); // Reset exposure in good light
            }
          }
        }
      }
    } catch (e) {
      // Log but don't crash if there's an error processing the image
      print('Error processing camera image: $e');
    }
  }

  // Update the _adjustExposure method to check for disposal
  Future<void> _adjustExposure(double adjustment) async {
    try {
      // Add a debounce mechanism to prevent too frequent adjustments
      if (_isAdjustingExposure || _isDisposing) return;
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

      // Only adjust if there's an actual change and not disposing
      if (newExposure != currentExposure && !_isDisposing) {
        await cameraController!.setExposureOffset(newExposure);
        currentExposure = newExposure;
      }
    } catch (e) {
      // Log the error but don't show to user unless it's critical
      print('Error adjusting exposure: $e');
      // Only show user-facing error for critical issues
      // that aren't just timing/race condition errors
      if (!_isDisposing && e.toString().contains('camera being closed') == false) {
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

  // Update the takePicture method to check for disposal
  Future<void> takePicture() async {
    if (cameraController == null || !cameraController!.value.isInitialized ||
        isCapturing || _isDisposing) {
      return;
    }

    setState(() {
      isCapturing = true;
    });

    try {
      // Only try to stop the image stream if it's actually streaming
      if (cameraController!.value.isStreamingImages) {
        try {
          await cameraController!.stopImageStream().timeout(
            Duration(seconds: 2),
            onTimeout: () {
              print('Warning: Stopping image stream timed out, continuing anyway');
            },
          );
        } catch (e) {
          print('Error stopping image stream: $e');
          // Continue anyway - we'll still try to take the picture
        }
      }

      // Add a small delay to ensure stream is stopped
      await Future.delayed(Duration(milliseconds: 200));

      // Check if we're disposing before continuing
      if (_isDisposing) {
        return;
      }

      // Take picture
      final XFile photo = await cameraController!.takePicture();

      // Process the image
      await identificationController.processImageFromCamera(File(photo.path), isLowLight);

      // Go back to previous screen
      if (!_isDisposing && mounted) {
        Get.back();
      }
    } catch (e) {
      print('Error taking picture: $e');
      if (!_isDisposing && mounted) {
        Get.snackbar(
          'Error',
          'Failed to take picture. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );

        // Try to restart the camera if it failed
        if (mounted && !_isDisposing) {
          setState(() {
            isCapturing = false;
          });

          // Try to restart the image stream if it was stopped
          try {
            if (cameraController != null && cameraController!.value.isInitialized &&
                !cameraController!.value.isStreamingImages) {
              await cameraController!.startImageStream(_processImageStream);
            }
          } catch (streamError) {
            print('Error restarting image stream: $streamError');
          }
        }
      }
    } finally {
      if (mounted && !_isDisposing) {
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
