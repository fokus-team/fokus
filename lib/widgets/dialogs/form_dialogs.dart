import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus_auth/fokus_auth.dart';
import 'package:formz/formz.dart';

import 'package:fokus/logic/settings/password_change/password_change_cubit.dart';
import 'package:fokus/model/ui/auth/password.dart';
import 'package:fokus/model/ui/auth/name.dart';
import 'package:fokus/model/ui/auth/confirmed_password.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/logic/auth/auth_bloc/authentication_bloc.dart';
import 'package:fokus/logic/settings/account_delete/account_delete_cubit.dart';
import 'package:fokus/logic/settings/name_change/name_change_cubit.dart';
import 'package:fokus/model/ui/user/ui_caregiver.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/auth/auth_input_field.dart';
import 'package:fokus/utils/snackbar_utils.dart';
import 'package:fokus/services/exception/auth_exceptions.dart';

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
											onPressed: () => onConfirm()
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

const String _settingsPageKey = 'page.settings.content';

class NameEditDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<NameChangeCubit, NameChangeState>(
	    listener: (context, state) {
		    if (state.status.isSubmissionSuccess) {
			    Navigator.of(context).pop();
			    showSuccessSnackbar(context, 'authentication.nameChanged');
		    }
	    },
      child: FormDialog(
				title: AppLocales.of(context).translate('$_settingsPageKey.profile.editNameLabel'),
				fields: [
					Padding(
						padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
						child: AuthenticationInputField<NameChangeCubit, NameChangeState>(
							getField: (state) => state.name,
							changedAction: (cubit, value) => cubit.nameChanged(value),
							labelKey: 'authentication.name',
							icon: Icons.edit,
							getErrorKey: (state) => [state.name.error.key],
						),
					),
				],
				onConfirm: () => context.bloc<NameChangeCubit>().nameChangeFormSubmitted()
			),
    );
  }
}

class AccountDeleteDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
	  var user = context.bloc<AuthenticationBloc>().state.user as UICaregiver;
  	var getText = (String key) => AppLocales.of(context).translate('$_settingsPageKey.profile.deleteAccount$key');
	  return BlocListener<AccountDeleteCubit, AccountDeleteState>(
		  listener: (context, state) {
			  if (state.status.isSubmissionFailure && state.error != null)
				  showFailSnackbar(context, state.error.key);
		  },
		  child: FormDialog(
			  title: getText('Label'),
			  fields: [
				  Padding(
					  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
					  child: Column(
						  crossAxisAlignment: CrossAxisAlignment.start,
					    children: [
					    	Text(getText('Description')),
						    SizedBox(height: 10),
						    ...getText('DataList').split('\|').map((point) => Padding(
							    padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 4.0),
							    child: Text('• $point'),
						    )),
						    SizedBox(height: 10),
						    Text(getText('Warning'), style: TextStyle(color: Colors.red)),
						    SizedBox(height: 10),
					      if (user.authMethod == AuthMethod.EMAIL)
						      ...[
						      	Text(getText('Confirm')),
							      SizedBox(height: 10),
							      AuthenticationInputField<AccountDeleteCubit, AccountDeleteState>(
										  getField: (state) => state.password,
										  changedAction: (cubit, value) => cubit.passwordChanged(value),
										  labelKey: 'authentication.password',
										  icon: Icons.lock_open,
										  getErrorKey: (state) => [state.password.error.key],
										  hideInput: true
							      ),
						      ]
					    ],
					  ),
				  ),
			  ],
			  onConfirm: () => context.bloc<AccountDeleteCubit>().accountDeleteFormSubmitted(),
		  ),
	  );
  }
}

class PasswordChangeDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<PasswordChangeCubit, PasswordChangeState>(
	    listener: (context, state) {
	    	if (state.status.isSubmissionSuccess) {
			    Navigator.of(context).pop();
			    showSuccessSnackbar(context, 'authentication.passwordChanged');
		    } else if (state.status.isSubmissionFailure && state.error != null)
			    showFailSnackbar(context, state.error.key);
	    },
      child: FormDialog(
				title: AppLocales.of(context).translate('$_settingsPageKey.profile.changePasswordLabel'),
				fields: [
					Padding(
						padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
						child: AuthenticationInputField<PasswordChangeCubit, PasswordChangeState>(
							getField: (state) => state.currentPassword,
							changedAction: (cubit, value) => cubit.currentPasswordChanged(value),
							labelKey: 'authentication.currentPassword',
							icon: Icons.lock_open,
							getErrorKey: (state) => [state.currentPassword.error.key],
							hideInput: true
						),
					),
					Padding(
						padding: EdgeInsets.symmetric(horizontal: 20.0),
						child: AuthenticationInputField<PasswordChangeCubit, PasswordChangeState>(
							getField: (state) => state.newPassword,
							changedAction: (cubit, value) => cubit.newPasswordChanged(value),
							labelKey: 'authentication.newPassword',
							icon: Icons.lock,
							getErrorKey: (state) => [state.newPassword.error.key, {'LENGTH': Password.minPasswordLength}],
							hideInput: true
						),
					),
					Padding(
						padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
						child: AuthenticationInputField<PasswordChangeCubit, PasswordChangeState>(
							getField: (state) => state.confirmedPassword,
							changedAction: (cubit, value) => cubit.confirmedPasswordChanged(value),
							labelKey: 'authentication.confirmPassword',
							icon: Icons.lock,
							getErrorKey: (state) => [state.confirmedPassword.error.key],
							hideInput: true
						),
					),
				],
				onConfirm: () => context.bloc<PasswordChangeCubit>().changePasswordFormSubmitted(),
			),
    );
  }
}

class CurrencyEditDialog extends StatefulWidget {
	final Function(String) callback;
	final String initialValue;

	CurrencyEditDialog({this.callback, this.initialValue});
	
	@override
	_CurrencyEditDialogState createState() => new _CurrencyEditDialogState();
}

class _CurrencyEditDialogState extends State<CurrencyEditDialog> {
	TextEditingController fieldController = TextEditingController();

	@override
  void initState() {
		fieldController.text = widget.initialValue ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FormDialog(
			title: AppLocales.of(context).translate('page.caregiverSection.currencies.content.currencyNameLabel'),
			fields: [
				Padding(
					padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
					child: Padding(
						padding: const EdgeInsets.all(8.0),
						child: TextField(
							controller: fieldController,
							maxLength: 30,
							decoration: InputDecoration(
								icon: Padding(padding: EdgeInsets.all(5.0), child: Icon(Icons.edit)),
								contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
								border: OutlineInputBorder(),
								labelText: AppLocales.of(context).translate('page.caregiverSection.currencies.content.currencyNameLabel')
							)
						)
					)
				)
			],
			onConfirm: () {
			  widget.callback(fieldController.text == '' ? null : fieldController.text);
			  Navigator.of(context).pop();
			}
		);
  }
}
