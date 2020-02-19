import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart';
import 'add2cart.dart';
import 'mycart.dart';
import 'package:progress_dialog/progress_dialog.dart';

class prodDescription extends StatefulWidget {
int counter;
final String email;
final DocumentSnapshot post;
final DocumentSnapshot userpost;
Map<String, double> map = Map<String, double>();
String tag;
prodDescription({this.post, this.email, this.counter, this.userpost, this.tag, this.map});
  @override
  _prodDescriptionState createState() => _prodDescriptionState();
}

class _prodDescriptionState extends State<prodDescription> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  double oplevel=0;
  int onpage=0;
  int counter;
  Timer _timer;
  int stock;
  int quantity=1;
  int rate1=0;
  int rate2=0;
  int rate3=0;
  int rate4=0;
  int rate5=0;
  int totalVotes=0;
  double userRate;
  double newUserRate=0;
  double totalRate=0;
  DocumentSnapshot data;
  StorageReference storageRef;
  ProgressDialog pr;
  
  Widget _shoppingCartBadge() {
    return Badge(
      position: BadgePosition.topRight(top: 0, right: 3),
      animationDuration: Duration(milliseconds: 300),
      animationType: BadgeAnimationType.slide,
      badgeContent: Text(
        counter.toString()!=null ? counter.toString() : "0",
        style: TextStyle(color: Colors.white),
      ),
      child: IconButton(icon: Icon(Icons.shopping_cart),       
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => mycart(userpost: widget.userpost, email: widget.userpost.documentID, counter: widget.counter,))),),
    );
  }

  Future deleteImage() async{
    storageRef = await FirebaseStorage.instance.getReferenceFromUrl(widget.post.data['imgurl']);
    await storageRef.delete();
  }

  Future updateRating() async{
    double oldRate=userRate;
    await giveRating(1);
    if(oldRate==newUserRate)
    {
      await Firestore.instance.collection('products').document(widget.post.documentID)
      .updateData({
        '${oldRate.toStringAsFixed(0)} Star': FieldValue.increment(-1)
      });
    }
    else{
      await Firestore.instance.collection('users/${widget.email}/Ratings').document(widget.post.documentID)
      .updateData({
        'Rate': newUserRate
      });
      await Firestore.instance.collection('products').document(widget.post.documentID)
      .updateData({
        '${oldRate.toStringAsFixed(0)} Star': FieldValue.increment(-1),
      });
    }
    await refreshRate();
  }
   
   Future getCartCount() async{
    QuerySnapshot _snap = await Firestore.instance.collection('/users/${widget.email}/Cart').getDocuments();
    List<DocumentSnapshot> _docCount = _snap.documents;
    setState(() {
      counter= _docCount.length;
    });
   }

   Future deleteItem() async{
     Navigator.pop(context);
     pr.show();
     await Firestore.instance.collection('products').document(widget.post.documentID).delete();
     await deleteImage();
     pr.hide();
     goBack(1);
   }

   Future getUserRating() async{
     await Firestore.instance.collection('/users/${widget.email}/Ratings').document(widget.post.documentID).get().then((DocumentSnapshot snap){
       
       if(snap.data!=null)
        setState(() {
          userRate=snap.data['Rate'];
        });
        else
        userRate=0;
     });
   }
  
   Future refreshRate() async{
     await Firestore.instance.collection('products').document(widget.post.documentID).get().then((DocumentSnapshot datasnap){
       setState(() {
        data=datasnap;
        stock=data.data['Stock'];
        rate1=data.data['1 Star'];
        rate2=data.data['2 Star'];
        rate3=data.data['3 Star'];
        rate4=data.data['4 Star'];
        rate5=data.data['5 Star'];
        totalVotes=rate1+rate2+rate3+rate4+rate5;
        totalVotes==0? totalRate=0 : totalRate=(1*rate1 + 2*rate2 + 3*rate3 + 4*rate4 + 5*rate5)/(totalVotes);
       });
     });
   }

   Widget showRate(){
     return Padding(
              padding: const EdgeInsets.only(left:90),
              child: Row(children: <Widget>[
                Text('Your rating: ${userRate.toStringAsFixed(0)}/5', style: TextStyle(color: Colors.white)),
                IconButton(icon: Icon(Icons.edit, color: Colors.grey, size: 22),onPressed: () => updateRating(),)
              ],)
    );
   }

   Widget rateButton(){
     return Padding(
              padding: const EdgeInsets.only(top:10, left:65),
              child: GestureDetector(
                onTap: () => giveRating(0),
                child: Container(
                  height: 30, width:100,
                  decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(20)),
                  child: Center(child: Text('Rate this item', style: TextStyle(color: Colors.white),))
                )
              ),
    );
   }

   Future setUserRating(int rate, int upd) async{
    Navigator.pop(context);
    int count;
    switch(rate){
      case 1: {
        count=rate1;
        break;
      }
      case 2: {
        count=rate2;
        break;
      }
      case 3: {
        count=rate3;
        break;
      }
      case 4: {
        count=rate4;
        break;
      }
      case 5: {
        count=rate5;
        break;
      }
      default: {
        count=0;
        break;
      }
    }
    if(rate!=0){
      await Firestore.instance.collection('products').document(widget.post.documentID)
      .updateData({
      '$rate Star': count+1,
      'Rate': upd==1? (((totalRate*(totalVotes-1))+rate)/(totalVotes)).round() : (((totalRate*totalVotes)+rate)/(totalVotes+1)).round()
    });
    await Firestore.instance.collection('users/${widget.email}/Ratings').document(widget.post.documentID)
    .setData({
      'Rate': newUserRate
    });
    refreshRate();
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Rating recorded!', 
    style: TextStyle(color: Colors.white)), 
    backgroundColor: Colors.green, 
    duration: Duration(milliseconds: 500),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)))));
    }
    userRate=newUserRate;
    setState(() {
    });
   }

   void addSnackBar() async{
     add2cart(widget.post, widget.email);
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Item added!", 
     style: TextStyle(color: Colors.white),), 
     backgroundColor: Colors.black, 
     duration: Duration(milliseconds: 1500),
     shape: RoundedRectangleBorder(
       borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)))));
     _timer = new Timer(const Duration(milliseconds: 800), () {
       getCartCount();
    }); 
     }

   void emptySnackBar(){
     _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Item is currently not in stock.", 
     style: TextStyle(color: Colors.white),), 
     backgroundColor: Colors.black, 
     duration: Duration(milliseconds: 1500),
     shape: RoundedRectangleBorder(
       borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)))));
   }

   warning(){
    return showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
          builder:(context, setState){
          return AlertDialog(
            title: Text('Warning!'),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Text('Confirm product deletion?'),
            actions: <Widget>[
              FlatButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(c, false),
              ),
              FlatButton(
                child: Text('Confirm'),
                onPressed: () => deleteItem(),
              )
            ],
          );
          }
      )
    );
   }
  

  @override
  void initState() { 
    super.initState();
    userRate=widget.map['${widget.post.documentID}']!=null? widget.map['${widget.post.documentID}'] : 0;
    data=widget.post;
    counter=widget.counter;
    stock=data.data['Stock'];
    rate1=data.data['1 Star'];
    rate2=data.data['2 Star'];
    rate3=data.data['3 Star'];
    rate4=data.data['4 Star'];
    rate5=data.data['5 Star'];
    totalVotes=rate1+rate2+rate3+rate4+rate5;
    totalVotes==0? totalRate=0 : totalRate=(1*rate1 + 2*rate2 + 3*rate3 + 4*rate4 + 5*rate5)/(totalVotes);
    _timer = new Timer(const Duration(milliseconds: 300), () {
      setState(() {
        oplevel=1;
      });
    });
  }
  
    @override
   void dispose(){
     super.dispose();
     _timer.cancel();
   }
  
   goBack(int val){
     setState(() {
       oplevel=0;
     });
     Navigator.pop(context, val);
   }

   Widget stars(double size, double rate, int count, Color color){
    return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(count, (val) {
              return Icon(
                val < rate? Icons.star : Icons.star_border,
                  color: color,
                    size: size,
              );
            }),
    );
   }

   Widget progress(int rate){
     double per = totalVotes==0? 0 : (rate*100)/totalVotes;
     return Padding(
      padding: EdgeInsets.only(top: 10, left:15),
      child: Row(
        children: <Widget>[
          LinearPercentIndicator(
            width: 220,
            percent: totalVotes==0? 0 :(rate/totalVotes),
            backgroundColor: Colors.grey,
            progressColor: Colors.grey[50],
          ),
          Text('${per.toStringAsFixed(0)}%', style: TextStyle(color: Colors.grey, fontSize: 12),)
        ],
      ),
    );
   }

  giveRating(int val){
    return showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
          builder:(context, setState){
          return AlertDialog(
          title: Row(
            children: <Widget>[
              Text('Select rating'),
              Padding(
                padding: const EdgeInsets.only(left:122),
                child: IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(c, false),),
              )
            ]
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
          content: Container(
            height: 40, width: 250,
            child: Column(
                children: <Widget>[
                Column(
                  children: <Widget>[
                    SmoothStarRating(
                      allowHalfRating: false,
                      onRatingChanged: (val){
                        setState((){
                           newUserRate = val;
                        });
                      },
                      starCount: 5,
                      rating: newUserRate,
                      size:35,
                      color: Color(0xFFe8b430),
                      borderColor: Color(0xFFe8b430),
                      spacing:1,
                    )
                  ],
                ),
              ],
            )
          ),
          actions: <Widget>[
            FlatButton( child: Text('Ok'), onPressed: () => setUserRating(newUserRate.toInt(), val)
            )
          ],
        );
        }
      )
    );
   }
   
  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(
          message: 'Deleting product...',
          borderRadius: 10.0,
          backgroundColor: Colors.white,
          progressWidget: CircularProgressIndicator(),
          elevation: 10.0,
          insetAnimCurve: Curves.easeInOut,
          progressTextStyle: TextStyle(
              color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
          messageTextStyle: TextStyle(
              color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
        ); 
    return WillPopScope(
          onWillPop: () => goBack(0),
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
                widget.userpost.data['Admin']==1? Container():
                counter>0 ? _shoppingCartBadge() : IconButton(icon: Icon(Icons.shopping_cart), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => mycart(userpost: widget.userpost, email: widget.post.documentID, counter: widget.counter,))))

              ],
              backgroundColor: Colors.black,
              leading: IconButton(icon: Icon(Icons.arrow_back,), highlightColor: Colors.white,onPressed: () => goBack(0)),
              title: Text(widget.post.data['ProdName'], style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))
            ),
            body: SingleChildScrollView(
                          child: Center(
                child: Column(children: <Widget>[
                  Hero(
                    tag: widget.tag.contains('card') ? 'card${widget.post.documentID}' : '${widget.post.documentID}',
                    child: Image.network(widget.post.data['imgurl'], height:300, width:300)
                  ),
                  Padding(padding: EdgeInsets.only(top:15),
                  child: Container(
                      width:380,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
                      color: Colors.black),
                      child:
                  AnimatedOpacity(
                    duration: Duration(milliseconds: 500),
                    opacity: oplevel,
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: <Widget>[
                        Padding(padding: const EdgeInsets.only(top:15, left:10, right:10),
                          child: Text(widget.post.data['Description'], style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 18))),
                        Padding(padding: const EdgeInsets.only(top:15, left:10),
                          child: Stack(
                            children: <Widget>[
                              Text('QR. ${widget.post.data['ProdCost'].toString()}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 34)),
                              Padding(padding: const EdgeInsets.only(left: 130.0, top:5),
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(left:90),
                                      child: stars(25,totalRate, 5, Color(0xFFe8b430)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left:65),
                                      child: Text('$totalVotes ratings', style: TextStyle(color: Colors.white)),
                                    ),
                                    widget.userpost.data['Admin']==1? Container() : userRate.toInt()==0? rateButton() : showRate(),
                                  ],
                                ),
                              ),
                            ],
                          )),
                        Padding(padding: const EdgeInsets.only(left:15),
                          child: Text(stock>0 ? ('In stock') : 'Out of stock!', style: TextStyle(color: stock>0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                        Padding(padding: const EdgeInsets.only(top:30, left:10, right:10),
                          child: Divider(height: 0.2, color: Colors.grey,)),
                        Padding(padding: const EdgeInsets.only(top:35, left:10),
                          child: Text('Rating:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 23))),
                        Padding(padding: const EdgeInsets.only(top:10, left:10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(totalVotes==0? 'None': totalRate.toStringAsFixed(1), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 34)),
                              Text(totalVotes==0? '' : 'out of 5', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 16)),
                            ],
                          )),
                        Padding(padding: const EdgeInsets.only(top: 10, left:5),
                          child: Column(
                            children: <Widget>[
                              Row(children: <Widget>[Padding(
                                padding: const EdgeInsets.only(left:15),
                                child: stars(15,5,5,Colors.white),
                              ), progress(rate5)],),
                              Row(children: <Widget>[Padding(
                                padding: const EdgeInsets.only(left:30),
                                child: stars(15,4,4,Colors.white),
                              ), progress(rate4)],),
                              Row(children: <Widget>[Padding(
                                padding: const EdgeInsets.only(left:45),
                                child: stars(15,3,3,Colors.white),
                              ), progress(rate3)],),
                              Row(children: <Widget>[Padding(
                                padding: const EdgeInsets.only(left:60),
                                child: stars(15,2,2,Colors.white),
                              ), progress(rate2)],),
                              Row(children: <Widget>[Padding(
                                padding: const EdgeInsets.only(left:75),
                                child: stars(15,1,1,Colors.white),
                              ), progress(rate1)],),
                           ],
                          )
                        ),
                        Padding(padding: const EdgeInsets.only(bottom:20),)
                      ]),
                 )
                 )),
               Padding(
                  padding: const EdgeInsets.only(top: 30, bottom:20),
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    width:260,
                    height:60,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                        splashColor: Colors.grey,
                          onTap: () => widget.userpost.data['Admin']==1? warning() : stock>0 ? addSnackBar(): emptySnackBar(),
                          child: Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              color: widget.userpost.data['Admin']==1? Colors.red : stock>0 ? Colors.green : Colors.orange,
                              child: Center(child: Text(widget.userpost.data['Admin']==1? 'Delete Product' : stock>0 ? 'Add To Cart' : 'Check back later', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26),))
                          ),
                    ),
                  ),
               )
              ],
              ),
            ),
          )
        )
      ),
    );
  }
}