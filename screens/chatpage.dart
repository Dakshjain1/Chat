//import 'dart:html';
//import 'dart:js';

//import 'dart:html';

import 'dart:async';
import 'dart:io';
//import 'dart:js';
//import 'dart:js';
//import 'dart:js';
//import 'dart:js';
//import 'dart:js';

import 'package:animations/animations.dart';
import 'package:bubble/bubble.dart';
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_test/helpers/Username.dart';
import 'package:firebase_test/helpers/database.dart';
import 'package:firebase_test/screens/imageview.dart';
import 'package:firebase_test/screens/navigationmap.dart';
import 'package:firebase_test/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as p;

class ChatPage extends StatefulWidget {
  Map location;
  String chatRoomId;
  String username;
  String display_url;
  bool isActive;
  Map isShared;
  String chatId;

  ChatPage(this.chatRoomId, this.isActive,
      {this.username, this.display_url, this.isShared,this.location});
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  File path;
  String isEnabled;
  bool notify = false;
  bool isVisible = true;
  String any;
  Stream chats;
  ScrollController _controller = new ScrollController();
  DataService db = new DataService();
  TextEditingController messageController = new TextEditingController();
  Widget chatMessages() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.80,
      margin: EdgeInsets.only(bottom: 60),
      //padding: EdgeInsets.only(bottom: 30),
      child: StreamBuilder(
        stream: chats,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  controller: _controller,
                  //reverse: true,
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    //snapshot.data.docs[index].data().
                    return MessageTile(
                        snapshot.data.docs[index].data()['type'],
                        snapshot.data.docs[index].data()['message'],
                        Constants.myuid ==
                            snapshot.data.docs[index].data()['sendBy'],
                        snapshot.data.docs[index].data()['timeStamp']);
                  },
                )
              : Container();
        },
      ),
    );
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        'type': "text",
        'message': messageController.text,
        'sendBy': Constants.myuid,
        'timeStamp': DateTime.now().millisecondsSinceEpoch,
      };
      db.addMessage(widget.chatRoomId, messageMap).then((value) {
        messageController.clear();
        Timer(Duration(milliseconds: 300),
            () => _controller.jumpTo(_controller.position.maxScrollExtent));
      });
    }
  }

  @override
  void initState() {
    print(widget.isShared);
    setState(() {
      isEnabled = widget.isShared['status'];
    });
    getShareUpdate();
    //  showAlert();
    getUserChats();
    super.initState();
  }

  getShareUpdate() {
    if (widget.isShared['status'] == "Requested") {
      if (widget.isShared['requestBy'] != Constants.myuid) {
        // showAlert();
        setState(() {
          notify = true;
        });
      }
    }
  }

  showAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${widget.username} has requested you to share location'),
          content: Text("Do you Agree ?"),
          actions: <Widget>[
            FlatButton(
              child: Text("YES"),
              onPressed: () async {
                //Put your code here which you want to execute on Yes button click.
                // Navigator.of(context).pop();
                await db.enableLocationShare(widget.chatRoomId);
                Fluttertoast.showToast(
                      msg: "Location Share Permission Enabled!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.SNACKBAR,
                      timeInSecForIosWeb: 3,
                      backgroundColor: Colors.black45,
                      textColor: Colors.white,
                      fontSize: 18.0
                  );
                setState(() {
                  notify = false;
                  widget.isShared['status'] = "Enabled";
                });
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("NO"),
              onPressed: () async {
                //Put your code here which you want to execute on No button click.
                //  Navigator.of(context).pop();
                await db.disableLocationShare(widget.chatRoomId);
                Fluttertoast.showToast(
                      msg: "Location Share Permission Disabled!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.SNACKBAR,
                      timeInSecForIosWeb: 3,
                      backgroundColor: Colors.black45,
                      textColor: Colors.white,
                      fontSize: 18.0
                  );
                setState(() {
                  notify = false;
                  widget.isShared['status'] = "Not Enabled";
                });
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("CANCEL"),
              onPressed: () {
                //Put your code here which you want to execute on Cancel button click.
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  getUserChats() async {
    await db.getUserChatStream(widget.chatRoomId).then((snapshot) {
      setState(() {
        chats = snapshot;
      });
    });
  }

  sendImage() async {
    // var camera = ImageSource.camera;
    var image_pick = new ImagePicker();
    var img = await image_pick.getImage(source: ImageSource.camera);
    setState(() {
      path = File(img.path);
    });
    await db.addChatImage(widget.chatRoomId, path, ".jpg").then((value) async {
      print(value);
      if (value != null) {
        print("image uploading");
        Map<String, dynamic> messageMap = {
          'type': FileType.image.toString(),
          'message': value,
          'sendBy': Constants.myuid,
          'timeStamp': DateTime.now().millisecondsSinceEpoch,
        };
        db.addMessage(widget.chatRoomId, messageMap).then((value) {
          messageController.clear();
          Timer(Duration(milliseconds: 300),
              () => _controller.jumpTo(_controller.position.maxScrollExtent));
        });
      } else {
        print("image not uploading");
      }
    });
    print(img.path);
  }

  showAttach() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: Icon(Icons.image),
                  title: Text('Image'),
                  onTap: () => showFilePicker(FileType.image)),
              ListTile(
                  leading: Icon(Icons.videocam),
                  title: Text('Video'),
                  onTap: () => showFilePicker(FileType.video)),
              ListTile(
                leading: Icon(Icons.insert_drive_file),
                title: Text('File'),
                onTap: () => showFilePicker(FileType.any),
              ),
            ],
          ),
        );
      },
    );
  }

  showFilePicker(fileType) async {
    var filePicked = await FilePicker.platform.pickFiles(type: fileType);
    print(fileType);
    //  print(filePicked.paths[0]);
    setState(() {
      path = File(filePicked.paths[0]);
      print(path);

      //  print(path.runtimeType);
    });
    var type = p.extension(path.toString());
    await db.addChatImage(widget.chatRoomId, path, type).then((value) async {
      print(value);
      if (value != null) {
        print("image uploading");
        Map<String, dynamic> messageMap = {
          'type': fileType.toString(),
          'message': value,
          'sendBy': Constants.myuid,
          'timeStamp': DateTime.now().millisecondsSinceEpoch,
        };
        db.addMessage(widget.chatRoomId, messageMap).then((value) {
          messageController.clear();
          Timer(Duration(milliseconds: 300),
              () => _controller.jumpTo(_controller.position.maxScrollExtent));
        });
      } else {
        print("image not uploading");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Type of data" + widget.location['lat'].runtimeType.toString());
    // showAlert();
    return Scaffold(
      backgroundColor: Colors.grey.shade400,
      appBar: PreferredSize(
        preferredSize: new AppBar().preferredSize,
        child: Hero(
          tag: widget.username,
          child: AppBar(
            automaticallyImplyLeading: false,
            titleSpacing: 0.0,
            title: Material(
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  /*           BackButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                  ),*/

                  CircleAvatar(
                    radius: 23,
                    backgroundImage: NetworkImage(widget.display_url),
                    //   backgroundColor: Colors.red,
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            widget.username,
                            style: TextStyle(
                                color: Colors.white,
                                //color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 19,
                                letterSpacing: 0.2),
                          ),
                          widget.isActive
                              ? Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 4,
                                      backgroundColor:
                                          Colors.lightGreenAccent.shade400,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      child: Text(
                                        "Active Now",
                                        style: TextStyle(
                                            color: Colors.white70,
                                            //color: Colors.black87,
                                            fontWeight: FontWeight.w600,
                                            //fontSize: ,
                                            letterSpacing: 0.2),
                                      ),
                                    ),
                                  ],
                                )
                              : Container()
                        ],
                      )),
                ],
              ),
            ),
            leading: BackButton(),
            elevation: 10,
            shadowColor: Colors.black,
            centerTitle: false,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.attach_file,
                  size: 30.0,
                ),
                onPressed: () {
                  showAttach();
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.location_on,
                  size: 30.0,
                ),
                onPressed: () {
                  widget.isShared['status'] == "Enabled"
                      ? Navigator.push(context,
                          MaterialPageRoute(builder: (context) => MapNav(widget.location['lat'],widget.location['long'])))
                      : Fluttertoast.showToast(
        msg: "Permission denied..Click '  \u{22EE}  ' to request permission for location share!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.black45,
        textColor: Colors.white,
        fontSize: 18.0
    );
                },
              ),
              notify
                  ? GestureDetector(
                      onTap: () {
                        showAlert();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4.0),

                        child: Icon(
                          Icons.notification_important,
                          color: Colors.red,
                          size: 25,
                        ),
                        // child: Text("1",style: TextStyle(color: Colors.black,),),
                      ),
                    )
                  : PopupMenuButton(
                      //  offset: Offset.fromDirection(90),
                      itemBuilder: (context) => [
                            PopupMenuItem(
                                value: 1,
                                child: widget.isShared['status'] == "Enabled"
                                    ? Text("Location Share Enabled")
                                    : GestureDetector(
                                        onTap: () async {
                                          await db.requestLocationShare(
                                              widget.chatRoomId);
                                        },
                                        child: Text("Request Location Share"),
                                      )),
                          ])
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            chatMessages(),
            //Padding(padding: EdgeInsets.symmetric(vertical: 15)),
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.08,
                margin: EdgeInsets.only(bottom: 5),
                //alignment: Alignment.bottomCenter,
                width: MediaQuery.of(context).size.width,
                //height: MediaQuery.of(context).size.height * ,
                //  padding: EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.88,
                      padding: EdgeInsets.only(left: 24, right: 5),
                      //  color: Color(0x54FFFFFF),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          //   border: Border.all(
                          //   style: BorderStyle.solid,
                          // ),

                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(color: Colors.white, blurRadius: 1.05),
                          ]),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: TextField(
                              //keyboardType: Emoji,
                              controller: messageController,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                              decoration: InputDecoration(
                                  hintText: "Message ...",
                                  hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                  border: InputBorder.none),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.camera_alt,
                              size: 25,
                              color: Colors.black54,
                            ),
                            onPressed: () {
                              sendImage();
                            },
                          )
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        sendMessage();
                      },
                      /*  child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                            color: Color(0xff145C9E),
                            borderRadius: BorderRadius.circular(20)),
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),*/
                      child: CircleAvatar(
                        radius: 23,
                        backgroundColor: Color(0xff145C9E),
                        child: Icon(
                          Icons.send,
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  //String image;
  // bool isImage;
  String type;
  String message;
  bool sendByMe;
  int timeStamp;
  MessageTile(this.type, this.message, this.sendByMe, this.timeStamp);

  void showVideoPlayer(parentContext, String videoUrl) async {
    await showModalBottomSheet(
        context: parentContext,
        builder: (BuildContext bc) {
          return VideoPlayerWidget(videoUrl);
        });
  }

  void downloadFile(url) async {
    var status = await Permission.storage.request();
    print(status);
    print(status.isGranted);
    final Directory extDir = await getExternalStorageDirectory();
    String dirPath = '${extDir.path}/Downloads';
    print(dirPath);
    dirPath =
        dirPath.replaceAll("Android/data/com.juzer.firebase_test/files/", "");
    print(dirPath);
    final savedDir = Directory(dirPath);
    bool hasExisted = savedDir.existsSync();
    if (!hasExisted) {
      print("exists");
      savedDir.createSync();
    }

    await FlutterDownloader.enqueue(
      url: url,
      savedDir: dirPath,
      showNotification: true,
      openFileFromNotification: true,
    );
  }

  String readTimestamp(int timestamp) {
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

  @override
  Widget build(BuildContext context) {
    print(type);
    print(message);
    //Image
    return type == "FileType.image"
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                margin: EdgeInsets.only(
                    top: 8,
                    bottom: 8,
                    left: sendByMe ? 0 : 12,
                    right: sendByMe ? 12 : 0),
                //    padding: EdgeInsets.only(
                //        top: 4, bottom: 4, left: sendByMe ? 0 : 8, right: sendByMe ? 8 : 0),
                alignment:
                    sendByMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                    // margin:
                    //     sendByMe ? EdgeInsets.only(left: 15) : EdgeInsets.only(right: 15),
                    // alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                    height: MediaQuery.of(context).size.height * 0.30,
                    width: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      //  shape: BoxShape.circle,
                      borderRadius: sendByMe
                          ? BorderRadius.only(
                              topLeft: Radius.circular(18),
                              topRight: Radius.circular(18),
                              bottomLeft: Radius.circular(18))
                          : BorderRadius.only(
                              topLeft: Radius.circular(18),
                              topRight: Radius.circular(18),
                              bottomRight: Radius.circular(18)),
                      gradient: LinearGradient(
                          colors: sendByMe
                              ? [
                                  const Color(0xff007EF4),
                                  const Color(0xff2A75BC)
                                ]
                              : [Color(0xffE8E8E8), Color(0xffE8E8E8)]),
                      /*       image: DecorationImage(
                  fit: BoxFit.fill,      
                  image: NetworkImage(
                    message,
      //          scale: 0.8
                    ) 
                  )*/
                    ),
                    child: OpenContainer(
                      transitionDuration: Duration(milliseconds: 900),
                      closedBuilder: (context, opencontainer) {
                        return Visibility(
                          visible: true,
                          child: GestureDetector(
                            onTap: () {
                              opencontainer();
                              // Navigator.push(context, MaterialPageRoute(builder: (context)=> ImageShow(message)));
                            },
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: FadeInImage.assetNetwork(
                                  placeholder: "assets/loading.gif",
                                  image: message,
                                  fit: BoxFit.fill,
                                )
                                /*Image(
                                fit: BoxFit.fill,
                                image: NetworkImage(
                                  message,
                                ),
                              ),*/
                                ),
                          ),
                        );
                      },
                      openBuilder: (context, closeContainer) {
                        return ImageShow(message);
                      },
                      closedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      openColor: Colors.transparent,
                      closedColor: Colors.transparent,
                      //   onClosed: (onClosed){
                      //     setState(() {
                      //        isVisible = true;
                      //       });
                      //     }
                    )
                    /*    child: Image.network(
                
                message,
                height: MediaQuery.of(context).size.height * 0.30,
            width: MediaQuery.of(context).size.width * 0.6,
                fit: BoxFit.fill
              ),*/
                    ),
              ),
              Container(
                alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(readTimestamp(timeStamp)),
              )
            ],
          )
        : type == "FileType.video"
            ? Column(
                crossAxisAlignment: sendByMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        top: 8,
                        bottom: 8,
                        left: sendByMe ? 0 : 12,
                        right: sendByMe ? 12 : 0),
                    //    padding: EdgeInsets.only(
                    //        top: 4, bottom: 4, left: sendByMe ? 0 : 8, right: sendByMe ? 8 : 0),
                    alignment:
                        sendByMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                        // margin:
                        //     sendByMe ? EdgeInsets.only(left: 15) : EdgeInsets.only(right: 15),
                        // alignment: Alignment.centerRight,
                        padding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                        height: MediaQuery.of(context).size.height * 0.30,
                        width: MediaQuery.of(context).size.width * 0.6,
                        decoration: BoxDecoration(
                          //  shape: BoxShape.circle,
                          borderRadius: sendByMe
                              ? BorderRadius.only(
                                  topLeft: Radius.circular(18),
                                  topRight: Radius.circular(18),
                                  bottomLeft: Radius.circular(18))
                              : BorderRadius.only(
                                  topLeft: Radius.circular(18),
                                  topRight: Radius.circular(18),
                                  bottomRight: Radius.circular(18)),
                          gradient: LinearGradient(
                              colors: sendByMe
                                  ? [
                                      const Color(0xff007EF4),
                                      const Color(0xff2A75BC)
                                    ]
                                  : [Color(0xffE8E8E8), Color(0xffE8E8E8)]),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Stack(
                                alignment: AlignmentDirectional.center,
                                children: <Widget>[
                                  Container(
                                    //  width: 130,
                                    color: Colors.black,
                                    height: 130,
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Icon(
                                        Icons.videocam,
                                        color: Colors.white,
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        'Video',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                  height: 50,
                                  child: IconButton(
                                      icon: Icon(
                                        Icons.play_arrow,
                                        color: sendByMe
                                            ? Colors.white
                                            : Colors.black,
                                        size: 30,
                                      ),
                                      onPressed: () =>
                                          showVideoPlayer(context, message)))
                            ],
                          ),
                        )),
                  ),
                  Container(
                    alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(readTimestamp(timeStamp)),
                  )
                ],
              )
            : type == "FileType.any"
                ? Column(
                    crossAxisAlignment: sendByMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            top: 8,
                            bottom: 8,
                            left: sendByMe ? 0 : 12,
                            right: sendByMe ? 12 : 0),
                        //    padding: EdgeInsets.only(
                        //        top: 4, bottom: 4, left: sendByMe ? 0 : 8, right: sendByMe ? 8 : 0),
                        alignment: sendByMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                            // margin:
                            //     sendByMe ? EdgeInsets.only(left: 15) : EdgeInsets.only(right: 15),
                            // alignment: Alignment.centerRight,
                            padding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 5),
                            height: MediaQuery.of(context).size.height * 0.30,
                            width: MediaQuery.of(context).size.width * 0.6,
                            decoration: BoxDecoration(
                              //  shape: BoxShape.circle,
                              borderRadius: sendByMe
                                  ? BorderRadius.only(
                                      topLeft: Radius.circular(18),
                                      topRight: Radius.circular(18),
                                      bottomLeft: Radius.circular(18))
                                  : BorderRadius.only(
                                      topLeft: Radius.circular(18),
                                      topRight: Radius.circular(18),
                                      bottomRight: Radius.circular(18)),
                              gradient: LinearGradient(
                                  colors: sendByMe
                                      ? [
                                          const Color(0xff007EF4),
                                          const Color(0xff2A75BC)
                                        ]
                                      : [Color(0xffE8E8E8), Color(0xffE8E8E8)]),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Stack(
                                    alignment: AlignmentDirectional.center,
                                    children: <Widget>[
                                      Container(
                                        //  width: 130,
                                        color: Colors.black,
                                        height: 130,
                                      ),
                                      Column(
                                        children: <Widget>[
                                          Icon(
                                            Icons.insert_drive_file,
                                            color: Colors.white,
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            'File',
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                      height: 50,
                                      child: IconButton(
                                          icon: Icon(
                                            Icons.file_download,
                                            color: sendByMe
                                                ? Colors.white
                                                : Colors.black,
                                            size: 30,
                                          ),
                                          onPressed: () =>
                                              downloadFile(message)))
                                ],
                              ),
                            )),
                      ),
                      Container(
                        alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
                        padding: const EdgeInsets.all(12.0),
                        child: Text(readTimestamp(timeStamp)),
                      )
                    ],
                  )
                : Column(
                    crossAxisAlignment: sendByMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                            top: 8,
                            bottom: 8,
                            left: sendByMe ? 0 : 12,
                            right: sendByMe ? 12 : 0),
                        alignment: sendByMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: sendByMe
                              ? EdgeInsets.only(left: 30)
                              : EdgeInsets.only(right: 30),
                          padding: EdgeInsets.only(
                              top: 17, bottom: 17, left: 20, right: 20),
                          decoration: BoxDecoration(
                              borderRadius: sendByMe
                                  ? BorderRadius.only(
                                      topLeft: Radius.circular(23),
                                      topRight: Radius.circular(23),
                                      bottomLeft: Radius.circular(23))
                                  : BorderRadius.only(
                                      topLeft: Radius.circular(23),
                                      topRight: Radius.circular(23),
                                      bottomRight: Radius.circular(23)),
                              gradient: LinearGradient(
                                  colors: sendByMe
                                      ? [
                                          const Color(0xff007EF4),
                                          const Color(0xff2A75BC)
                                        ]
                                      : [Color(0xffE8E8E8), Color(0xffE8E8E8)]
                                  //  [Colors.white30, Colors.white10],
                                  //     stops: [0.9,1.8]
                                  )),
                          child: Text(message,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color: sendByMe ? Colors.white : Colors.black,
                                  fontSize: 16,
                                  fontFamily: 'OverpassRegular',
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                      Container(
                        alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(readTimestamp(timeStamp)),
                      )
                    ],
                  );
  }
}

