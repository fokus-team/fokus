import 'package:flutter/material.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';

class FormDialog extends StatelessWidget {
	final String title;
	final List<Widget> fields;
	final Function onConfirm;

	FormDialog({this.title, this.fields, this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
			insetPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
			child: ListView(
				shrinkWrap: true,
				children: [
					Column(
						mainAxisSize: MainAxisSize.min,
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Padding(
								padding: EdgeInsets.all(24.0).copyWith(bottom: 8.0), 
								child: Text(
									title,
									style: Theme.of(context).textTheme.headline6
								)
							),
							...fields,
							Padding(
								padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
								child: Row(
									mainAxisAlignment: MainAxisAlignment.spaceBetween,
									children: [
										FlatButton(
											textColor: AppColors.mediumTextColor,
											child: Text(AppLocales.of(context).translate('actions.cancel')),
											onPressed: () => Navigator.of(context).pop()
										),
										FlatButton(
											textColor: AppColors.caregiverBackgroundColor,
											child: Text(AppLocales.of(context).translate('actions.confirm')),
											onPressed: () {
												onConfirm();
												Navigator.of(context).pop();
											}
										)
									]
								)
							)
						]
					)
				]
			)
		);
  }
	
}

class NameEditDialog extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return FormDialog(
			title: AppLocales.of(context).translate('page.settings.content.profile.editNameLabel'),
			fields: [
				Padding(
					padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
					child: Padding(
						padding: const EdgeInsets.all(8.0),
						child: TextField(
							decoration: InputDecoration(
								icon: Padding(padding: EdgeInsets.all(5.0), child: Icon(Icons.edit)),
								contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
								border: OutlineInputBorder(),
								labelText: AppLocales.of(context).translate('authentication.name')
							)
						)
					)
				)
			],
			onConfirm: () => {}
		);
  }
	
}

class PasswordChangeDialog extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return FormDialog(
			title: AppLocales.of(context).translate('page.settings.content.profile.changePasswordLabel'),
			fields: [
				Padding(
					padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
					child: Padding(
						padding: const EdgeInsets.all(8.0),
						child: TextField(
							decoration: InputDecoration(
								icon: Padding(padding: EdgeInsets.all(5.0), child: Icon(Icons.lock_open)),
								contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
								border: OutlineInputBorder(),
								labelText: AppLocales.of(context).translate('authentication.currentPassword')
							),
							obscureText: true
						)
					)
				),
				Padding(
					padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
					child: Padding(
						padding: const EdgeInsets.all(8.0),
						child: TextField(
							decoration: InputDecoration(
								icon: Padding(padding: EdgeInsets.all(5.0), child: Icon(Icons.lock)),
								contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
								border: OutlineInputBorder(),
								labelText: AppLocales.of(context).translate('authentication.newPassword')
							),
							obscureText: true
						)
					)
				),
				Padding(
					padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
					child: Padding(
						padding: const EdgeInsets.all(8.0),
						child: TextField(
							decoration: InputDecoration(
								icon: Padding(padding: EdgeInsets.all(5.0), child: Icon(Icons.lock)),
								contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
								border: OutlineInputBorder(),
								labelText: AppLocales.of(context).translate('authentication.confirmPassword')
							),
							obscureText: true
						)
					)
				),
			],
			onConfirm: () => {}
		);
  }
	
}
