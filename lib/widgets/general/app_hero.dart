import 'package:flutter/material.dart';
import '../../utils/ui/theme_config.dart';

class AppHero extends StatelessWidget {
	final String? header;
	final String title;
	final IconData? icon;
	final Color? color;
	final Widget? actionWidget;
	final bool dense;

	AppHero({
		this.header,
		required this.title,
		this.icon,
		this.color,
		this.actionWidget,
		this.dense = false
	});

  @override
  Widget build(BuildContext context) {
		var heroColor = color ?? Colors.grey[500]!;

		return Center(
			child: Padding(
				padding: EdgeInsets.symmetric(horizontal: AppBoxProperties.screenEdgePadding*3).copyWith(top: dense ? 0.0 : 40.0),
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
						if(header != null)
							Text(
								header!,
								style: TextStyle(
									fontSize: 20.0,
									color: Colors.grey[700],
									fontWeight: FontWeight.bold
								),
								textAlign: TextAlign.center
							),
						Text(
							title,
							style: TextStyle(
								fontSize: 16.0,
								color: heroColor
							),
							textAlign: TextAlign.center
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
