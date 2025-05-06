import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

PageRouteBuilder transition(Widget pantalla) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => pantalla,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: SharedAxisTransitionType.horizontal,
        child: child,
      );
    },
  );
}
