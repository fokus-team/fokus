import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';

class BackIconButton extends StatelessWidget {
	final Brightness theme;

	BackIconButton({this.theme = Brightness.light});

	@override
	Widget build(BuildContext context) {
		return IconButton(
			tooltip: AppLocales.of(context).translate('actions.back'),
			icon: Icon(Icons.arrow_back, color: (theme == Brightness.light) ? AppColors.lightTextColor : AppColors.darkTextColor),
			onPressed: () => Navigator.of(context).pop()
		);
	}

}
