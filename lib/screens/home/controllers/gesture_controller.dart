import 'package:ai_tutor/core/widget/snackbar_content.dart';
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
  RxBool isDetecting = false.obs;
  RxBool isCameraInitialized = false.obs;
  RxBool isVideoInitialized = false.obs;
  RxBool isVideoPlaying = true.obs;
  RxBool isGestureDetected = false.obs;
  RxBool speechEnable = false.obs;
  RxString wordSpoken = ''.obs;

  Map<int, String> labelIndexToLabel = {
    0: 'pause',
    1: 'play',
    2: 'nothing'
    // Add more mappings as needed
  };
  RxBool ttsMessageSent = false.obs;
  RxBool isTtsActive = false.obs;
  RxBool isSstActive = false.obs;
  RxString recognizedWords = ''.obs;
  RxString label = ''.obs;
  double confidence = 0;
  FlutterTts flutterTts = FlutterTts();
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
    } catch (e) {
      print(e);
    }
  }

  Future<void> speakMessage(String message) async {
  try {
    isTtsActive.value = true;
    await flutterTts.speak(message);
    return Future.delayed(Duration(milliseconds: 500)); // Add a small delay after speaking
  } catch (e) {
    print('Error speaking message: $e');
  } finally {
    isTtsActive.value = false;
    ttsMessageSent.value = false;
  }
}

  void initSpeech() async {
    speechEnable.value = await speechToText.initialize();
  }

   _startListening() async {
    try {
      isSstActive.value = true;
      await Future.delayed(Duration(seconds: 2));
      await speechToText.listen(onResult: _onSpeechResult);
       await Future.delayed(Duration(seconds: 7));  // Adjust timeout as needed
    await _stopListening();
    } catch (e) {
      print('Error starting speech recognition: $e');
      isSstActive.value = false;
    }
  }

   _stopListening() async {
    try {
      await speechToText.stop();
      isSstActive.value = false;
    } catch (e) {
      print('Error stopping speech recognition: $e');
      isSstActive.value = false;
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    try {
      wordSpoken.value = result.recognizedWords;
      recognizedWords.value = wordSpoken.value;
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

    try {
      await cameraController.initialize();
      print("Camera initialized successfully");
      isCameraInitialized.value = true;

      // Introduce a delay before starting image stream to avoid immediate gesture detection
      await Future.delayed(const Duration(seconds: 2));

      // Display the camera feed for debugging
      if (cameraController.value.isInitialized) {
        print("Camera feed is ready to be displayed.");

        cameraController.startImageStream((imageStream) {
          if (!isDetecting.value) {
            isDetecting.value = true;
            cameraImage = imageStream;
            runModelOnFrame();
          }
        });
      }

      return true; // Return true to indicate successful initialization
    } catch (e) {
      print("Error initializing camera: $e");
      return false;
    }
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
        threshold: 0.7,
        asynch: true,
      );

      print(recognitions);

      if (recognitions != null && recognitions.isNotEmpty) {
        for (var element in recognitions) {
          int index = element['index']!;
          String label = labelIndexToLabel[index] ?? 'unknown gesture';
          double confidence = element['confidence'];
          print('Gesture recognized: $label with confidence: $confidence');

          if (label == 'pause') {
            if (confidence > 0.8 && !ttsMessageSent.value && isVideoPlaying.value) {
              isGestureDetected.value = true;
              ttsMessageSent.value = true;

              // 1. Pause the video
              videoController.pause();
              isVideoPlaying.value = false;
              print('Video paused');

              // 2. Show snackbar immediately after pausing
              Get.snackbar(
                '', '',
                snackPosition: SnackPosition.BOTTOM,
                boxShadows: [
                  BoxShadow(
                    color: Colors.black26,
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: Offset(0, 3)
                  )
                ],
                animationDuration: Duration(milliseconds: 500),
                forwardAnimationCurve: Curves.easeInOut,
                reverseAnimationCurve: Curves.easeOut,
                backgroundColor: Color.fromRGBO(167, 181, 185, 53),
                duration: Duration(seconds: 25),
                isDismissible: true,
                borderRadius: 10,
                margin: EdgeInsets.all(10),
                messageText: Container(
                  width: double.infinity,
                  height: MediaQuery.of(Get.context!).size.height * 0.4,
                  child: SnackbarContent(),
                ),
              );

              // 3. Speak the greeting
              await speakMessage('Hello, how can I help you?');

              // 4. Start listening and wait for it to complete
              await _startListening();

              // 5. Speak the longer message
              await speakMessage(
                'When light is reflected off a surface, the incident ray strikes the surface at an angle, and the reflected ray bounces off the surface at the same angle, with both the incident and reflected rays lying in the same plane as the normal, which is perpendicular to the surface at the point of incidence');
            }
          } else if (label == 'play' && confidence > 0.5) {
            print('Play gesture detected with confidence $confidence');
            if (!isVideoPlaying.value) {
              videoController.play();
              isVideoPlaying.value = true;
              print('Video played');
              isGestureDetected.value = false;
              ttsMessageSent.value = false;
            } else {
              print('Video is already playing');
            }
          }
        }
      } else {
        isGestureDetected.value = false;
      }
      isDetecting.value = false;
    } catch (e) {
      print('Error running model: $e');
    }
  } else {
    print('Camera image is null');
    isDetecting.value = false;
  }
}

  void initializeVideoPlayer() {
    videoController = VideoPlayerController.asset('assets/video1.mp4');
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
      isVideoPlaying.value = true;
    });
  }

  void toggleVideoPlayback() {
    if (videoController.value.isPlaying) {
      videoController.pause();
      isVideoPlaying.value = false;
    } else {
      videoController.play();
      isVideoPlaying.value = true;
    }
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

  bool get isPlaying => videoController.value.isPlaying;
}
