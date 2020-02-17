import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:badges/badges.dart';
import 'mycart.dart'; 
import 'products.dart';
import 'login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent/android_intent.dart';

class myAccount extends StatefulWidget {
  int counter;
  DocumentSnapshot post;
  myAccount({this.post, this.counter});
  @override
  _myAccountState createState() => _myAccountState();
}

class _myAccountState extends State<myAccount > {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>(); 
  bool visible = false;
  bool enabled = false;
  double lat;
  double lng;
  double newlat;
  double newlng;
  String mylocation='Loading...';
  TextEditingController fnamecontroller = new TextEditingController();
  TextEditingController lnamecontroller = new TextEditingController();
  TextEditingController mobcontroller = new TextEditingController();
  TextEditingController addresscontroller = new TextEditingController();
  FocusNode node1 = FocusNode();
  FocusNode node2 = FocusNode();
  FocusNode node3 = FocusNode();
  FocusNode node4 = FocusNode();
  GoogleMap map;
  DocumentSnapshot data;

  @override
  void initState() { 
    super.initState();
    lat=widget.post.data['Latitude'];
    lng=widget.post.data['Longitude'];
    data=widget.post;
    fnamecontroller = TextEditingController(text: '${widget.post.data['FName']}');
    lnamecontroller = TextEditingController(text: '${widget.post.data['LName']}');
    mobcontroller = TextEditingController(text: '${widget.post.data['Mob'].toString()}');
    addresscontroller = TextEditingController(text: '${widget.post.data['Address']}');
    getPlace();
  }

