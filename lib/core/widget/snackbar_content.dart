import 'package:ai_tutor/screens/home/controllers/gesture_controller.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SnackbarContent extends StatelessWidget {
  SnackbarContent({super.key});

  final videoPlayerController = Get.put(GestureVideoController());

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAvatarColumn(
                  isActive: videoPlayerController.isTtsActive,
                  icon: Icons.person,
                  color: Color.fromRGBO(6, 172, 255, 100),
                ),
                SizedBox(width: 60),
                _buildAvatarColumn(
                  isActive: videoPlayerController.isSstActive,
                  icon: Icons.mic,
                  color: Color.fromRGBO(32, 193, 148, 100),
                ),
              ],
            ),
            SizedBox(height: 20),
            Obx(() => Container(
              constraints: BoxConstraints(maxWidth: 250),
              child: Text(
                videoPlayerController.recognizedWords.value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarColumn({
    required RxBool isActive,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(
          () => AvatarGlow(
            glowColor: color,
            duration: const Duration(milliseconds: 2000),
            glowCount: 2,
            startDelay: const Duration(milliseconds: 100),
            animate: isActive.value,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 40.0,
              child: Obx(
                () => Icon(
                  icon,
                  size: 40,
                  color: isActive.value ? color : color.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}