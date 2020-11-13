//import 'dart:js';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_test/helpers/Username.dart';
import 'package:firebase_test/helpers/database.dart';
import 'package:firebase_test/screens/chatpage.dart';
import 'package:firebase_test/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  String slate;
  bool friends = false;
  bool isLoading = false;
  bool isSearching = false;
  Icon actionIcon = Icon(
    Icons.search,
    color: Colors.white,
  );
  Widget appBarTitle = Text(
    "Search Friend",
    style: GoogleFonts.cairo(
      fontSize: 22,
      fontWeight: FontWeight.w500,
    ),
  );
  DataService db = new DataService();
  TextEditingController searchController = new TextEditingController();
  var searchSnap;
  serachUser() async {
    if (searchController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      await db.getUserbyName(searchController.text).then((snapshots) {
        setState(() {
          searchSnap = snapshots;
          //  print(searchSnap);
          isLoading = false;
          isSearching = true;
        });
      });
    }
  }

  Widget userList() {
    print(isSearching);
    return isSearching
        ? searchSnap.docs.length != 0
            ? ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  print(searchSnap);

                  return UserTile(
                    searchSnap.docs[index].data()['username'],
                    searchSnap.docs[index].data()['email'],
                    searchSnap.docs[index].data()['uid'],
                    searchSnap,
                    index,
                  );
                },
                itemCount: searchSnap.docs.length,
              )
            : Container(
                height: MediaQuery.of(context).size.height * 0.88,
                // alignment: Ali,
                child: Image.network(
                  'https://cdn.dribbble.com/users/874140/screenshots/3489641/ghost_result.gif',
                  fit: BoxFit.cover,
                ),
                color: Colors.grey,
              )
        : Container();
  }

  void _handleSearchEnd() {
    setState(() {
      this.actionIcon = new Icon(
        Icons.search,
        color: Colors.white,
        size: 24,
      );
      this.appBarTitle = new Text(
        "Search Friend",
        style: GoogleFonts.cairo(
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
      );
      isSearching = false;
      searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white54,
        appBar: AppBar(
          centerTitle: false,
          title: appBarTitle,
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 0.0),
              child: new IconButton(
                icon: actionIcon,
                onPressed: () {
                  setState(() {
                    if (this.actionIcon.icon == Icons.search) {
                      this.actionIcon = new Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      );
                      this.appBarTitle = new TextField(
                        controller: searchController,
                        style: new TextStyle(
                          color: Colors.white,
                        ),
                        onSubmitted: (v) {
                          serachUser();
                        },
                        decoration: new InputDecoration(
                            prefixIcon:
                                new Icon(Icons.search, color: Colors.white),
                            hintText: "Search by username...",
                            hintStyle: new TextStyle(color: Colors.white)),
                      );
                      //_handleSearchStart();
                    } else {
                      _handleSearchEnd();
                    }
                  });
                },
              ),
            ),
          ],
        ),
        body: isLoading
            ? Center(
                child: Container(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.amberAccent),
                  ),
                ),
              )
            : Column(
                children: [
                  /*  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 40),
                    //  height: MediaQuery.of(context).size.height * 0.1,
                    //color: Colors.blue,

                    child: Card(
                      elevation: 8,
                      color: Colors.white,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: TextField(
                                controller: searchController,
                                style: simpleTextStyle(),
                                decoration: InputDecoration(
                                    hintText: 'search by username',
                                    hintStyle: TextStyle(
                                        color: Colors.white70, fontSize: 16.0),
                                    border: InputBorder.none),
                              ),
                            ),
                          ),
                          Container(
                            // color: Colors.blueGrey,
                            decoration: BoxDecoration(
                                //      color: Colors.blueGrey,
                                borderRadius: BorderRadius.circular(30)),
                            child: IconButton(
                                icon: Icon(Icons.search),
                                onPressed: () {
                                  serachUser();
                                }),
                          )
                        ],
                      ),
                    ),
                  ),*/
                  userList(),
                ],
              ));
  }
}

class UserTile extends StatefulWidget {
  String userId;
  String username;
  String email;
  var searchSnap;
  int index;
  UserTile(
    this.username,
    this.email,
    this.userId,
    this.searchSnap,
    this.index,
  );

  @override
  _UserTileState createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  DataService db = new DataService();
  bool friends;
  bool requested;
  @override
  void initState() {
    isFriend();
    isRequested();
    super.initState();
  }

