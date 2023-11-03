import 'package:chatapp/firestore_helper.dart';
import 'package:chatapp/model/chat_msg.dart';
import 'package:chatapp/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final MyUser myUser;

  const ChatScreen({super.key, required this.myUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController msgController = TextEditingController();
  var cUser = FirebaseAuth.instance.currentUser?.email ?? "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          leading: CircleAvatar(),
          contentPadding: EdgeInsets.zero,
          title: Text(widget.myUser.email ?? ""),
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
                    .doc("$cUser${widget.myUser.email ?? ""}")
                    .collection("$cUser${widget.myUser.email ?? ""}")
                    // .orderBy(FieldPath.documentId,descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var docsList = snapshot.data?.docs;
                    return ListView.builder(
                      itemCount: docsList?.length ?? 0,
                      itemBuilder: (context, index) {

                        var chatMsg = ChatMsg.fromJson(docsList?[index].data() ?? {});
                        bool isSender = chatMsg.senderId==cUser;

                        return Align(
                          alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
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
                              Text("10/15/2023")
                            ],
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
                  controller: msgController,
                  onSubmitted: (value) {
                    print("Val $value");
                    send();
                  },
                  decoration: InputDecoration(
                      hintText: "Message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      )),
                )),
                IconButton(
                    onPressed: () {
                      send();
                    },
                    icon: Icon(Icons.send))
              ],
            ),
          ),
        ],
      ),
    );
  }

  void send() {
    ChatMsg chatMsg = ChatMsg(
      msg: msgController.text,
      isRead: false,
      senderId: cUser,
      time: DateTime.now().toString(),
    );

    FireStoreHelper().sendMsg(cUser, widget.myUser.email ?? "", chatMsg);
    msgController.clear();
  }
}
