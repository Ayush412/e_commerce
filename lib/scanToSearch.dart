import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'descpage.dart';
import 'products.dart';

class scanToSearch extends StatefulWidget {
   final DocumentSnapshot post;
   final int counter;
   Map<String, double> map = Map<String, double>();
   scanToSearch({this.post, this.counter, this.map});
  @override
  _scanToSearchState createState() => _scanToSearchState();
}

class _scanToSearchState extends State<scanToSearch> {

  List<ImageLabel> labels = List<ImageLabel>();
  Future data;
  String bestText;
  double bestConfidence=0;
  
  Future getImageFile() async {
    bestConfidence=0;
    labels.clear();
    File imageFile;
    FirebaseVisionImage visionImage;
    ImageLabeler labeler = FirebaseVision.instance.imageLabeler();
    imageFile =  await ImagePicker.pickImage(source: ImageSource.camera);
    if(imageFile==null)
      return 0;
    else{
      visionImage = FirebaseVisionImage.fromFile(imageFile);
      labels = await labeler.processImage(visionImage);
      for (ImageLabel label in labels) {
        final String text = label.text;
        final String entityId = label.entityId;
        final double confidence = label.confidence;
        print(text);
        print(entityId);
        print(confidence);
        print("");
        if(double.parse('$confidence') > bestConfidence)
        {
          bestText = text;
          bestConfidence = double.parse('$confidence');
        }
      }
      print('Best: $bestText => $bestConfidence');
      setState(() {
        data=getScanData();
      });
    }
  }

  Future getScanData() async{
    QuerySnapshot qs = await Firestore.instance.collection('products').where('scan', arrayContains: bestText).getDocuments();
    return qs.documents;
  }

  navigateToDetail(DocumentSnapshot post, String tag){
    String email = widget.post.documentID.toString();
    Navigator.push(context, PageRouteBuilder(transitionDuration: Duration(milliseconds:600) ,pageBuilder: (_,__,___)=> prodDescription(post: post, email: email, counter: widget.counter, userpost: widget.post, tag: tag, map: widget.map,)));
  }

  Widget display(){
    if(labels.length>0)
    return Stack(
          children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top:10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
                      child: Container(
                        child: FutureBuilder(
                          future: data,
                          builder: (_, snapshot){
                            if(snapshot.connectionState == ConnectionState.waiting){
                              return Center(child: CircularProgressIndicator());
                            }
                            else{
                              if(snapshot.data.length>0){
                
                              return Stack(
                                    children: <Widget>[
                                       Padding(
                                      padding: const EdgeInsets.only(top: 10, left: 15),
                                      child: Text('Best predicted matches:', style: TextStyle(fontSize: 21, color: Colors.white, fontWeight: FontWeight.w600),)
                                    ),
                                      ListView.builder(
                                          padding: const EdgeInsets.only(left: 4, right:4, top: 40),
                                          itemCount: snapshot.data.length,
                                          itemBuilder: (_, index){
                                            return Container(height: 130,
                                              child: Card(
                                                elevation: 0,
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
                                ],
                              );
                              }
                              else{
                                return centerImage("Couldn't find relevant products\n[ Predicted: `$bestText` ]", 'search.png');
                              }
                            }
                          },
                        ),
                      )
                    ),
                  ),
                ],
    );
        else 
        return  Padding(
                    padding: const EdgeInsets.only(top:10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
                      child: centerImage('Scan an object to begin search', 'scan.png')
                    )
        );
  }
  
  Widget centerImage(String text, String img){
    return Stack(
      children: <Widget>[
        Center(
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(img, height:100, width: 100),
            ),
          )
        ),
        Center(
           child: Padding(padding: EdgeInsets.only(top:200),
            child: Text(text, textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)
            )
           ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => Navigator.push(context, MaterialPageRoute(builder: (context) => listPage(post: widget.post,))),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            extendBody: true,
            backgroundColor: Colors.white,
            appBar: AppBar(
              centerTitle: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(25))),
              toolbarOpacity: 0.5,
              elevation: 0,
              backgroundColor: Colors.black,
              leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white),onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => listPage(post: widget.post,)))),
              title: Text('Scan To Search', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.info), 
                  color: Colors.white,
                  onPressed: () => showDialog(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: Text('How it works'),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                            content: Text('Click the camera icon below to take a picture of an object. Based on the best predictions made by the algorithm, you can find relevant products that match the category of the scanned object.'),
                            actions: <Widget>[
                              FlatButton(child: Text('OK'), onPressed: () => Navigator.pop(c, false))
                            ],
                          )
                          ),
                )
              ],
            ),
            body: Stack(
              children: <Widget>[
                Container(color: Colors.white),
                Padding(
                  padding: const EdgeInsets.only(top:10),
                  child: Container( decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),)
                ),
                Padding(
                  padding: const EdgeInsets.only(top:51),
                  child: Container(
                   decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
                  )
                ),
                display(),
              ],
            ),
            bottomNavigationBar: ClipRRect(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                      child: BottomAppBar(
                        shape: CircularNotchedRectangle(),
                        color: Colors.orange,
                        child: Container(height: 40,),
                      )
                    ),
            floatingActionButton: FloatingActionButton(
              elevation: 0,
              onPressed: () => getImageFile(),
              child: Icon(Icons.camera_alt, color: Colors.black),
              backgroundColor: Colors.orange,
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          )
        )
    );
  }
}