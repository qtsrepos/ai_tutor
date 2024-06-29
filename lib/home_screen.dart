import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:video_player/video_player.dart';

class GestureVideoController extends GetxController {
  late CameraController cameraController;
  late VideoPlayerController videoController;
  CameraImage? cameraImage;
  bool pausedetecting = false;
  bool isDetecting = false;
  bool isCameraInitialized = false;
  var isVideoInitialized = false.obs;
  bool isVideoPlaying = true;
  bool isGestureDetected = false;
  bool speechEnable = false;
  String wordSpoken = '';
  double confidenceLevel = 0;
  Map<int, String> labelIndexToLabel = {
    0: 'play',
    1: 'pause',
    // Add more mappings as needed
  };
  bool ttsmessagesent=false;
FlutterTts flutterTts=FlutterTts();
  final SpeechToText speechToText = SpeechToText();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showInitializationDialog();
    });
    loadModel();
    initializeVideoPlayer();
    initTTS();
    initSpeech();
  }

  void initTTS() async {
  try {
    var voices = await flutterTts.getVoices;
    print(voices); // Debugging purposes
    await flutterTts.setLanguage('en-US'); // Set the language
    //await flutterTts.speak('Hello World'); // Test speaking
  } catch (e) {
    print(e);
  }
}

void speakMessage(String message) async {
  try {
    await flutterTts.speak(message);
  } catch (e) {
    print('Error speaking message: $e');
  }
}

void initSpeech() async {
    speechEnable = await speechToText.initialize();
  }

  void _startListening() async {
    try {
      await Future.delayed(Duration(seconds: 2));
      await speechToText.listen(onResult: _onSpeechResult);
    } catch (e) {
      print('Error starting speech recognition: $e');
    }
  }

  void _stopListening() async {
    try {
      await speechToText.stop();
    } catch (e) {
      print('Error stopping speech recognition: $e');
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    try {
      wordSpoken = result.recognizedWords;
      print('Recognized words: $wordSpoken'); // Print the recognized words
    } catch (e) {
      print('Error processing speech result: $e');
    }
  }



  showInitializationDialog() async {
    AwesomeDialog dialog = AwesomeDialog(
      context: Get.context!,
      animType: AnimType.bottomSlide,
      dialogType: DialogType.info,
      body: Center(
        child: Column(
          children: <Widget>[
            Text(
              'AI assistant',
              style: TextStyle(fontSize: 22),
            ),
            SizedBox(height: 10),
            Text(
              'Do you want to continue with the assistant?',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      btnOkOnPress: () async {
        bool success = await initializeCamera();
        if (success) {
          success = await loadModel();
          if (success) {
            Get.back(); // Close dialog
          } else {
            // Handle model loading failure
            Get.back(); // Close dialog
          }
        } else {
          // Handle camera initialization failure
          Get.back(); // Close dialog
        }
      },
      btnCancelOnPress: () {
        // Handle cancel button press
        Get.back(); // Close dialog
      },
    );

    dialog.show();
  }

 Future<bool> initializeCamera() async {
  List<CameraDescription> cameras = await availableCameras();

  // Use front camera for gesture detection
  CameraDescription? frontCamera;
  for (CameraDescription camera in cameras) {
    if (camera.lensDirection == CameraLensDirection.front) {
      frontCamera = camera;
      break;
    }
  }

  cameraController = CameraController(
    frontCamera!,
    ResolutionPreset.high,
  );

  await cameraController.initialize();
  isCameraInitialized = true;

  // Introduce a delay before starting image stream to avoid immediate gesture detection
  await Future.delayed(Duration(seconds: 2));

  cameraController.startImageStream((imageStream) {
    if (!isDetecting) {
      isDetecting = true;
      cameraImage = imageStream;
      runModelOnFrame();
    }
  });

  return true; // Return true to indicate successful initialization
}


  loadModel() async {
    try {
      await Tflite.loadModel(
        model: "assets/hand.tflite",
        labels: "assets/labels.txt",
      );
      print("Model loaded successfully");
    } catch (e) {
      print('Failed to load model: $e');
    }
  }

  void runModelOnFrame() async {
    if (cameraImage != null) {
      try {
        var recognitions = await Tflite.runModelOnFrame(
          bytesList: cameraImage!.planes.map((plane) {
            return plane.bytes;
          }).toList(),
          imageHeight: cameraImage!.height,
          imageWidth: cameraImage!.width,
          imageMean: 127.5,
          imageStd: 127.5,
          rotation: 90,
          numResults: 2,
          threshold: 0.1, // Lower threshold to catch more gestures
          asynch: true,
        );

        print('Recognitions: $recognitions'); // Print all recognitions

        if (recognitions != null && recognitions.isNotEmpty) {
          recognitions.forEach((element) {
            int index =
                element['index']; // Assuming your model outputs an index
            String label = labelIndexToLabel[index] ?? 'unknown gesture';
            double confidence = element['confidence'];
            print('Gesture recognized: $label');

            // Removed play detection logic here

            // Only detect pause gesture now
            if (label == 'pause' && confidence > 0.8 && !ttsmessagesent) {
              pausedetecting = true;
              speakMessage('hello how can i help you');
              ttsmessagesent=true;
              _startListening();
            }

            // Control the video based on detected gestures
            if (pausedetecting && isVideoPlaying) {
              videoController.pause();
              isVideoPlaying = false;
              isGestureDetected = true;
              print('Video paused');
            }
          });
        } else {
          isGestureDetected = false;
        }
      } catch (e) {
        print('Error running model: $e');
      } finally {
        isDetecting = false;
      }
    } else {
      print('Camera image is null');
      isDetecting = false;
    }
  }

 void initializeVideoPlayer() {
    videoController = VideoPlayerController.networkUrl(
      Uri.parse(
          'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'),
    );

    videoController.addListener(() {
      if (videoController.value.hasError) {
        print(
            'Video player encountered an error: ${videoController.value.errorDescription}');
      }
    });

    videoController.initialize().then((_) {
      videoController.setLooping(true);
      isVideoInitialized.value = true;
      videoController.play();
      update();
    });
  }

  @override
  void onClose() {
    cameraController.stopImageStream();
    cameraController.dispose();
    videoController.pause();
    videoController.dispose();
    Tflite.close();
    super.onClose();
  }
}
