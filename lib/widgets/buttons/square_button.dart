import 'package:flutter/material.dart';

class SquareButton extends StatelessWidget {
  final String title;
  final bool isVertical;
  final IconData icon;
  final Function behaviour;
  final Color backgroundColor;

  SquareButton(this.title, this.icon, this.behaviour, {this.isVertical = false, this.backgroundColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return  FlatButton(
			color: backgroundColor,
			onPressed: behaviour,
			child: Column(
				children: [
					Icon(icon),
					Text(title)
				],
			),
		);
  }
}
