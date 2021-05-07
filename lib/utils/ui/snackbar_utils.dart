import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/theme_config.dart';

void showBasicSnackbar(BuildContext context, {required String content, Map<String, String>? contentArgs, Color? backgroundColor, IconData? icon}) {
	Flushbar(
		padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
		messageText: Text(
			AppLocales.of(context).translate(content, contentArgs),
			style: TextStyle(fontSize: 17.0, color: Colors.white)
		),
		icon: icon != null ? Icon(
			icon,
			size: 32.0,
			color: backgroundColor
		) : SizedBox.shrink(),
		flushbarStyle: FlushbarStyle.FLOATING,
		margin: EdgeInsets.all(8.0),
		borderRadius: BorderRadius.all(Radius.circular(4.0)),
		duration: Duration(seconds: 5)
	)..show(context);
}

void showInfoSnackbar(BuildContext context, String content) {
	showBasicSnackbar(context, content: content, backgroundColor: AppColors.infoColor, icon: Icons.info);
}

void showFailSnackbar(BuildContext context, String content, [Map<String, String>? contentArgs]) {
	showBasicSnackbar(context, content: content, contentArgs: contentArgs, backgroundColor: AppColors.failColor, icon: Icons.error);
}

void showSuccessSnackbar(BuildContext context, String content) {
	showBasicSnackbar(context, content: content, backgroundColor: AppColors.successColor, icon: Icons.check_circle);
}
