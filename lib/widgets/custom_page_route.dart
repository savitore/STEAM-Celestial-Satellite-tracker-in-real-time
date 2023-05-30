import 'package:flutter/material.dart';

class CustomPageRoute extends PageRouteBuilder{
  final Widget child;
  CustomPageRoute({required this.child}): super(
    // transitionDuration: Duration(seconds: 1),
    // reverseTransitionDuration: Duration(seconds: 1),
    pageBuilder: (context, animation, secondaryAnimation) =>child
  );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child)
  => SlideTransition(
    position: Tween<Offset>(
      begin: Offset(1,0),
      end: Offset.zero
    ).animate(animation),
    child: child,
  );

}