import 'package:flutter/material.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/theme_config.dart';

enum ButtonType { exit, ok, retry, close, details, edit, delete, unpair, signIn, signUp }

class UIButton {
	final String textKey;
	final Color? color;
	final IconData? icon;
	final void Function()? action;

	UIButton(this.textKey, this.action, [this.color, this.icon]);
	UIButton.ofType(ButtonType type, this.action, [this.color, this.icon]) : textKey = type.key;

  Widget getWidget(BuildContext context) {
    return FlatButton(
			child: Text(AppLocales.of(context).translate(textKey)),
			textColor: color ?? AppColors.mainBackgroundColor,
			onPressed: action ?? () => Navigator.of(context).pop()
		);
  }

}

extension TextButtonType on ButtonType {
  String get key => const {
	  ButtonType.exit: 'actions.exit',
	  ButtonType.ok: 'actions.ok',
		ButtonType.retry: 'actions.retry',
		ButtonType.close: 'actions.close',
		ButtonType.details: 'actions.details',
		ButtonType.edit: 'actions.edit',
		ButtonType.delete: 'actions.delete',
		ButtonType.unpair: 'actions.unpair',
	  ButtonType.signIn: 'actions.signIn',
	  ButtonType.signUp: 'actions.signUp'
  }[this]!;
}
