import 'package:flutter/material.dart';
import 'package:fokus/model/button_type.dart';
import 'package:fokus/utils/app_locales.dart';

class AppDialog extends StatelessWidget {
	final String titleKey, textKey;
	final ButtonType button;
	final void Function() action;

	AppDialog(this.titleKey, this.textKey, this.button, this.action);

	@override
	Widget build(BuildContext context) {
		return AlertDialog(
			title: Text(AppLocales.of(context).translate(titleKey)),
			content: Text(AppLocales.of(context).translate(textKey)),
			actions: [
				FlatButton(
					child: Text(AppLocales.of(context).translate(button.key)),
					onPressed: () {
						action();
					},
				),
			],
		);
	}
}
