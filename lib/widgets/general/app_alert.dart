// @dart = 2.10
import 'package:flutter/material.dart';
import 'package:fokus/utils/ui/theme_config.dart';

class AppAlert extends StatelessWidget {
	final String text;
	final Color color;
	final IconData icon;
	final Function() onTap;
	final EdgeInsets padding;

	AppAlert({
		@required this.text,
		this.color = Colors.pink,
		this.icon = Icons.warning,
		this.onTap,
		this.padding
	});

  @override
  Widget build(BuildContext context) {
		return Container(
			margin: padding ?? EdgeInsets.symmetric(vertical: 12.0, horizontal: AppBoxProperties.screenEdgePadding).copyWith(bottom: 2.0),
			decoration: BoxDecoration(
				color: color,
				borderRadius: BorderRadius.all(Radius.circular(AppBoxProperties.roundedCornersRadius))
			),
			child: Material(
				type: MaterialType.transparency,
				child: InkWell(
					onTap: () => onTap(),
					splashColor: Colors.black12,
					borderRadius: BorderRadius.all(Radius.circular(AppBoxProperties.roundedCornersRadius)),
					child: Padding(
						padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
						child: Row(
							children: [
								Icon(icon, color: Colors.white),
								Expanded(
									child: Padding(
										padding: EdgeInsets.symmetric(horizontal: 16.0),
										child: Text(
											text,
											style: TextStyle(color: Colors.white)
										)
									)
								),
								Icon(Icons.arrow_forward, color: Colors.black38)
							]
						)
					)
				)
			)
		);
  }

}
