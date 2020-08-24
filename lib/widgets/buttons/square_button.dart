import 'package:flutter/material.dart';

class SquareButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Function behaviour;

  SquareButton(this.title, this.icon, this.behaviour);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: FlatButton(
        onPressed: behaviour,
        child: Column(
          children: [
            Icon(icon),
            Text(title)
          ],
        ),
      )
    );
  }
}