  isFriend() {
    try {
      if (widget.searchSnap.docs[widget.index]
          .data()['friends']
          .contains(Constants.myuid)) {
        setState(() {
          friends = true;
          print('yes');
        });
      } else {
        setState(() {
          friends = false;
          //print(sear);
        });
      }
    } catch (e) {
      setState(() {
        friends = false;
        print('no');
      });
    }
  }

  isRequested() {
    try {
      if (widget.searchSnap.docs[widget.index]
          .data()['requests']
          .contains(Constants.myuid)) {
        setState(() {
          requested = true;
          print('yes');
        });
      } else {
        setState(() {
          requested = false;
          //print(sear);
        });
      }
    } catch (e) {
      setState(() {
        requested = false;
        print('no');
      });
    }
  }

  Widget addFriendTile(username, userId) {
    return Material(
      animationDuration: Duration(seconds: 2),
      color: Colors.white,
      // color: Colors.blueGrey.shade200,
      // color: const Color(0xff2A75BC),
      type: MaterialType.button,
      shadowColor: Colors.black,
      elevation: 10,
      borderRadius: BorderRadius.circular(15),
      child: MaterialButton(
        child: Text(
          "Add Friend",
          style: TextStyle(
            // color: Colors.black54,
            fontSize: 16,
          ),
        ),
        onPressed: () {
          addFriend(Constants.myuid, userId);
        },
      ),
    );
    /* GestureDetector(
      onTap: () {
        addFriend(Constants.myuid, userId);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            //color: Color(0xff145C9E),
            gradient: LinearGradient(
              colors: [
                const Color(0xff007EF4),
                const Color(0xff2A75BC),
              ],
            ),
            boxShadow: [
              BoxShadow(
                offset: Offset.fromDirection(5),
                color: Colors.black,
                blurRadius: 3.0,
                spreadRadius: 0.5,
              ),
            ]),
        child: Text(
          'Add Friend',
          style: biggerTextStyle(),
        ),
      ),
    );*/
  }

  Widget sendMessageTile(userName, userId) {
    return Material(
      animationDuration: Duration(seconds: 2),
      color: const Color(0xff007EF4),
      //color: const Color(0xff2A75BC),
      type: MaterialType.button,
      shadowColor: Colors.white,
      elevation: 5,
      borderRadius: BorderRadius.circular(15),
      child: MaterialButton(
        child: Text(
          "Send Message",
          style: TextStyle(
            //  color: Colors.black54,
            fontSize: 16,
          ),
        ),
        onPressed: () {
          //  addFriend(Constants.myuid, userId);
        },
      ),
    );
    /* GestureDetector(
      onTap: () {
        sendMessage(userName, userId);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            //color: Color(0xff145C9E),
            gradient: LinearGradient(
              colors: [const Color(0xff007EF4), const Color(0xff2A75BC)],
            ),
            boxShadow: [
              BoxShadow(
                offset: Offset.fromDirection(5),
                color: Colors.black,
                blurRadius: 3.0,
                spreadRadius: 0.5,
              ),
            ]),
        child: Text(
          'Send Message',
          style: biggerTextStyle(),
        ),
      ),
    );*/
  }

  Widget requestedTile() {
    return Material(
      animationDuration: Duration(seconds: 2),
      color: Colors.white,
      //color: Colors.blueGrey.shade200,
      //color: const Color(0xff2A75BC),
      type: MaterialType.button,
      shadowColor: Colors.white,
      elevation: 5,
      borderRadius: BorderRadius.circular(15),
      child: MaterialButton(
        child: Text(
          "Requested",
          style: TextStyle(
            //  color: Colors.black54,
            fontSize: 16,
          ),
        ),
        onPressed: () {
          //  addFriend(Constants.myuid, userId);
        },
      ),
    );
  }

  addFriend(userId, otherId) async {
    var result = await db.requestFriend(userId, otherId);
    print(result);
    if (result != "failed") {
      setState(() {
        requested = true;
        print('yessss');
        print(requested);
      });
      print('added');
    }
  }

