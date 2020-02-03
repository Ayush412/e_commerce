import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';
import 'products.dart';

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
  bool visible = false;
  String dropdownvalue = '--City--';

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
    await Firestore.instance.collection('users').document(widget.email)
    .setData({
      'FName': fnamecontroller.text,
      'LName': lnamecontroller.text,
      'Address': addresscontroller.text,
      'Mob': int.parse(mobcontroller.text),
      'City': dropdownvalue
    });
    navigateToProducts();
  }

  Future navigateToProducts() async{
     await Firestore.instance.collection('users').document(widget.email).get().then((DocumentSnapshot mysnap){
       Navigator.push(context, MaterialPageRoute(builder: (context) => listPage(post: mysnap)));
    });
  }
  
  List <String> cityName = [
    '--City--', 'Doha', 'Al Khor', 'Dukhan', 'Mesaieed'
    ] ;

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
                    padding: const EdgeInsets.only(top:30),
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
                             hint: Text("City"),
                             value: dropdownvalue,
                             isExpanded: true,
                             onChanged: (String data) {
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