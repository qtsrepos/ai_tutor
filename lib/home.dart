import 'package:ai_tutor/home_screen.dart';
import 'package:ai_tutor/widget/controls_overlay.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerScreen extends StatelessWidget {
  const VideoPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GestureVideoController videoPlayerController =
        Get.put(GestureVideoController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player with Gesture Control'),
      ),
      body: Obx(
        () => videoPlayerController.isVideoInitialized.value
            ? Column(
                children: [
                  AspectRatio(
                    aspectRatio:
                        videoPlayerController.videoController.value.aspectRatio,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                      VideoPlayer(videoPlayerController.videoController),
                     ControlsOverlay(controller: videoPlayerController.videoController),
                      VideoProgressIndicator(videoPlayerController.videoController, allowScrubbing: true),
                       Positioned(
            bottom: 10,
            left: 10,
            child: 
               IconButton(
                icon: 
                   Obx(()=>
                      Icon(
                      videoPlayerController.isVideoPlaying.value?Icons.pause:Icons.play_arrow,
                      color: Colors.black,
                      size: 30.0,
                                       ),
                   ),
                
                onPressed: () {
                  videoPlayerController.toggleVideoPlayback();
                },
              ),
            
           ),
                    ]),
                  ),
                  // SizedBox(
                  //   height: 70,
                  // ),
                  // AvatarGlow(
                  //   glowColor: Colors.blue,
                  //   duration: const Duration(milliseconds: 2000),
                  //   repeat: true,
                  //   glowCount: 2,
                  //   startDelay: const Duration(milliseconds: 100),
                  //   animate: videoPlayerController.isTtsActive.value ||
                  //       videoPlayerController.isSstActive.value,
                  //   child: CircleAvatar(
                  //     backgroundColor: Colors.blue,
                  //     radius: 50.0,
                  //     child: Icon(
                  //         videoPlayerController.isTtsActive.value
                  //             ? Icons.person
                  //             : Icons.mic,
                  //         size: 50,
                  //         color: Colors.white),
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: 20,
                  // ),
                  // Obx(
                  //   () => Text(
                  //     videoPlayerController.recognizedWords.value,
                  //     style: TextStyle(fontSize: 20),
                  //   ),
                  // )
                ],
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.blue,
      //   onPressed: videoPlayerController.toggleVideoPlayback,
      //   child: Obx(
      //     () => Icon(
      //       videoPlayerController.isVideoPlaying.value
      //           ? Icons.pause
      //           : Icons.play_arrow,
      //     ),
      //   ),
      // ),
    );
  }
}
