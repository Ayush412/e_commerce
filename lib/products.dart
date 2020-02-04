import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'descpage.dart';
import 'dart:async';
import 'login.dart';
import 'package:badges/badges.dart';
import 'mycart.dart';
import 'myaccount.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'addNotification.dart';
import 'myNotifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'globalVariable.dart' as globals;

class listPage extends StatefulWidget {

  final DocumentSnapshot post;
  listPage({this.post});
  @override
  _listPageState createState() => _listPageState();
}

class _listPageState extends State<listPage> {
  
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseMessaging _fcm = FirebaseMessaging();
  String catVal;
  String subcatVal;
  String catVal2;
  String subcatVal2;
  String text;
  String title;
  String imgurl;
  double oplevel=0;
  Timer _timer;
  int _counter=0;
  int _notifCount=0;
  int _current=0;

  @override
  void initState() { 
    super.initState();
    globals.globalVariable.play=true;
    //_fcm.getToken().then((token) => print(token));
    _fcm.subscribeToTopic('e-commerce');
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
            addNotification(text, title, widget.post.documentID, imgurl);
            setState(() {
              getNotifCount();
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
            addNotification(text, title, widget.post.documentID, imgurl);
            setState(() {
              getNotifCount();
            });
        },
  );
    data=getData();
    topdata=getTopData();
    _timer = new Timer(const Duration(milliseconds: 1100), () {
      setState(() {
        oplevel=1;
      });
      getCartCount();
      getNotifCount();
    }); 
  }

  Future getCartCount() async{
    QuerySnapshot _snap = await Firestore.instance.collection('/users/${widget.post.documentID}/Cart').getDocuments();
    List<DocumentSnapshot> _docCount = _snap.documents;
    setState(() {
      _counter= _docCount.length;
    });  
  }

  Future getNotifCount() async{
    QuerySnapshot _snap = await Firestore.instance.collection('/users/${widget.post.documentID}/Notifications').where('Read', isEqualTo: 0).getDocuments();
    List<DocumentSnapshot> _docCount = _snap.documents;
    setState(() {
      _notifCount= _docCount.length;
    });  
  }

  @override
  void dispose(){
     super.dispose();
     _timer.cancel();
   }

   void goBack(){
     setState(() {
       oplevel=0;
     });
     Navigator.pop(context);
   }

  logOut() async{
     SharedPreferences prefs = await SharedPreferences.getInstance();
     prefs.setString('email', null);
     Navigator.push(context, MaterialPageRoute(builder: (context) => login()));
  }
   
  Future data;
  Future getData() async {
    QuerySnapshot qs = await Firestore.instance.collection('products').getDocuments();
    return qs.documents;
  }

  Future topdata;
  Future getTopData() async {
    QuerySnapshot qs = await Firestore.instance.collection('products').where('Rate', isGreaterThanOrEqualTo: 4).getDocuments();
    return qs.documents;
  }

  Future searchData(String name) async{
    QuerySnapshot qs = await Firestore.instance.collection('products').where('ProdName', isLessThanOrEqualTo: name).getDocuments();
    return qs.documents;
  }

  Future sortData(String field, bool mybool) async{
    QuerySnapshot qs = await Firestore.instance.collection('products').orderBy("$field", descending: mybool).getDocuments();
    return qs.documents;
  }
  

  Future catSortData(String field, bool mybool) async{
    QuerySnapshot qs = await Firestore.instance.collection('products').where("Category", isEqualTo: "$catVal").orderBy("$field", descending: mybool).getDocuments();
    return qs.documents;
  }

   Future subCatSortData(String field, bool mybool) async{
    QuerySnapshot qs = await Firestore.instance.collection('products').where("SubCategory", isEqualTo: "$subcatVal").orderBy("$field", descending: mybool).getDocuments();
    return qs.documents;
   }

  Future categorySort(String category) async {
    QuerySnapshot qs = await Firestore.instance.collection('products').where("Category", isEqualTo: "$category").getDocuments();
    return qs.documents;
  }

  Future subCategorySort(String subcategory) async {
    QuerySnapshot qs = await Firestore.instance.collection('products').where("SubCategory", isEqualTo: "$subcategory").getDocuments();
    return qs.documents;
  }

  navigateToDetail(DocumentSnapshot post, String tag){
    setState(() {
      globals.globalVariable.play=false;
    });
    String email = widget.post.documentID.toString();
    Navigator.push(context, PageRouteBuilder(transitionDuration: Duration(milliseconds:600) ,pageBuilder: (_,__,___)=> prodDescription(post: post, email: email, counter: _counter, userpost: widget.post, tag: tag,)));
  }

