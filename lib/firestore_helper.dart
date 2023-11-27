import 'package:chatapp/model/chat_msg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'model/user.dart';

class FireStoreHelper {
  static final FireStoreHelper _storeHelper = FireStoreHelper._();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  FireStoreHelper._();

  factory FireStoreHelper() {
    return _storeHelper;
  }

  void addUser(MyUser user) {
    firestore.collection("User").doc(user.email ?? "").set(user.toJson());
  }

  void addCounter({String? userName}) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      firestore.collection("User").doc(currentUser.email ?? "").update({
        "email": currentUser.email,
        "loginCount": FieldValue.increment(1),
      });
    }
  }

  void updateToken() async{
    User? currentUser = FirebaseAuth.instance.currentUser;
    var token =await  FirebaseMessaging.instance.getToken();

    if (currentUser != null) {
      firestore.collection("User").doc(currentUser.email ?? "").update({
        "fcmToken": token,
      });
    }
  }

  void addUser2() {
    firestore.collection("User").doc("abc").update({"User": FieldValue.increment(1)});
  }

  void sendMsg(String cUser,String receiverId,ChatMsg chatMsg){


    // firestore.collection("chat").doc("$cUser$receiverId").collection("$cUser$receiverId").add(chatMsg.toJson());
    // firestore.collection("chat").doc("$receiverId$cUser").collection("$receiverId$cUser").add(chatMsg.toJson());

    var millisecondsSinceEpoch = DateTime.now().millisecondsSinceEpoch;

    firestore.collection("chat").doc("$cUser$receiverId").collection("$cUser$receiverId").doc("$millisecondsSinceEpoch").set(chatMsg.toJson());
    firestore.collection("chat").doc("$receiverId$cUser").collection("$receiverId$cUser").doc("$millisecondsSinceEpoch").set(chatMsg.toJson());
  }
}
