import 'package:chatapp/chat_screen.dart';
import 'package:chatapp/firestore_helper.dart';
import 'package:chatapp/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User List"),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FireStoreHelper().firestore.collection("User").snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.separated(
                itemCount: snapshot.data?.docs.length ?? 0,
                itemBuilder: (context, index) {
                  var doc = snapshot.data?.docs[index];

                  return ListTile(
                    onTap: () {

                      var myUser = MyUser.fromJson(doc?.data()??{});

                      // Get.to(ChatScreen(myUser: myUser));
                      Get.toNamed("chat-screen",arguments: myUser);
                      // Navigator.push(context, MaterialPageRoute(
                      //   builder: (context) {
                      //     return ChatScreen(myUser: myUser);
                      //   },
                      // ));

                      // Navigator.pushNamed(context, "chat-screen",arguments: myUser);

                    },
                    leading: CircleAvatar(
                      child: Text("a"),
                    ),
                    title: Text(doc?.id ?? ""),
                    //title: Text("${doc?.data()["userName"]}"),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(
                    thickness: 2,
                    indent: 10,
                    endIndent: 10,
                  );
                },
              );
            } else {
              return CircularProgressIndicator();
            }
          }),
    );
  }
}
