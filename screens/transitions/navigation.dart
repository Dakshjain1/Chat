//import 'dart:js';

import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';

class AnimatedTransition {
  static scaleTransition(page,chatRoomId,context){
    return PageRouteBuilder(
      pageBuilder: (context,animation,secondaryAnimation) => page(chatRoomId),
      transitionDuration: Duration(seconds: 1),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeThroughTransition(animation: animation, secondaryAnimation: secondaryAnimation, child: child);
      }
      );
  }
}