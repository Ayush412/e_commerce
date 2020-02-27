import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class reviews extends StatefulWidget {
  String docID;
  reviews({this.docID});
  @override
  _reviewsState createState() => _reviewsState();
}

class _reviewsState extends State<reviews> {

  List<DocumentSnapshot> products = [];
  bool isLoading = true;
  bool moreLoading = false;
  bool moreDocsLeft = true;
  double height;
  DocumentSnapshot lastDoc;
  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    getReviews();
    height=170;
    controller.addListener(() {
      double maxScroll = controller.position.maxScrollExtent;
      double currentScroll = controller.position.pixels;
      double delta = MediaQuery.of(context).size.height*0.25;
      if(maxScroll - currentScroll <= delta){
        getNextReviews();
      }
    });
  }

  Future getReviews() async{
    setState(() {
      isLoading=true;
    });
    QuerySnapshot qs = await Firestore.instance.collection('products/${widget.docID}/Reviews').orderBy('Date', descending: true).limit(2).getDocuments();
    products = qs.documents;
    if(products.length == 0){
      setState(() {
        isLoading = false;
      });
      return;
    }
    lastDoc = qs.documents[qs.documentChanges.length-1];
    setState(() {
      isLoading=false;
    });
  }

  Future getNextReviews() async{
    if(moreDocsLeft == false){
      return;
    }
    if(moreLoading == true){
      return;
    }
    moreLoading = true;
    QuerySnapshot qs = await Firestore.instance.collection('products/${widget.docID}/Reviews').orderBy('Date', descending: true).startAfter([lastDoc.data['Date']]).limit(2).getDocuments();
    if(qs.documents.length == 0){
      setState(() {
        moreDocsLeft = false;
      });
      return;
    }
    products.addAll(qs.documents);
    lastDoc = qs.documents[qs.documents.length-1];
    moreLoading = false;
    setState((){
      height=240;
    });
  }

  Widget stars(double rate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(5, (val) {
        return Icon(
          val < rate ? Icons.star : Icons.star_border,
          color: Color(0xFFe8b430),
          size: 12,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
      return AnimatedContainer(
        duration: Duration(milliseconds: 300),
        height: height,
        curve: Curves.easeOut,
        width: MediaQuery.of(context).size.width,
        child: isLoading? Center(child: Text('Loading...', style: TextStyle(color: Colors.white))) 
        : products.length==0? Center(child: Text('No reviews', style: TextStyle(color: Colors.white)))
          : MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: ListView.builder(
                  controller: controller,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 15, left: 5, right: 5),
                        child: Stack(
                          children: <Widget>[
                            Icon(Icons.account_circle, color: Colors.white,),
                            Padding(
                              padding: const EdgeInsets.only(left: 35),
                              child: Text(products[index].data['Name'], style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500))
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top:35, left: 5),
                              child: stars(products[index].data['Rate'].toDouble()),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 60),
                              child: Text(products[index].data['Text'], style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w300, wordSpacing: 2, height: 1.3))
                            ),
                            Positioned(right: 5, top: 5,
                            child: Text(products[index].data['Date'], style: TextStyle(color: Colors.grey),),
                            )
                          ],
                        ),
                      ), 
                      Divider(
                        height: 0.2,
                        color: Colors.grey,
                      ),
                    ],
                  );
                },
                ),
              ),
      );
  }
}