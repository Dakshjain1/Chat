//import 'dart:js';

import 'dart:async';
//import 'dart:js';
//import 'dart:html';
//import 'dart:js';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_test/helpers/Username.dart';
import 'package:firebase_test/helpers/database.dart';
import 'package:firebase_test/screens/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'chatpage.dart';

class RequestScreen extends StatefulWidget {
  @override
  _RequestScreenState createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  var fsconnect = FirebaseFirestore.instance;
  Stream friendStream;
  DataService db = new DataService();
  @override
  void initState() {
    getUserFriends();
    super.initState();
  }

  getUserFriends() async {
    await db.userSnap(Constants.myuid).then((snapshot) {
      setState(() {
        friendStream = snapshot;
        //   print(friendStream);
      });
    });
  }

  String friendname;
  List<String> friends = [];
  Widget FriendList() {
    return StreamBuilder(
        stream: friendStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? 
              snapshot.data.data()['requests'] != null
                  ? snapshot.data.data()['requests'].length != 0 ?
                  AnimationLimiter(
                        child: ListView.builder(
                        itemCount: snapshot.data.data()['requests'].length,
                        itemBuilder: (context, index) {
                          return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: Duration(milliseconds: 1200),
                                child: SlideAnimation(
                                  //horizontalOffset: 800.0,
                                    verticalOffset: 50.0,
                                      child: FadeInAnimation(
                                  // delay: Duration(milliseconds: 100),     
                                  child: RequestTile(snapshot.data.data()['requests'][index])
                                  //    ),
                                ),
                              ));
                            }),
                  )
                  :
                Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people,size: 100,color: Colors.black54,),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "No friend requests",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54
                              ),
                            ),
                          ),
                        
                        ],
                      ),
                    )  
              : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people,size: 100,color: Colors.black54,),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "No friend requests",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54
                              ),
                            ),
                          ),
                        
                        ],
                      ),
                    )
                :                    
              Center(
                  child: CircularProgressIndicator(),
                );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FriendList(),
    );
  }
}

class RequestTile extends StatefulWidget {
  String userId;
  RequestTile(this.userId);
  @override
  _RequestTileState createState() => _RequestTileState();
}

class _RequestTileState extends State<RequestTile> {
  String useremail;
  Stream personstream;
  String display_url;
  var fsconnect = FirebaseFirestore.instance;
  DataService db = new DataService();
  @override
  void initState() {
    /*getUseremail(widget.username).then((value){
      setState(() {
        useremail = value;
      });
    });*/
    getStream();
    super.initState();
  }

  getStream() async {
    await db.userSnap(widget.userId).then((snapshot) {
      setState(() {
        personstream = snapshot;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: personstream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? friend_tile(snapshot.data.data()['username'],
                  snapshot.data.data()['uid'], snapshot)
              : CircularProgressIndicator();
        });
  }

  getChatRoomId(String a, String b) {
    print(a.codeUnitAt(0));
    print(b.codeUnitAt(0));
    int i = 0;
    //int j=0;
    while (i < a.length && i < b.length) {
      if (a.codeUnitAt(i) > b.codeUnitAt(i)) {
        return "$a\_$b";
      } else if (a.codeUnitAt(i) < b.codeUnitAt(i)) {
        return "$b\_$a";
      } else {
        i++;
      }
    }
    if (a.length > i) {
      return "$a\_$b";
    } else {
      return "$b\_$a";
    }
  }

  

  acceptRequest(userId, otherId, username, othername) async {
    var result = await db.addFriend(userId, otherId);
    print(result);
    if (result != "failed") {
      print('added');
    }
  }

  declineRequest(userId, otherId) async {
    var result = await db.declineFriendRequest(userId, otherId);
    print(result);
    if (result != "failed") {
      print('removed');
    }
  }

  Widget friend_tile(username, userid, snapshot) {
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
    return Card(
      color: Colors.white,
      shadowColor: Colors.black87,
      elevation: 8,
      //    shadowColor: Color,
      child: Container(
        height: 70,
        //   padding: EdgeInsets.only(bottom: 4),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListTile(
                  //leading: Container(child: Icon(Icons.account_circle),//color: //Colors.white24,
                  leading: Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: CircleAvatar(
                      backgroundImage: display_url != null
                          ? NetworkImage(display_url)
                          : NetworkImage(
                              'https://raw.githubusercontent.com/juzer-patan/asset/master/download.png'),
                      radius: 25,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal : 2.0),
                        child: CircleAvatar(
                            backgroundColor: Colors.brown.shade100,
                            child: IconButton(
                             // color: Colors.blue,
                              icon: Icon(Icons.close),
                              onPressed: (){
                                declineRequest(Constants.myuid,userid);
                            },
                          ),
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: IconButton(
                          color: Colors.white,
                          icon: Icon(Icons.check),
                          onPressed: (){
                            acceptRequest(Constants.myuid,userid,Constants.myname,username);
                          },
                        ),
                      )
                    ],
                  ),
                  title: Material(
                    color: Colors.transparent,
                    child: Text(
                      username,
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          letterSpacing: 0.2),
                    ),
                  ),
                  onTap: () {
                   //  sendMessage(userid,username,display_url,snapshot.data.data()['active']);
                  },
                  subtitle: Text(snapshot.data.data()['email'])),
            ),
            /*   Container(
                  margin: EdgeInsets.only(left: 85),
                  height: 1.5,
                  width: 300,
                  color: Color(0xff145C9E),
                ),*/
          ],
        ),
      ),
    );
  }
}

/*
GestureDetector(
            onTap: () {
           //     sendMessage(username);
            },
            child: Container(
            padding : EdgeInsets.only(top: 20,bottom: 20,left: 24),   
            //padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              //mainAxisAlignment: MainAxisAlignment,
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                Row(
                  
                  children: [
                    Text(
                      username,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                         color: Colors.white,
                         fontSize: 16,
                         fontFamily: 'OverpassRegular',
                         fontWeight: FontWeight.w500,
                         letterSpacing: 1.0,
                      ),
                      
                    ),
                    SizedBox(
                        width : MediaQuery.of(context).size.width * 0.48
                    ),
                    GestureDetector(
                  onTap: () {
                    acceptRequest(Constants.myuid,userid,Constants.myname,username);
                  },
                    child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey.shade400,
                    ),
                    child: Icon(Icons.check,size: 30,),
                  ),
                                  ),
                  SizedBox(
                      width: 4,
                  ) ,               
                  GestureDetector(
                  onTap: () {
                    declineRequest(Constants.myuid,userid);
                  },
                    child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color(0xff145C9E),
                    ),
                    child: Icon(Icons.close,size: 30,),
                  ),
                                  ),
                
                  ],
                ),
                
                
              ],
            ),    
          ),
        );
*/
