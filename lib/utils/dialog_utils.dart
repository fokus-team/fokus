import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/settings/account_delete/account_delete_cubit.dart';
import 'package:fokus/logic/settings/name_change/name_change_cubit.dart';
import 'package:fokus/logic/settings/password_change/password_change_cubit.dart';
import 'package:fokus/model/ui/gamification/ui_badge.dart';
import 'package:fokus/model/ui/gamification/ui_reward.dart';

import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/bloc_utils.dart';
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
		builder: (_) => forwardCubit(NameEditDialog(), context.bloc<NameChangeCubit>())
	);
}

void showPasswordChangeDialog(BuildContext context) {
	showDialog(
		context: context,
		builder: (_) => forwardCubit(PasswordChangeDialog(), context.bloc<PasswordChangeCubit>())
	);
}

void showAccountDeleteDialog(BuildContext context) {
	showDialog(
		context: context,
		builder: (_) => forwardCubit(AccountDeleteDialog(), context.bloc<AccountDeleteCubit>())
	);
}

void showCurrencyEditDialog(BuildContext context, Function(String) callback, {String initialValue}) {
	showDialog(
		context: context,
		builder: (context) => CurrencyEditDialog(callback: callback, initialValue: initialValue)
	);
}

void showRewardDialog(BuildContext context, UIReward reward, {bool showHeader = true, Function claimFeedback}) {
	showDialog(
		context: context,
		builder: (context) => RewardDialog(reward: reward, showHeader: showHeader, claimFeedback: claimFeedback,)
	);
}

void showBadgeDialog(BuildContext context, UIBadge badge, {bool showHeader = true}) {
	showDialog(
		context: context,
		builder: (context) => BadgeDialog(badge: badge, showHeader: showHeader)
	);
}
