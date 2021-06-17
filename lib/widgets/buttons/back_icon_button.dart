import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../services/app_locales.dart';
import '../../utils/ui/theme_config.dart';

class BackIconButton extends StatelessWidget {
	final Brightness? theme;
	final void Function()? exitCallback;
	final dynamic args;

	BackIconButton({this.theme = Brightness.light, this.exitCallback, this.args});

	@override
	Widget build(BuildContext context) {
		return IconButton(
			tooltip: AppLocales.of(context).translate('actions.back'),
			icon: Icon(Icons.arrow_back, color: (theme == Brightness.light) ? AppColors.lightTextColor : AppColors.darkTextColor),
			onPressed: () => exitCallback != null ? exitCallback!() : Navigator.of(context).pop(args)
		);
	}

}