  sendMessage(userName, userId) async {
    List<String> members = [Constants.myuid, userId];
    String chatRoomId = getChatRoomId(Constants.myuid, userId);
    Map<String, dynamic> chatRoomMap = {
      'user': members,
      'chatRoomId': chatRoomId
    };
    await db.createChatRoom(chatRoomId, chatRoomMap).then((value) {
      print(chatRoomId);
      print('done');
      //  Navigator.push(context,
      //       MaterialPageRoute(builder: (context) => ChatPage(chatRoomId,)));
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(color: Colors.blueGrey
            //orderRadius: BorderRadius.circular(20),

            ),
        //height: 30,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.username,
                  // style: simpleTextStyle(),
                  style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  widget.email,
                  style: TextStyle(fontSize: 18.0, color: Colors.white70),
                ),
              ],
            ),
            friends != null
                ? friends
                    ? sendMessageTile(widget.username, widget.userId)
                    : requested != null
                        ? requested
                            ? requestedTile()
                            : addFriendTile(widget.username, widget.userId)
                        : addFriendTile(widget.username, widget.userId)
                : CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

/*
Widget userTile(userName,email){
    return  Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24,vertical: 16),
        decoration: BoxDecoration(
          color: Colors.blueGrey
          //orderRadius: BorderRadius.circular(20),
          
        ),
        //height: 30,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              userName,
                             // style: simpleTextStyle(),
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.white70
                              ),
                              ),
                          
                          Text(email,style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.white70
                              ),
                              ),  
                        ],
                      ),
                      
                      friends != null ? friends ? sendMessageTile(userName) : addFriendTile(userName) : CircularProgressIndicator(),
            ],
          ),
        
      ),
    );
  }

  isFriend() {
    try{
              if(searchSnap.docs[0].data()['friends'].contains(Constants.myname)){
               setState(() {
                 
               });
                  friends = true;
                  print('yes');
                
              }
              else{
                  setState(() {
                    
                  
                  friends = false;
                 //print(sear);
                });
              }
            }catch(e){
              setState(() {
                
              
                friends =false;
                print('no');
              });
            }
  }

  Widget addFriendTile(username){
    return RaisedButton(
                          onPressed: (){
                        //    addFriend(Constants.myname,username);
                          },
                          child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 24,vertical: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            //color: Color(0xff145C9E),
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xff007EF4),
                                const Color(0xff2A75BC)
                              ],
                            ),
                            boxShadow: [
                                BoxShadow(
                                  offset: Offset.fromDirection(5),
                                  color: Colors.black,
                                  blurRadius: 3.0,
                                  spreadRadius: 0.5,
                                ),
                                
                            ]
                          ),
                          child: Text(
                           'Add Friend',
                            style: biggerTextStyle(),
                          ),
                          
                        ),
                      );
  }

  Widget sendMessageTile(userName){
    return GestureDetector(
                          onTap: (){
                            sendMessage(userName);
                          },
                          child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 24,vertical: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            //color: Color(0xff145C9E),
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xff007EF4),
                                const Color(0xff2A75BC)
                              ],
                            ),
                            boxShadow: [
                                BoxShadow(
                                  offset: Offset.fromDirection(5),
                                  color: Colors.black,
                                  blurRadius: 3.0,
                                  spreadRadius: 0.5,
                                ),
                                
                            ]
                          ),
                          child: Text(
                            'Send Message',
                            style: biggerTextStyle(),
                          ),
                          
                        ),
                      );
  }
  /*addFriend(userName,otherName) async{
      var result = await db.addFriend(userName, otherName);
      if(result != null){
        setState(() {
          friends = true;
        });
        print('added');
      }
  }*/

  sendMessage( userName) async{
      List<String> members = [Constants.myname,userName];
      String chatRoomId = getChatRoomId(Constants.myname,userName);
      Map<String,dynamic> chatRoomMap = {
        'user' : members,
        'chatRoomId' : chatRoomId
      };
      await db.createChatRoom(chatRoomId, chatRoomMap).then((value) {
        print(chatRoomId);
        print('done');
        Navigator.push(context, MaterialPageRoute(builder: (context)=> ChatPage(chatRoomId)));
      });
  }

  getChatRoomId(String a, String b) {
    print(a.codeUnitAt(0));
    print(b.codeUnitAt(0));
    int i =0;
    //int j=0;
    while(i < a.length && i < b.length){
      if(a.codeUnitAt(i) > b.codeUnitAt(i)){
        return "$a\_$b";
      }
      else if(a.codeUnitAt(i) < b.codeUnitAt(i)){
        return "$b\_$a";
      }
      else{
        i++;
      }
    }
    if(a.length > i){
        return "$a\_$b";
    }
    else{
      return "$b\_$a";
    }
    
  }
*/
