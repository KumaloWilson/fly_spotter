import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:specifier/utiils/ai_models.dart';
import 'package:specifier/widgets/camera_overlay.dart';
import 'package:tflite_v3/tflite_v3.dart';


class XrayScanner extends StatefulWidget {
  const XrayScanner({super.key});

  @override
  State<XrayScanner> createState() => _XrayScannerState();
}


class _XrayScannerState extends State<XrayScanner> {
  bool screenActive = false;
  //CAMERA VARIABLES
  late CameraController _cameraController;
  CameraImage? imgCamera;
  late List<CameraDescription> cameras;

  bool isWorking = false;
  Image? img;
  String result = "";
  double resultConfidence = 0;
  late String imagePath;
  bool scanning = false;

  //CAMERA FUNCTIONS
  _initializeCamera() async {
    _cameraController = CameraController(cameras[0], ResolutionPreset.max);
    _cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        print("CAMERA FAILED ZVEKUTODAROoox");
      }
    });
  }

  //TAKING IMAGE TO BE SCANNED
  Future<void> _scanImage() async {
    setState(() {
      scanning = true;
    });
    if (_cameraController.value.isInitialized) {
      try {
        final pictureFile = await _cameraController.takePicture();

        setState(() {
          imagePath = pictureFile.path;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'An error occurred when scanning text, please try again\nAn error occurred when scanning text, please try again\nAn error occurred when scanning text, please try again\nAn error occurred when scanning text, please try again\nAn error occurred when scanning text, please try again\nAn error occurred when scanning text, please try again\nAn error occurred when scanning text, please try again\nAn error occurred when scanning text, please try again\nAn error occurred when scanning text, please try again\nAn error occurred when scanning text, please try again\nAn error occurred when scanning text, please try again\nAn error occurred when scanning text, please try again\nAn error occurred when scanning text, please try again\nAn error occurred when scanning text, please try again\nAn error occurred when scanning text, please try again\nAn error occurred when scanning text, please try again\n'),
          ),
        );
      }
    }
  }

  //LOADING MODEL FOR DETECTION
  loadModel() async {
    await Tflite.loadModel(
      model: AIModels.xRayModel,
      labels: AIModels.xRayModelLabels,
    );
  }

  //IMAGE DETECTION
  classifyImage(String imagePath) async {
    var recognitions = await Tflite.runModelOnImage(
      path: imagePath,
      numResults: 1,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    //-------------------------------------------------------------------------------------------------------
    result = "";

    recognitions?.forEach((response) {
      result += response["label"];
      resultConfidence = response["confidence"] * 100;
    });

    setState(() {
      result;
      resultConfidence;
    });

  }

  @override
  void initState() {
    super.initState();
    loadModel();
    setState(() {
      useAvailableCameras();
    });
  }

  void useAvailableCameras() async{
    cameras = await availableCameras();
  }

  @override
  void dispose() async {
    _cameraController.dispose();
    screenActive = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width;
    double displayHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          screenActive
              ? SizedBox(
            width: displayWidth,
            height: displayHeight,
            child: _cameraController.value.isInitialized
                ? Stack(
              children: [
                SizedBox(
                  width: displayWidth,
                  height: displayHeight,
                  child: AspectRatio(
                    aspectRatio:
                    _cameraController.value.aspectRatio,
                    child: CameraPreview(_cameraController),
                  ),
                ),
                GestureDetector(
                  onDoubleTap: () async {
                    await _scanImage();
                    await classifyImage(imagePath);
                  },
                  child: CameraOverlay(
                      scanAreaRadius: 1,
                      overlayColour:
                      Colors.black.withValues(alpha: 0.5),
                      lineColor: Colors.blue,
                      scanAreaHeight: displayHeight * 0.3,
                      scanAreaWidth: displayWidth * 0.85),
                ),
                result != "" && result != null
                    ? GestureDetector(
                  onLongPress: () async {
                    setState(() {
                      scanning = false;
                      result = "";
                    });
                  },
                  child: Center(
                    child: Container(
                      width: displayWidth * 0.85 - 35,
                      height: displayHeight * 0.3 - 25,
                      decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(10),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.7),
                            Colors.grey.withOpacity(0.3),
                          ],
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius:
                        BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius:
                            BorderRadius.circular(10),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.grey
                                    .withOpacity(0.3),
                                Colors.white
                                    .withOpacity(0.7),
                              ],
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: displayWidth * 0.1,
                                height: displayHeight * 0.1,
                                child: Image.network(
                                    result.contains("Tuberculosis")
                                        ? "https://cdn-icons-png.flaticon.com/128/387/387617.png"
                                        : 'https://cdn-icons-png.flaticon.com/128/10629/10629607.png'
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  width:   displayWidth * 0.7,
                                  height:  displayHeight * 0.32,
                                  padding: const EdgeInsets.all(10),
                                  child: result != ""  ? SingleChildScrollView(
                                    child: Text(
                                      "${result.split(' ').last}\nConfidence $resultConfidence",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize:  16,
                                          color:  Colors.blue,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  )
                                      : const Center(
                                    child: SizedBox(
                                      width: 50,
                                      height: 50,
                                      child:
                                      CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>( Colors.blue),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: displayWidth * 0.85,
                                color: Colors.blue,
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      scanning = false;
                                      result = "";
                                    });
                                  },
                                  child: const Text(
                                    'Rescan',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight:FontWeight.bold
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                    : Container()
              ],
            )
                : const Center(
              child: SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey)
                  )
              ),
            ),
          )
              : GestureDetector(
            onDoubleTap: () async {
              _initializeCamera();
              print("=============started camera===============");
              setState(() {
                screenActive = true;
              });
            },
            child: Container(
              padding: EdgeInsets.only(
                  top: displayHeight * 0.05, bottom: displayHeight * 0.15),
              width: displayWidth,
              height: displayHeight,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                        top: displayHeight * 0.05,
                        bottom: displayHeight * 0.03,
                        left: 20),
                    width: displayWidth,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xray TB Scanner',
                          style: TextStyle(
                              fontSize: 30,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold),
                        ),

                      ],
                    ),
                  ),
                  SizedBox(
                    width: displayWidth,
                    height: displayHeight * 0.45,
                    child: Stack(
                      children: [
                        Center(
                          child: SizedBox(
                            width: displayWidth,
                            height: displayHeight * 0.12,
                            child: Image.asset("MyImageLocalAssets.xRayScanner"),
                          ),
                        ),
                        Positioned(
                          child: Center(
                            child: CustomPaint(
                                painter: BorderPainter(),
                                child: Container(
                                  width: displayHeight * 0.3 * 0.75,
                                  height: displayHeight * 0.3 * 0.75,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Container(
                                          width: displayHeight * 0.1 * 0.75,
                                          height:
                                          displayHeight * 0.1 * 0.75,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.7),
                                            borderRadius:
                                            BorderRadius.circular(10),
                                            border: Border.all(
                                              color: Colors.grey,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: ElevatedButton(
                      onPressed: () {
                        _initializeCamera();
                        // _initializeCamera(cameras[0]);
                        print("=============started camera===============");
                        setState(() {
                          screenActive = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shadowColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        minimumSize: Size(displayWidth * 0.8, 50),
                      ),
                      child: const Text(
                        'Start Camera',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class BorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double sh = size.height; // for convenient shortage
    double sw = size.width; // for convenient shortage
    double cornerSide = sh * 0.1; // desirable value for corners side

    Paint paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Path path = Path()
      ..moveTo(cornerSide, 0)
      ..quadraticBezierTo(0, 0, 0, cornerSide)
      ..moveTo(0, sh - cornerSide)
      ..quadraticBezierTo(0, sh, cornerSide, sh)
      ..moveTo(sw - cornerSide, sh)
      ..quadraticBezierTo(sw, sh, sw, sh - cornerSide)
      ..moveTo(sw, cornerSide)
      ..quadraticBezierTo(sw, 0, sw - cornerSide, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(BorderPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(BorderPainter oldDelegate) => false;
}