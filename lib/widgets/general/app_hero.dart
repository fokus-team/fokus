import 'package:flutter/material.dart';

class AppHero extends StatelessWidget {
	final String title;
	final IconData icon;
	final Color color;
	final Widget actionWidget;
	final bool dense;

	AppHero({
		@required this.title,
		this.icon,
		this.color,
		this.actionWidget,
		this.dense = false
	});

  @override
  Widget build(BuildContext context) {
		Color heroColor = color ?? Colors.grey[400];

		return Center(
			child: Padding(
				padding: EdgeInsets.only(top: dense ? 0.0 : 40.0),
				child: Column(
					children: <Widget>[
						if(icon != null)
							Padding(
								padding: EdgeInsets.only(bottom: 10.0),
								child: Icon(
									icon,
									size: 65.0,
									color: heroColor
								)
							),
						Text(
							title,
							style: TextStyle(
								fontSize: 16.0,
								color: heroColor
							)
						),
						if(actionWidget != null)
							Padding(
								padding: EdgeInsets.only(top: 6.0),
								child: actionWidget
							)
					]
				)
			)
		);
  }

}
