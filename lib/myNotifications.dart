
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notifdesc.dart';
import 'package:date_format/date_format.dart';
import 'products.dart';
import 'addNotification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:page_transition/page_transition.dart';

class myNotifications extends StatefulWidget {

  String email;
  DocumentSnapshot userpost;
  myNotifications(String email, DocumentSnapshot post)
  {
    this.userpost=post;
    this.email=email;
  }
  @override
  _myNotificationsState createState() => _myNotificationsState();
}

class _myNotificationsState extends State<myNotifications> {

 String text;
 String title;
 String imgurl;
 final FirebaseMessaging _fcm = FirebaseMessaging();
  void initState() { 
    super.initState();
    _fcm.configure(
          onMessage: (Map<String, dynamic> message) async {
            text=message['notification']['body'];
            title=message['notification']['title'];
            int i=0;
            imgurl='';
            while(text[i]!= ' '){
            imgurl+=text[i];
            i++;
            }
            text=text.substring(i+1, text.length);
            addNotification(text, title, widget.email, imgurl);
            setState(() {
              data=getData();
            });
        },
        onResume: (Map<String, dynamic> message) async {
            text=message['notification']['body'];
            title=message['notification']['title'];
            int i=0;
            imgurl='';
            while(text[i]!= ' '){
            imgurl+=text[i];
            i++;
            }
            text=text.substring(i+1, text.length);
            addNotification(text, title, widget.email, imgurl);
            setState(() {
              data=getData();
            });
        },   
  );
    data=getData();
  }

  Future data;
  Future getData() async {
    QuerySnapshot qs = await Firestore.instance.collection('/users/${widget.email}/Notifications').orderBy('Date', descending: true).getDocuments();
    return qs.documents;
  }

  navigateToDetail(DocumentSnapshot post){
   Navigator.push(context, PageTransition(type: PageTransitionType.downToUp, duration:Duration(milliseconds: 250), child: notifDescription(post, widget.userpost, widget.email)));
  }

   Future clearAll() async{
    QuerySnapshot qs = await Firestore.instance.collection('users/${widget.email}/Notifications').getDocuments();
    qs.documents.forEach((f) => delNotification(f));
  }

  Future delNotification(DocumentSnapshot post) async{
    await Firestore.instance.collection('users/${widget.email}/Notifications').document(post.documentID).delete();
    setState(() {
      data=getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Navigator.push(context, MaterialPageRoute(builder: (context) => listPage(post: widget.userpost))),
          child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(25))),
            toolbarOpacity: 0.5,
            elevation: 0,
            backgroundColor: Colors.black,
            leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white),onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => listPage(post: widget.userpost)))),
            title: Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            actions: <Widget>[
              FlatButton(
                onPressed: () => clearAll(),
              child: Text('Clear All', style: TextStyle(color: Colors.grey, fontSize: 16.4))
              )
            ],
          ),
          body: Stack(
                      children: <Widget>[
                        Container(color: Colors.white,),
              Padding(
                padding: const EdgeInsets.only(top:10),
                              child: Container(
                                padding: const EdgeInsets.only(top:10),
                                decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25) ),
                                color: Colors.black),
                      child: FutureBuilder(
                        future: data,
                        builder: (_, snapshot){
                          if(snapshot.connectionState == ConnectionState.waiting)
                          return Center(child: CircularProgressIndicator());
                          else{
                            if(snapshot.data.length>0){
                                      return ListView.builder(
                                      padding: const EdgeInsets.all(8.0),
                                      itemCount: snapshot.data.length,
                                      itemBuilder: (_, index){
                                        return Padding(
                                          padding: const EdgeInsets.only(top:6.0),
                                          child: Container(height: 250,
                                          decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xffffd89b), Color(0xffc4e0e5)]), borderRadius: BorderRadius.circular(25)),
                                            child: GestureDetector(
                                              onTap: () => navigateToDetail(snapshot.data[index]),
                                                child: Card(
                                                elevation: 8,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                                child: Stack(
                                                  children: <Widget>[
                                                    Padding(
                                                    padding: const EdgeInsets.only(top:70),
                                                    child: Container(height: 200, decoration: BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)), 
                                                    image: DecorationImage(image: NetworkImage(snapshot.data[index].data['imgurl']), fit: BoxFit.cover)))
                                                    ),
                                                   ListTile(
                                                     contentPadding: EdgeInsets.only(left:20, right:30),
                                                    subtitle: Text('Read More', style: TextStyle(color: Colors.grey)),
                                                    title: Text(snapshot.data[index].data['Title'], style: TextStyle(fontSize: 20,
                                                    fontWeight: snapshot.data[index].data['Read']==0 ? FontWeight.bold : FontWeight.w300,
                                                    color: snapshot.data[index].data['Read']==0 ? Colors.black : Colors.grey)),
                                                  ),
                                                  Positioned(
                                                    right:10, top: 50,
                                                    child: Text(formatDate(snapshot.data[index].data['Date'].toDate(), [dd, '/', 'mm', '/', yy]), style: TextStyle(color: Colors.grey),),
                                                    ),
                                                    Positioned(
                                                    right:0, top:-2,
                                                    child: IconButton(
                                                      onPressed: () => delNotification(snapshot.data[index]),
                                                      icon: Icon(Icons.clear, color: Colors.grey, size: 23,),
                                                    ),
                                                  )
                                                  
                                                  ]
                                                )
                                           
                                          ),
                                            )
                                        )
                                      );
                                    }
                                  );                 
                             }
                            else{
                              return Center(child: Text('No new notifications!', style: TextStyle(color: Colors.grey, fontSize: 20),),);
                            }
                          }
                        },
                      )
                    ),
              ),
                ],
          ),
        ),
        
      ),
    );
  }
}