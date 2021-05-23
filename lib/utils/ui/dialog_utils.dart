import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/caregiver/caregiver_friends_cubit.dart';
import 'package:fokus/logic/child/child_rewards_cubit.dart';
import 'package:fokus/logic/common/settings/account_delete/account_delete_cubit.dart';
import 'package:fokus/logic/common/settings/name_change/name_change_cubit.dart';
import 'package:fokus/logic/common/settings/password_change/password_change_cubit.dart';
import 'package:fokus/model/ui/app_popup.dart';
import 'package:fokus/model/ui/gamification/ui_badge.dart';
import 'package:fokus/model/ui/gamification/ui_reward.dart';
import 'package:fokus/model/ui/user/ui_user.dart';

import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/bloc_utils.dart';
import 'package:fokus/utils/ui/snackbar_utils.dart';
import 'package:fokus/widgets/dialogs/about_app_dialog.dart';
import 'package:fokus/widgets/dialogs/reward_dialog.dart';
import 'package:fokus/widgets/dialogs/badge_dialog.dart';
import 'package:fokus/widgets/dialogs/general_dialog.dart';
import 'package:fokus/widgets/dialogs/help_dialog.dart';
import 'package:fokus/widgets/dialogs/form_dialogs.dart';

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

void showUserCodeDialog(BuildContext context, String title, String code) {
	// TODO show popup with QR
	showBasicDialog(
		context, 
		GeneralDialog.confirm(
			title: AppLocales.of(context).translate(title),
			content: code,
			cancelText: 'actions.close',
			confirmText: 'actions.copyCode',
			confirmAction: () {
				Clipboard.setData(ClipboardData(text: code));
				Navigator.of(context).pop();
				showSuccessSnackbar(context, 'alert.codeCopied');
			}
		)
	);
}

void showAboutAppDialog(BuildContext context) {
	showDialog(
		context: context,
		builder: (context) => AboutAppDialog()
	);
}

Future<String> showNameEditDialog(BuildContext context, UIUser user) {
	return showDialog(
		context: context,
		builder: (_) => forwardCubit(NameEditDialog(user.role), BlocProvider.of<NameChangeCubit>(context))
	);
}

void showPasswordChangeDialog(BuildContext context, {PasswordChangeCubit cubit, bool dismissible = true}) {
	showDialog(
		context: context,
		barrierDismissible: dismissible,
		builder: (_) => cubit == null ? forwardCubit(PasswordChangeDialog(), BlocProvider.of<PasswordChangeCubit>(context)):
			withCubit(PasswordChangeDialog(), cubit)
	);
}

Future showAccountDeleteDialog(BuildContext context, UIUser user) {
	return showDialog(
		context: context,
		builder: (_) => forwardCubit(AccountDeleteDialog(user.role), BlocProvider.of<AccountDeleteCubit>(context))
	);
}

Future showAddFriendDialog(BuildContext context) {
	return showDialog(
		context: context,
		builder: (_) => forwardCubit(AddFriendDialog(), BlocProvider.of<CaregiverFriendsCubit>(context))
	);
}

void showCurrencyEditDialog(BuildContext context, Function(String) callback, {String initialValue}) {
	showDialog(
		context: context,
		builder: (context) => CurrencyEditDialog(callback: callback, initialValue: initialValue)
	);
}

void showRewardDialog(BuildContext context, UIReward reward, {Function claimFeedback, AppPopup popupType}) {
	showDialog(
		context: context,
		builder: (_) => tryForwardCubit<ChildRewardsCubit>(RewardDialog(reward: reward, claimFeedback: claimFeedback), context),
		routeSettings: RouteSettings(name: popupType.name),
	);
}

void showBadgeDialog(BuildContext context, UIBadge badge, {bool showHeader = true}) {
	showDialog(
		context: context,
		builder: (context) => BadgeDialog(badge: badge, showHeader: showHeader)
	);
}
