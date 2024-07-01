import 'package:ai_tutor/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gesture Controlled Video Player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VideoPlayerScreen(),
    );
  }
}
