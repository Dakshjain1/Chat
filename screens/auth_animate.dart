import 'package:firebase_test/backend/auth.dart';
import 'package:firebase_test/helpers/database.dart';
import 'package:firebase_test/helpers/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';

import 'home_user.dart';

class AuthAni extends StatefulWidget {
  @override
  _AuthAniState createState() => _AuthAniState();
}

class _AuthAniState extends State<AuthAni> {
  AuthService auth = new AuthService();
  bool isValid;
  DataService db = new DataService();
  Color initial = Colors.transparent;
  signIn(LoginData data) async {
    // if (form_key.currentState.validate()) {
      
    await auth
        .signInwithEmailandPassword(data.name, data.password)
        .then((value) async {
      if (value != null) {
     //   print("value" + value);
        //SharedPref.saveLogInSharedPreferences(true);

        var snap_user = await db.getUserbyEmail(data.name);
        print(snap_user.docs[0].data()['username']);
        SharedPref.saveLogInSharedPreferences(true);
        SharedPref.saveUserNameSharedPreferences(
            snap_user.docs[0].data()['username']);
        SharedPref.saveUserEmailSharedPreferences(
            snap_user.docs[0].data()['email']);
        SharedPref.saveUserIdSharedPreferences(snap_user.docs[0].data()['uid']);
        setState(() {
          isValid = true;
        });
      }
      else{
        print("Not Correct");
        print(value);
        setState(() {
        isValid = false;
      });  
      }
    });
    
   
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          backgroundColor: initial,
          body: FlutterLogin(
        onSignup: (data) {
          print(data);
        },
        onLogin: (data) {
          signIn(data);
        },
        onRecoverPassword: null,
        onSubmitAnimationCompleted: () {
          if (isValid) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => UserHome()));
          } else {
            setState(() {
              initial = Colors.white;
            });
            showDialog(
              context: context,
              builder: (context){
                return AlertDialog(
                  title: Text("Incorrect Credentials"),
                );
              }
            );
          }
        },
      ),
    );
  }
}
