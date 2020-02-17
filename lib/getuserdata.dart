import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';
import 'products.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent/android_intent.dart';

class getUserData extends StatefulWidget {
  final String email;
  getUserData({this.email});
  @override
  _getUserDataState createState() => _getUserDataState();
}

class _getUserDataState extends State<getUserData> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>(); 
  TextEditingController fnamecontroller = TextEditingController();
  TextEditingController lnamecontroller = TextEditingController();
  TextEditingController mobcontroller = TextEditingController();
  TextEditingController addresscontroller = TextEditingController();
  FocusNode node1 = FocusNode();
  FocusNode node2 = FocusNode();
  FocusNode node3 = FocusNode();
  FocusNode node4 = FocusNode();
  double lat=0;
  double newlat=0;
  double lng=0;
  double newlng=0;
  bool visible = false;
  String mylocation='Choose a location';
  GoogleMap map;

  Geolocator geolocator = Geolocator();

  @override
  void initState() { 
    super.initState();
    getLocation();
    checkPermission();
  }

  Map<PermissionGroup, PermissionStatus> permissions;
  checkPermission() async{
    permissions = await PermissionHandler().requestPermissions([PermissionGroup.location]);
    PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.location);
    print(permission.value);
    switch(permission.value){
      case 0:
      case 5:{
        await showDialog(
                context: context,
                builder: (c) => AlertDialog(
                  title: Text('Location disabled'),
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

  getPlace() async{
    List<Placemark> p = await Geolocator().placemarkFromCoordinates(lat,lng);
    Placemark place = p[0];
    setState(() {
      mylocation="${place.name}, ${place.subLocality}, ${place.locality}, ${place.country}";
    });
  }

  Future getLocation() async {
    Position currentLocation = await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    setState(() {
      lat = currentLocation.latitude;
      lng = currentLocation.longitude;
    });
    
  }

  void _onCameraMove(CameraPosition position){
    CameraPosition newPosition = CameraPosition(target: position.target);
    setState(() {
      print(newPosition.target);
      newlat=newPosition.target.latitude;
      newlng=newPosition.target.longitude;
      });
  }


  showMap() async{
    await checkPermission();
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
            FlatButton(child: Text('Cancel', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)), onPressed: () => onCancel())
          ],
         )
    );
  }

  onCancel(){
    Navigator.pop(context);
    newlat=0;
    newlng=0;
  }

  Future <void> updateMap() async {
    setState(() {
      visible=false;
    });
    if(lat==newlat && lng ==newlat)
      return 0;
    else{
      lat=newlat;
      lng=newlng;
      getPlace();
      Navigator.pop(context);
      final GoogleMapController controller = await _controller1.future;
      controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng (newlat, newlng), 18.5));
    }
  }
  
  checkDetails(){
    if (fnamecontroller.text!='' && lnamecontroller.text!='' && addresscontroller.text!='' && mobcontroller.text!='' && lat!=0 && lng!=0)
    addUserDetails();
    else
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(lat!=0 ?  "Please fill all fields": "Select map location", 
          style: TextStyle(color: Colors.white)), 
          backgroundColor: Colors.black, 
          duration: Duration(milliseconds: 1500),
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)))));
  }

  Future addUserDetails() async {
    setState(() {
      visible = true;
    });
    await Firestore.instance.collection('users').document(widget.email)
    .setData({
      'FName': fnamecontroller.text,
      'LName': lnamecontroller.text,
      'Address': addresscontroller.text,
      'Mob': int.parse(mobcontroller.text),
      'Latitude': lat,
      'Longitude': lng 
    });
    setState(() {
      visible=false;
    });
    navigateToProducts();
  }

  Future navigateToProducts() async{
     await Firestore.instance.collection('users').document(widget.email).get().then((DocumentSnapshot mysnap){
       Navigator.push(context, MaterialPageRoute(builder: (context) => listPage(post: mysnap)));
    });
  }

  Completer<GoogleMapController> _controller1 = Completer();
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
        title: Text('User details', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.black,
        leading: IconButton(icon: Icon(Icons.arrow_back),onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => login()))),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.info), color: Colors.white,
          onPressed: () => _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Enter user credentials.", 
          style: TextStyle(color: Colors.white)), 
          backgroundColor: Colors.black, 
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
                    padding: const EdgeInsets.only(top:20),
                    child: Container(
                                width: 300,
                                padding: EdgeInsets.all(10.0),
                    child: Theme(
                      data: ThemeData(primaryColor: Colors.black),
                      child: TextField (autocorrect: true, 
                      controller: fnamecontroller,
                      focusNode: node1,
                      decoration: new InputDecoration(
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
                      decoration: new InputDecoration(
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
                      decoration: new InputDecoration(
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
                      decoration: new InputDecoration(
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
                          color: Colors.black,
                          onPressed: () =>  checkPermission())
                        ), 
                        Positioned(
                          top: 40, right:20,
                          child: Text('EDIT', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w600),)
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
                    onPressed: () => checkDetails(),
                    textColor: Colors.white,
                    color: Colors.orange,
                    shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                    child: Container(
                      width: 250,
                      height: 55,
                      decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(80.0))
                      ),
                      child: Center(
                        child: const Text('Save details', style: TextStyle(fontSize: 20)
                        ),
                      ),
                    ),
                  ),
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