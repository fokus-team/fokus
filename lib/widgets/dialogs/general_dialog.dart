// @dart = 2.10
import 'package:flutter/material.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/utils/ui/theme_config.dart';

enum GeneralDialogType { confirm, discard }

class GeneralDialog extends StatelessWidget {
	final String title;
	final String content;
	final RichText richContent;
	final UIButton cancelButton;
	final UIButton confirmButton;
	final UIButton discardButton;
	final GeneralDialogType type;

	GeneralDialog({
		@required this.title,
		this.content,
		this.richContent,
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
		RichText richContent,
		Function confirmAction,
		String cancelText,
		Color cancelColor,
		Function cancelAction
	}) : this(
		title: title,
		content: content,
		richContent: richContent,
		cancelButton: UIButton(
			cancelText ?? 'actions.cancel',
			cancelAction,
			cancelColor ?? AppColors.mediumTextColor,
		),
		confirmButton: UIButton(
			confirmText ?? 'actions.confirm',
			confirmAction,
			confirmColor ?? AppColors.mainBackgroundColor
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
		discardButton: UIButton(
			discardText ?? 'actions.ok',
			discardAction,
			discardColor ?? AppColors.mainBackgroundColor
		),
		type: GeneralDialogType.discard
	);

	@override
  Widget build(BuildContext context) {
		return AlertDialog(
			title: Text(title),
			content: richContent ?? Text(content),
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
