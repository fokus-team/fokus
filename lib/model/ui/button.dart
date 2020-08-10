import 'package:flutter/cupertino.dart';

class UIButton {
	final ButtonType type;
	final void Function(BuildContext) action;

	UIButton(this.type, this.action);
}

enum ButtonType {
	exit, ok, retry, close, signIn, signUp
}

extension TextButtonType on ButtonType {
	String get key => const {
		ButtonType.exit: 'actions.exit',
		ButtonType.ok: 'actions.ok',
		ButtonType.retry: 'actions.retry',
		ButtonType.close: 'actions.close',
		ButtonType.signIn: 'actions.signIn',
		ButtonType.signUp: 'actions.signUp'
	}[this];
}
