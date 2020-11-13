//import 'dart:js';

import 'dart:async';
//import 'dart:js';
//import 'dart:js';
//import 'dart:html';
//import 'dart:js';

import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_test/helpers/Username.dart';
import 'package:firebase_test/helpers/database.dart';
import 'package:firebase_test/screens/search.dart';
import 'package:firebase_test/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'chatpage.dart';

class FriendScreen extends StatefulWidget {
  @override
  _FriendScreenState createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  bool isVisible = true;
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
//FriendTile(snapshot.data.data()['friends'][index]
  String friendname;
  List<String> friends = [];
  Widget FriendList() {
    return StreamBuilder(
        stream: friendStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? 
              snapshot.data.data()['friends'] != null
                  ? snapshot.data.data()['friends'].length != 0 ?
                  AnimationLimiter(
                        child: ListView.builder(
                        itemCount: snapshot.data.data()['friends'].length,
                        itemBuilder: (context, index) {
                          return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: Duration(milliseconds: 1200),
                                child: SlideAnimation(
                                  //horizontalOffset: 800.0,
                                    verticalOffset: 50.0,
                                      child: FadeInAnimation(
                                  // delay: Duration(milliseconds: 100),     
                                  child: FriendTile(snapshot.data.data()['friends'][index])
                                  //    ),
                                ),
                              ));
                            }),
                  )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sentiment_dissatisfied,size: 100,color: Colors.black54,),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "No friends to show",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Tap the search icon to add new friends!",
                              style: TextStyle(
                                fontSize: 19,
                                //fontWeight: FontWeight.w600,
                                color: Colors.black45
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
                          Icon(Icons.sentiment_dissatisfied,size: 100,color: Colors.black54,),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "No friends to show",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Tap the search icon to add new friends!",
                              style: TextStyle(
                                fontSize: 19,
                                //fontWeight: FontWeight.w600,
                                color: Colors.black45
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
              : Center(
                  child: CircularProgressIndicator(),
                );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FriendList(),
        floatingActionButton: OpenContainer(
            transitionDuration: Duration(milliseconds: 900),
            closedBuilder: (context, opencontainer) {
              return Visibility(
                visible: isVisible,
                child: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      isVisible = false;
                    });
                    opencontainer();
                  },
                  //() {
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(builder: (context) => Search()),
                  //   );

                  // },
                  child: Icon(Icons.search),
                ),
              );
            },
            openBuilder: (context, closeContainer) {
              return Search();
            },
            closedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(200)),
            openColor: Colors.white70,
            closedColor: Colors.blue,
            onClosed: (onClosed) {
              setState(() {
                isVisible = true;
              });
            }));
  }
}

class FriendTile extends StatefulWidget {
  String userId;
  FriendTile(this.userId);
  @override
  _FriendTileState createState() => _FriendTileState();
}

/*FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Search()),
          );
        },
        child: Icon(Icons.search),
      ),*/
class _FriendTileState extends State<FriendTile> {
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
                  snapshot.data.data()['location'],
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

  sendMessage(userId,username,display_url,isActive,location) async {
    var shareLoc;
    List<String> members = [Constants.myuid, userId];
    String chatRoomId = getChatRoomId(Constants.myuid, userId);
    Map<String, dynamic> chatRoomMap = {
      'user': members,
      'chatRoomId': chatRoomId
    };
    await db.createChatRoom(chatRoomId, chatRoomMap).then((value) async{
      await db.getChatRoomLocation(chatRoomId).then((value) async{
          if(value.data().containsKey("shareLocation")){
            print(value.data()['shareLocation']);
            shareLoc = value.data()['shareLocation'];
            print(chatRoomId);
            print('done');
            
                }
          else{
            shareLoc = {
              'status' : 'Not Enabled'
            };
            await db.disableLocationShare(chatRoomId);
          }
          print(shareLoc) ;
          Navigator.push(context,
                MaterialPageRoute(builder: (context) => ChatPage(chatRoomId,isActive, username: username,display_url: display_url,isShared: shareLoc,location: location,)));    
      });
      
    });
  }

  Widget friend_tile(username,location, userId, snapshot) {
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
                  
                  trailing: Material(
                    animationDuration: Duration(seconds: 2),
                    color: Colors.blueGrey.shade200,
                   // color: const Color(0xff2A75BC),
                    type: MaterialType.button,
                    shadowColor: Colors.black,
                    elevation: 10,
                    borderRadius: BorderRadius.circular(15),
                    child: MaterialButton(
                      child: Text(
                        "Remove",
                        style: TextStyle(
                         // color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                      onPressed: () {
                        print("something");
                      },
                    ),
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
                     sendMessage(userId,username,display_url,snapshot.data.data()['active'],location);
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
        sendMessage(userId);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
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
            )
          ],
        ),
      ),
    );
*/
