import 'package:flutter/material.dart';
import 'package:fokus/model/ui/button.dart';
import 'package:fokus/utils/app_locales.dart';

class AppDialog extends StatelessWidget {
	final String titleKey, textKey;
	final List<UIButton> buttons;

	AppDialog({@required this.titleKey, this.textKey, this.buttons = const []});

	@override
	Widget build(BuildContext context) {
		return AlertDialog(
			title: Text(AppLocales.of(context).translate(titleKey)),
			content: Text(AppLocales.of(context).translate(textKey)),
			actions: buttons.map((button) => FlatButton(
				child: Text(AppLocales.of(context).translate(button.type.key)),
				onPressed: () => button.action(context),
			)).toList(),
		);
	}
}
