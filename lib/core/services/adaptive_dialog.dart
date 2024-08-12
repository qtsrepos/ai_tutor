import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


Future<void> awesomeOkDialog({
  Function()? onOk,
  String? title,
  String? message,
  String? okLabel,
  bool isDismissible = true,
}) async {
  await AwesomeDialog(
    context: Get.context!,
    dialogType: DialogType.info,
    animType: AnimType.bottomSlide,
    title: title,
    desc: message,
    btnOkText: okLabel ?? 'OK',
    btnOkOnPress: onOk,
    dismissOnTouchOutside: isDismissible,
    dismissOnBackKeyPress: isDismissible,
    btnOkColor: Colors.green,
    headerAnimationLoop: false,
    padding: const EdgeInsets.all(16),
    dialogBackgroundColor: Colors.white,
    buttonsTextStyle: const TextStyle(color: Colors.white),
    titleTextStyle: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
    descTextStyle: const TextStyle(fontSize: 18),
  ).show();
}