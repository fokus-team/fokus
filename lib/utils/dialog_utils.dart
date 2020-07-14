import 'package:flutter/material.dart';
import 'package:fokus/model/button_type.dart';

import 'package:fokus/widgets/dialog.dart';
import 'package:fokus/widgets/help_dialog.dart';

void showAlertDialog(BuildContext context, String titleKey, String textKey, ButtonType button, void Function() action) {
	showDialog(
		context: context,
		builder: (BuildContext context) {
			return AppDialog(titleKey, textKey, button, action);
		}
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
