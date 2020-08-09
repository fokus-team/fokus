import 'package:flutter/material.dart';
import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';

enum GeneralDialogType { confirm, discard }

class GeneralDialogButton {
	String text;
	Color color;
	Function action;

	GeneralDialogButton({
		@required this.text,
		@required this.color,
		@required this.action
	});

  Widget getWidget(BuildContext context) {
    return FlatButton(
			child: Text(AppLocales.of(context).translate(text)),
			textColor: color,
			onPressed: action ?? () => Navigator.of(context).pop()
		);
  }

}

class GeneralDialog extends StatelessWidget {
	final String title;
	final String content;
	final GeneralDialogButton cancelButton;
	final GeneralDialogButton confirmButton;
	final GeneralDialogButton discardButton;
	final GeneralDialogType type;

	GeneralDialog({
		@required this.title,
		@required this.content,
		this.cancelButton,
		this.confirmButton,
		this.discardButton,
		@required this.type
	});

	GeneralDialog.confirm({
		String title,
		String content,
		String confirmText,
		Color confirmColor,
		Function confirmAction,
		String cancelText,
		Color cancelColor,
		Function cancelAction
	}) : this(
		title: title,
		content: content,
		cancelButton: GeneralDialogButton(
			text: cancelText ?? 'actions.cancel',
			color: cancelColor ?? AppColors.mediumTextColor,
			action: cancelAction
		),
		confirmButton: GeneralDialogButton(
			text: confirmText ?? 'actions.confirm',
			color: confirmColor ?? AppColors.mainBackgroundColor,
			action: confirmAction
		),
		type: GeneralDialogType.confirm
	);

	GeneralDialog.discard({
		String title,
		String content,
		String discardText,
		Color discardColor,
		Function discardAction,
	}) : this(
		title: title,
		content: content,
		discardButton: GeneralDialogButton(
			text: discardText ?? 'actions.ok',
			color: discardColor ?? AppColors.mainBackgroundColor,
			action: discardAction
		),
		type: GeneralDialogType.discard
	);

	@override
  Widget build(BuildContext context) {
		return AlertDialog(
			title: Text(title),
			content: Text(content),
			actions: [
				if(type == GeneralDialogType.discard)
					discardButton.getWidget(context),
				if(type == GeneralDialogType.confirm)
					cancelButton.getWidget(context),
				if(type == GeneralDialogType.confirm)
					confirmButton.getWidget(context)
			]
		);
	}

}
