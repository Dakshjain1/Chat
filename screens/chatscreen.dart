//import 'dart:js';

import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_test/helpers/Username.dart';
import 'package:firebase_test/helpers/database.dart';
import 'package:firebase_test/helpers/shared.dart';
import 'package:firebase_test/screens/transitions/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'chatpage.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Stream chatList;
  DataService db = new DataService();
  @override
  void initState() {
    getUserChatList();
    super.initState();
  }

  getUserChatList() async {
    Constants.myname = await SharedPref.getUserNameSharedPreferences();
    Constants.myuid = await SharedPref.getUserIdSharedPreferences();
    await db.getUserChatListStream(Constants.myuid).then((snapshot) {
      setState(() {
        chatList = snapshot;
        print(snapshot);
      });
    });
  }

  Widget ChatList() {
    return StreamBuilder(
        stream: chatList,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? snapshot.data.docs.
              length != 0
                  ? AnimationLimiter(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (context, index) {
                            //print(snapshot.data.docs[index].collections('chats').;

                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: Duration(milliseconds: 1200),
                              child: SlideAnimation(
                                //horizontalOffset: 800.0,
                                  verticalOffset: 50.0,
                                    child: FadeInAnimation(
                                // delay: Duration(milliseconds: 100),     
                                child: ChatTile(
                                  snapshot.data.docs[index]
                                      .data()['chatRoomId']
                                      .toString()
                                      .replaceAll("_", "")
                                      .replaceAll(Constants.myuid, ""),
                                  snapshot.data.docs[index]
                                      .data()['chatRoomId'],
                                  snapshot.data.docs[index]
                                      .data()['lastMessage'],
                                  snapshot.data.docs[index]
                                      .data()['lastMessageType'],
                                  snapshot.data.docs[index]
                                      .data()['lastMessageTime'],
                                  //"true"
                                  snapshot.data.docs[index]
                                      .data()['shareLocation'],
                                ),
                                //    ),
                              ),
                            ));
                          }),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.message,size: 100,color: Colors.black54,),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "No chat messages",
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
                              "Start conversing to see your\n\t\t\t\t\t\t\t\t\t\t\t\t\t\tchats here!",
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
              : Center(child: Container(child: CircularProgressIndicator()));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ChatList(),
      ),
    );
  }
}

