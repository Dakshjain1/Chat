//import 'dart:js';

//import 'dart:js';

//import 'dart:js';

//import 'dart:async';

//import 'dart:js';

//import 'dart:js';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_test/backend/auth.dart';
import 'package:firebase_test/helpers/authenticate.dart';
import 'package:firebase_test/helpers/database.dart';
import 'package:firebase_test/helpers/imagechange.dart';
import 'package:firebase_test/helpers/shared.dart';
import 'package:firebase_test/screens/auth_animate.dart';
import 'package:firebase_test/screens/chatscreen.dart';
import 'package:firebase_test/screens/friends.dart';
import 'package:firebase_test/screens/images.dart';
import 'package:firebase_test/screens/request.dart';
//import 'package:firebase_test/screens/requests.dart';
import 'package:firebase_test/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:firebase_test/helpers/Username.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';

import 'edit_profile.dart';

class UserHome extends StatefulWidget {
  @override
  _UserHomeState createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  var isFriend;
  String email;
  String name;
  Location location;
  Stream profile;
  String display_url;
  AuthService auth = new AuthService();
  DataService db = new DataService();
  var fsconnect = FirebaseFirestore.instance;
  LocationData currentLoc;
  ChangeProfile change = new ChangeProfile();
  @override
  void initState() {
    getUserInfo();
    print("Entered");
    location = new Location();
    // TODO: implement initState
    super.initState();
    getLocation();
  }

  getUserInfo() async {
    Constants.myname = await SharedPref.getUserNameSharedPreferences();
    Constants.myuid = await SharedPref.getUserIdSharedPreferences();

    //  Constants.myuid = "aa0b60ef-22de-5e53-9068-a5ca74e843c9";
    //  Constants.myname = "ajab";
    if (Constants.myuid != null && Constants.myname != null) {
      await db.userSnap(Constants.myuid).then((snap) async {
        profile = snap;
        print("Got it");
        await db.updateLastActive(Constants.myuid, true);
      });
    }

    print(Constants.myname);
    setState(() {});
  }

  getLocation() async {
    currentLoc = await location.getLocation();
    if (currentLoc != null) {
      var latLang = {'lat': currentLoc.latitude, 'long': currentLoc.longitude};
      var locChange = {'location': latLang};
      print(latLang);
      print(currentLoc);
      print("Giiving location");
      await db.updateLastActive(Constants.myuid, true);
      await db.updateUserInfo(Constants.myuid, locChange);
    }
  }

  signOut() async {
    await auth.signOut().then((value) {
      SharedPref.saveLogInSharedPreferences(false);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Authenticate()));
      //     context, MaterialPageRoute(builder: (context) => AuthAni()));
    });
  }

  List<String> categories = ['Messages', 'Friends', 'Requests'];
  var selectedindex = 0;

  Widget _profileImage(context) {
    return StreamBuilder(
        stream: profile,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? imageShow(snapshot, context)
              : Center(child: CircularProgressIndicator());
        });
  }

  Widget imageShow(snapshot, context) {
    name = snapshot.data.data()['Full_name'];
    email = snapshot.data.data()['email'];

    try {
      if (snapshot.data.data()['profile_url'] != null) {
        display_url = snapshot.data.data()['profile_url'];
        print(display_url);
      } else {
        display_url =
            'https://raw.githubusercontent.com/juzer-patan/asset/master/download.png';
      }
    } catch (e) {
      print(e);
      display_url =
          'https://raw.githubusercontent.com/juzer-patan/asset/master/download.png';
    }
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(60),
          image: DecorationImage(
              image: display_url != null
                  ? NetworkImage(display_url)
                  : NetworkImage(
                      "https://raw.githubusercontent.com/juzer-patan/asset/master/download.png"),
              fit: BoxFit.cover)),
      //  height: 50,
      height: MediaQuery.of(context).size.height * 0.15,
      width: MediaQuery.of(context).size.width * 0.25,
      // width: 60,
      //child: path != null ? Image.file(path,) : Text('Image'),
    );
  }

  Widget _plusIcon(context) {
    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.05,
      //  bottom: 30,
      child: GestureDetector(
        onTap: () {
          showAttach();
        },
        child: Container(
            //alignment: Alignment.bottomCenter,
            height: 25,
            width: 25,
            decoration: BoxDecoration(
                color: Colors.green, borderRadius: BorderRadius.circular(15.0)),
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 25.0,
            )),
      ),
    );
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
                          onPressed: () {
                            deletePhoto();
                          },
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Remove",
                        style: GoogleFonts.cairo(
                            fontSize: 15, fontWeight: FontWeight.w500),
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
                          onPressed: () {
                            changePhoto(ImageSource.gallery);
                          },
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Gallery",
                        style: GoogleFonts.cairo(
                            fontSize: 15, fontWeight: FontWeight.w500),
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
                          onPressed: () {
                            changePhoto(ImageSource.camera);
                          },
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Camera",
                        style: GoogleFonts.cairo(
                            fontSize: 15, fontWeight: FontWeight.w500),
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

  deletePhoto() async {
    await change.removePhoto();
  }

  changePhoto(source) async {
    await change.changePhoto(source);
  }

  @override
  Widget build(BuildContext context) {
    var scaff = Scaffold(
        endDrawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                  //  curve: Curves.easeInCubic,
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.25,
                      vertical: 15),
                  decoration: BoxDecoration(
                    //color: Color(0xff007EF4),
                    gradient: LinearGradient(colors: [
                      const Color(0xff007EF4),
                      const Color(0xff2A75BC)
                    ]),
                    //borderRadius: BorderRadius.circular(10)
                  ),
                  child: Stack(
                    children: [
                      _profileImage(context),
                      _plusIcon(context),
                      Positioned(
                        bottom: 0,
                        left: MediaQuery.of(context).size.width * 0.05,
                        child: Constants.myname != null
                            ? Text(
                                '@' + Constants.myname,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              )
                            : Text(""),
                      )
                    ],
                  )),
              ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditProfile(display_url,
                              Constants.myuid, name, Constants.myname, email)));
                },
                leading: Icon(
                  Icons.edit,
                  size: 30,
                ),
                title: Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              ListTile(
                onTap: () {
                  signOut();
                },
                leading: Icon(
                  Icons.exit_to_app,
                  size: 30,
                ),
                title: Text(
                  'Log Out',
                  style: TextStyle(fontSize: 18),
                ),
              )
            ],
          ),
        ),
        appBar: AppBar(
          title: Text(
              'ChatBuzz',
              textAlign: TextAlign.center,
              style: GoogleFonts.tangerine(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5
              )
            
          ),
          elevation: 0.0,
          centerTitle: false,
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
          /*actions: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () {
                    signOut();
                  }),
            ),
          ],*/
          bottom: TabBar(
              labelColor: Color(0xff145C9E),
              unselectedLabelColor: Colors.white70,
              indicatorSize: TabBarIndicatorSize.label,
              indicator: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                  color: Colors.white),
              tabs: [
                Tab(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text("MESSAGES"),
                  ),
                ),
                Tab(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text("FRIENDS"),
                  ),
                ),
                Tab(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text("REQUESTS"),
                  ),
                ),
              ]),
          //]),
        ),
        body: TabBarView(children: [
          ChatScreen(),
          FriendScreen(),
          RequestScreen(),
          //    ImageScreen(),
        ]));
    return DefaultTabController(length: 3, child: scaff);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    print("Bahar");
  }
}
