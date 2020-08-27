import 'package:flutter/material.dart';
import 'package:fokus/services/app_locales.dart';

class SquareButton extends StatelessWidget {
  final String title;
  final bool isVertical;
  final IconData icon;
  final Function behaviour;
  final Color backgroundColor;

  SquareButton(this.title, this.icon, this.behaviour, {this.isVertical = false, this.backgroundColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return  RaisedButton(
			color: backgroundColor,
			onPressed: behaviour,
			child: Padding(
			  padding: EdgeInsets.all(8.0),
					child: !this.isVertical ? Column(
					children: [
						Icon(icon, color: Colors.white,),
						Text(
							AppLocales.of(context).translate(title),
							style: TextStyle(color: Colors.white),
							overflow: TextOverflow.fade,
							maxLines: 1,
						)
					],
					) :
					Row(
					children: [
							Text(
								AppLocales.of(context).translate(title),
								style: TextStyle(color: Colors.white),
								overflow: TextOverflow.fade,
								maxLines: 1,
							),
						Icon(icon, color: Colors.white,)
					],
					),
			)
		);
  }
}