  Widget _shoppingCartBadge() {
    return Badge(
      position: BadgePosition.topRight(top: 0, right: 3),
      animationDuration: Duration(milliseconds: 300),
      animationType: BadgeAnimationType.slide,
      badgeContent: Text(
        _counter.toString(),
        style: TextStyle(color: Colors.white),
      ),
      child: IconButton(icon: Icon(Icons.shopping_cart), 
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => mycart(userpost: widget.post, email: widget.post.documentID))),
    ));
  }

  Widget _notificationBadge() {
    return Badge(
      position: BadgePosition.topRight(top: 0, right: 3),
      animationDuration: Duration(milliseconds: 300),
      animationType: BadgeAnimationType.slide,
      badgeContent: Text(_notifCount.toString(),
        style: TextStyle(color: Colors.white),
      ),
      child: IconButton(icon: Icon(Icons.notifications), color: Colors.white,
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => myNotifications(widget.post.documentID, widget.post))),
    ));
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
                child: Text("${widget.post.data['FName']} ${widget.post.data['LName']}", 
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
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => myAccount(post: widget.post, counter: _counter,))),
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
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => mycart(userpost: widget.post, email: widget.post.documentID, counter: _counter,))),
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

  subCatMenu(String category){
    if (category=='Fashion')
    {
        return <PopupMenuItem<String>>[
                      new PopupMenuItem<String>(
                                height: 40,
                                child: const Text('Caps', style: TextStyle(color: Colors.white, fontSize: 15),), value: 'Caps'),
                      new PopupMenuItem<String>(
                                height: 40,
                                child: const Text('Bottoms', style: TextStyle(color: Colors.white, fontSize: 15),), value: 'Bottoms'),
                      new PopupMenuItem<String>(
                                height: 40,
                                child: const Text('Eye Wear', style: TextStyle(color: Colors.white, fontSize: 15),), value: 'Eye Wear'),
                      new PopupMenuItem<String>(
                                height: 40,
                                child: const Text('T-Shirts', style: TextStyle(color: Colors.white, fontSize: 15),), value: 'T-Shirts'),
                      new PopupMenuItem<String>(
                                height: 40,
                                child: const Text('Watches', style: TextStyle(color: Colors.white, fontSize: 15),), value: 'Watches'),
                    
       ];
    }
    else if (category=='Electronics')
    {
        return <PopupMenuItem<String>>[
                      new PopupMenuItem<String>(
                                height: 40,
                                child: const Text('Laptops', style: TextStyle(color: Colors.white, fontSize: 15),), value: 'Laptops'),
                      new PopupMenuItem<String>(
                                height: 40,
                                child: const Text('Mobile Phones', style: TextStyle(color: Colors.white, fontSize: 15),), value: 'Mobile Phones'),
                       new PopupMenuItem<String>(
                                height: 40,
                                child: const Text('Games', style: TextStyle(color: Colors.white, fontSize: 15),), value: 'Games'),
        
        ];
    }
  }

  Widget build(BuildContext context) {
    return WillPopScope(
          onWillPop: () => showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: Text('Warning'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
          content: Text('Do you wish to log out?'),
          actions: <Widget>[
            FlatButton(child: Text('Yes'), onPressed: () => login(),),
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
              IconButton(icon: Icon(Icons.refresh),
              onPressed: () => setState((){
                  data=getData();
                  topdata=getTopData();
                  globals.globalVariable.play=true;
                  subcatVal=null;
                  catVal=null;
                  _notifCount=0;
                  getCartCount();
                  getNotifCount();
              })),
              _notifCount>0 ? _notificationBadge() : IconButton(icon: Icon(Icons.notifications), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => myNotifications(widget.post.documentID, widget.post)))),

              _shoppingCartBadge()
            ],
            backgroundColor: Colors.black,
            leading: IconButton(icon: Icon(Icons.settings, color: Colors.white),onPressed: () => _scaffoldKey.currentState.openDrawer()),
            title: Text('Products', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))
          ),
          drawer: myDrawer(),
          body: Stack(
                    children: <Widget>[
              Container(color: Colors.white),
              Padding(
                padding: const EdgeInsets.only(top:10),
                child: Container(
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
                )
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: FutureBuilder(
                  future: topdata,
                  builder: (_,topsnap){
                    if(topsnap.connectionState == ConnectionState.waiting)
                      return Padding(
                        padding: const EdgeInsets.all(100.0),
                        child: Align (alignment: Alignment.topCenter , child: CircularProgressIndicator()),
                      );
                    else
                    {
                      return CarouselSlider.builder(
                        autoPlay: globals.globalVariable.play,
                        itemCount: topsnap.data.length,
                        pauseAutoPlayOnTouch: Duration(seconds: 10),
                        onPageChanged: (index) {
                            setState(() {
                              _current = index;
                            });
                          },
                        itemBuilder: (BuildContext context, int index) =>
                        Padding(
                          padding: const EdgeInsets.only(top:30.0),
                          child: Container(
                                color: Colors.black,
                                width: 320,
                                child: GestureDetector(
                                      onTap: () => navigateToDetail(topsnap.data[index], 'card${topsnap.data[index].documentID}'),
                                      child: Card(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      child: Stack(
                                        children: <Widget>[
                                          Positioned(
                                            top: 5, left: 20,
                                            child: Text(topsnap.data[index].data['ProdName'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)
                                          ),
                                          Center(
                                            child: Hero(
                                              tag: 'card${topsnap.data[index].documentID}',
                                              child: Image.network(topsnap.data[index].data['imgurl'], height:120, width:120)),
                                          ),
                                          Positioned(
                                            top: 165, left:20,
                                            child: Text('QR. ${topsnap.data[index].data['ProdCost']}', style: TextStyle(fontSize: 18),)
                                          ),
                                          Positioned(
                                            top:160,
                                            right:20,
                                            child: Container(
                                              height:25,
                                              width: 80,
                                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.green),
                                              child: Center(child: Text("Buy Now", style: TextStyle(color: Colors.white),))
                                            )
                                          ),
                                        ],
                                      )
                                  ),
                                )
                          ),
                        ),
                      );
                     } 
                  }
                )
              ),
              Positioned(
                top: 17,
                left:15,
                child: Text("Most Popular Items", style: TextStyle(color: Colors.white, fontSize:22, fontWeight: FontWeight.w400),)
              ),
              Padding(
                padding: const EdgeInsets.only(top:280.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
                  child: FutureBuilder(
                    future: data,
                    builder: (_, snapshot){
                      if(snapshot.connectionState == ConnectionState.waiting)
                      return Center(child: CircularProgressIndicator());
                      else{
                        return AnimatedOpacity(
                          duration: Duration(milliseconds: 300),
                          opacity: oplevel,
                          child: ListView.builder(
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
                                          onTap: () => navigateToDetail(snapshot.data[index], '${snapshot.data[index].documentID}'),
                                          leading: Hero(
                                            tag: '${snapshot.data[index].documentID}',
                                            child: Image.network(snapshot.data[index].data['imgurl'],height: 100, width: 100)),
                                          subtitle: Text('QR. ${snapshot.data[index].data['ProdCost'].toString()}', style: TextStyle(color: Colors.grey)),
                                          title: Text(snapshot.data[index].data['ProdName'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                                        ),
                                        Positioned(
                                          left:260,
                                          top:45,
                                        child: Row(
                                          children: List.generate(5, (val) {
                                                return Icon(
                                                val < snapshot.data[index].data['Rate'] ? Icons.star : Icons.star_border,
                                                color: Colors.black,
                                              );
                                          }),
                                        )
                                        )
                                        ]
                                      ),
                                    )
                                    ),
                                  );
                                }
                           
                          ),
                        );
                      }
                    },
                  )
                ),
              ),
              Positioned(
                left: 10, right: 10, bottom: 14,
                  child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BottomNavigationBar(
                backgroundColor: Color(0x2FFAFAFA),
                items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.sort, color: Colors.white,),
                  title: Text('Sort', style: TextStyle(color: Colors.white),)
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu, color: Colors.white,),
                  title: Text('Category', style: TextStyle(color: Colors.white),)
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.filter_list, color: Colors.white,),
                  title: Text('Sub Category', style: TextStyle(color: Colors.white),)
                ),
                ],
                currentIndex: 0,
                onTap: (int index) async {
                  if(index == 0){
                    int sortVal = await showMenu<int>(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      color: Colors.black,
                      context: context,
                      position: RelativeRect.fromLTRB(20, 475.0, 60.0, 0.0),
                      items: <PopupMenuItem<int>>[
                        new PopupMenuItem<int>(
                                  height: 40,
                                  child: const Text('Price: Low to High', style: TextStyle(color: Colors.white, fontSize: 15),), value: 1),
                        new PopupMenuItem<int>(
                                  height: 40,
                                  child: const Text('Price: High to Low', style: TextStyle(color: Colors.white, fontSize: 15),), value: 2),
                        new PopupMenuItem<int>(
                                  height: 40,
                                  child: const Text('List: A to Z', style: TextStyle(color: Colors.white, fontSize: 15),), value: 3),
                        new PopupMenuItem<int>(
                                  height: 40,
                                  child: const Text('List: Z to A', style: TextStyle(color: Colors.white, fontSize: 15),), value: 4),
                      ],
                      elevation: 0,
                    );
                    switch (sortVal){
                      case 1: {
                        if(catVal2!=null && subcatVal2==null)
                        {
                          setState(() {
                          data=catSortData("ProdCost", false);
                        });
                        }
                        else if(subcatVal2!=null){
                          setState(() {
                            data=subCatSortData("ProdCost", false);
                          });
                        }
                        else
                        setState(() {
                          data=sortData("ProdCost", false);
                        });
                        break;
                      }
                      case 2:{
                        if(catVal2!=null && subcatVal2==null)
                        {
                          setState(() {
                          data=catSortData("ProdCost", true);
                        });
                        }
                        else if(subcatVal2!=null){
                          setState(() {
                            data=subCatSortData("ProdCost", true);
                          });
                        }
                        else
                        setState(() {
                          data=sortData("ProdCost", true);
                        });
                        break;
                      }
                      case 3:{if(catVal2!=null && subcatVal2==null)
                        {
                          setState(() {
                          data=catSortData("ProdName", false);
                        });
                        }
                        else if(subcatVal2!=null){
                          setState(() {
                            data=subCatSortData("ProdName", false);
                          });
                        }
                        else
                        setState(() {
                          data=sortData("ProdName", false);
                        });
                        break;
                      }
                      case 4:{if(catVal2!=null && subcatVal2==null)
                        {
                          setState(() {
                          data=catSortData("ProdName", true);
                        });
                        }
                        else if(subcatVal2!=null){
                          setState(() {
                            data=subCatSortData("ProdName", true);
                          });
                        }
                        else
                        setState(() {
                          data=sortData("ProdName", true);
                        });
                        break;
                      }
                    }
                 }
                 else if(index == 1){
                      catVal = await showMenu<String>(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      color: Colors.black,
                      context: context,
                      position: RelativeRect.fromLTRB(30.0, 515.0, 30.0, 0.0),
                      items: <PopupMenuItem<String>>[
                        new PopupMenuItem<String>(
                                  height: 40,
                                  child: const Text('All', style: TextStyle(color: Colors.white, fontSize: 15),), value: 'All'),
                        
                        new PopupMenuItem<String>(
                                  height: 40,
                                  child: const Text('Fashion', style: TextStyle(color: Colors.white, fontSize: 15),), value: 'Fashion'),
                        new PopupMenuItem<String>(
                                  height: 40,
                                  child: const Text('Electronics', style: TextStyle(color: Colors.white, fontSize: 15),), value: 'Electronics'),
                       ],
                      elevation: 0,
                    );
                    if(catVal=="All"){
                      setState(() {
                        catVal=null;
                        catVal2=null;
                        subcatVal=null;
                        subcatVal2=null;
                        data=getData();
                      });
                    }
                    else if(catVal!=null){
                    setState(() {
                      catVal2=catVal;
                      data=categorySort(catVal);
                      subcatVal=null;
                      subcatVal2=null;
                      subCatMenu(catVal);
                    });
                    }
                 }
                 else if(index == 2){
                      if (catVal2==null)
                      {
                        _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Select a category first.", 
                        style: TextStyle(color: Colors.white)), 
                        backgroundColor: Colors.green, 
                        duration: Duration(milliseconds: 500),
                        shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)))));
        
                      }
                      subcatVal = await showMenu<String>(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      color: Colors.black,
                      context: context,
                      position: catVal2=="Fashion" ? RelativeRect.fromLTRB(38.0, 435.0, 20.0, 0.0) : RelativeRect.fromLTRB(38.0, 515.0, 20.0, 0.0), //38.0, 555.0, 10.0, 0.0
                      items: subCatMenu(catVal2),
                      elevation: 0
                    );
                    if(subcatVal!=null)
                    {
                      subcatVal2=subcatVal;
                      setState(() {
                        data=subCategorySort(subcatVal2);
                      });
                    }
                    }
                }, 
                ),
            ),
              ),
            ],
          )
        )
        
      ),
    );
  }
}