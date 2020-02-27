import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class userReview extends StatefulWidget {
  DocumentSnapshot userpost;
  String docID;
  userReview({this.userpost, this.docID, Key key}) : super(key: key);
  @override
  userReviewState createState() => userReviewState();
}

class userReviewState extends State<userReview> {
  String text;
  DocumentSnapshot ds;
  double userRate;
  TextEditingController controller = TextEditingController();
  FocusNode node = FocusNode();
  bool edit = false;
  bool hasText = false;
  bool deleteEnabled = false;
  String date;

  @override
  void initState() { 
    super.initState();
    date = formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd]);
    edit = false;
    getUserRating();
    getUserReview();
  }

  Future getUserReview() async{
    ds = await Firestore.instance.collection('products/${widget.docID}/Reviews').document(widget.userpost.documentID).get();
    if(ds.data!=null){
      text = ds.data['Text'];
      setState(() {
        controller.text=text;
        hasText = true;
      });
    }
  }
  Future getUserRating() async {
    await Firestore.instance
        .collection('/users/${widget.userpost.documentID}/Visited')
        .document(widget.docID)
        .get()
        .then((DocumentSnapshot snap) {
      if (snap.data != null && snap.data['Rate']!=null)
        setState(() {
          userRate = snap.data['Rate'];
        });
      else
        userRate = 0;
    });
  }

  Future addUserReview() async{
    await Firestore.instance.collection('products/${widget.docID}/Reviews').document(widget.userpost.documentID).setData({
      'Name': '${widget.userpost.data['FName']} ${widget.userpost.data['LName']}',
      'Date': date,
      'Rate': userRate,
      'Text': text
    });
    showSnack('Review added!');
  }

  Future deleteReview() async{
    await Firestore.instance.collection('products/${widget.docID}/Reviews').document(widget.userpost.documentID).delete();
    setState(() {
      hasText = false;
      controller.text='';
      text=null;
      edit = false;
    });
    showSnack('Review deleted.');
  }

  showSnack(String text){
    return Scaffold.of(context).showSnackBar(SnackBar(
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

  setReview(){
    setState(() {
      edit = true;
      hasText = true;
    });
    FocusScope.of(context).requestFocus(node);
  }

  submit(){
    setState(() {
      edit = false;
      hasText = true;
      if(controller.text=='')
        controller.text = text;
      else
      text = controller.text;
    });
    FocusScope.of(context).requestFocus(new FocusNode());
    if(text!='')
      addUserReview();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(text==null? 'Write a review' : 'Your review - ', style: TextStyle(color: Colors.grey[400], fontSize: 18)),
            edit? Container() : Padding(
              padding: const EdgeInsets.only(left: 10),
              child: IconButton(
                icon: Icon(Icons.edit, color: Colors.grey),
                onPressed: () => setReview(),
              ),
            ),
            
          ]
        ),
        hasText? Padding(
          padding: const EdgeInsets.only(top: 10),
          child: TextField(
            controller: controller,
            focusNode: node,
            enabled: edit,
            autocorrect: true,
            keyboardType: TextInputType.text,
            style: TextStyle(color: Colors.white),
            onEditingComplete: () => FocusScope.of(context).requestFocus(new FocusNode()),
            decoration: InputDecoration(
              hintText: 'Type Here',
              hintStyle: TextStyle(color: Colors.grey[600]),
              fillColor: Colors.grey[900],
              filled: true
            )
          ),
        ) : Container(),
        hasText? Padding(
          padding: const EdgeInsets.only(top: 5),
          child: FlatButton(
            onPressed: () => deleteReview(),
            child: Text('Delete', style: TextStyle(color: Colors.red, fontSize: 16))
            )
        ) : Container(),
        Align(
          alignment: Alignment.bottomRight,
          child: edit? FlatButton(
            child: Text('Submit', style: TextStyle(color: Colors.blue, fontSize: 16),),
            onPressed: () => submit(),
          ) : Container()
        )
      ]
    );
  }
}