import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_test/backend/auth.dart';
import 'package:firebase_test/helpers/database.dart';
import 'package:firebase_test/helpers/shared.dart';
import 'package:firebase_test/screens/auth_animate.dart';
import 'package:firebase_test/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home_user.dart';

class SignIn extends StatefulWidget {
  Function toggle;
  SignIn(this.toggle);
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> with SingleTickerProviderStateMixin {
  AuthService auth = new AuthService();
  DataService db = new DataService();
  final form_key = GlobalKey<FormState>();
  bool isLoading = false;
  TextEditingController emailEdittingController = new TextEditingController();
  TextEditingController passwordEdittingController =
      new TextEditingController();
  AnimationController _controller;
  Animation textFieldWidth;
  Animation conHeight;
  Animation conWidth;
  Animation conOpac;
  Animation textOpac;
  Animation color;
  Animation rotation;
  Animation cardOpac;
  Animation scaffcol;
  signIn() async {
    if (form_key.currentState.validate()) {
    //  _controller.forward();
      setState(() {
        isLoading = true;
      });
      await auth
          .signInwithEmailandPassword(
              emailEdittingController.text, passwordEdittingController.text)
          .then((value) async {
        if (value != null) {
          _controller.forward();
          print(value);

          //SharedPref.saveLogInSharedPreferences(true);
         
          QuerySnapshot snap_user = await db.getUserbyEmail(emailEdittingController.text);
          print(snap_user.docs[0].data()['username']);
          if(snap_user != null){
          await SharedPref.saveLogInSharedPreferences(true);
          await SharedPref.saveUserNameSharedPreferences(snap_user.docs[0].data()['username']);
          await SharedPref.saveUserEmailSharedPreferences(snap_user.docs[0].data()['email']);
          await SharedPref.saveUserIdSharedPreferences(snap_user.docs[0].data()['uid']);
          }
//          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserHome()));
        }
      });
    }
  }
  
  
    @override
    void initState() {
      super.initState();
      _controller = AnimationController(vsync: this,duration: Duration(seconds: 2));

      textFieldWidth = Tween(
        begin: 1.0,
        end: 0.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Interval(0.0, 0.5)));
      conHeight = TweenSequence(
        [
          TweenSequenceItem(tween: Tween(
        begin: 0.46,
        end: 0.15,
      ), weight: 1),
          TweenSequenceItem(tween: Tween(
        begin: 0.15,
        end: 0.8,
      ), weight: 1),
          
          
        ]
      ).animate(CurvedAnimation(parent: _controller, curve: Interval(0.5, 1.0)));

      conWidth = TweenSequence(
        [
          TweenSequenceItem(tween: Tween(
        begin: 0.8,
        end: 0.3,
      ), weight: 1),
          TweenSequenceItem(tween: Tween(
        begin: 0.3,
        end: 1.0,
      ), weight: 1),
          
          
        ]
      ).animate(CurvedAnimation(parent: _controller, curve: Interval(0.5, 1.0)));

/*      conHeight = Tween(
        begin: 0.46,
        end: 0.15,
      ).animate(CurvedAnimation(parent: _controller, curve: Interval(0.5, 0.65)));*/

     

      conOpac = Tween(
        begin: 1.0,
        end: 0.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Interval(0.48, 0.5)));

      cardOpac = Tween(
        begin: 1.0,
        end: 0.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Interval(0.8, 1.0)));

      textOpac = Tween(
        begin: 1.0,
        end: 0.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Interval(0.3, 0.5)));
      scaffcol = ColorTween(
        begin: Color(0xff007EF4),
        end : Colors.white54
      ).animate(CurvedAnimation(parent: _controller, curve: Interval(0.8, 1.0)));
      
      color = TweenSequence(
        [
          TweenSequenceItem(tween: ColorTween(
        begin: Colors.white,
        end : Colors.grey
      ), weight: 1),
          TweenSequenceItem(tween: ColorTween(
        begin: Colors.grey,
        end : Colors.white
      ), weight: 1),
          
          
        ]
      ).animate(CurvedAnimation(parent: _controller, curve: Interval(0.65, 1.0)));
    
        rotation = Tween(
        begin: 0.0,
        end: 3.14,
      ).animate(CurvedAnimation(parent: _controller, curve: Interval(0.8, 1.0)));
       _controller.addListener(() {
      setState(() {
        //print(first_text.value);
        if(_controller.value ==1){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserHome()));
      //     _controller.dispose();
        }
        print(_controller.value);
      
      });
    });
      
    }
  
    @override
    void dispose() {
      super.dispose();
      _controller.dispose();
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //appBar: appBarMain(context),
      //  backgroundColor: scaffcol.value,
        backgroundColor: const Color(0xff007EF4),
        body: Center(
          child: SingleChildScrollView(
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                      opacity: textOpac.value,
                       
                      child: Text(
                      "ChatBuzz",
                      style: GoogleFonts.tangerine(
                          fontSize: 85, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 7,
                ),
                Center(
              //    widthFactor: 0.5,
                  child:
                      Transform.rotate(
                        angle: rotation.value,
                        child: Opacity(
                              opacity: 1,
                      //      opacity: cardOpac.value,
                            child: Container(
                          //    height: 60,
                //    height: MediaQuery.of(context).size.height * 0.15,
                          //  width: MediaQuery.of(context).size.width * 0.3,
                            width: MediaQuery.of(context).size.width * conWidth.value,
                            height: MediaQuery.of(context).size.height * conHeight.value,
                            child: Card(
                              color:color.value,
                              elevation: 38,
                              shadowColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              child: Container(
                            //   color: color.value,
                                  width: MediaQuery.of(context).size.width * 0.8,
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                                  child: Form(
                                      key: form_key,
                                      child: Opacity(
                                        opacity: conOpac.value,
                                        child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          
                                          Container(
                                            alignment: Alignment.centerRight,
                                            width: MediaQuery.of(context).size.width * textFieldWidth.value,
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextFormField(
                                              controller: emailEdittingController,
                                              validator: (val){
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
                                                      borderRadius: BorderRadius.circular(60)),
                                                  border: OutlineInputBorder(
                                                      borderSide: BorderSide.none,
                                                      borderRadius: BorderRadius.circular(60))),
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context).size.width * textFieldWidth.value,
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
                                          Align(
                                              alignment: Alignment.center,
                                              child: Padding(
                                              padding: EdgeInsets.all(8),
                                              //alignment: Ali,
                                              child: Text(
                                                "Forgot Password?",
                                                style: GoogleFonts.cambay(
                                                    //fontWeight: FontWeight.,
                                                    fontSize: 16,
                                                    color: Colors.black54),
                                              ),
                                            ),
                                          ),
                                          isLoading ? 
                                          Center(
                                            child: CircularProgressIndicator(
                                                
                                            ),
                                          ) :
                                          GestureDetector(
                                            onTap: () {
                                              signIn();
                                            },
                                            child: Align(
                                                alignment: Alignment.center,
                                                child: Container(
                                               // alignment: Alignment.center,
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
                                                        //  cons
                                                        
                                                        // Color(0xff2A75BC)
                                                      ],
                                                    )),
                                                width: MediaQuery.of(context).size.width * 0.4,
                                                child: Text(
                                                  'SIGN IN',
                                                  style: biggerTextStyle(),
                                                  textAlign: TextAlign.center,
                                                ),
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
                                                "Don't have an account?",
                                                style: GoogleFonts.cambay(
                                                    color: Colors.black54, fontSize: 16),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  widget.toggle();
                                                },
                                                child: Container(
                                                  child: Text(
                                                    'Register Now',
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
