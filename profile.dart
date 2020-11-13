//import 'dart:js';

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashed_circle/dashed_circle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_test/helpers/database.dart';
import 'package:firebase_test/helpers/shared.dart';
import 'package:firebase_test/screens/home_user.dart';
import 'package:firebase_test/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import 'helpers/Username.dart';

class MyProfile extends StatefulWidget {
  
  String uid;
  MyProfile(this.uid);
  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> with TickerProviderStateMixin{
  final form_key = GlobalKey<FormState>();
  var uuid = Uuid();
  DataService db = new DataService(); 
  var authc = FirebaseAuth.instance;
  var fs = FirebaseFirestore.instance;
  AnimationController _controller;
  AnimationController _aniController;
  String name,phone;
  Animation base;
  Animation conOpac;
  Animation conHeight;
  Animation conWidth;
  Animation reverse;
  Animation rotation;
  Animation color;
  Animation gap;
  File path;
  String display_url;
  Animation textFieldWidth;
  TextEditingController usernameController = new TextEditingController();
  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    //_controller = AnimationController(vsync: this,duration: Duration(seconds: 2));
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 3));
    _aniController = AnimationController(vsync: this, duration: Duration(seconds: 10));
    
    base = CurvedAnimation(parent: _aniController, curve: Curves.easeOut);
    reverse = Tween<double>(begin: 0.0, end: -1.0).animate(base);
    textFieldWidth = Tween(
        begin: 1.0,
        end: 0.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Interval(0.0, 0.5)));
    conOpac = Tween(
        begin: 1.0,
        end: 0.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Interval(0.48, 0.5)));  

    conHeight = TweenSequence(
        [
          TweenSequenceItem(tween: Tween(
        begin: 0.6,
        end: 0.15,
      ), weight: 1),
          TweenSequenceItem(tween: Tween(
        begin: 0.15,
        end: 0.85,
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


    gap = Tween<double>(begin: 3.0, end: 0.0).animate(base);
          _controller.addListener(() {
              setState(() {
                if(_controller.value ==1){
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserHome()));
      //     _controller.dispose();
        }
              });
          });
          _aniController.addListener(() {
            
            setState(() {
              
            });
          });
    _aniController.forward();
    super.initState();
  }

  signUp()async{
  
    if (form_key.currentState.validate()){
        setState(() {
      isLoading = true;
    });
     // _controller.forward();   
      var changeMap = {
          'username' : usernameController.text,
        };
        await db.updateUserInfo(widget.uid, changeMap);
        _controller.forward(); 
        await SharedPref.saveUserNameSharedPreferences(usernameController.text);
        
        
     //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserHome()));
    }

  }
  showAttach() {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          padding: EdgeInsets.all(15),
          child: Wrap(
            children: [
              Text("Change Profile Photo",
                  style: GoogleFonts.cairo(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 25,
                          backgroundColor: Colors.purpleAccent,
                          child: IconButton(
                          icon: Icon(Icons.photo),
                          onPressed: (){
                           changePhoto(ImageSource.gallery);
                          },
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Gallery",
                        style: GoogleFonts.cairo(
                      fontSize: 15,fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 25,
                          backgroundColor: Colors.blueAccent,
                          child: IconButton(
                          icon: Icon(Icons.camera_alt),
                          onPressed: (){
                           changePhoto(ImageSource.camera);
                          },
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Camera",
                        style: GoogleFonts.cairo(
                      fontSize: 15,fontWeight: FontWeight.w500),
                      )
                    ],
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }

  changePhoto(ImageSource source) async{
     var image_pick =new ImagePicker();
     var img = await image_pick.getImage(
       source: source);
    if(img != null){
      path = File(img.path);
      
    
    await db.addProfileImage(widget.uid, path).then((value) async{
        print(value);
        if(value !=  null){
       
        setState(() {
         display_url = value;
        });
        var changeMap = {
          'profile_url' : value,
        };
        await db.updateUserInfo(widget.uid, changeMap);
       
        }
      });
    // print(img.path); 
    
  }
  }
  @override
  Widget build(BuildContext context) {
      var currentUser = authc.currentUser;
    
    return Scaffold(
       // appBar: appBarMain(context),
        backgroundColor: const Color(0xff007EF4),
        body: Center(
          child: SingleChildScrollView(
                    child: Container(
              height: MediaQuery.of(context).size.height,        
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                /*    Text(
                      "Social Chat",
                      style: GoogleFonts.tangerine(
                          fontSize: 85, fontWeight: FontWeight.bold),
                    ),*/
                    SizedBox(
                      height: 15,
                    ),
                    Center(
                      child: Transform.rotate(
                          angle: rotation.value,
                          child: Container(
                          width: MediaQuery.of(context).size.width * conWidth.value,
                          height: MediaQuery.of(context).size.height * conHeight.value,
                          child: Card(
                            color: color.value,
                            elevation: 38,
                            shadowColor: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                              child: Form(
                                key: form_key,
                                child: Opacity(
                                    opacity: conOpac.value,
                                    child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                      child :  RotationTransition(
                                          turns: base,
                                          child: DashedCircle(
                                            gapSize: gap.value,
                                            dashes: 40,
                                            color: Color(0XFFED4634),
                                            child: RotationTransition(
                                              turns: reverse,
                                              child: Padding(
                                                padding: const EdgeInsets.all(5.0),
                                                child: CircleAvatar(
                                                  radius: 70.0,
                                                  backgroundImage: display_url != null ? NetworkImage(display_url) : NetworkImage('https://raw.githubusercontent.com/juzer-patan/asset/master/download.png')
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),),
                                      GestureDetector(
                                        onTap: (){
                                        showAttach();
                                          
                                        },
                                        child: Text(
                                          'Add Profile Photo',
                                          style: GoogleFonts.cairo(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff007EF4)
                                          )),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),

                                      Align(
                                          alignment: AlignmentDirectional.centerStart,
                                          child: Container(
                                        //  alignment: Alignment.centerRight,
                                          width: MediaQuery.of(context).size.width * textFieldWidth.value,
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            controller: usernameController,
                                            validator: (v) {
                                              return v.isEmpty || v.length < 6
                                                  ? "Please enter valid name"
                                                  : null;
                                            },
                                            decoration: InputDecoration(
                                                prefixIcon: Icon(
                                                  Icons.person,
                                                  size: 30,
                                                ),
                                                filled: true,
                                                focusColor: Colors.brown,
                                                labelStyle: GoogleFonts.cairo(fontSize: 18),
                                                labelText: "What should we call you?",
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
                                          signUp();
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
                                      
                                    ],
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

/*
Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Center(
      child: Container(
        //color: Colors.grey.shade300,
        //decoration: BoxDecoration(
         
          // boxShadow: BoxShadow()
       // ),
        width: MediaQuery.of(context).size.width * 0.7  ,
       // height: MediaQuery.of(context).size.height * 0.7,
        //margin: EdgeInsets.all(20),
        //padding: EdgeInsets.symmetric(
         // horizontal: 50,
          //vertical: 30,
        //),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
                                onChanged: (value){
                                  name = value;
                                },
                                style: simpleTextStyle(),
                                cursorColor: Colors.lightGreen,
                                decoration: InputDecoration(
                                
                                hintText: "What Should We Call You?",
                                hintStyle: TextStyle(fontSize: 16),
                                focusedBorder:
                                    UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                                enabledBorder:
                                    UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                               // autocorrect: false,
                                                          //controller: _emailcontroller,
                                ),)
            SizedBox(
              height: 10,
            ),

            
            SizedBox(
                height: 10,
            ),
            
            Material(
              color: Colors.blueAccent,
              shadowColor: Colors.black,
              type: MaterialType.button,
              borderRadius: BorderRadius.circular(15),
              child: MaterialButton(
                child: Text('Submit'),
                onPressed: () async{
                 // print('something');
                 try{
                  print(currentUser.email);
                  var uid = uuid.v5(Uuid.NAMESPACE_NIL, name);
                  
                  var changeName = await currentUser.updateProfile(displayName: name).then((value){
                    SharedPref.saveLogInSharedPreferences(true);
                    SharedPref.saveUserEmailSharedPreferences(widget.email);
                    SharedPref.saveUserNameSharedPreferences(name);
                    SharedPref.saveUserIdSharedPreferences(uid);

                    Map<String, String> userData = {
                      'uid' :  uid,
                      'username' : name,
                      'email' : widget.email 
                    };
                    
                    db.addUserInfo(userData,uid);

                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserHome()));
                    

                  });
             //     print(changeName);
             
                //  var changePhone = await currentUser.updatePhoneNumber(phoneCredential)
                  }
                  catch(e){
                    print('error');
                    print(e);
                  }
                }
                ),
            ),
            
            // Text(
//
            //        ),
          ],
        ),
      ),
    )
    );
*/