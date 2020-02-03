import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'myNotifications.dart';
import 'package:date_format/date_format.dart';
import 'package:page_transition/page_transition.dart';

class notifDescription extends StatefulWidget {

  DocumentSnapshot post;
  DocumentSnapshot userpost;
  String email;
  notifDescription(DocumentSnapshot post,DocumentSnapshot userpost, String email)
  {
    this.post=post;
    this.userpost=userpost;
    this.email=email;
  }
  @override
  _notifDescriptionState createState() => _notifDescriptionState();
}

class _notifDescriptionState extends State<notifDescription> {

  String text;
  String title;
  String imgurl;
  String date;

  Future markAsRead() async{
  await Firestore.instance.collection('users/${widget.email}/Notifications').document(widget.post.documentID)
    .updateData({
      'Read': 1
    });
    print(text);
  } 

@override
  void initState() {
    super.initState();
    markAsRead();
    text = widget.post.data['Text'];
    title = widget.post.data['Title'];
    imgurl = widget.post.data['imgurl'];
    date = formatDate(widget.post.data['Date'].toDate(), [dd, '/', 'mm', '/', yy]);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
          onWillPop: () => Navigator.push(context, PageTransition(type: PageTransitionType.upToDown, duration:Duration(milliseconds: 250), child: myNotifications(widget.email, widget.userpost))),
         child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(25))),
            toolbarOpacity: 0.5,
            elevation: 0,
            backgroundColor: Colors.black,
            leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white),onPressed: () => Navigator.push(context, PageTransition(type: PageTransitionType.upToDown, duration:Duration(milliseconds: 250), child: myNotifications(widget.email, widget.userpost)))),
          ),
          body: Stack(
                children: <Widget>[
                  Container(color: Colors.white,),
                 Padding(
                    padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
                    child: Container(height: 200,
                      decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10), 
                      image: DecorationImage(image: NetworkImage(imgurl), fit: BoxFit.fill)
                      )
                    )
                  ),
                  Positioned(
                    top:230, left:20,
                    child: Text(date, style: TextStyle(color: Colors.grey, fontSize: 16),)
                  ),
                  Positioned(
                    top: 260, left:30, right: 30,
                    child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24))
                  ),
                  Positioned(
                    top: 340, left:30, right: 30,
                    child: Text(text, style: TextStyle(fontSize: 18, color: Colors.black54))
                  ),
                ],
          )
        ),
        
      ),
    );
  }
}