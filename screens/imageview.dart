import 'package:flutter/material.dart';

class ImageShow extends StatelessWidget {
  String url;
  ImageShow(this.url);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white70.withOpacity(0.4),
        elevation: 0.0,
        title: Text("Image"),
      ),
      body:  Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image:NetworkImage(url),
            fit: BoxFit.cover,
          ),
        ),

      ),
    );
  }
}