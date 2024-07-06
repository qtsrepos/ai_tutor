import 'package:ai_tutor/home_screen.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SnackbarContent extends StatelessWidget {
  SnackbarContent({
    Key? key,
  }) : super(key: key);

  final GestureVideoController videoPlayerController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(
            () => AvatarGlow(
              glowColor: videoPlayerController.isTtsActive.value
                  ? Colors.blue
                  : Colors.green,
              duration: const Duration(milliseconds: 2000),
              // repeat: true,
              glowCount: 2,
              startDelay: const Duration(milliseconds: 100),
              animate: videoPlayerController.isTtsActive.value ||
                  videoPlayerController.isSstActive.value,
              child: CircleAvatar(
                backgroundColor: videoPlayerController.isTtsActive.value
                    ? Colors.blue
                    : Colors.green,
                radius: 50.0,
                child: Obx(
                  () => Icon(
                      videoPlayerController.isTtsActive.value
                          ? Icons.person
                          : Icons.mic,
                      size: 50,
                      color: Colors.white),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Obx(
            () => Text(
              videoPlayerController.recognizedWords.value,
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}
