import 'package:flutter/material.dart';

class AppHero extends StatelessWidget {
	final String title;
	final IconData icon;
	final Widget actionWidget;

	AppHero({
		@required this.title,
		this.icon,
		this.actionWidget,
	});

  @override
  Widget build(BuildContext context) {
		return Center(
			child: Padding(
				padding: EdgeInsets.only(top: 40.0),
				child: Column(
					children: <Widget>[
						if(icon != null)
							Padding(
								padding: EdgeInsets.only(bottom: 10.0),
								child: Icon(
									icon,
									size: 65.0,
									color: Colors.grey[400]
								)
							),
						Text(
							title,
							style: TextStyle(
								fontSize: 16.0,
								color: Colors.grey[400]
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
