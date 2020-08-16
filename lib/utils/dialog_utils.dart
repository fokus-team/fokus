import 'package:flutter/material.dart';

import 'package:fokus/services/app_locales.dart';
import 'package:fokus/widgets/dialogs/general_dialog.dart';
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
			buttons: [UIButton.ofType(ButtonType.retry, action)],
		),
	);
}

void showBasicDialog(BuildContext context, GeneralDialog dialog) {
	showDialog(
		context: context,
		builder: (context) => dialog
	);
}

void showHelpDialog(BuildContext context, String helpPage) {
	showGeneralDialog(
		transitionBuilder: (context, a1, a2, widget) {
      return Transform.translate(
        offset: Offset(0.0, a1.value),
        child: Opacity(
          opacity: a1.value,
          child: HelpDialog(helpPage: helpPage)
        ),
      );
    },
    transitionDuration: Duration(milliseconds: 300),
    barrierDismissible: true,
		barrierLabel: AppLocales.of(context).translate('actions.close'),
    barrierColor: Colors.black.withOpacity(0.4),
		context: context,
		pageBuilder: (context, anim1, anim2) { return SizedBox.shrink(); },
	);
}
