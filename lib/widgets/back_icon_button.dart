import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';

enum BackIconButtonTheme { light, dark }

class BackIconButton extends StatelessWidget {
	final BackIconButtonTheme theme;

	BackIconButton({this.theme = BackIconButtonTheme.light});

	@override
	Widget build(BuildContext context) {
		return Tooltip(
			message: AppLocales.of(context).translate('actions.back'),
			child: InkWell(
				customBorder: new CircleBorder(),
				onTap: () => {Navigator.of(context).pop()},
				child: Padding(
					padding: EdgeInsets.symmetric(horizontal: 8.0),
					child: Icon(
						Icons.chevron_left,
						size: 40.0,
						color: (theme == BackIconButtonTheme.light) ? AppColors.lightTextColor : AppColors.darkTextColor
					)
				)
			)
		);
	}

}
