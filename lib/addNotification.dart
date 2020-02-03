import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class addNotification{
  String email;
  String text;
  String title;
  String imgurl;
  addNotification(String text, String title, String email, String imgurl){
    this.text=text;
    this.title=title;
    this.email=email;
    this.imgurl=imgurl;
    add();
  }
  Future add() async{
    await Firestore.instance.collection('users/$email/Notifications').document()
    .setData({
      'Title': title,
      'Text': text,
      'Date': DateTime.now(),
      'Read': 0,
      'imgurl': imgurl
    });

  }
}