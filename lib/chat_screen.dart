import 'dart:math';

import 'package:chatapp/chat_controler.dart';
import 'package:chatapp/firestore_helper.dart';
import 'package:chatapp/model/chat_msg.dart';
import 'package:chatapp/model/fcm_model.dart';
import 'package:chatapp/model/user.dart';
import 'package:chatapp/network/api_end_point.dart';
import 'package:chatapp/network/http_helper.dart';
import 'package:chatapp/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  // MyUser? myUser;

  ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ChatController controller = Get.put(ChatController());


  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          leading: CircleAvatar(),
          contentPadding: EdgeInsets.zero,
          title: Text(controller.myUser?.email ?? ""),
          subtitle: Text("Online"),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
                stream: FireStoreHelper()
                    .firestore
                    .collection("chat")
                    .doc("${controller.cUser}${controller.myUser?.email ?? ""}")
                    .collection("${controller.cUser}${controller.myUser?.email ?? ""}")
                    // .orderBy(FieldPath.documentId,descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var docsList = snapshot.data?.docs;
                    return ListView.builder(
                      itemCount: docsList?.length ?? 0,
                      itemBuilder: (context, index) {
                        var docId = docsList?[index].id;
                        var chatMsg = ChatMsg.fromJson(docsList?[index].data() ?? {});
                        bool isSender = chatMsg.senderId == controller.cUser;

                        var dateFormat = DateFormat("h:mm a");
                        String df = "";
                        try {
                          var date = DateFormat("yyyy-MM-dd HH:mm:ss").parse(chatMsg.time ?? "");

                          df = dateFormat.format(date);
                        } catch (e) {
                          print("Error Parse $e");
                        }

                        return Align(
                          alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                          child: Dismissible(
                            key: ValueKey(docId),
                            onDismissed: (direction) {
                              FireStoreHelper()
                                  .firestore
                                  .collection("chat")
                                  .doc("${controller.cUser}${controller.myUser?.email ?? ""}")
                                  .collection("${controller.cUser}${controller.myUser?.email ?? ""}")
                                  .doc(docId)
                                  .delete();
                            },
                            child: Column(
                              crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onLongPress: () {
                                    print("${chatMsg.senderId}==${controller.cUser}");
                                    controller.onEdit(chatMsg,docId??"");

                                    print("docId => $docId");
                                  },
                                  child: Container(
                                    constraints:
                                        BoxConstraints(minWidth: 20, maxWidth: MediaQuery.sizeOf(context).width * 0.5),
                                    padding: EdgeInsets.all(10),
                                    margin: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade200,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(isSender ? 10 : 0),
                                        bottomRight: Radius.circular(isSender ? 0 : 10),
                                      ),
                                    ),
                                    child: Text(chatMsg.msg ?? ""),
                                  ),
                                ),
                                Text(df)
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                  controller: controller.msgController,
                  onSubmitted: (value) {
                    print("Val $value");
                    controller.send();
                  },
                  decoration: InputDecoration(
                      hintText: "Message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      )),
                )),
                IconButton(
                    onPressed: () {
                      if (controller.editRef != null) {
                        controller.edtMsg(controller.editRef!);
                      } else {
                       controller. send();
                      }
                    },
                    icon: Icon(Icons.send))
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.msgController.dispose();
    super.dispose();
  }

}