class ChatTile extends StatefulWidget {
  int lastMessageTime;
  String lastMessageType;
  String userId;
  String lastMessage;
  Map loactionShare;
  String chatId;
  //bool isImage;
  ChatTile(this.userId, this.chatId, this.lastMessage, this.lastMessageType,
      this.lastMessageTime, this.loactionShare);
  @override
  _ChatTileState createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  String display_url;
  String useremail;
  Stream personstream;
  var fsconnect = FirebaseFirestore.instance;
  DataService db = new DataService();
  @override
  void initState() {
    /*getUseremail(widget.username).then((value){
      setState(() {
        useremail = value;
      });
    });*/
    // print("Location" + widget.loactionShare);
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
    return widget.lastMessage != null
        ? StreamBuilder(
            stream: personstream,
            builder: (context, snapshot) {
              return snapshot.hasData
                  ? friend_tile(snapshot.data.data()['username'],
                      snapshot.data.data()['location'],
                      snapshot.data.data()['uid'], snapshot)
                  : Container(child: CircularProgressIndicator());
            })
        : Container();
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

  sendMessage(userId, username, profile, isActive, snap,location) async {
    List<String> members = [Constants.myuid, userId];
    String chatRoomId = getChatRoomId(Constants.myuid, userId);
    Map<String, dynamic> chatRoomMap = {
      'user': members,
      'chatRoomId': chatRoomId
    };
    await db.createChatRoom(chatRoomId, chatRoomMap).then((value) {
      print(chatRoomId);
      print('done');
      Navigator.push(
          context,
          PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                return ChatPage(
                  chatRoomId,
                  isActive,
                  username: username,
                  display_url: profile,
                  isShared: widget.loactionShare,
                  location: location,
                );
              },
              transitionDuration: Duration(milliseconds: 800),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeThroughTransition(
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  child: child,
                );
                //  SizeTransition(sizeFactor: animation,child: child,);
                //ScaleTransition(scale: animation,child: child,);
                //   FadeTransition(opacity: animation,child: child,);
              }));
    });
  }

  sendMess(chatRoomId, chatRoomMap) async {
    await db.createChatRoom(chatRoomId, chatRoomMap);
  }

  String readTimestamp(int timestamp) {
    print(timestamp);
    var now = DateTime.now();
    var format = DateFormat('HH:mm a');
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var diff = now.difference(date);
    var time = '';
    print(diff.inSeconds);
    print(diff.inDays);
    if (diff.inSeconds <= 0 ||
        diff.inSeconds > 0 && diff.inMinutes == 0 ||
        diff.inMinutes > 0 && diff.inHours == 0 ||
        diff.inHours > 0 && diff.inDays == 0) {
      time = format.format(date);
    } else if (diff.inDays > 0 && diff.inDays < 7) {
      if (diff.inDays == 1) {
        time = diff.inDays.toString() + ' DAY AGO';
      } else {
        time = diff.inDays.toString() + ' DAYS AGO';
      }
    } else {
      if (diff.inDays == 7) {
        time = (diff.inDays / 7).floor().toString() + ' WEEK AGO';
      } else {
        time = (diff.inDays / 7).round().toString() + ' WEEKS AGO';
      }
    }

    return time;
  }

  Widget friend_tile(username,location,userId, snapshot) {
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
    return Hero(
      tag: username,
      child: Card(
        color: Colors.white,
        shadowColor: Colors.blue,
        elevation: 10,
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

                  title: Material(
                    color: Colors.transparent,
                    child: Text(
                      username,
                      style:
                          /*GoogleFonts.brawler(
                            color: Colors.black87,
                            fontWeight: FontWeight.w700,
                            fontSize:18,
                            letterSpacing: 0.2
                          )*/
                          TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 19,
                              letterSpacing: 0.3),
                    ),
                  ),

                  onTap: () {
                    sendMessage(userId, username, display_url,
                        snapshot.data.data()['active'], snapshot,location);
                  },
                  subtitle: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: widget.lastMessageType == "FileType.image"
                            ? Row(
                                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(
                                    Icons.image,
                                    size: 24,
                                    color: Colors.black87,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text(
                                      'Photo',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                          letterSpacing: 0.2),
                                    ),
                                  )
                                ],
                              )
                            : widget.lastMessageType == "FileType.video"
                                ? Row(
                                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(
                                        Icons.videocam,
                                        size: 24,
                                        color: Colors.black87,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                          'Video',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87,
                                              letterSpacing: 0.2),
                                        ),
                                      )
                                    ],
                                  )
                                : widget.lastMessageType == "FileType.any"
                                    ? Row(
                                        //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Icon(
                                            Icons.insert_drive_file,
                                            size: 24,
                                            color: Colors.black87,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Text(
                                              'File',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black87,
                                                  letterSpacing: 0.2),
                                            ),
                                          )
                                        ],
                                      )
                                    : Text(
                                        widget.lastMessage ?? ' ',
                                        style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 16,
                                            letterSpacing: 0.2
                                            //   fontWeight: FontWeight.w300,
                                            ),
                                      ),
                      ),
                      //  Icon(Icons.last)
                      Text("• " + readTimestamp(widget.lastMessageTime))
                    ],
                  ),
                ),
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
      ),
    );
    /*OpenContainer(
            openColor: Colors.transparent,
            closedColor: Colors.transparent,
            transitionDuration: Duration(milliseconds: 900),
            openBuilder: (context, closeContainer) {
                     List<String> members = [Constants.myuid, userId];
                      String chatRoomId = getChatRoomId(Constants.myuid, userId);
                      Map<String, dynamic> chatRoomMap = {
                        'user': members,
                        'chatRoomId': chatRoomId
                      };
                        sendMess(chatRoomId, chatRoomMap);
                        print(chatRoomId);
                        print('done');
                        return ChatPage(chatRoomId,snapshot.data.data()['active'],chatRoomId,username: username,display_url: display_url,isShared: widget.loactionShare,);
                      
                    //return sendMess(userId, username, display_url,snapshot.data.data()['active'],snapshot);              
            },
            closedBuilder: (context, opencontainer){
                return   Card(
                  
                  color: Colors.white,
                  shadowColor: Colors.blue,
                  elevation: 10,
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
                        padding: const EdgeInsets.only(bottom : 4.0),
                        child: CircleAvatar(
                            backgroundImage: display_url != null
                                ? NetworkImage(display_url)
                                : NetworkImage(
                                    'https://raw.githubusercontent.com/juzer-patan/asset/master/download.png'),
                            radius: 25,
                          ),
                      ),
                      

                      title:  Material(
                            color: Colors.transparent,
                            child: Text(
                            username,
                            style: /*GoogleFonts.brawler(
                              color: Colors.black87,
                              fontWeight: FontWeight.w700,
                              fontSize:18,
                              letterSpacing: 0.2
                            )*/
                            TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 19,
                              letterSpacing: 0.3
                            ),
                        ),
                          ),
                      
                      onTap: () {
                          opencontainer();
                    //    sendMessage(userId,username,display_url,snapshot.data.data()['active'],snapshot);
                      },
                      subtitle: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: widget.lastMessageType == "FileType.image"
                                ? Row(
                                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(
                                        Icons.image,
                                        size: 24,
                                        color: Colors.black87,
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                          'Photo',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87,
                                            letterSpacing: 0.2
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                : widget.lastMessageType == "FileType.video" ?
                                   Row(
                                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(
                                        Icons.videocam,
                                        size: 24,
                                        color: Colors.black87,
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                          'Video',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87,
                                            letterSpacing: 0.2
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                : widget.lastMessageType == "FileType.any" ?
                                   Row(
                                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(
                                        Icons.insert_drive_file,
                                        size: 24,
                                        color: Colors.black87,
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                          'File',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87,
                                            letterSpacing: 0.2
                                          ),
                                        ),
                                      )
                                    ],
                                  )                          
                                : Text(
                                    widget.lastMessage ?? ' ',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,
                                      letterSpacing: 0.2
                                   //   fontWeight: FontWeight.w300,
                                    ),
                                  ),
                          ),
                        //  Icon(Icons.last)
                          Text(
                          "• " + readTimestamp(widget.lastMessageTime)
                          )
                        ],
                      ),
                    ),
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
     );*/
  }
}

