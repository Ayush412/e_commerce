import 'package:e_commerce/login.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'products.dart';
import 'package:page_transition/page_transition.dart';

void main() {
  runApp(Home());
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp()      
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  String email;
  DocumentSnapshot ds;
  Timer _timer;

  Future afterSplash () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email');
    if(email==null)
      Navigator.push(context, PageTransition(type: PageTransitionType.fade, duration:Duration(milliseconds: 300), child: login()));
    else {
      await Firestore.instance.collection('users').document(email).get().then((DocumentSnapshot mysnap){
      ds=mysnap;
      if(mysnap.data!=null)
      Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeftWithFade, duration:Duration(milliseconds: 400), child: listPage(post: ds,)));
      }); 
    }
  }

  @override
  void initState() {
    super.initState();
    _timer = new Timer(const Duration(seconds: 3), () {
      afterSplash();
    });
  }

  @override
   void dispose(){
     super.dispose();
     _timer.cancel();
   }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
          home: Container(
          color: Colors.white,
          child: Image.asset('assets/logo2(noName).png', height: 100,)
      ),
    );
  }
}
