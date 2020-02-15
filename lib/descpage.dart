import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart';
import 'add2cart.dart';
import 'mycart.dart';

class prodDescription extends StatefulWidget {
int counter;
final String email;
final DocumentSnapshot post;
final DocumentSnapshot userpost;
String tag;
prodDescription({this.post, this.email, this.counter, this.userpost, this.tag});

  @override
  _prodDescriptionState createState() => _prodDescriptionState();
}

class _prodDescriptionState extends State<prodDescription> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  double oplevel=0;
  int onpage=0;
  Timer _timer;
  int stock;
  int quantity=1;
  Widget _shoppingCartBadge() {
    return Badge(
      position: BadgePosition.topRight(top: 0, right: 3),
      animationDuration: Duration(milliseconds: 300),
      animationType: BadgeAnimationType.slide,
      badgeContent: Text(
        widget.counter.toString()!=null ? widget.counter.toString() : "0",
        style: TextStyle(color: Colors.white),
      ),
      child: IconButton(icon: Icon(Icons.shopping_cart),       
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => mycart(userpost: widget.userpost, email: widget.userpost.documentID))),),
    );
  }
   
   Future getCartCount() async{
    QuerySnapshot _snap = await Firestore.instance.collection('/users/${widget.email}/Cart').getDocuments();
    List<DocumentSnapshot> _docCount = _snap.documents;
    setState(() {
      widget.counter= _docCount.length;
    });
   }

   void addSnackBar(){
     add2cart(widget.post, widget.email);
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Item added!", 
     style: TextStyle(color: Colors.white),), 
     backgroundColor: Colors.black, 
     duration: Duration(milliseconds: 1500),
     shape: RoundedRectangleBorder(
       borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)))));
     }

   void emptySnackBar(){
     _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Item is currently not in stock.", 
     style: TextStyle(color: Colors.white),), 
     backgroundColor: Colors.black, 
     duration: Duration(milliseconds: 1500),
     shape: RoundedRectangleBorder(
       borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)))));
   }
  

  @override
  void initState() { 
    super.initState();
    stock=widget.post.data['Stock'];
    _timer = new Timer(const Duration(milliseconds: 300), () {
      setState(() {
        oplevel=1;
      });
      getCartCount();
    });
  }
    @override
   void dispose(){
     super.dispose();
     _timer.cancel();
   }

   goBack(){
     setState(() {
       oplevel=0;
     });
     Navigator.pop(context);
   }
   
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
          onWillPop: () => goBack(),
          child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            key:_scaffoldKey,
            backgroundColor: Colors.white,
            appBar: AppBar(
              centerTitle: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(25))),
              toolbarOpacity: 0.5,
              elevation: 0,
              actions: <Widget>[
                widget.counter>0 ? _shoppingCartBadge() : IconButton(icon: Icon(Icons.shopping_cart), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => mycart(userpost: widget.userpost, email: widget.post.documentID))))

              ],
              backgroundColor: Colors.black,
              leading: IconButton(icon: Icon(Icons.arrow_back,), highlightColor: Colors.white,onPressed: () => goBack()),
              title: Text(widget.post.data['ProdName'], style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))
            ),
            body: Center(
              child: Column(children: <Widget>[
                Hero(
                  tag: widget.tag.contains('card') ? 'card${widget.post.documentID}' : '${widget.post.documentID}',
                  child: Image.network(widget.post.data['imgurl'], height:300, width:300)
                ),
                Padding(padding: EdgeInsets.only(top:15),
                child: Container(
                    height: 200,
                    width:380,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
                    color: Colors.black),
                    child:
                AnimatedOpacity(
                  duration: Duration(milliseconds: 500),
                  opacity: oplevel,
                   child: Column(children: <Widget>[
                   Padding(padding: EdgeInsets.only(top:18),
                                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (val) {
                          return Icon(
                          val < widget.post.data['Rate'] ? Icons.star : Icons.star_border,
                          color: Colors.white,
                          );
                          }),
                        ),
                   ),
                Padding(padding: const EdgeInsets.only(top:15, bottom: 8),
                child: Text('Category: ${widget.post.data['Category']}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
                Padding(padding: const EdgeInsets.all(8),
                child: Text('Product: ${widget.post.data['ProdName']}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
                Padding(padding: const EdgeInsets.all(8),
                child: Text('Cost: QR. ${widget.post.data['ProdCost'].toString()}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
                Padding(padding: const EdgeInsets.only(top: 5),
                child: Text(stock>0 ? ('In stock') : 'Out of stock!', style: TextStyle(color: stock>0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 18))),
                    ]),
                  )
              )),
              Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Container(
                          alignment: Alignment.bottomCenter,
                          width:260,
                          height:60,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(30),
                            splashColor: Colors.grey,
                            onTap: () => stock>0 ? addSnackBar(): emptySnackBar(),
                            child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          color: stock>0 ? Colors.green : Colors.orange,
                          child: Center(child: Text(stock>0 ? 'Add To Cart' : 'Check back later', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26),))
                      ),
                        ),
                    ),
              )
              ],
              ),
            )
          )
      ),
    );
  }
}