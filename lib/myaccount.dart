import 'package:e_commerce/getuserdata.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:badges/badges.dart';
import 'mycart.dart'; 
import 'products.dart';
import 'login.dart';

class myAccount extends StatefulWidget {
  int counter;
  final DocumentSnapshot post;
  myAccount({this.post, this.counter});
  @override
  _myAccountState createState() => _myAccountState();
}

class _myAccountState extends State<myAccount > {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>(); 
  bool visible = false;
  bool enabled = false;
  String dropdownvalue;
  TextEditingController fnamecontroller;
  TextEditingController lnamecontroller;
  TextEditingController mobcontroller;
  TextEditingController addresscontroller;
  FocusNode node1 = FocusNode();
  FocusNode node2 = FocusNode();
  FocusNode node3 = FocusNode();
  FocusNode node4 = FocusNode();
  
  Future getUserInfo() async{
    setState(() {
      visible=true;
    });
   await Firestore.instance.collection('users').document(widget.post.documentID).get().then((DocumentSnapshot mysnap){
     setState(() {
       dropdownvalue = '${mysnap.data['City']}';
    fnamecontroller = TextEditingController(text: '${mysnap.data['FName']}');
    lnamecontroller = TextEditingController(text: '${mysnap.data['LName']}');
    mobcontroller = TextEditingController(text: '${mysnap.data['Mob'].toString()}');
    addresscontroller = TextEditingController(text: '${mysnap.data['Address']}');
     });
   });
   setState(() {
     visible=false;
   });
  }

  @override
  void initState() { 
    super.initState();
    dropdownvalue = '${widget.post.data['City']}';
    fnamecontroller = TextEditingController(text: '${widget.post.data['FName']}');
    lnamecontroller = TextEditingController(text: '${widget.post.data['LName']}');
    mobcontroller = TextEditingController(text: '${widget.post.data['Mob'].toString()}');
    addresscontroller = TextEditingController(text: '${widget.post.data['Address']}');
    getCartCount();
    
  }

