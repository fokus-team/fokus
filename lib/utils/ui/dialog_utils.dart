import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:round_spot/round_spot.dart' as round_spot;

import '../../logic/caregiver/caregiver_friends_cubit.dart';
import '../../logic/child/child_rewards_cubit.dart';
import '../../logic/common/settings/account_delete/account_delete_cubit.dart';
import '../../logic/common/settings/name_change/name_change_cubit.dart';
import '../../logic/common/settings/password_change/password_change_cubit.dart';
import '../../model/db/gamification/badge.dart';
import '../../model/db/gamification/reward.dart';
import '../../model/db/user/user.dart';
import '../../model/ui/app_popup.dart';
import '../../services/app_locales.dart';
import '../../widgets/dialogs/about_app_dialog.dart';
import '../../widgets/dialogs/badge_dialog.dart';
import '../../widgets/dialogs/form_dialogs.dart';
import '../../widgets/dialogs/general_dialog.dart';
import '../../widgets/dialogs/help_dialog.dart';
import '../../widgets/dialogs/reward_dialog.dart';
import '../bloc_utils.dart';
import 'snackbar_utils.dart';

void showBasicDialog(BuildContext context, GeneralDialog dialog) {
	showDialog(
		context: context,
		builder: (context) => round_spot.Detector(
			areaID: AppPopup.general.name,
			child: dialog,
		),
		routeSettings: RouteSettings(name: AppPopup.general.name),
	);
}

void showHelpDialog(BuildContext context, String helpPage) {
	showGeneralDialog(
		transitionBuilder: (context, a1, a2, widget) {
      return Transform.translate(
        offset: Offset(0.0, a1.value),
        child: Opacity(
          opacity: a1.value,
          child: round_spot.Detector(
	          areaID: AppPopup.help.name,
						child: HelpDialog(helpPage: helpPage)
          ),
        ),
      );
    },
    transitionDuration: Duration(milliseconds: 300),
    barrierDismissible: true,
		barrierLabel: AppLocales.of(context).translate('actions.close'),
    barrierColor: Colors.black.withOpacity(0.4),
		context: context,
		pageBuilder: (context, anim1, anim2) { return SizedBox.shrink(); },
		routeSettings: RouteSettings(name: '${AppPopup.help.name}/$helpPage'),
	);
}

Future<bool?> showExitFormDialog(BuildContext context, bool isSystemPop, bool isDataChanged) {
	if (!isDataChanged) {
		Navigator.pop(context, true);
		return Future.value(false);
	}
	FocusManager.instance.primaryFocus?.unfocus();
	return showDialog<bool>(
		context: context,
		builder: (c) => round_spot.Detector(
			areaID: AppPopup.formExit.name,
			child: AlertDialog(
				title: Text(AppLocales.of(context).translate('alert.unsavedProgressTitle')),
				content: Text(AppLocales.of(context).translate('alert.unsavedProgressMessage')),
				actions: [
					TextButton(
						child: Text(AppLocales.of(context).translate('actions.cancel')),
						onPressed: () => Navigator.pop(c, false),
					),
					TextButton(
						style: TextButton.styleFrom(
							primary: Colors.red
						),
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
			),
		),
		routeSettings: RouteSettings(name: AppPopup.formExit.name),
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
		),
	);
}

void showAboutAppDialog(BuildContext context) {
	showDialog(
		context: context,
		builder: (context) => round_spot.Detector(
			areaID: AppPopup.aboutApp.name,
			child: AboutAppDialog(),
		),
		routeSettings: RouteSettings(name: AppPopup.aboutApp.name),
	);
}

Future<String?> showNameEditDialog(BuildContext context, User user) {
	return showDialog(
		context: context,
		builder: (_) => forwardCubit(
			round_spot.Detector(
				areaID: AppPopup.nameEdit.name,
				child: NameEditDialog(user.role!),
			),
			BlocProvider.of<NameChangeCubit>(context)
		),
		routeSettings: RouteSettings(name: AppPopup.nameEdit.name),
	);
}

void showPasswordChangeDialog(BuildContext context, {PasswordChangeCubit? cubit, bool dismissible = true}) {
	showDialog(
		context: context,
		barrierDismissible: dismissible,
		builder: (_) => cubit == null ? forwardCubit(
			round_spot.Detector(
				areaID: AppPopup.passwordChange.name,
				child: PasswordChangeDialog(),
			),
			BlocProvider.of<PasswordChangeCubit>(context)
		) : withCubit(PasswordChangeDialog(), cubit),
		routeSettings: RouteSettings(name: AppPopup.passwordChange.name),
	);
}

Future showAccountDeleteDialog(BuildContext context, User user) {
	return showDialog(
		context: context,
		builder: (_) => forwardCubit(
			round_spot.Detector(
				areaID: AppPopup.accountDelete.name,
				child: AccountDeleteDialog(user.role!),
			),
			BlocProvider.of<AccountDeleteCubit>(context)
		),
		routeSettings: RouteSettings(name: AppPopup.accountDelete.name),
	);
}

Future showAddFriendDialog(BuildContext context) {
	return showDialog(
		context: context,
		builder: (_) => forwardCubit(
			round_spot.Detector(
				areaID: AppPopup.addFriend.name,
				child: AddFriendDialog(),
			),
			BlocProvider.of<CaregiverFriendsCubit>(context)
		),
		routeSettings: RouteSettings(name: AppPopup.addFriend.name),
	);
}

void showCurrencyEditDialog(BuildContext context, Function(String?) callback, {String? initialValue}) {
	showDialog(
		context: context,
		builder: (context) => round_spot.Detector(
			areaID: AppPopup.currencyEdit.name,
			child: CurrencyEditDialog(callback: callback, initialValue: initialValue),
		),
		routeSettings: RouteSettings(name: AppPopup.currencyEdit.name),
	);
}

void showRewardDialog(BuildContext context, Reward reward, {void Function()? claimFeedback}) {
	showDialog(
		context: context,
		builder: (_) => tryForwardCubit<ChildRewardsCubit>(
			round_spot.Detector(
				areaID: AppPopup.reward.name,
				child: RewardDialog(reward: reward, claimFeedback: claimFeedback),
			),
			context,
		),
		routeSettings: RouteSettings(name: AppPopup.reward.name),
	);
}

void showBadgeDialog(BuildContext context, Badge badge, {bool showHeader = true}) {
	showDialog(
		context: context,
		builder: (context) => round_spot.Detector(
			areaID: AppPopup.badge.name,
			child: BadgeDialog(badge: badge, showHeader: showHeader),
		),
		routeSettings: RouteSettings(name: AppPopup.badge.name),
	);
}
