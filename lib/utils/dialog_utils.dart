import 'package:flutter/material.dart';
import 'package:fokus/model/ui/ui_button.dart';

import 'package:fokus/widgets/dialogs/dialog.dart';
import 'package:fokus/widgets/dialogs/help_dialog.dart';

void showNoConnectionDialog(BuildContext context, void Function() action) {
	showDialog(
		context: context,
		barrierDismissible: false,
		builder: (context) => AppDialog(
			titleKey: 'alert.noConnection',
			textKey: 'alert.connectionRetry',
			buttons: [DialogButton(ButtonType.retry, action)],
		),
	);
}

void showHelpDialog(BuildContext context, String helpPage) {
	showDialog(
		context: context,
		builder: (BuildContext context) {
			return HelpDialog(helpPage: helpPage);
		}
	);
}
