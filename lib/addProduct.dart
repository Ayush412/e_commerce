import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'products.dart';

class addProduct extends StatefulWidget {
  DocumentSnapshot post;
  addProduct({this.post});
  @override
  _addProductState createState() => _addProductState();
}

class _addProductState extends State<addProduct> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController prodNameController = TextEditingController();
  TextEditingController prodCostController = TextEditingController();
  TextEditingController prodCategoryController = TextEditingController();
  TextEditingController prodSubCategoryController = TextEditingController();
  TextEditingController prodStockController = TextEditingController();
  TextEditingController prodDescriptionController = TextEditingController();
  TextEditingController imageLabelController = TextEditingController();
  FocusNode node1 = FocusNode();
  FocusNode node2 = FocusNode();
  FocusNode node3 = FocusNode();
  FocusNode node4 = FocusNode();
  FocusNode node5 = FocusNode();
  FocusNode node6 = FocusNode();
  FocusNode node7 = FocusNode();
  String url;
  String desc='';
  bool visible=false;
  bool added=false;
  File imageFile;
  StorageReference storageRef;
  List<String> myList = List<String>();
  ProgressDialog pr;
  Timer _timer;

  goBack(int val){
    int change;
    if(added)
      change=1;
    if(val==1)
      Navigator.pop(context, change);
    Navigator.push(context, MaterialPageRoute(builder: (context) => listPage(post: widget.post,)));
  }

  Future getImage() async{
    File newFile;
    newFile =  await ImagePicker.pickImage(source: ImageSource.gallery);
    if(newFile!=null)
      imageFile=newFile;
    setState(() {});
  }

  Future putImage() async{
    storageRef = FirebaseStorage.instance.ref().child('product images/${prodNameController.text} ${Random().nextInt(10000)}-${Random().nextInt(10000)}-${prodCostController.text}.jpg');
    StorageUploadTask upload = storageRef.putFile(imageFile);
    StorageTaskSnapshot downloadUrl = await upload.onComplete;
    url = await downloadUrl.ref.getDownloadURL();
  }

  checkDetails(){
    if (prodDescriptionController.text!='' && prodCategoryController.text!='' && prodSubCategoryController.text!='' && prodCostController.text!='' && prodStockController.text!='' && prodDescriptionController.text!='' && imageFile!=null && myList.isNotEmpty)
    dialog("Add this product to database?", 1);
    else
    snack('All fields are required.', Colors.black, Colors.orange);
  }

  Future addProductDetails() async{
    Navigator.pop(context);
    pr.show();
    added=true;
    await putImage();
    await Firestore.instance.collection('products').document()
    .setData({
      '1 Star': 0,
      '2 Star': 0,
      '3 Star': 0,
      '4 Star': 0,
      '5 Star': 0,
      'Rate': 0,
      'ProdName': prodNameController.text,
      'Category': prodCategoryController.text,
      'SubCategory': prodSubCategoryController.text,
      'Stock': int.parse(prodStockController.text),
      'ProdCost': int.parse(prodCostController.text),
      'Description': prodDescriptionController.text,
      'imgurl': url,
      'notifUrl': url,
      'scan': myList
    });
    clearAll();
    pr.hide();
    snack('Product added!', Colors.white, Colors.green );
  }

  snack(String text, Color colorText, Color colorBack){
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(text, 
      style: TextStyle(color: colorText)), 
      backgroundColor: colorBack, 
      duration: Duration(milliseconds: 1500),
      shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)))));
  }

  Widget textField(String text, FocusNode node, TextEditingController controller, TextInputType type, IconData icon)
  {
    return Padding(
      padding: const EdgeInsets.only(top:35),
        child: Container(
          height:80,
          width: 300,
          padding: EdgeInsets.all(10.0),
          child: Theme(
            data: ThemeData(primaryColor: Colors.black),
            child: TextField (autocorrect: true, 
              controller: controller,
              maxLines: null,
              focusNode: node,
              onSubmitted: (text){setState((){
                  node.unfocus();
                });
              },
              keyboardType: type,
              decoration: new InputDecoration(
              labelText: text,
              prefixIcon: Icon(icon, color: Colors.black,),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0),
              )
              )
            ),
          )
        ),
    );
  }

  dialog(String text, int val){
    showDialog(
          context: context,
          builder: (c) => AlertDialog(
            content: Text(text),
            shape: RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.circular(15)),
            actions: <Widget>[
              FlatButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(c, false),
              ),
              FlatButton(
                child: Text('OK'),
                onPressed: () => val==1? addProductDetails() : goBack(1),
              )
            ],
          )
        );
  }

  clearAll(){
    setState(() {
      FocusScope.of(context).requestFocus(new FocusNode());
      prodNameController.clear();
      prodCostController.clear();
      prodCategoryController.clear();
      prodSubCategoryController.clear();
      prodStockController.clear();
      prodDescriptionController.clear();
      imageFile=null;
      myList.clear();
      desc='';
    });
  }

  checkBeforeExit(){
    if (prodDescriptionController.text!='' || prodCategoryController.text!='' || prodSubCategoryController.text!='' || prodCostController.text!='' || prodStockController.text!='' || prodDescriptionController.text!='' || imageFile!=null || myList.isNotEmpty)
    dialog("Exit without adding product?", 0);
    else
    goBack(0);
  }

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(
          message: 'Adding product...',
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
        onWillPop: () => added? goBack(0) : checkBeforeExit(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            key: _scaffoldKey,
            extendBody: true,
            appBar: AppBar(
            centerTitle: true,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(25))),
            toolbarOpacity: 0.5,
            elevation: 0,
            backgroundColor: Colors.black,
            leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => added? goBack(0) : checkBeforeExit()),
            title: Text("New Product", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            actions: <Widget>[
              FlatButton(
                onPressed: () => clearAll(),
                highlightColor: Colors.white,
                child: Text('Clear All', style: TextStyle(color: Colors.grey),),
              )
            ],
            ),
            body: SingleChildScrollView(
              child: Center(
                child: Stack(
                    children: <Widget>[
                    Column(
                      children: <Widget>[
                        textField('Product Name', node1, prodNameController, TextInputType.text, Icons.loyalty),
                        textField('Category', node2, prodCategoryController, TextInputType.text, Icons.category),
                        textField('Subcategory', node3, prodSubCategoryController, TextInputType.text, Icons.sort),
                        textField('Cost', node4, prodCostController, TextInputType.number, Icons.local_offer),
                        textField('Stock', node5, prodStockController, TextInputType.number, Icons.exposure_plus_1),
                        Container(
                          margin: EdgeInsets.all(40.0),
                          padding: EdgeInsets.only(top: 10.0),
                          child: Theme(
                            data: ThemeData(primaryColor: Colors.black),
                            child: Stack(
                              children: <Widget>[
                                TextField(
                                  focusNode: node6,
                                  controller: prodDescriptionController,
                                  maxLines: null,
                                  keyboardType: TextInputType.multiline,
                                  onChanged: (String text){
                                    setState(() {
                                      desc=text;
                                    });
                                  },
                                  decoration: new InputDecoration(
                                  hintText: 'Product Description',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0),
                                  )
                                  )
                                ),
                                desc==''? Container() : Positioned(
                                  right: 5, top: 3,
                                  child: IconButton(
                                    onPressed: () => setState((){
                                      node6.unfocus();
                                    }),
                                    icon: Icon(Icons.check, size:28),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(padding: const EdgeInsets.only(top:10, bottom:40),
                          child: Container(
                            height: 380, width: 340,
                            decoration: BoxDecoration(color: Color(0xffe8f4f8), borderRadius: BorderRadiusDirectional.circular(20)),
                            child: Stack(
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 30.0),
                                    child: Container(
                                      height:270, width:270,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: imageFile==null? AssetImage('upload.png') : FileImage(imageFile), 
                                          fit: BoxFit.cover),
                                          borderRadius: imageFile==null ? BorderRadius.circular(20) : null
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: 20),
                                    child: GestureDetector(
                                      onTap: () => getImage(),
                                      child: Container(
                                        height: 35, width:110,
                                        decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadiusDirectional.circular(15)),
                                        child: Center(child: Text(imageFile==null? 'Upload Image' : 'Change Image', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),))
                                      ),
                                    )
                                  ),
                                )
                              ],
                            ),
                          )
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top:15),
                          child: Text('Image Labels*: ${myList.toString()}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))
                        ),
                        Padding(padding: const EdgeInsets.only(top:10),
                            child: Container(
                              height:75,
                              width: 300,
                              padding: EdgeInsets.all(10.0),
                              child: Stack(
                                children: <Widget>[
                                  Theme(
                                    data: ThemeData(primaryColor: Colors.black),
                                    child: TextField (autocorrect: true, 
                                      controller: imageLabelController,
                                      focusNode: node7,
                                      keyboardType: TextInputType.text,
                                      onSubmitted: (text){
                                        imageLabelController.clear();
                                        node7.unfocus();
                                      },
                                      decoration: new InputDecoration(
                                        labelText: 'Image Labels',
                                        prefixIcon: Icon(Icons.image, color: Colors.black,),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0),
                                      )
                                      )
                                    ),
                                  ),
                                  Positioned(
                                    right:5, top:3,
                                    child: IconButton(
                                      onPressed: () => setState(() {
                                          if (imageLabelController.text!=''){
                                            myList.add(imageLabelController.text); 
                                            imageLabelController.clear();
                                          }
                                        }),
                                      icon: Icon(Icons.add_circle_outline, size: 28,),
                                    ),
                                  )
                                ],
                              )
                            ),
                        ),
                        Text('*Required for scan to search prediction fields'),
                        Padding(padding: const EdgeInsets.only(top: 35, bottom: 45),
                          child: GestureDetector(
                            onTap: (){
                              FocusScope.of(context).requestFocus(new FocusNode());
                              _timer = new Timer(const Duration(milliseconds: 300), () {
                                checkDetails();
                              });
                            },
                            child: Container(
                              height: 60, width: 160,
                              decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadiusDirectional.circular(15)),
                              child: Center(
                                child: Text('Add Product', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),),
                              ),
                            ),
                          )
                        )
                      ],
                    ),
                  ],
                ),
              )
            ),
          ),
        ),
    );
  }
}