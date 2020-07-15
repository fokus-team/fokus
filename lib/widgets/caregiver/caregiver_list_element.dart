import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';

class CaregiverListElement extends StatelessWidget {
	final String name;

	CaregiverListElement({
		@required this.name,
	});

	@override
	Widget build(BuildContext context) {
		return Card(
			shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppBoxProperties.roundedCornersRadius)),
			margin: EdgeInsets.symmetric(
				vertical: AppBoxProperties.cardListPadding,
				horizontal: AppBoxProperties.screenEdgePadding
			),
			child: IntrinsicHeight(
				child: Row(
					mainAxisAlignment: MainAxisAlignment.spaceBetween,
					crossAxisAlignment: CrossAxisAlignment.start,
					children: <Widget>[
						Padding(
							padding: EdgeInsets.only(left: 12.0),
							child: Column(
								mainAxisAlignment: MainAxisAlignment.center,
								children: <Widget>[
									Text(
										name,
										style: Theme.of(context).textTheme.headline3
									)
								]
							),
						),
						InkWell(
							customBorder: new CircleBorder(),
							child: PopupMenuButton<int>(
								icon: Icon(
									Icons.more_vert,
									size: 26.0
								),
								onSelected: (int value) => {
									log("Akcja: #" + value.toString())
								},
								itemBuilder: (context) => [
									PopupMenuItem(value: 1, child: Text(AppLocales.of(context).translate('actions.delete'))),
								],
							)
						)
					]
				)
			)
		);
	}

}
