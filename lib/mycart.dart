import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'login.dart';
import 'products.dart';
import 'myaccount.dart';
import 'package:shared_preferences/shared_preferences.dart';

class mycart extends StatefulWidget {
  int counter;
  final String email;
  final DocumentSnapshot userpost;
  mycart({this.userpost,this.email, this.counter});

  @override
  _mycartState createState() => _mycartState();
}

class _mycartState extends State<mycart> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int total;
  List<int> mylist;
  @override
  void initState() { 
    super.initState();
    data=getData();
    }

  void addTotal(int quantity, int cost)
  {
    setState(() {
      total=total+(quantity*cost);
    });
  }

   logOut() async{
     SharedPreferences prefs = await SharedPreferences.getInstance();
     prefs.setString('email', null);
     Navigator.push(context, MaterialPageRoute(builder: (context) => login()));
  }

  Future data;
  Future getData() async {
    total=0;
    QuerySnapshot qs = await Firestore.instance.collection('/users/${widget.email}/Cart').getDocuments();
    qs.documents.forEach((f) => addTotal(f.data['Quantity'], f.data['ProdCost']));
    return qs.documents;
  }

  Future addVal(DocumentSnapshot post, int quantity) async{
    await Firestore.instance.collection('users/${widget.email}/Cart').document(post.documentID)
    .updateData({
      'Quantity': quantity+1,
    });
    setState(() {
      data=getData();
    });
  }

  Future remVal(DocumentSnapshot post, int quantity) async{
    await Firestore.instance.collection('users/${widget.email}/Cart').document(post.documentID)
    .updateData({
      'Quantity': quantity-1,
    });
    setState(() {
      data=getData();
    });
  }

  Future delProd(DocumentSnapshot post) async{
    await Firestore.instance.collection('users/${widget.email}/Cart').document(post.documentID).delete();
    setState(() {
      data=getData();
    });
  }
  
  Future backToProducts() async{
    Navigator.push(context, MaterialPageRoute(builder: (context) => listPage(post: widget.userpost)));
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
                child: Text("${widget.userpost.data['FName']} ${widget.userpost.data['LName']}", 
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
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => myAccount(post: widget.userpost, counter: widget.counter,))),
                        child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      color: Colors.black,
                      child: Stack(
                        children: <Widget>[
                        Center(child: Text('My Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),)),
                        Positioned(
                          left:17,
                          top:14,
                          child: Icon(Icons.supervisor_account, color: Colors.grey,),)
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
                        onTap: () => backToProducts(),
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
            ],)
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: Text('Warning'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
          content: Text('Go back to products page?'),
          actions: <Widget>[
            FlatButton(child: Text('Yes'), onPressed: () => backToProducts(),),
            FlatButton(child: Text('No'), onPressed: () => Navigator.pop(c, false))
          ],
         )
        ),
          child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          appBar: AppBar(
            centerTitle: true,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(25))),
            toolbarOpacity: 0.5,
            elevation: 0,
            actions: <Widget>[
              IconButton(icon: Icon(Icons.shopping_basket),
              onPressed: () => backToProducts())
              ],
            backgroundColor: Colors.black,
            leading: IconButton(icon: Icon(Icons.settings, color: Colors.white),onPressed: () => _scaffoldKey.currentState.openDrawer()),
            title: Text('My Cart', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))
          ),
          drawer: myDrawer(),
          body: Stack(
                children: <Widget>[
                Container(color: Colors.white),
                Padding(
                padding: const EdgeInsets.only(top:10),
                child: Container( decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),)
              ),
               Padding(
                 padding: const EdgeInsets.only(top: 15, left: 5, right: 5),
                 child: Container(
                 child: FutureBuilder(
                  future: data,
                  builder: (_, snapshot){
                    if(snapshot.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator());
                    else{
                      if(snapshot.data.length>0){
                        return Stack(
                                   children: <Widget>[
                                   ListView.builder(
                                  padding: const EdgeInsets.all(4.0),
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (_, index){
                                    return Container(height: 150,
                                      child: Card(
                                        elevation: 1,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                        child: Center(
                                        child: Stack(
                                          children: <Widget>[
                                           ListTile(
                                            leading: Image.network(snapshot.data[index].data['imgurl'],height: 100, width: 100),
                                            title: Text(snapshot.data[index].data['ProdName'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                            subtitle: Text('QR. ${snapshot.data[index].data['ProdCost']}', style: TextStyle(fontSize: 16)),
                                           ),
                                           Positioned(
                                             left:252,
                                             top:21,
                                             child: IconButton(icon: Icon(Icons.remove_circle_outline),
                                             onPressed: () => snapshot.data[index].data['Quantity']>1 ? remVal(snapshot.data[index], snapshot.data[index].data['Quantity']) : null,
                                              ),
                                           ),
                                           Positioned(
                                             left:300,
                                             top:38,
                                             child: Text(snapshot.data[index].data["Quantity"].toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),)
                                            ),
                                            Positioned(
                                             left:311,
                                             top:21,
                                             child: IconButton(icon: Icon(Icons.add_circle_outline),
                                             onPressed: () => addVal(snapshot.data[index], snapshot.data[index].data['Quantity']),
                                             ),
                                            ),
                                            Positioned(
                                             left:340,
                                             top:38,
                                             child: IconButton(icon: Icon(Icons.delete),
                                             onPressed: () => delProd(snapshot.data[index]),
                                             color: Colors.red,
                                             ),
                                            )
                                          ]
                                        ),
                                      )
                                    ),
                                  );
                               }
                          ),
                        Align(
                          alignment: Alignment.bottomCenter,
                               child: Padding(
                                 padding: const EdgeInsets.only(bottom:10.0),
                                 child: Container(
                              alignment: Alignment.bottomCenter,
                              width:250,
                              height:60,
                              child: Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              color: Colors.green,
                              child: Center(child: Text('TOTAL: QR. $total', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),))
                                  )),
                               ),
                        )
                      ],
                        );
                      }
                      else{
                        return Center(
                          child: Stack(children: <Widget>[
                              Center(
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle, 
                                    image: DecorationImage(
                                      image: AssetImage('empty2.png'),
                                      fit: BoxFit.cover)),
                                )
                              ),
                              Center(
                                child: Padding(padding: EdgeInsets.only(top:240),
                                child: Text("Your cart is empty!", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),)),
                              )
                            ],),
                        );
                      }
                    }
                  },
              )
          ),
               ),
        ],
          )
        )
          )
    );
  }
  }