/*
Hero(
        tag: username,
        child: Card(
                
                color: Colors.white,
                shadowColor: Colors.blue,
                elevation: 10,
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
                      padding: const EdgeInsets.only(bottom : 4.0),
                      child: CircleAvatar(
                          backgroundImage: display_url != null
                              ? NetworkImage(display_url)
                              : NetworkImage(
                                  'https://raw.githubusercontent.com/juzer-patan/asset/master/download.png'),
                          radius: 25,
                        ),
                    ),
                    

                    title:  Material(
                          color: Colors.transparent,
                          child: Text(
                          username,
                          style: /*GoogleFonts.brawler(
                            color: Colors.black87,
                            fontWeight: FontWeight.w700,
                            fontSize:18,
                            letterSpacing: 0.2
                          )*/
                          TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 19,
                            letterSpacing: 0.3
                          ),
                      ),
                        ),
                    
                    onTap: () {
                      sendMessage(userId,username,display_url,snapshot.data.data()['active'],snapshot);
                    },
                    subtitle: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: widget.lastMessageType == "FileType.image"
                              ? Row(
                                  //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(
                                      Icons.image,
                                      size: 24,
                                      color: Colors.black87,
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text(
                                        'Photo',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                          letterSpacing: 0.2
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              : widget.lastMessageType == "FileType.video" ?
                                 Row(
                                  //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(
                                      Icons.videocam,
                                      size: 24,
                                      color: Colors.black87,
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text(
                                        'Video',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                          letterSpacing: 0.2
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              : widget.lastMessageType == "FileType.any" ?
                                 Row(
                                  //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(
                                      Icons.insert_drive_file,
                                      size: 24,
                                      color: Colors.black87,
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text(
                                        'File',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                          letterSpacing: 0.2
                                        ),
                                      ),
                                    )
                                  ],
                                )                          
                              : Text(
                                  widget.lastMessage ?? ' ',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                    letterSpacing: 0.2
                                 //   fontWeight: FontWeight.w300,
                                  ),
                                ),
                        ),
                      //  Icon(Icons.last)
                        Text(
                        "• " + readTimestamp(widget.lastMessageTime)
                        )
                      ],
                    ),
                  ),
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
        
    ),
     );
*/