  Map<PermissionGroup, PermissionStatus> permissions;
  Future checkPermission() async{
    permissions = await PermissionHandler().requestPermissions([PermissionGroup.location]);
    PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.location);
    print(permission.value);
    switch(permission.value){
      case 0:
      case 5:{
        await showDialog(
                context: context,
                builder: (c) => AlertDialog(
                  title: Text('Location services disabled'),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  content: Text("Please enble location services"),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Cancel', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)), 
                      onPressed: () => Navigator.pop(c, false)
                    ),
                    FlatButton(
                      child: Text('OK', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)), 
                      onPressed: () => openSettings()
                    )
                  ],
                )
        );
        break;
      }
      case 1:{
        await showDialog(
                context: context,
                builder: (c) => AlertDialog(
                  title: Text('GPS disabled'),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  content: Text("Please enble GPS services"),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Cancel', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)), 
                      onPressed: () => Navigator.pop(c, false)
                    ),
                    FlatButton(
                      child: Text('OK', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)), 
                      onPressed: () => enableGPS()
                    )
                  ],
                )
        );
        break;
      }
      case 2:{
        showMap();
        break;
      }
    }
  }

  enableGPS()
  {
    final AndroidIntent intent = new AndroidIntent(
        action: 'android.settings.LOCATION_SOURCE_SETTINGS',);
        intent.launch();
    Navigator.pop(context);
  }

  openSettings() async{
    await PermissionHandler().openAppSettings();
    Navigator.pop(context);
    await checkPermission();
  }

  void _onCameraMove(CameraPosition position){
    CameraPosition newPosition = CameraPosition(target: position.target);
    setState(() {
      newlat=newPosition.target.latitude;
      newlng=newPosition.target.longitude;
      });
  }

  getPlace() async{
    List<Placemark> p = await Geolocator().placemarkFromCoordinates(lat,lng);
    Placemark place = p[0];
    setState(() {
      mylocation="${place.name}, ${place.subLocality}, ${place.locality}, ${place.country}";
    });
  }

  showMap() async{
    Completer<GoogleMapController> _controller2 = Completer();
    return showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: Text('Select Delivery Location'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
          content: Container(
            height: 400, width: 300,
            child: Stack(
                  children: <Widget>[
                  GoogleMap(
                    onMapCreated: (GoogleMapController controller){
                      _controller2.complete(controller);
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    onCameraMove: _onCameraMove,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(lat, lng),
                      zoom: 18.0
                    ),
                  ),
                  Align(
                      alignment: Alignment.topCenter,    
                      child: Padding(
                      padding: const EdgeInsets.only(top: 165), 
                      child: Icon(Icons.location_on, size:38)
                      ),
                  )
              ],
            )
          ),
          actions: <Widget>[
            FlatButton(child: Text('OK', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)), onPressed: () => updateMap()),
            FlatButton(child: Text('Cancel', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)), onPressed: () => Navigator.pop(c, false))
          ],
         )
    );
  }

  Future <void> updateMap() async {
     setState((){
      visible = false;
     });
     if(lat==newlat && lng ==newlat)
     return 0;
     else{
    lat=newlat;
    lng=newlng;
    getPlace();
    Navigator.pop(context);
    final GoogleMapController controller = await _controller1.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng (lat, lng), 18.5));
     }
  }

  Future getUserInfo() async{
    setState(() {
      visible=true;
    });
   await Firestore.instance.collection('users').document(widget.post.documentID).get().then((DocumentSnapshot mysnap){
     setState(() {
    data=mysnap;
    fnamecontroller = TextEditingController(text: '${mysnap.data['FName']}');
    lnamecontroller = TextEditingController(text: '${mysnap.data['LName']}');
    mobcontroller = TextEditingController(text: '${mysnap.data['Mob'].toString()}');
    addresscontroller = TextEditingController(text: '${mysnap.data['Address']}');
    lat = mysnap.data['Latitude'];
    lng = mysnap.data['Longitude'];
    getPlace();
     });
   });
   final GoogleMapController controller = await _controller1.future;
   setState(() {
     visible=false;
   });
   controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng (lat, lng), 18.5));
  }

  checkDetails(){
    if (fnamecontroller.text!=null && lnamecontroller.text!=null && addresscontroller.text!=null && mobcontroller.text!=null)
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
    setState(() {
      visible=true;
    });
    await Firestore.instance.collection('users').document(widget.post.documentID)
    .setData({
      'FName': fnamecontroller.text,
      'LName': lnamecontroller.text,
      'Address': addresscontroller.text,
      'Mob': int.parse(mobcontroller.text),
      'Latitude': lat,
      'Longitude': lng
    });
    await Firestore.instance.collection('users').document(widget.post.documentID).get().then((DocumentSnapshot mysnap){
      data=mysnap;
    });
    setState(() {
      visible=false;
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
      child: IconButton(icon: Icon(Icons.shopping_cart), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => mycart(userpost: data, email:data.documentID, counter: widget.counter,))),
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
                child: Text('${fnamecontroller.text} ${lnamecontroller.text}', 
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
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => listPage(post: data))),
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
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => mycart(userpost: data, email: widget.post.documentID, counter: widget.counter,))),
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
                        onTap: () => logOut(),
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

  logOut() async{
     SharedPreferences prefs = await SharedPreferences.getInstance();
     prefs.setString('email', null);
     Navigator.push(context, MaterialPageRoute(builder: (context) => login()));
  }

 Completer<GoogleMapController> _controller1 = Completer();
 @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
                getCartCount();
                getUserInfo();
            })),
          widget.counter>0 ? _shoppingCartBadge() : IconButton(icon: Icon(Icons.shopping_cart), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => mycart(userpost: data, email: widget.post.documentID, counter: widget.counter,))))
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(25))),
        elevation: 0.0),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
                  child: Center(
            child: Stack(
                children: <Widget>[
                Column(children: <Widget>[
                  Padding(
                        padding: const EdgeInsets.only(top:25),
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
                            hintText: widget.post.data['FName'],
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
                            hintText: widget.post.data['LName'],
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
                            hintText: widget.post.data['Mob'].toString(),
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
                            hintText: widget.post.data['Address'],
                            labelText: 'Building and Flat No.',
                            prefixIcon: Icon(Icons.location_city, color: Colors.black,),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0),
                            ))
                          ),
                        )
                        ),
                      ),
                      Padding(
                      padding: const EdgeInsets.only(top:30),
                      child: Container(
                        height: 200, width: 340,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
                        child: Stack(
                          children: <Widget>[
                            ClipRRect(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                                child: map = GoogleMap(
                                onMapCreated: (GoogleMapController controller){
                                  _controller1.complete(controller);
                                },
                                myLocationEnabled: false,
                                myLocationButtonEnabled: false,
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(lat,lng),
                                  zoom: 18.5
                                ),
                                )
                              ),
                            Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 60),
                                child: Icon(Icons.location_on, size: 40),
                              )
                            ),
                            Center(
                              child: Visibility(
                                visible: visible,
                                child: Center(
                                 child: CircularProgressIndicator()
                                )
                              )
                            ),
                            Container(
                              color: Colors.transparent
                            ),
                            Positioned(
                              right: 7,
                              child: IconButton(icon: Icon(Icons.edit, size: 25,),  
                              color: enabled ? Colors.black : Colors.transparent, 
                              onPressed: () => enabled ? checkPermission() : null)
                            ), 
                            Positioned(
                              top: 40, right:20,
                              child: Text('EDIT', style: TextStyle(color: enabled ? Colors.black : Colors.transparent, fontSize: 12, fontWeight: FontWeight.w600),)
                            )
                          ],
                        )
                      )
                    ),
                    Container(
                        width: 340,
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Text(mylocation, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),)
                        )
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom:20),
                        child: RaisedButton(
                                splashColor: enabled ? Colors.grey : Colors.transparent,
                                highlightColor: enabled? Colors.grey : Colors.transparent,
                                onPressed: () => enabled ? checkDetails() : null,
                                textColor: Colors.white,
                                elevation: 0,
                                color: enabled ? Colors.orange : Colors.white,
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
                ],
                ),
              ],
            )
          ),
        )
      )    
    );
  }
}