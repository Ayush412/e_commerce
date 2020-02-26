import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/products.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart';
import 'add2cart.dart';
import 'mycart.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:date_format/date_format.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class prodDescription extends StatefulWidget {
  int counter;
  final String email;
  final DocumentSnapshot post;
  final DocumentSnapshot userpost;
  Map<String, double> map = Map<String, double>();
  List<String> list = List<String>();
  String tag;
  prodDescription(
      {this.post,
      this.email,
      this.counter,
      this.userpost,
      this.tag,
      this.map,
      this.list});
  @override
  _prodDescriptionState createState() => _prodDescriptionState();
}

class _prodDescriptionState extends State<prodDescription> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int onpage = 0;
  int counter;
  int stock;
  int quantity = 1;
  int rate1 = 0;
  int rate2 = 0;
  int rate3 = 0;
  int rate4 = 0;
  int rate5 = 0;
  int totalVotes = 0;
  int views = 0;
  int year = 0;
  int month = 0;
  int day = 0;
  double oplevel = 0;
  double userRate;
  double newUserRate = 0;
  double totalRate = 0;
  DocumentSnapshot data;
  StorageReference storageRef;
  ProgressDialog pr;
  TextEditingController stockController = TextEditingController();
  TextEditingController costController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();
  FocusNode node1 = FocusNode();
  FocusNode node2 = FocusNode();
  FocusNode node3 = FocusNode();
  FocusNode node4 = FocusNode();
  Timer _timer;
  bool editOK = true;
  bool changed = false;
  bool graph;
  String name;
  String cost;
  String desc;
  String url;
  String key;
  String date;
  var value;
  var keys;
  List<charts.Series<ProductData, String>> series;
  List<double> visitCount = List<double>();
  List<double> addCount = List<double>();
  List<String> test = List<String>();
  List<String> labels = List<String>();
  List<ProductData> productData = List<ProductData>();
  File imageFile;
  Map<dynamic, dynamic> myMap = Map<dynamic, dynamic>();

  @override
  void initState() {
    super.initState();
    date = formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd]);
    graph=false;
    visitCount = [];
    addCount = [];
    keys = [];
    productData = [];
    getViewsAndAdds();
    userRate = widget.map['${widget.post.documentID}'] != null
        ? widget.map['${widget.post.documentID}']
        : 0;
    data = widget.post;
    counter = widget.counter;
    stock = data.data['Stock'];
    rate1 = data.data['1 Star'];
    rate2 = data.data['2 Star'];
    rate3 = data.data['3 Star'];
    rate4 = data.data['4 Star'];
    rate5 = data.data['5 Star'];
    views = data.data['Views'];
    url = data.data['imgurl'];
    totalVotes = rate1 + rate2 + rate3 + rate4 + rate5;
    totalVotes == 0
        ? totalRate = 0
        : totalRate =
            (1 * rate1 + 2 * rate2 + 3 * rate3 + 4 * rate4 + 5 * rate5) /
                (totalVotes);
    name = data.data['ProdName'];
    cost = data.data['ProdCost'].toString();
    desc = data.data['Description'];
    nameController.text = name;
    stockController.text = stock.toString();
    costController.text = cost;
    descController.text = desc;
    if (!widget.list.contains(widget.post.documentID) &&
        widget.userpost.data['Admin'] != 1) addView();
    _timer = new Timer(const Duration(milliseconds: 300), () {
      setState(() {
        oplevel = 1;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  Future getViewsAndAdds() async {
    setState(() {
      graph=false;
    });
    DocumentSnapshot ds = await Firestore.instance
        .collection('views')
        .document(widget.post.documentID)
        .get();
    if (ds.data == null) {
      myMap[date] = [0, 0];
      addViewsAndPurchases(0);
    } else {
      myMap = ds.data['Map'];
      if (myMap[date] == null) {
        myMap[date] = [0, 0];
        addViewsAndPurchases(1);
      }
    }
    if (widget.userpost.data['Admin'] != 1) {
      myMap[date][0] += 1;
      addViewsAndPurchases(1);
    }
    keys = myMap.keys.toList()..sort();
    for (int i = 0; i < keys.length; i++) {
      visitCount.add((myMap[keys[i]][0]).toDouble());
      addCount.add((myMap[keys[i]][1]).toDouble());
      year =
          int.parse(formatDate(DateTime.parse('${keys[i]} 00:00:00'), [yyyy]));
      month =
          int.parse(formatDate(DateTime.parse('${keys[i]} 00:00:00'), [mm]));
      day = int.parse(formatDate(DateTime.parse('${keys[i]} 00:00:00'), [dd]));
      labels.add(
          (formatDate(DateTime.parse('${keys[i]} 00:00:00'), [dd, ' ', M, yy]))
              .toString());
      productData.add(ProductData(labels[i], visitCount[i], addCount[i]));
    }
    series = [
      charts.Series(
          id: 'Views',
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (ProductData visits, _) => visits.date,
          measureFn: (ProductData visits, _) => visits.visits,
          data: productData),
      charts.Series(
          id: 'Purchases',
          colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
          domainFn: (ProductData adds, _) => adds.date,
          measureFn: (ProductData adds, _) => adds.adds,
          data: productData),
    ];
    setState(() {
      graph=true;
    });
  }

  Future addViewsAndPurchases(int val) async {
    if (val == 1) {
      await Firestore.instance
          .collection('views')
          .document(widget.post.documentID)
          .updateData({'Map': myMap});
    } else {
      await Firestore.instance
          .collection('views')
          .document(widget.post.documentID)
          .setData({'Map': myMap});
    }
  }

  Future getImage() async {
    File newFile;
    newFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (newFile != null) imageFile = newFile;
    setState(() {});
  }

  Future putImage() async {
    storageRef = FirebaseStorage.instance.ref().child(
        'product images/$name ${Random().nextInt(10000)}-${Random().nextInt(10000)}-$cost.jpg');
    StorageUploadTask upload = storageRef.putFile(imageFile);
    StorageTaskSnapshot downloadUrl = await upload.onComplete;
    url = await downloadUrl.ref.getDownloadURL();
  }

  Widget _shoppingCartBadge() {
    return Badge(
      position: BadgePosition.topRight(top: 0, right: 3),
      animationDuration: Duration(milliseconds: 300),
      animationType: BadgeAnimationType.slide,
      badgeContent: Text(
        counter.toString() != null ? counter.toString() : "0",
        style: TextStyle(color: Colors.white),
      ),
      child: IconButton(
        icon: Icon(Icons.shopping_cart),
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => mycart(
                      userpost: widget.userpost,
                      email: widget.userpost.documentID,
                      counter: widget.counter,
                    ))),
      ),
    );
  }

  Future deleteImage() async {
    storageRef = await FirebaseStorage.instance.getReferenceFromUrl(url);
    await storageRef.delete();
  }

  Future addView() async {
    await Firestore.instance
        .collection('users/${widget.email}/Visited')
        .document(widget.post.documentID)
        .setData({});
    await Firestore.instance
        .collection('products')
        .document(widget.post.documentID)
        .updateData({'Views': FieldValue.increment(1)});
  }

  Future updateRating() async {
    double oldRate = userRate;
    await giveRating(1);
    if (oldRate == newUserRate) {
      await Firestore.instance
          .collection('products')
          .document(widget.post.documentID)
          .updateData(
              {'${oldRate.toStringAsFixed(0)} Star': FieldValue.increment(-1)});
    } else {
      await Firestore.instance
          .collection('users/${widget.email}/Visited')
          .document(widget.post.documentID)
          .updateData({'Rate': newUserRate});
      await Firestore.instance
          .collection('products')
          .document(widget.post.documentID)
          .updateData({
        '${oldRate.toStringAsFixed(0)} Star': FieldValue.increment(-1),
      });
    }
    await refreshRate();
  }

  Future getCartCount() async {
    QuerySnapshot _snap = await Firestore.instance
        .collection('/users/${widget.email}/Cart')
        .getDocuments();
    List<DocumentSnapshot> _docCount = _snap.documents;
    setState(() {
      counter = _docCount.length;
    });
  }

  Future deleteItem() async {
    Navigator.pop(context);
    pr.show();
    await Firestore.instance
        .collection('products')
        .document(widget.post.documentID)
        .delete();
    await deleteImage();
    pr.hide();
    goBack(1);
  }

  Future getUserRating() async {
    await Firestore.instance
        .collection('/users/${widget.email}/Visited')
        .document(widget.post.documentID)
        .get()
        .then((DocumentSnapshot snap) {
      if (snap.data != null)
        setState(() {
          userRate = snap.data['Rate'];
        });
      else
        userRate = 0;
    });
  }

  Future refreshRate() async {
    await Firestore.instance
        .collection('products')
        .document(widget.post.documentID)
        .get()
        .then((DocumentSnapshot datasnap) {
      setState(() {
        data = datasnap;
        stock = data.data['Stock'];
        rate1 = data.data['1 Star'];
        rate2 = data.data['2 Star'];
        rate3 = data.data['3 Star'];
        rate4 = data.data['4 Star'];
        rate5 = data.data['5 Star'];
        views = data.data['Views'];
        totalVotes = rate1 + rate2 + rate3 + rate4 + rate5;
        totalVotes == 0
            ? totalRate = 0
            : totalRate =
                (1 * rate1 + 2 * rate2 + 3 * rate3 + 4 * rate4 + 5 * rate5) /
                    (totalVotes);
        name = data.data['ProdName'];
        cost = data.data['ProdCost'].toString();
        desc = data.data['Description'];
        url = data.data['imgurl'].toString();
        nameController.text = name;
        stockController.text = stock.toString();
        costController.text = cost;
        descController.text = desc;
        editOK = true;
        imageFile = null;
      });
    });
  }

  Widget showRate() {
    return Padding(
        padding: const EdgeInsets.only(left: 90),
        child: Row(
          children: <Widget>[
            Text('Your rating: ${userRate.toStringAsFixed(0)}/5',
                style: TextStyle(color: Colors.white)),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.grey, size: 22),
              onPressed: () => updateRating(),
            )
          ],
        ));
  }

  Widget rateButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 65),
      child: GestureDetector(
          onTap: () => giveRating(0),
          child: Container(
              height: 30,
              width: 100,
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(20)),
              child: Center(
                  child: Text(
                'Rate this item',
                style: TextStyle(color: Colors.white),
              )))),
    );
  }

  Future setUserRating(int rate, int upd) async {
    Navigator.pop(context);
    int count;
    switch (rate) {
      case 1:
        {
          count = rate1;
          break;
        }
      case 2:
        {
          count = rate2;
          break;
        }
      case 3:
        {
          count = rate3;
          break;
        }
      case 4:
        {
          count = rate4;
          break;
        }
      case 5:
        {
          count = rate5;
          break;
        }
      default:
        {
          count = 0;
          break;
        }
    }
    if (rate != 0) {
      await Firestore.instance
          .collection('products')
          .document(widget.post.documentID)
          .updateData({
        '$rate Star': count + 1,
        'Rate': upd == 1
            ? (((totalRate * (totalVotes - 1)) + rate) / (totalVotes)).round()
            : (((totalRate * totalVotes) + rate) / (totalVotes + 1)).round()
      });
      await Firestore.instance
          .collection('users/${widget.email}/Visited')
          .document(widget.post.documentID)
          .setData({'Rate': newUserRate});
      refreshRate();
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content:
              Text('Rating recorded!', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
          duration: Duration(milliseconds: 500),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30)))));
    }
    userRate = newUserRate;
    setState(() {});
  }

  Future changeData() async {
    FocusScope.of(context).requestFocus(new FocusNode());
    Navigator.pop(context);
    Navigator.pop(context);
    changed = true;
    pr.show();
    if (imageFile != null) {
      await deleteImage();
      await putImage();
    }
    await Firestore.instance
        .collection('products')
        .document(widget.post.documentID)
        .updateData({
      'ProdName': nameController.text,
      'ProdCost': int.parse(costController.text),
      'Stock': int.parse(stockController.text),
      'Description': descController.text,
      'imgurl': url
    });
    setState(() {
      name = nameController.text;
      desc = descController.text;
      cost = costController.text;
      stock = int.parse(stockController.text);
    });
    refreshRate();
    pr.hide();
    addSnackBar('Changes saved!', 0);
  }

  void addSnackBar(String text, int val) async {
    if(val==1){
      add2cart(widget.post, widget.email);
      myMap[date][1] += 1;
      addViewsAndPurchases(1);
       _timer = new Timer(const Duration(milliseconds: 800), () {
      getCartCount();
    });
    }
    _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: Duration(milliseconds: 1500),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30)))));
  }

  void emptySnackBar() {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
          "Item is currently not in stock.",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        duration: Duration(milliseconds: 1500),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30)))));
  }

  warning() {
    return showDialog(
        context: context,
        builder: (c) => StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
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
            }));
  }

  goBack(int val) {
    setState(() {
      oplevel = 0;
    });
    if (changed)
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => listPage(post: widget.userpost)));
    else
      Navigator.pop(context, val);
  }

  Widget stars(double size, double rate, int count, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(count, (val) {
        return Icon(
          val < rate ? Icons.star : Icons.star_border,
          color: color,
          size: size,
        );
      }),
    );
  }

  Widget progress(int rate) {
    double per = totalVotes == 0 ? 0 : (rate * 100) / totalVotes;
    return Padding(
      padding: EdgeInsets.only(top: 10, left: 15),
      child: Row(
        children: <Widget>[
          LinearPercentIndicator(
            width: 220,
            percent: totalVotes == 0 ? 0 : (rate / totalVotes),
            backgroundColor: Colors.grey,
            progressColor: Colors.grey[50],
          ),
          Text(
            '${per.toStringAsFixed(0)}%',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          )
        ],
      ),
    );
  }

  giveRating(int val) {
    return showDialog(
        context: context,
        builder: (c) => StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                title: Row(children: <Widget>[
                  Text('Select rating'),
                  Padding(
                    padding: const EdgeInsets.only(left: 122),
                    child: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(c, false),
                    ),
                  )
                ]),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                content: Container(
                    height: 40,
                    width: 250,
                    child: Column(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            SmoothStarRating(
                              allowHalfRating: false,
                              onRatingChanged: (val) {
                                setState(() {
                                  newUserRate = val;
                                });
                              },
                              starCount: 5,
                              rating: newUserRate,
                              size: 35,
                              color: Color(0xFFe8b430),
                              borderColor: Color(0xFFe8b430),
                              spacing: 1,
                            )
                          ],
                        ),
                      ],
                    )),
                actions: <Widget>[
                  FlatButton(
                      child: Text('Ok'),
                      onPressed: () => setUserRating(newUserRate.toInt(), val))
                ],
              );
            }));
  }

  validate(TextEditingController controller) {
    if (controller.text.isEmpty)
      return "Can't be blank";
    else
      return null;
  }

  Widget textField(FocusNode node, TextEditingController controller,
      IconData icon, String label, TextInputType type, con) {
    return StatefulBuilder(builder: (con, setState) {
      return Padding(
          padding: const EdgeInsets.only(top: 25),
          child: Theme(
              data: ThemeData(primaryColor: Colors.black),
              child: TextField(
                maxLines: null,
                focusNode: node,
                keyboardType: type,
                controller: controller,
                autofocus: false,
                onChanged: (value) {
                  setState(() {
                    if (controller.text.isEmpty)
                      editOK = false;
                    else
                      editOK = true;
                  });
                },
                decoration: InputDecoration(
                  errorText: validate(controller),
                  labelText: label,
                  prefixIcon: Icon(
                    icon,
                    color: Colors.black,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                ),
              )));
    });
  }

  checkForChange(int val) {
    if (nameController.text != data.data['ProdName'] ||
        costController.text != data.data['ProdCost'].toString() ||
        stockController.text != data.data['Stock'].toString() ||
        descController.text != data.data['Description'] ||
        imageFile != null) {
      if (val == 0)
        return showDialog(
            context: context,
            builder: (c) => StatefulBuilder(builder: (context, setState) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    content: Text('Discard all changes?'),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.pop(c, false),
                      ),
                      FlatButton(
                        child: Text('Confirm'),
                        onPressed: () {
                          editOK = true;
                          Navigator.pop(c, false);
                          Navigator.pop(context);
                        },
                      )
                    ],
                  );
                }));
      else
        return showDialog(
            context: context,
            builder: (c) => StatefulBuilder(builder: (context, setState) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    content: Text('Confirm changes'),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.pop(c, false),
                      ),
                      FlatButton(
                          child: Text('Confirm'), onPressed: () => changeData())
                    ],
                  );
                }));
    } else
      Navigator.pop(context);
  }

  editData() {
    nameController = TextEditingController(text: data.data['ProdName']);
    stockController = TextEditingController(text: stock.toString());
    costController =
        TextEditingController(text: data.data['ProdCost'].toString());
    descController =
        TextEditingController(text: data.data['Description'].toString());
    imageFile = null;
    url = data.data['imgurl'];
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                  title: Text('Edit details'),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  content: Container(
                    height: 450,
                    child: SingleChildScrollView(
                      child: Material(
                        child: Container(
                          color: Colors.white,
                          child: Column(
                            children: <Widget>[
                              textField(node1, nameController, Icons.loyalty,
                                  'Name', TextInputType.text, context),
                              textField(
                                  node2,
                                  costController,
                                  Icons.local_offer,
                                  'Cost',
                                  TextInputType.number,
                                  context),
                              textField(node3, stockController, Icons.plus_one,
                                  'Stock', TextInputType.number, context),
                              textField(
                                  node4,
                                  descController,
                                  Icons.short_text,
                                  'Description',
                                  TextInputType.multiline,
                                  context),
                              Padding(
                                padding: const EdgeInsets.only(top: 25),
                                child: Column(
                                  children: <Widget>[
                                    imageFile == null
                                        ? Image.network(url,
                                            height: 200, width: 200)
                                        : Container(
                                            height: 200,
                                            width: 200,
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: FileImage(imageFile),
                                                    fit: BoxFit.contain))),
                                    Padding(
                                        padding: const EdgeInsets.only(top: 20),
                                        child: GestureDetector(
                                          onTap: () async {
                                            await getImage();
                                            setState(() {});
                                          },
                                          child: Container(
                                              height: 35,
                                              width: 110,
                                              decoration: BoxDecoration(
                                                  color: Colors.blue,
                                                  borderRadius:
                                                      BorderRadiusDirectional
                                                          .circular(15)),
                                              child: Center(
                                                  child: Text(
                                                'Change Image',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w900),
                                              ))),
                                        ))
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Cancel'),
                      onPressed: () => checkForChange(0),
                    ),
                    FlatButton(
                        child: Text('Confirm'),
                        onPressed: () => editOK ? checkForChange(1) : null)
                  ]);
            }));
  }

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(
      message: 'Please Wait...',
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
              key: _scaffoldKey,
              backgroundColor: Colors.white,
              appBar: AppBar(
                  centerTitle: true,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(25))),
                  toolbarOpacity: 0.5,
                  elevation: 0,
                  actions: <Widget>[
                    widget.userpost.data['Admin'] == 1
                        ? Container()
                        : counter > 0
                            ? _shoppingCartBadge()
                            : IconButton(
                                icon: Icon(Icons.shopping_cart),
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => mycart(
                                              userpost: widget.userpost,
                                              email: widget.post.documentID,
                                              counter: widget.counter,
                                            )))),
                    widget.userpost.data['Admin'] == 1
                        ? IconButton(
                            onPressed: () => editData(),
                            icon: Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                          )
                        : Container()
                  ],
                  backgroundColor: Colors.black,
                  leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                      ),
                      highlightColor: Colors.white,
                      onPressed: () => goBack(0)),
                  title: Text(name,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white))),
              body: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 25, bottom: 10),
                        child: Hero(
                            tag: widget.tag.contains('card')
                                ? 'card${widget.post.documentID}'
                                : '${widget.post.documentID}',
                            child: Image.network(url, height: 300, width: 300)),
                      ),
                      AnimatedOpacity(
                        duration: Duration(milliseconds: 500),
                        opacity: oplevel,
                        child: Container(
                          height: 30,
                          child: Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 15),
                                child: Container(
                                  height: 25,
                                  decoration: BoxDecoration(
                                      color: Color(0xffffc966),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10, top: 3),
                                    child: Text(
                                        views == null
                                            ? 'No views'
                                            : views == 1
                                                ? "$views view"
                                                : '$views views',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black)),
                                  ),
                                ),
                              )),
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: Container(
                              width: 380,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.black),
                              child: AnimatedOpacity(
                                duration: Duration(milliseconds: 500),
                                opacity: oplevel,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                          padding: const EdgeInsets.only(
                                              top: 15, left: 10, right: 10),
                                          child: Text(desc,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 18))),
                                      Padding(
                                          padding: const EdgeInsets.only(
                                              top: 15, left: 10),
                                          child: Stack(
                                            children: <Widget>[
                                              Text('QR. $cost',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 34)),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 130.0, top: 5),
                                                child: Column(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 90),
                                                      child: stars(
                                                          25,
                                                          totalRate,
                                                          5,
                                                          Color(0xFFe8b430)),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 65),
                                                      child: Text(
                                                          '$totalVotes ratings',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white)),
                                                    ),
                                                    widget.userpost.data[
                                                                'Admin'] ==
                                                            1
                                                        ? Container()
                                                        : userRate.toInt() == 0
                                                            ? rateButton()
                                                            : showRate(),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 15),
                                        child: Text(
                                            stock > 0
                                                ? 'In stock'
                                                : 'Out of stock!',
                                            style: TextStyle(
                                                color: stock > 0
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18)),
                                      ),
                                      widget.userpost.data['Admin'] == 1
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15, top: 10),
                                              child: Row(
                                                children: <Widget>[
                                                  Text('Stock : $stock',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 19)),
                                                ],
                                              ))
                                          : Container(),
                                      Padding(
                                          padding: const EdgeInsets.only(
                                              top: 30, left: 10, right: 10),
                                          child: Divider(
                                            height: 0.2,
                                            color: Colors.grey,
                                          )),
                                      Padding(
                                          padding: const EdgeInsets.only(
                                              top: 35, left: 10),
                                          child: Text('Rating:',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 23))),
                                      Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10, left: 10),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                  totalVotes == 0
                                                      ? 'None'
                                                      : totalRate
                                                          .toStringAsFixed(1),
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 34)),
                                              Text(
                                                  totalVotes == 0
                                                      ? ''
                                                      : 'out of 5',
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 16)),
                                            ],
                                          )),
                                      Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10, left: 5),
                                          child: Column(
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 15),
                                                    child: stars(
                                                        15, 5, 5, Colors.white),
                                                  ),
                                                  progress(rate5)
                                                ],
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 30),
                                                    child: stars(
                                                        15, 4, 4, Colors.white),
                                                  ),
                                                  progress(rate4)
                                                ],
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 45),
                                                    child: stars(
                                                        15, 3, 3, Colors.white),
                                                  ),
                                                  progress(rate3)
                                                ],
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 60),
                                                    child: stars(
                                                        15, 2, 2, Colors.white),
                                                  ),
                                                  progress(rate2)
                                                ],
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 75),
                                                    child: stars(
                                                        15, 1, 1, Colors.white),
                                                  ),
                                                  progress(rate1)
                                                ],
                                              ),
                                            ],
                                          )),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 20),
                                      )
                                    ]),
                              ))),
                      widget.userpost.data['Admin'] == 1
                          ? Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Container(
                                  width:
                                      MediaQuery.of(context).size.width / 1.05,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      gradient: LinearGradient(colors: [
                                        Color(0xffddd6f3),
                                        Color(0xfffaaca8)
                                      ])),
                                  child: Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 20, bottom: 20),
                                        child: Container(
                                            height: 40,
                                            width: 300,
                                            decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child: Center(
                                                child: Text(
                                                    'Views and Purchase Analysis',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    )))),
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.only(
                                              top: 20, bottom: 20),
                                          child: Container(
                                              height: 200,
                                              width: 340,
                                              child: graph? charts.OrdinalComboChart(
                                                  series,
                                                  animate: false,
                                                  primaryMeasureAxis: new charts.NumericAxisSpec(
                                                    renderSpec: new charts.GridlineRendererSpec(
                                                      labelStyle: new charts.TextStyleSpec(
                                                        fontSize: 15, 
                                                        color: charts.MaterialPalette.black
                                                      ),
                                                      lineStyle: new charts.LineStyleSpec(
                                                      color: charts.MaterialPalette.white)
                                                    )
                                                  ),
                                                  domainAxis: new charts.OrdinalAxisSpec(
                                                    renderSpec: charts.SmallTickRendererSpec(
                                                    labelStyle: new charts.TextStyleSpec(
                                                        fontSize: 15,
                                                        
                                                        color: charts.MaterialPalette.black),
                                                    lineStyle: new charts.LineStyleSpec(
                                                        color: charts.MaterialPalette.black)),
                                                    viewport: new charts.OrdinalViewport(labels[labels.length-1], 4),
                                                  ),
                                                  behaviors: [
                                                    charts.SlidingViewport(),
                                                    charts.PanAndZoomBehavior(),
                                                    charts.SeriesLegend()
                                                  ],
                                                  defaultRenderer:
                                                      charts.LineRendererConfig(
                                                          customRendererId:
                                                              'customLine'
                                                      )
                                              ) : Container(height: 30, width:30, child: CircularProgressIndicator())
                                          )
                                      ),
                                    ],
                                  )))
                          : Container(),
                      Padding(
                        padding: const EdgeInsets.only(top: 30, bottom: 20),
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          width: 260,
                          height: 60,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(30),
                            splashColor: Colors.grey,
                            onTap: () => widget.userpost.data['Admin'] == 1
                                ? warning()
                                : stock > 0
                                    ? addSnackBar('Item added!', 1)
                                    : emptySnackBar(),
                            child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                color: widget.userpost.data['Admin'] == 1
                                    ? Colors.red
                                    : stock > 0 ? Colors.green : Colors.orange,
                                child: Center(
                                    child: Text(
                                  widget.userpost.data['Admin'] == 1
                                      ? 'Delete Product'
                                      : stock > 0
                                          ? 'Add To Cart'
                                          : 'Check back later',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 26),
                                ))),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ))),
    );
  }
}

class ProductData {
  String date;
  double visits;
  double adds;
  ProductData(this.date, this.visits, this.adds);
}
