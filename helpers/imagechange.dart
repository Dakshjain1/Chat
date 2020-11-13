import 'dart:io';

import 'package:firebase_test/helpers/Username.dart';
import 'package:firebase_test/helpers/database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ChangeProfile {
  File path;
  DataService db = new DataService();
  String display_url;
  removePhoto()async {
    await db.uploadProfileImage(Constants.myuid, 'https://raw.githubusercontent.com/juzer-patan/asset/master/download.png');
  //  Constants.myphotoUrl = 'https://raw.githubusercontent.com/juzer-patan/asset/master/download.png';
    
  }

  Future changePhoto(ImageSource source) async{
     var image_pick =new ImagePicker();
     var img = await image_pick.getImage(
       source: source);
    if(img != null){
      path = File(img.path);
      
    
    display_url = await db.addProfileImage(Constants.myuid, path).then((value) async{
        print(value);
        if(value !=  null){
        Constants.myphotoUrl = value;
        print(display_url);
        var changeMap = {
          'profile_url' : value,
        };
        await db.updateUserInfo(Constants.myuid, changeMap);
       
        }
      });
    // print(img.path); 
    return display_url;
  }
  }
  showAttach(context) {
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
                            removePhoto();
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
  

  
  
}

class ChangeProfil extends StatefulWidget {
  @override
  ChangeProfileState createState() => ChangeProfileState();
}

class ChangeProfileState extends State<ChangeProfil> {
   File path;
  DataService db = new DataService();
  String display_url;
  removePhoto()async {
    await db.uploadProfileImage(Constants.myuid, 'https://raw.githubusercontent.com/juzer-patan/asset/master/download.png');
    setState(() {
      Constants.myphotoUrl = 'https://raw.githubusercontent.com/juzer-patan/asset/master/download.png';  
    });
    
    
  }

  Future changePhoto(ImageSource source) async{
     var image_pick =new ImagePicker();
     var img = await image_pick.getImage(
       source: source);
    if(img != null){
      path = File(img.path);
      
    
    display_url = await db.addProfileImage(Constants.myuid, path).then((value) async{
        print(value);
        if(value !=  null){
        setState(() {
          Constants.myphotoUrl = value;  
        });
        
        print(display_url);
        var changeMap = {
          'profile_url' : value,
        };
        await db.updateUserInfo(Constants.myuid, changeMap);
       
        }
      });
    // print(img.path); 
    return display_url;
  }
  }
  showAttach(context) {
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
                            removePhoto();
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
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}