  checkDetails(){
    if (fnamecontroller.text!=null && lnamecontroller.text!=null && addresscontroller.text!=null && mobcontroller.text!=null && dropdownvalue!='--City--')
    addUserDetails();
    else
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Please fill all fields.", 
          style: TextStyle(color: Colors.black)), 
          backgroundColor: Colors.orange, 
          duration: Duration(milliseconds: 1500),
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)))));
  }

  Future addUserDetails() async {
    await Firestore.instance.collection('users').document(widget.post.documentID)
    .setData({
      'FName': fnamecontroller.text,
      'LName': lnamecontroller.text,
      'Address': addresscontroller.text,
      'Mob': int.parse(mobcontroller.text),
      'City': dropdownvalue
    });
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Changes saved.", 
          style: TextStyle(color: Colors.white)), 
          backgroundColor: Colors.green, 
          duration: Duration(milliseconds: 1500),
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)))));
    setState(() {
      enabled=false;
    });
  }

  Widget _shoppingCartBadge() {
    return Badge(
      position: BadgePosition.topRight(top: 0, right: 3),
      animationDuration: Duration(milliseconds: 300),
      animationType: BadgeAnimationType.slide,
      badgeContent: Text(
        widget.counter.toString()!=null ? widget.counter.toString() : "0",
        style: TextStyle(color: Colors.white),
      ),
      child: IconButton(icon: Icon(Icons.shopping_cart), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => mycart(userpost: widget.post, email: widget.post.documentID))),
      ),
    );
  }
   
   Future getCartCount() async{
    QuerySnapshot _snap = await Firestore.instance.collection('/users/${widget.post.documentID}/Cart').getDocuments();
    List<DocumentSnapshot> _docCount = _snap.documents;
    setState(() {
      widget.counter= _docCount.length;
    });
   }

    List <String> cityName = [
    '--City--', 'Doha', 'Al Khor', 'Dukhan', 'Mesaieed'
    ] ;

  Widget myDrawer(){
    return ClipRRect(
      borderRadius: BorderRadius.only(topRight: Radius.circular(80), bottomRight: Radius.circular(80)),
      child: Drawer(
        elevation: 4.5,
        child: Column(children: <Widget>[
          DrawerHeader(decoration: BoxDecoration(color: Colors.black),
            child: Center(
              child: Row(children: <Widget>[
                Padding(padding: EdgeInsets.all(8),
                child:Icon(Icons.account_circle, color: Colors.white),),
                Padding(padding: EdgeInsets.all(2),
                child: Text("${fnamecontroller.text} ${lnamecontroller.text}", 
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)))  
              ],),
            )
            ),
              Padding(
                padding: const EdgeInsets.only(top: 25.0),
                child: Container(
                      width:250,
                      height:60,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        splashColor: Colors.grey,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => listPage(post: widget.post))),
                        child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      color: Colors.black,
                      child: Stack(
                        children: <Widget>[
                        Center(child: Text('Products', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),)),
                        Positioned(
                          left:17,
                          top:14,
                          child: Icon(Icons.shopping_basket, color: Colors.grey,),)
                        ]
                        )
                  ),
                    ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 25.0),
                child: Container(
                      width:250,
                      height:60,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        splashColor: Colors.grey,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => mycart(userpost: widget.post, email: widget.post.documentID))),
                        child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      color: Colors.black,
                      child: Stack(
                        children: <Widget>[
                        Center(child: Text('Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),)),
                        Positioned(
                          left:17,
                          top:14,
                          child: Icon(Icons.shopping_cart, color: Colors.grey,),)
                        ]
                        )
                        ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 290),
                child: Container(
                      alignment: Alignment.bottomCenter,
                      width:180,
                      height:50,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        splashColor: Colors.grey,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => login())),
                        child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      color: Colors.orange,
                      child: Center(child: Text('LOGOUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),))
                      ),
                    ),
                 ),
               ) 
           ],
        )
      ) 
    );
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
        drawer: myDrawer(),
        appBar: AppBar(
        toolbarOpacity: 0.5,
        centerTitle: true,
        title: Text('My details', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.black,
        leading: IconButton(icon: Icon(Icons.settings, color: Colors.white),onPressed: () => _scaffoldKey.currentState.openDrawer()),
        actions: <Widget>[
         IconButton(icon: Icon(Icons.edit), 
         color: enabled ? Colors.black : Colors.white, 
         highlightColor: enabled ? Colors.transparent : Colors.grey,
         splashColor: enabled ? Colors.transparent : Colors.grey,
          onPressed: () => enabled ? null: setState((){enabled=true;})),
          IconButton(icon: Icon(Icons.refresh),
            onPressed: () => setState((){
                getUserInfo();
                getCartCount();
            })),
          _shoppingCartBadge()
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(25))),
        elevation: 0.0),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
                  child: Center(
            child: Column(children: <Widget>[
              Padding(
                    padding: const EdgeInsets.only(top:30),
                    child: Container(
                                width: 300,
                                padding: EdgeInsets.all(10.0),
                    child: Theme(
                      data: ThemeData(primaryColor: Colors.black),
                      child: TextField (autocorrect: true, 
                      controller: fnamecontroller,
                      focusNode: node1,
                      enabled: enabled,
                      decoration: new InputDecoration(
                        hintText: '${widget.post.data['FName']}',
                        labelText: 'First Name',
                        prefixIcon: Icon(Icons.person, color: Colors.black,),
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
                      controller: lnamecontroller,
                      focusNode: node2,
                      enabled: enabled,
                      decoration: new InputDecoration(
                        hintText: '${widget.post.data['LName']}',
                        labelText: 'Last Name',
                        prefixIcon: Icon(Icons.supervisor_account, color: Colors.black,),
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
                      controller: mobcontroller,
                      focusNode: node3,
                      keyboardType:TextInputType.phone,
                      enabled: enabled,
                      decoration: new InputDecoration(
                        hintText: '${widget.post.data['Mob']}',
                        labelText: 'Mobile',
                        prefixIcon: Icon(Icons.phone, color: Colors.black,),
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
                      controller: addresscontroller,
                      focusNode: node4,
                      enabled: enabled,
                      decoration: new InputDecoration(
                        hintText: '${widget.post.data['Address']}',
                        labelText: 'Address',
                        prefixIcon: Icon(Icons.home, color: Colors.black,),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0),
                        ))
                      ),
                    )
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Container(
                      width: 280,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1.0, style: BorderStyle.solid, color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left:10.0, right:3.0),
                        child: DropdownButtonHideUnderline(
                             child: DropdownButton<String>(
                             hint: Text(dropdownvalue),
                             value: dropdownvalue,
                             isExpanded: true,
                             onChanged: enabled==false ? null : (String data) {
                             setState(() {
                              dropdownvalue = data;
                            });
                          },
                             items: cityName.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: RaisedButton(
                    onPressed: () => enabled ? checkDetails() : null,
                    textColor: Colors.white,
                    elevation: 0,
                    color: Colors.orange,
                    shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                    child: Container(
                      width: 250,
                      height: 55,
                      decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(80.0))
                      ),
                      child: Center(
                        child: const Text('Save changes', style: TextStyle(fontSize: 20)
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                          visible: visible,
                          child: Container(
                              margin: EdgeInsets.only(bottom: 30),
                              child: Center(child: CircularProgressIndicator())
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