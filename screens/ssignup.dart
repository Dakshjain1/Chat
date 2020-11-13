//import 'dart:js';
import 'dart:ui';

import 'package:firebase_test/backend/auth.dart';
import 'package:firebase_test/helpers/authenticate.dart';
import 'package:firebase_test/helpers/database.dart';
import 'package:firebase_test/helpers/shared.dart';
import 'package:firebase_test/profile.dart';
import 'package:firebase_test/widgets/widgets.dart';
//import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:firebase_test/helpers/shared.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:uuid/uuid.dart';

class SignUp extends StatefulWidget {
  Function toggle;
  SignUp(this.toggle);
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool isLoading= false;
  final form_key = GlobalKey<FormState>();
  //GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  AuthService auth = new AuthService();
  TextEditingController emailEdittingController = new TextEditingController();
  TextEditingController nameEdittingController = new TextEditingController();
  TextEditingController passwordEdittingController =
      new TextEditingController();
      bool isVisible = true;
  var uuid = Uuid();
  DataService db = new DataService();
  signup() async {
    if (form_key.currentState.validate()) {
          var uid = uuid.v5(Uuid.NAMESPACE_NIL, nameEdittingController.text);
         setState(() {
           isLoading = true;
         });
      
        await auth
          .signUpwithEmailandPassword(
              emailEdittingController.text, passwordEdittingController.text)
          .then((value) async{
        if (value != null) {
          print(value);
          //SharedPref.saveLogInSharedPreferences(true);
          var uid = uuid.v5(Uuid.NAMESPACE_NIL, nameEdittingController.text);
                   await SharedPref.saveLogInSharedPreferences(true);
                    await SharedPref.saveUserEmailSharedPreferences(emailEdittingController.text);
              //      SharedPref.saveUserNameSharedPreferences(nameEdittingController.text);
                    await SharedPref.saveUserIdSharedPreferences(uid);

                    Map<String, String> userData = {
                      'uid' :  uid,
                      'Full_name' : nameEdittingController.text,
                      'email' : emailEdittingController.text 
                    };
                    
                     db.addUserInfo(userData,uid);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => MyProfile(uid)));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //appBar: appBarMain(context),
     //  resizeToAvoidBottomInset: false,
       // resizeToAvoidBottomPadding: false,
        backgroundColor: const Color(0xff007EF4),
        body: Center(
          child: SingleChildScrollView(
                    
                    physics: ClampingScrollPhysics(),
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                    
                      child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      "ChatBuzz",
                      style: GoogleFonts.tangerine(
                          fontSize: 85, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                      height: 7,
                  ),
                  Center(
                      child: Card(
                        elevation: 38,
                        shadowColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                          child: Form(
                            key: form_key,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    controller: nameEdittingController,
                                    validator: (v) {
                                      return v.isEmpty || v.length < 6
                                          ? "Please enter valid name"
                                          : null;
                                    },
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.account_circle,
                                          size: 30,
                                        ),
                                        filled: true,
                                        focusColor: Colors.brown,
                                        labelStyle: GoogleFonts.cairo(fontSize: 18),
                                        labelText: "Full Name",
                                        fillColor: Colors.blue[50],
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.blue,
                                                style: BorderStyle.solid),
                                            borderRadius: BorderRadius.circular(30)),
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius: BorderRadius.circular(30))),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    controller: emailEdittingController,
                                    validator: (val) {
                                      return RegExp(
                                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                              .hasMatch(val)
                                          ? null
                                          : "Please enter valid email address";
                                    },
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.account_circle,
                                          size: 30,
                                        ),
                                        filled: true,
                                        focusColor: Colors.brown,
                                        labelStyle: GoogleFonts.cairo(fontSize: 18),
                                        labelText: "Email",
                                        fillColor: Colors.blue[50],
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.blue,
                                                style: BorderStyle.solid),
                                            borderRadius: BorderRadius.circular(30)),
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius: BorderRadius.circular(30))),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    obscureText: true,
                                    controller: passwordEdittingController,
                                    validator: (v) {
                                      return v.isEmpty || v.length < 6
                                          ? "Please enter password with 6 or more characters"
                                          : null;
                                    },
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.lock,
                                          size: 30,
                                        ),
                                        filled: true,
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.blue,
                                                style: BorderStyle.solid),
                                            borderRadius: BorderRadius.circular(30)),
                                        focusColor: Colors.brown,
                                        labelStyle: GoogleFonts.cairo(fontSize: 18),
                                        labelText: "Password",
                                        fillColor: Colors.blue[50],
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius: BorderRadius.circular(30))),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                isLoading ?
                                Center(
                                            child: CircularProgressIndicator(
                                                
                                            ),
                                          ) :
                                GestureDetector(
                                  onTap: () {
                                    signup();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black87,
                                              blurRadius: 3.0,
                                              offset: Offset.fromDirection(150)
                                              //  spreadRadius: 5.0
                                              )
                                        ],
                                        borderRadius: BorderRadius.circular(30),
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xff007EF4),
                                            const Color(0xff007EF4),
                                            //  const Color(0xff2A75BC)
                                          ],
                                        )),
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    child: Text(
                                      'SIGN UP',
                                      style: biggerTextStyle(),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      'Already have an account?',
                                      style: GoogleFonts.cambay(
                                          color: Colors.black54, fontSize: 16),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        widget.toggle();
                                      },
                                      child: Container(
                                        child: Text(
                                          'SignIn Now',
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 16,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                  ),
                ],
              
            ),
                    ),
          ),
        ));
  }
}

/*
Center(
        child: Card(
          color: Colors.black12,
         // padding: EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              //Spacer(),
              Form(
                  key: form_key,
                  child: Column(
                  children: [
                    TextFormField(
                      validator: (val) {
                        return RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(val)
                            ? null
                            : "Please enter valid email address";
                      },
                      style: simpleTextStyle(),
                      controller: emailEdittingController,
                      decoration: textFieldInputDecoration('Enter email address'),
                    ),
                    TextFormField(
                      validator: (v) {
                        return v.isEmpty || v.length < 6
                            ? "Please enter password with 6 or more characters"
                            : null;
                      },
                      style: simpleTextStyle(),
                      controller: passwordEdittingController,
                      decoration: textFieldInputDecoration('Enter email password'),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    GestureDetector(
                        onTap: (){
                          signup();
                        },
                        child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xff007EF4),
                                const Color(0xff2A75BC)
                              ],
                            )),
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          'SIGN UP',
                          style: biggerTextStyle(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'Already have an account?',
                          style: simpleTextStyle(),
                        ),
                        GestureDetector(
                          onTap: () {
                            widget.toggle();
                          },
                          child: Container(
                            child: Text(
                              'SignIn Now',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
             
            ],
          ),
        ),
      ),
*/
