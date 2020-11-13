//import 'dart:js';
//import 'dart:ui';

//import 'dart:js';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_test/chat.dart';
import 'package:firebase_test/helpers/database.dart';
import 'package:firebase_test/helpers/shared.dart';
import 'package:firebase_test/screens/auth_animate.dart';
import 'package:firebase_test/screens/home_user.dart';

import 'package:firebase_test/screens/ssignup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:http/http.dart' as http;

import 'Reg.dart';
import 'helpers/Username.dart';
import 'helpers/authenticate.dart';
import 'profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FlutterDownloader.initialize();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool isLoggedIn;
  DataService db = new DataService();
  @override
  void initState() {
    getUserStatus();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }
  
   void didChangeAppLifecycleState(AppLifecycleState state) async{
    switch (state) {
    case AppLifecycleState.inactive:
    print("Inactive");
    await db.updateLastActive(Constants.myuid, false);
    break;
    case AppLifecycleState.paused:
    print("Paused");
    
    break;
    case AppLifecycleState.resumed:
    print("Resumed");
    break;
    case AppLifecycleState.detached:
    print("Suspending");
    break;
    }
  }

  getUserStatus() async {
    print(await SharedPref.getLogInSharedPreferences());
    isLoggedIn = await SharedPref.getLogInSharedPreferences();
    setState(()  {
      
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
     //   primaryColor: Colors.lightBlue.shade900,
        scaffoldBackgroundColor: Colors.white54,
        
        accentColor: Color(0xff007EF4),
        fontFamily: "OverpassRegular",
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home : isLoggedIn != null  ? isLoggedIn ? UserHome() : Authenticate() : Authenticate(),
     //   home : AuthAni()
       
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    print("Exited from this app?");
    super.dispose();
  }
}

//Color(0xff145C9E)

//scaffoldColor(0xff1F1F1F)