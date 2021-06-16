import 'package:flutter/material.dart';
import '../../model/ui/ui_button.dart';
import '../../utils/ui/theme_config.dart';

enum GeneralDialogType { confirm, discard }

class GeneralDialog extends StatelessWidget {
	final String title;
	final String? content;
	final RichText? richContent;
	final UIButton? cancelButton;
	final UIButton? confirmButton;
	final UIButton? discardButton;
	final GeneralDialogType? type;

	GeneralDialog({
		required this.title,
		this.content,
		this.richContent,
		this.cancelButton,
		this.confirmButton,
		this.discardButton,
		@required this.type
	});

	GeneralDialog.confirm({
		required String title,
		String? content,
		String? confirmText,
		Color? confirmColor,
		RichText? richContent,
		void Function()? confirmAction,
		String? cancelText,
		Color? cancelColor,
		void Function()? cancelAction
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
		required String title,
		String? content,
		String? discardText,
		Color? discardColor,
		void Function()? discardAction,
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
			content: richContent ?? Text(content!),
			actions: [
				if(type == GeneralDialogType.discard)
					discardButton!.getWidget(context),
				if(type == GeneralDialogType.confirm)
					cancelButton!.getWidget(context),
				if(type == GeneralDialogType.confirm)
					confirmButton!.getWidget(context)
			]
		);
	}

}
