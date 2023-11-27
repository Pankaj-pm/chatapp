import 'package:chatapp/firestore_helper.dart';
import 'package:chatapp/model/chat_msg.dart';
import 'package:chatapp/model/fcm_model.dart';
import 'package:chatapp/model/user.dart';
import 'package:chatapp/network/api_end_point.dart';
import 'package:chatapp/network/http_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatController extends GetxController{

  MyUser? myUser;
  var count=0.obs;

  TextEditingController msgController = TextEditingController();

  DocumentReference? editRef;
  var cUser = FirebaseAuth.instance.currentUser?.email ?? "";


  @override
  void onInit() {
    myUser = Get.arguments;
    print("myuser?.email = >${myUser?.email}");
    super.onInit();
  }
  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  void send() async {
    ChatMsg chatMsg = ChatMsg(
      msg: msgController.text,
      isRead: false,
      senderId: cUser,
      time: DateTime.now().toString(),
    );

    var email = myUser?.email;

    FireStoreHelper().sendMsg(cUser, email ?? "", chatMsg);

    var documentSnapshot = await FireStoreHelper().firestore.collection("User").doc(email).get();
    String? token = documentSnapshot.data()?["fcmToken"] ?? "";

    print("Token  $token");

    var fcmModel = FcmModel(
      to: token ?? "",
      notification: Data(title: cUser, body: msgController.text),
      data: Data(title: cUser, body: msgController.text),
    );
    HttpHelper().postHttp(sendEndPoint, fcmModel.toJson());

    msgController.clear();
  }

  void onEdit(ChatMsg chatMsg,String docId){
    if (chatMsg.senderId == cUser) {
      editRef = FireStoreHelper()
          .firestore
          .collection("chat")
          .doc("${cUser}${myUser?.email ?? ""}")
          .collection("${cUser}${myUser?.email ?? ""}")
          .doc(docId);

      msgController.text = chatMsg.msg ?? "";
    }
  }

  void edtMsg(DocumentReference reference) {
    ChatMsg chatMsg = ChatMsg(
      msg: msgController.text,
      isRead: false,
      senderId: cUser,
      time: DateTime.now().toString(),
    );

    reference.update(chatMsg.toJson());
    editRef = null;
    msgController.clear();
  }
}