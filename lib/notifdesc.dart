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
          extendBody: true,
          body: SingleChildScrollView(
                child: Stack(
                  children: <Widget>[
                    Container(
                    height:MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xffffd89b), Color(0xffc4e0e5)]))),
                    AppBar(
                    centerTitle: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(25))),
                    toolbarOpacity: 0.5,
                    elevation: 0,
                    backgroundColor: Colors.black,
                    leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white),onPressed: () => Navigator.push(context, PageTransition(type: PageTransitionType.upToDown, duration:Duration(milliseconds: 250), child: myNotifications(widget.email, widget.userpost)))),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top:80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                       Center(
                         child: Padding(
                              padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
                              child: Container(height: 250, width:350,
                                decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10), 
                                image: DecorationImage(image: NetworkImage(imgurl), fit: BoxFit.cover)
                                )
                              )
                          ),
                       ),
                        Padding(
                            padding: const EdgeInsets.only(top:20, left:10),
                            child: Text(date, style: TextStyle(color: Color(0xff19547b), fontSize: 16))
                        ),
                        Padding(
                            padding: const EdgeInsets.only(top:30, left:20, right:20),
                            child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24))
                        ),
                        Padding(
                            padding: const EdgeInsets.only(top:40, left:20, right:20),
                            child: Text(text, style: TextStyle(fontSize: 18, color: Colors.black54))
                        ),
                      ],
              ),
                  ),
            ],
                      ),
          )
        ),
        
      ),
    );
  }
}