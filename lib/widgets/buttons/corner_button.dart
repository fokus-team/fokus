import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CornerButton extends StatelessWidget {
  final String title;
  final bool isLeft;
  final IconData icon;
  final Function behaviour;
  final Color backgroundColor;
	final Color iconColor;

  static double borderRadius = 120;

  CornerButton(this.title, this.icon, this.behaviour, {this.isLeft = false, this.backgroundColor = Colors.white10, this.iconColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return  ClipRRect(
			borderRadius: isLeft ? BorderRadius.only(topRight: Radius.circular(borderRadius)) : BorderRadius.only(topLeft: Radius.circular(borderRadius)),
      child: RaisedButton(
				color: backgroundColor,
				onPressed: behaviour,
				child: Align(
					alignment: isLeft ? Alignment.bottomLeft : Alignment.bottomRight,
					child: Padding(
						padding: isLeft ? EdgeInsets.fromLTRB(0,20,20,8) : EdgeInsets.fromLTRB(20,20,0,8),
						child: Icon(icon, color: Colors.white, size: 56,)
					),
				),
			),
    );
  }
}
