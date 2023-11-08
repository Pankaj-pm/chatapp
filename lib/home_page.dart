import 'package:chatapp/firestore_helper.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/user_list.dart';
import 'package:chatapp/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HomePage extends StatelessWidget {
  int i = 0;

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          IconButton(
            onPressed: () async {
              await auth.signOut();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(title: "title"),
                  ));
            },
            icon: Icon(Icons.logout),
          )
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            // DrawerHeader(child: Text(""),),
            UserAccountsDrawerHeader(
              accountName: Text("Meet"),
              accountEmail: Text("meetpatel@gmail.com"),
              currentAccountPicture: CircleAvatar(),
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.only(bottomRight: Radius.circular(50)), color: Colors.red),
              otherAccountsPictures: [
                // CircleAvatar(backgroundColor: Colors.orange),
                // CircleAvatar(backgroundColor: Colors.blueGrey),
                // CircleAvatar(backgroundColor: Colors.amber),
                CircleAvatar(backgroundColor: Colors.black),
                CircleAvatar(backgroundColor: Colors.white),
                CircleAvatar(backgroundColor: Colors.amber),
              ],
              otherAccountsPicturesSize: Size(10, 10),
            ),
            ListTile(title: Text("Option 1")),
            ListTile(title: Text("Option 2")),
            ListTile(title: Text("Option 3")),
            ListTile(title: Text("Option 4")),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showScheduleNotification(i++, "Schedule", "Hellelelel");
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => UserList(),
          //     ));
        },
      ),
    );
  }
}
