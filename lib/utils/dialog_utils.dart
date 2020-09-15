import 'package:flutter/material.dart';
import 'package:fokus/model/ui/gamification/ui_badge.dart';
import 'package:fokus/model/ui/gamification/ui_reward.dart';

import 'package:fokus/services/app_locales.dart';
import 'package:fokus/widgets/dialogs/app_info_dialog.dart';
import 'package:fokus/widgets/dialogs/reward_dialog.dart';
import 'package:fokus/widgets/dialogs/badge_dialog.dart';
import 'package:fokus/widgets/dialogs/general_dialog.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/widgets/dialogs/dialog.dart';
import 'package:fokus/widgets/dialogs/help_dialog.dart';
import 'package:fokus/widgets/dialogs/form_dialogs.dart';

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

Future<bool> showExitFormDialog(BuildContext context, bool isSystemPop, bool isDataChanged) {
	if (!isDataChanged) {
		Navigator.pop(context, true);
		return Future.value(false);
	}
	FocusManager.instance.primaryFocus.unfocus();
	return showDialog<bool>(
		context: context,
		builder: (c) => AlertDialog(
			title: Text(AppLocales.of(context).translate('alert.unsavedProgressTitle')),
			content: Text(AppLocales.of(context).translate('alert.unsavedProgressMessage')),
			actions: [
				FlatButton(
					child: Text(AppLocales.of(context).translate('actions.cancel')),
					onPressed: () => Navigator.pop(c, false),
				),
				FlatButton(
					textColor: Colors.red,
					child: Text(AppLocales.of(context).translate('actions.exit')),
					onPressed: () {
						if(isSystemPop)
							Navigator.pop(c, true);
						else {
							Navigator.of(context).pop();
							Navigator.of(context).pop();
						}
					}
				)
			]
		)
	);
}

void showAppInfoDialog(BuildContext context) {
	showDialog(
		context: context,
		builder: (context) => AppInfoDialog()
	);
}

void showNameEditDialog(BuildContext context) {
	showDialog(
		context: context,
		builder: (context) => NameEditDialog()
	);
}

void showPasswordChangeDialog(BuildContext context) {
	showDialog(
		context: context,
		builder: (context) => PasswordChangeDialog()
	);
}

void showRewardDialog(BuildContext context, UIReward reward) {
	showDialog(
		context: context,
		builder: (context) => RewardDialog(reward: reward)
	);
}

void showBadgeDialog(BuildContext context, UIBadge badge) {
	showDialog(
		context: context,
		builder: (context) => BadgeDialog(badge: badge)
	);
}
