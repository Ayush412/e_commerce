import 'package:e_commerce/login.dart';
import 'package:flutter/material.dart';
import 'package:animated_splash/animated_splash.dart';
import 'package:flutter/services.dart';
import 'login.dart';

void main() {
  Function duringSplash = () {
    return 1;
  };
  Map<int, Widget> op = {1: login()};
   WidgetsFlutterBinding.ensureInitialized(); //lock device rotation
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
    .then((_) {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AnimatedSplash(
        imagePath: 'assets/logo2.png',
        home: login(),
        customFunction: duringSplash,
        duration: 3500,
        type: AnimatedSplashType.BackgroundProcess,
        outputAndHome: op,
      ),
    ),
  );
});}