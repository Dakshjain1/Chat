import 'package:flutter/material.dart';

Widget appBarMain(BuildContext context) {
  
  return AppBar(
    title: Text('Social Chat'),
    elevation: 0.0,
    centerTitle: false,
    flexibleSpace: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
           begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
              Colors.red,
              Colors.blue]
        )
      ),
    ),
  );
}

InputDecoration textFieldInputDecoration(String hintText) {
  return InputDecoration(
              
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.white54),
      focusedBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      enabledBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)));
}

TextStyle simpleTextStyle() {
  return TextStyle(color: Colors.white, fontSize: 16);
}

TextStyle biggerTextStyle() {
  return TextStyle(color: Colors.white, fontSize: 17);
}