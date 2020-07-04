import 'package:flutter/material.dart';
import 'package:fokus/data/model/button_type.dart';

import 'package:fokus/wigets/dialog.dart';

void showAlertDialog(BuildContext context, String titleKey, String textKey, ButtonType button, void Function() action) {
	showDialog(
		context: context,
		builder: (BuildContext context) {
			return AppDialog(titleKey, textKey, button, action);
		}
	);
}