/*Bubble(
      padding: BubbleEdges.symmetric(horizontal: 10,vertical: 10),
      margin: BubbleEdges.only(top: 15),
      alignment: sendByMe ? Alignment.topRight : Alignment.topLeft,
      nip: sendByMe ? BubbleNip.rightBottom : BubbleNip.leftBottom,
      color: sendByMe ? Color(0xff007EF4) :  Color(0x1AFFFFFF),
      child: Text(
        message,
        textAlign: TextAlign.start,
        style:  TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'OverpassRegular',
            fontWeight: FontWeight.w300)),
      
      
    );*/
/*Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
              fit: BoxFit.fill,      
              image: NetworkImage(
                message,
      //          scale: 0.8
                ) */
//const Color(0x1AFFFFFF), const Color(0x1AFFFFFF)
//Color(0x54FFFFFF)
class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  VideoPlayerWidget(this.videoUrl);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState(videoUrl);
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  final VideoPlayerController videoPlayerController;
  final String videoUrl;
  double videoDuration = 0;
  double currentDuration = 0;
  _VideoPlayerWidgetState(this.videoUrl)
      : videoPlayerController = VideoPlayerController.network(videoUrl);

  @override
  void initState() {
    super.initState();
    videoPlayerController.initialize().then((_) {
      setState(() {
        videoDuration =
            videoPlayerController.value.duration.inMilliseconds.toDouble();
      });
    });

    videoPlayerController.addListener(() {
      setState(() {
        currentDuration =
            videoPlayerController.value.position.inMilliseconds.toDouble();
      });
    });
    print(videoUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF737373),
      // This line set the transparent background
      child: Container(
          color: Colors.black,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                  //  color: Colors.blue,
                  constraints: BoxConstraints(maxHeight: 800),
                  child: videoPlayerController.value.initialized
                      ? AspectRatio(
                          aspectRatio: videoPlayerController.value.aspectRatio,
                          child: VideoPlayer(videoPlayerController),
                        )
                      : CircularProgressIndicator()),
              Slider(
                  min: 0,
                  value: currentDuration,
                  max: videoDuration,
                  onChanged: (value) {
                    videoPlayerController
                        .seekTo(Duration(milliseconds: value.toInt()));
                    setState(() {});
                  }),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: FloatingActionButton(
                    elevation: 0,
                    child: Icon(
                      videoPlayerController.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                    onPressed: () {
                      setState(() {
                        videoPlayerController.value.isPlaying
                            ? videoPlayerController.pause()
                            : videoPlayerController.play();
                      });
                    }),
              )
            ],
          )),
    );
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    super.dispose();
  }
}
/*GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> ImageShow(message)));
                      },
                      child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image(
                        fit: BoxFit.fill,
                        image: NetworkImage(
                          message,
                        ),
                      ),
                    ),
                  ),*/
