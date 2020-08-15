import 'package:flutter/material.dart';

enum ButtonType { exit, ok, retry, close, details, edit, delete, unpair }

class UIButton {
	final String textKey;
	final void Function(BuildContext) action;

	UIButton(this.textKey, this.action);
	UIButton.ofType(ButtonType type, this.action) : textKey = type.key;
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
		ButtonType.unpair: 'actions.unpair'
  }[this];
}
