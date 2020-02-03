import 'dart:async';
import 'package:e_commerce/getuserdata.dart';
import 'package:e_commerce/products.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register.dart';
import 'dart:io';


class login extends StatefulWidget {
  @override
  _loginState createState() => _loginState();
}

class _loginState extends State<login> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>(); 
  bool visible = false;
  bool emailok = false;
  bool isFilled1 = false;
  TextEditingController usercontroller = TextEditingController();
  TextEditingController passcontroller = TextEditingController();
  FocusNode node1 = FocusNode();
  FocusNode node2 = FocusNode();
    void showdialog(){
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Check fields again", 
          style: TextStyle(color: Colors.black)), 
          backgroundColor: Colors.orange, 
          duration: Duration(milliseconds: 1500),
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)))));
  }
  bool validate1(){
    if((usercontroller.text.contains(' ') || !usercontroller.text.contains('@') || !usercontroller.text.contains('.')) && usercontroller.text.isNotEmpty && node1.hasPrimaryFocus==false)
      {
        setState(() {
          emailok = false;
        });
        return true;
      }
      else if (usercontroller.text.isEmpty)
      {
        setState(() {
          emailok = false;
        });
        return false;
      }
    else 
      {
      setState(() {
          emailok = true;
        });
      return false;
      }
  }
  void handle1(String text){
    validate1();
  }
  
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future getUserInfo() async{
   await Firestore.instance.collection('users').document(usercontroller.text).get().then((DocumentSnapshot mysnap){
     if(mysnap.data!=null)
      Navigator.push(context, MaterialPageRoute(builder: (context) => listPage(post: mysnap)));
     else
      Navigator.push(context, MaterialPageRoute(builder: (context) => getUserData(email: usercontroller.text)));
   });
    
  }

  Future checklogin() async{
   setState((){
      visible=true;
    });
    String email = usercontroller.text;
    String pass = passcontroller.text;
    FirebaseUser user;

    setState(() {
      visible = true;
    });

    try{
     user =  (await auth.signInWithEmailAndPassword(email: email, password: pass)).user;
    } catch(e){print(e.toString());}
    finally{
      
      if (user!=null)
      {
          getUserInfo();
      }
      else{
          _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("User not found.", 
          style: TextStyle(color: Colors.black)), 
          backgroundColor: Colors.orange, 
          duration: Duration(milliseconds: 1500),
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)))));
      
      }
      setState((){
      visible=false;
    });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(   
      onWillPop: () => showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: Text('Warning'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
          content: Text('Exit the app?'),
          actions: <Widget>[
            FlatButton(child: Text('Yes'), onPressed: () => exit(0),),
            FlatButton(child: Text('No'), onPressed: () => Navigator.pop(c, false))
          ],
        )
      ),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
        toolbarOpacity: 0.5,
        centerTitle: true,
        backgroundColor: Colors.black,
        leading: IconButton(icon: Icon(Icons.close),onPressed: () => showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: Text('Warning'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
          content: Text('Exit the app?'),
          actions: <Widget>[
            FlatButton(child: Text('Yes'), onPressed: () => exit(0),),
            FlatButton(child: Text('No'), onPressed: () => Navigator.pop(c, false))
           ],
          )
         )
        ),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.info), color: Colors.white,
          onPressed: () => _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Enter user credentials.", 
          style: TextStyle(color: Colors.black)), 
          backgroundColor: Colors.orange, 
          duration: Duration(milliseconds: 1500),
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))))))
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(25))),
        elevation: 0.0),
        body: SingleChildScrollView(
            child: Center(
              child: Column(children: <Widget>[
                Padding(padding: const EdgeInsets.only(top:120.0),
                ),
                Container(
                            width: 300,
                            padding: EdgeInsets.all(10.0),
                child: Theme(
                  data: ThemeData(primaryColor: Colors.black ),
                  child: TextField (autocorrect: true, 
                  controller: usercontroller,
                  focusNode: node1,
                  onSubmitted: handle1,
                  keyboardType:TextInputType.emailAddress,
                  onChanged: (String text){
                                  setState((){
                                    isFilled1 = text.length>0;
                                  });
                                },
                  decoration: new InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person, color: Colors.black,),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                    errorText: validate1() ? 'Enter a valid email' : null)
                  ),
                ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top:30),
                  child: Container(
                              width: 300,
                              padding: EdgeInsets.all(10.0),
                  child: Theme(
                    data: ThemeData(primaryColor: Colors.black),
                    child: TextField (autocorrect: true, 
                    controller: passcontroller,
                    focusNode: node2,
                    obscureText: true,
                    decoration: new InputDecoration(
                      //hintText: 'Password',
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock, color: Colors.black,),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0),
                      ))
                    ),
                  )
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: RaisedButton(
                  onPressed: () {(emailok==true) ? checklogin() : showdialog();},
                  textColor: Colors.white,
                  color: Colors.black,
                  shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                  child: Container(
                    width: 250,
                    height: 55,
                    decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(80.0))
                    ),
                    child: Center(
                      child: const Text('LOGIN', style: TextStyle(fontSize: 20)
                      ),
                    ),
                  ),
                ),
                              ),
                Padding(
                  padding: const EdgeInsets.only(top:120),
                  child: GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => register()));
                            },
                            child: Container(height:50,
                              child: Center(child: Text('New user? Click here to register', style: TextStyle(fontSize: 18.0, color: Colors.black, fontWeight: FontWeight.w400, decoration: TextDecoration.underline))))
                          ),
                   ),
                  Visibility(
                            visible: visible,
                            child: Container(
                                margin: EdgeInsets.only(bottom: 50),
                                child: CircularProgressIndicator()
                            )
                        ),
              ],
              ),
            )
          ),
        )
      )    
    );
  }
}

