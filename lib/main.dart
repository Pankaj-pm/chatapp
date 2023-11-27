// ignore_for_file: use_build_context_synchronously

import 'package:chatapp/chat_screen.dart';
import 'package:chatapp/firebase_options.dart';
import 'package:chatapp/firestore_helper.dart';
import 'package:chatapp/home_page.dart';
import 'package:chatapp/model/user.dart';
import 'package:chatapp/util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

late FirebaseAuth auth;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> firebaseBgMsg(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setupFlutterNotifications();

  showNotification(0, message.notification?.title ?? "", message.notification?.body ?? "");

  print("Remote bg Msg ${message.data}");
  print("Remote bg Msg ${message.notification}");
  print('Handling a background message ${message.messageId}');
}

bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        description: 'This channel is used for important notifications.', // description
        importance: Importance.high,
      ));

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseBgMsg);
  await setupFlutterNotifications();
  await notificationIni();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation("Asia/Kolkata"));
  FirebaseMessaging.instance.onTokenRefresh.listen((event) {
    print("onTokenRefresh $event");
  });
  FirebaseMessaging.instance.getToken().then((value) {
    print("getToken $value");
  });
  auth = FirebaseAuth.instance;
  FireStoreHelper();
  runApp(const MyApp());
}

Future<void> notificationIni() async {
  await flutterLocalNotificationsPlugin.initialize(InitializationSettings(
    android: AndroidInitializationSettings("noti_icon"),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      getPages: [
        GetPage(name: "/chat-screen", page: () => ChatScreen(),),
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    var currentUser = auth.currentUser;
    print("currentUser $currentUser");
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (currentUser != null) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ));
      }
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: emailController,
                decoration: InputDecoration(hintText: "email"),
              ),
              TextField(
                controller: passController,
                decoration: InputDecoration(hintText: "Password"),
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(hintText: "User Name"),
              ),
              ElevatedButton(
                  onPressed: () async {
                    login();
                  },
                  child: Text("Login")),
              ElevatedButton(
                  onPressed: () async {
                    UserCredential createUserWithEmailAndPassword = await auth.createUserWithEmailAndPassword(
                      email: emailController.text,
                      password: passController.text,
                    );
                    if (createUserWithEmailAndPassword.user != null) {
                      FireStoreHelper().addUser(MyUser(email: emailController.text,userName: nameController.text));
                      Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (context) {
                          return HomePage();
                        },
                      ));
                    }
                  },
                  child: Text("Signup")),
              ElevatedButton(
                  onPressed: () async {
                    /*  UserCredential signInAnonymously = await auth.signInAnonymously();
                    print(signInAnonymously);
                    if(signInAnonymously.user!=null){
                      Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (context) {
                          return HomePage();
                        },
                      ));
                    }*/
                  },
                  child: Text("Anonymous login")),
              IconButton(
                  onPressed: () {
                    socialLogin();
                  },
                  icon: Image.asset("assets/android_google.png"))
            ],
          ),
        ),
      ),
    );
  }

  void login() async {
    // UserCredential createUserWithEmailAndPassword =
    //     await auth.createUserWithEmailAndPassword(email: emailController.text, password: passController.text);

    try {
      UserCredential userCredential =
          await auth.signInWithEmailAndPassword(email: emailController.text, password: passController.text);
      print(userCredential.user);

      if (userCredential.user != null) {
        FireStoreHelper().addUser(MyUser(email: emailController.text,userName: nameController.text));
        FireStoreHelper().addCounter();
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) {
            return HomePage();
          },
        ));
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        var exp = e as FirebaseAuthException;
        var message = exp.message;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(exp.message ?? "")));
        print("===> $message");
      }
      print("===> $e");
    }
  }

  void socialLogin() async {
    GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
    try {
      var signIn = await _googleSignIn.signIn();
      print(signIn);
    } catch (e) {
      print("==> $e");
    }
  }
}
