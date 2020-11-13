import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_test/helpers/Username.dart';
import 'package:firebase_test/helpers/database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageScreen extends StatefulWidget {
  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  DataService db = new DataService();
  File path;
  //var storage = FirebaseStorage.instance.ref().child()
  image_click() async{
     var image_pick =new ImagePicker();
     var img = await image_pick.getImage(
       source: ImageSource.camera);
    setState(() {
      path = File(img.path);
      
    });
    await db.addProfileImage(Constants.myuid, path).then((value) async{
        print(value);
        await db.uploadProfileImage(Constants.myuid, value);
      });
     print(img.path);
  }
  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(50),
             image: DecorationImage(
               image: path != null ?  FileImage(path) : NetworkImage("https://raw.githubusercontent.com/juzer-patan/asset/master/download.png"),
               fit: BoxFit.cover
               ) 
            ),
            //height: 50,
            height: MediaQuery.of(context).size.height * 0.2,
            width: MediaQuery.of(context).size.width * 0.3,
            //child: path != null ? Image.file(path,) : Text('Image'),
          ),
          Container(
            child: RaisedButton(
              onPressed: () {
       //         image_click();
              }
            ),
          ),
        ],
      ),
    );
  }
}