import 'package:ai_tutor/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final GestureVideoController videoPlayerController =
        Get.put(GestureVideoController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Video Player with Gesture Control'),
      ),
      body: Obx(
        () => videoPlayerController.isVideoInitialized.value
            ? Column(
                children: [
                  AspectRatio(
                    aspectRatio:
                        videoPlayerController.videoController.value.aspectRatio,
                    child: VideoPlayer(videoPlayerController.videoController),
                  ),
                  Container(
                    child: Text(videoPlayerController.wordSpoken,style: TextStyle(fontSize: 20),),
                  )
                ],
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}
