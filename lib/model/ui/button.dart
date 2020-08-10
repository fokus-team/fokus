import 'package:flutter/cupertino.dart';

class UIButton {
	final ButtonType type;
	final void Function(BuildContext) action;

	UIButton(this.type, this.action);
}

enum ButtonType {
	exit, ok, retry, close, login, signIn
}

extension TextButtonType on ButtonType {
	String get key => const {
		ButtonType.exit: 'actions.exit',
		ButtonType.ok: 'actions.ok',
		ButtonType.retry: 'actions.retry',
		ButtonType.close: 'actions.close',
		ButtonType.login: 'actions.login',
		ButtonType.signIn: 'actions.signIn'
	}[this];
}
