import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'getuserdata.dart';
import 'login.dart';

class register extends StatefulWidget {
  @override
  _registerState createState() => _registerState();
}

class _registerState extends State<register> {
  
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>(); 
  bool visible = false;
  bool isFilled1 = false;
  bool isFilled2 = false;
  bool isFilled3 = false;
  TextEditingController usercontroller = TextEditingController();
  TextEditingController passcontroller1 = TextEditingController();
  TextEditingController passcontroller2 = TextEditingController();
  FocusNode node1 = FocusNode();
  FocusNode node2 = FocusNode();
  FocusNode node3 = FocusNode();
  bool emailok = false;
  bool passok1 = false;
  bool passok2 = false;

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
  bool validatepass(){
    if (passcontroller1.text.contains(' ') || (passcontroller1.text.length < 6 && node2.hasFocus==true))
      {
        setState(() {
          passok1 = false;
        });
        return true;
      }
      else if (passcontroller1.text.isEmpty)
     { setState(() {
          passok1 = false;
        });
      return false;
      }
    else 
      {
      setState(() {
          passok1 = true;
        });
      return false;
      }
  }
  bool validateretype(){
    
    if(passcontroller2.text.isEmpty)
    {
      setState(() {
          passok2 = false;
        });
      return false;
    }
    else if (passcontroller1.text!=passcontroller2.text)
      {
        setState(() {
          passok2 = false;
        });
        return true;
      }
    else 
      {
      setState(() {
          passok2 = true;
        });
      return false;
      }
  }
  void passfill(String text){
    setState(() {
              isFilled3=true;
            });
  }
  
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future checklogin() async{
     setState((){
      visible=true;
    });
    String email = usercontroller.text;
    String pass = passcontroller1.text;
    FirebaseUser user;

    Future getUserInfo() async{
      Navigator.push(context, MaterialPageRoute(builder: (context) => getUserData(email: email)));
   }

    try{
     user =  (await auth.createUserWithEmailAndPassword(email: email, password: pass)).user;
    } catch(e){print(e.toString());}
    finally{
      if (user!=null)
      {
        
          getUserInfo(); //TODO parameter 
      }
      else
      {
        _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("User already exists.", 
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
      onWillPop: () => Navigator.push(context, MaterialPageRoute(builder: (context) => login())),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
        toolbarOpacity: 0.5,
        centerTitle: true,
        title: Text('Sign-up', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.black,
        leading: IconButton(icon: Icon(Icons.arrow_back),onPressed: () => Navigator.of(context).pop()),
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
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
                  child: Center(
            child: Column(children: <Widget>[
              Padding(
                    padding: const EdgeInsets.only(top:80),
                    child: Container(
                                width: 300,
                                padding: EdgeInsets.all(10.0),
                    child: Theme(
                      data: ThemeData(primaryColor: Colors.black),
                      child: TextField (autocorrect: true, 
                      controller: usercontroller,
                      focusNode: node1,
                      keyboardType:TextInputType.emailAddress,
                      onEditingComplete: validate1,
                      onChanged: (String text){
                            setState((){
                              isFilled1 = text.length>0;
                            });
                          },
                      decoration: new InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person, color: Colors.black,),
                        errorText: validate1() ? 'Enter a valid email' : null,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0),
                        ))
                      ),
                    )
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
                      controller: passcontroller1,
                      focusNode: node2,
                      obscureText: true,
                      onChanged: (String text){
                            setState((){
                              isFilled2 = text.length>0;
                            });
                          },
                      decoration: new InputDecoration(//hintText: 'Password',
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock, color: Colors.black,),
                        errorText: validatepass() ? 'No white spaces. At least 6 characters long.' : null,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0),
                        ))
                      ),
                    )
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
                      controller: passcontroller2,
                      focusNode: node3,
                      obscureText: true,
                      onChanged: (String text){
                            setState((){
                              isFilled3 = text.length>0;
                            });
                          },
                      decoration: new InputDecoration(
                        labelText: 'Re-type password',
                        prefixIcon: Icon(Icons.lock, color: Colors.black,),
                        errorText: validateretype()? "Passwords don't match" : null,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0),
                        ))
                      ),
                    )
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: RaisedButton(
                    onPressed: () {(emailok==true && passok1==true && passok2==true) ? checklogin() : showdialog() ;},
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
                        child: const Text('Register', style: TextStyle(fontSize: 20)
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                          visible: visible,
                          child: Container(
                              margin: EdgeInsets.only(bottom: 30),
                              child: CircularProgressIndicator()
                          )
                      ),
            ],
            )
          ),
        )
      )  
    )   
    );
  }
}