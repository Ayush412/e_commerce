import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class add2cart{

  String email;
  DocumentSnapshot post;
  add2cart(DocumentSnapshot post, String email){
    this.post=post;
    this.email=email;
    getCartCount();
  }

  int cartQuantity=0;
  Future getCartCount() async{
    QuerySnapshot _snap = await Firestore.instance.collection('/users/$email/Cart')
    .document(post.documentID)
    .get()
    .then((DocumentSnapshot snap){
       snap.exists ? cartQuantity=snap.data['Quantity'] : cartQuantity=0;
    });
    add();
   }
  Future add() async{
    await Firestore.instance.collection('users/$email/Cart').document(post.documentID)
    .setData({
      'Quantity': cartQuantity+1,
      'ProdName': post.data['ProdName'],
      'ProdCost': post.data['ProdCost'],
      'imgurl': post.data['imgurl'],
      'Rate': false
    });

  }
}