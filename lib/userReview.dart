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
    print(userRate);
  }

  Future addUserReview() async{
    await Firestore.instance.collection('products/${widget.docID}/Reviews').document(widget.userpost.documentID).setData({
      'Name': '${widget.userpost.data['FName']} ${widget.userpost.data['LName']}',
      'Date': date,
      'Rate': userRate,
      'Text': text
    });
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
    addUserReview();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(text==null? 'Write a review' : 'Your review', style: TextStyle(color: Colors.grey[400], fontSize: 18)),
            edit? Container() : IconButton(
              icon: Icon(Icons.edit, color: Colors.grey,),
              onPressed: () => setReview(),
            ) 
          ]
        ),
        hasText? TextField(
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
            fillColor: Colors.black,
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