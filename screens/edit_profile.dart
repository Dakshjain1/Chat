import 'dart:io';

import 'package:dashed_circle/dashed_circle.dart';
import 'package:firebase_test/helpers/Username.dart';
import 'package:firebase_test/helpers/database.dart';
import 'package:firebase_test/helpers/imagechange.dart';
import 'package:firebase_test/helpers/shared.dart';
import 'package:firebase_test/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class EditProfile extends StatefulWidget {
  String name;
  String userId;
  String username;
  String email;
  String display_url;
  
  EditProfile(this.display_url, this.userId,this.name, this.username, this.email);
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> with SingleTickerProviderStateMixin{
  ChangeProfile change = new ChangeProfile();
 // ChangeProfileState change = new ChangeProfileState();
  File path;
  var uuid = Uuid();
  DataService db = new DataService();
  final form_key = GlobalKey<FormState>();
  TextEditingController nameController = new TextEditingController();
  TextEditingController usernameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  //String display_url;
  AnimationController _aniController;
  Animation base;
  Animation gap;
  Animation reverse;
  @override
  void initState() {
    _aniController = AnimationController(vsync: this, duration: Duration(seconds: 10));

    base = CurvedAnimation(parent: _aniController, curve: Curves.easeOut);
    reverse = Tween<double>(begin: 0.0, end: -1.0).animate(base);
    
    gap = Tween<double>(begin: 3.0, end: 0.0).animate(base);

     _aniController.addListener(() {
            
            setState(() {
              
            });
          });
    _aniController.forward();
    nameController.text = widget.name;
    usernameController.text = widget.username;
    emailController.text = widget.email;
    
    super.initState();
  }
  updateInfo() async{
    if (form_key.currentState.validate()) {
      Map<String,dynamic> changed = {
        'name' : nameController.text,
        'email' : emailController.text,
        'username' : usernameController.text,
      //  'display_url' : widget.display_url
      };

      await db.updateUserInfo(widget.userId,changed).then((value) {
        SharedPref.saveUserEmailSharedPreferences(emailController.text);
        SharedPref.saveUserNameSharedPreferences(usernameController.text);
        Constants.myname = usernameController.text;
        Navigator.pop(context);
      });
      
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
                          backgroundColor: Colors.red,
                          child: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: (){
                            deletePhoto();
                          },
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Remove",
                        style: GoogleFonts.cairo(
                      fontSize: 15,fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
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
  deletePhoto() async{
    await change.removePhoto().then((value){
      setState(() {
        widget.display_url = 'https://raw.githubusercontent.com/juzer-patan/asset/master/download.png';
      });
    });
  }


 /* changePhoto(source) async{
    String changedurl = await change.changePhoto(source);
    print(changedurl);
    if(changedurl != null){
      setState(() {
        widget.display_url = changedurl;
      });
    }
  }*/

   changePhoto(ImageSource source) async{
     var image_pick =new ImagePicker();
     var img = await image_pick.getImage(
       source: source);
    if(img != null){
      path = File(img.path);
      
    
    await db.addProfileImage(Constants.myuid, path).then((value) async{
        print(value);
        if(value !=  null){
       
        setState(() {
         widget.display_url = value;
        });
        var changeMap = {
          'profile_url' : value,
        };
        await db.updateUserInfo(Constants.myuid, changeMap);
       
        }
      });
    // print(img.path); 
    
  }
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade400,
      appBar: AppBar(
        title: Text('Edit Profile'),
        elevation: 0.0,
        centerTitle: false,
        actions: [
          IconButton(
              iconSize: 34,
              icon: Icon(Icons.check),
              onPressed: () {
                updateInfo();
              }),
        ],
        flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                  const Color(0xff007EF4),
                  const Color(0xff2A75BC)
                ])),
          ),
      ),
      body: Center(
          child: SingleChildScrollView(
                    
                //    physics: ClampingScrollPhysics(),
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                    
                      child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 
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
                                            backgroundImage: widget.display_url != null ? NetworkImage(widget.display_url) : NetworkImage('https://raw.githubusercontent.com/juzer-patan/asset/master/download.png')
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
                                    'Change Profile Photo',
                                    style: GoogleFonts.cairo(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff007EF4)
                                    )),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    controller: nameController,
                                    validator: (v) {
                                      return v.isEmpty || v.length < 6
                                          ? "Please enter valid name"
                                          : null;
                                    },
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.person_outline,
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
                                    controller: usernameController,
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
                                        labelText: "Username",
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
                                    controller: emailController,
                                    validator: (val) {
                                      return RegExp(
                                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                              .hasMatch(val)
                                          ? null
                                          : "Please enter valid email address";
                                    },
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.mail,
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
                                        labelText: "Email",
                                        fillColor: Colors.blue[50],
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius: BorderRadius.circular(30))),
                                  ),
                                ),
                             /*   SizedBox(
                                  height: 10,
                                ),
                                GestureDetector(
                                  onTap: () {
                                  //  signup();
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
                                ),*/
                                SizedBox(
                                  height: 16,
                                ),
                                
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
        )
    );
  }
}

/*
SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                child: CircleAvatar(
                  radius: 45,
                  backgroundImage: Constants.myphotoUrl != null ? NetworkImage(Constants.myphotoUrl) : NetworkImage(widget.display_url),
                ),
                margin: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.4),
                //color: Colors.red,
                //height: MediaQuery.of(context).size.width * 0.20,
                //width: MediaQuery.of(context).size.height * 0.58,
              ),

              SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03
              ),
              GestureDetector(
                onTap: (){
                 showAttach();
                // change.showAttach(context);
                },
                child: Text(
                  'Change Profile Photo',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                  )),
              ),
              Form(
                key: form_key,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: TextFormField(
                        //key: form_key,
                        validator: (v) {
                          return v.isEmpty ? "Please enter valid name" : null;
                        },
                        controller: nameController,
                        style: simpleTextStyle(),
                        decoration: InputDecoration(
                            //contentPadding: EdgeInsets.symmetric(horizontal: 10),
                            labelText: "Name",
                            labelStyle:
                                TextStyle(color: Colors.white54, fontSize: 17),
                            //hintText: hintText,
                            //hintStyle: TextStyle(color: Colors.white54),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white))),
                      ),
                    ),
                    Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: TextFormField(
                    //key: form_key,
                    validator: (v) {
                      return v.isEmpty || v.length < 6
                          ? "Please enter valid username"
                          : null;
                    },
                    controller: usernameController,
                    style: simpleTextStyle(),
                    decoration: InputDecoration(
                        //contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        labelText: "Username",
                        labelStyle:
                            TextStyle(color: Colors.white54, fontSize: 17),
                        //hintText: hintText,
                        //hintStyle: TextStyle(color: Colors.white54),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: TextFormField(
                    //key: form_key,
                    validator: (val) {
                      return RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(val)
                          ? null
                          : "Please enter valid email address";
                    },
                    controller: emailController,
                    style: simpleTextStyle(),
                    decoration: InputDecoration(
                        //contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        labelText: "Email",
                        labelStyle:
                            TextStyle(color: Colors.white54, fontSize: 17),
                        //hintText: hintText,
                        //hintStyle: TextStyle(color: Colors.white54),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white))),
                  ),
                ),
                  ],
                ),
              ),
              
            ],
          ),
        ),
      ),
*/