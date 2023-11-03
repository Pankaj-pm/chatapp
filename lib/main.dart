// ignore_for_file: use_build_context_synchronously

import 'package:chatapp/firebase_options.dart';
import 'package:chatapp/firestore_helper.dart';
import 'package:chatapp/home_page.dart';
import 'package:chatapp/model/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

late FirebaseAuth auth;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  auth = FirebaseAuth.instance;
  FireStoreHelper();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
              ElevatedButton(
                  onPressed: () async {
                    login();
                  },
                  child: Text("Login")),
              ElevatedButton(
                  onPressed: () async {
                    UserCredential createUserWithEmailAndPassword = await auth.createUserWithEmailAndPassword(
                        email: emailController.text, password: passController.text);
                    if (createUserWithEmailAndPassword.user != null) {
                      FireStoreHelper().addUser(MyUser(email: emailController.text));
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
        FireStoreHelper().addUser(MyUser(email: emailController.text));
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
