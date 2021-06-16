import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:fokus_auth/fokus_auth.dart';
import 'package:formz/formz.dart';

import '../../../logic/caregiver/auth/sign_in/caregiver_sign_in_cubit.dart';
import '../../../model/ui/app_page.dart';
import '../../../model/ui/auth/email.dart';
import '../../../model/ui/auth/password.dart';
import '../../../model/ui/ui_button.dart';
import '../../../services/app_locales.dart';
import '../../../services/exception/auth_exceptions.dart';
import '../../../utils/ui/form_config.dart';
import '../../../utils/ui/snackbar_utils.dart';
import '../../../utils/ui/theme_config.dart';
import '../../../widgets/auth/auth_button.dart';
import '../../../widgets/auth/auth_input_field.dart';
import '../../../widgets/auth/auth_widgets.dart';
import '../../../widgets/buttons/popup_menu_list.dart';

class CaregiverSignInPage extends StatelessWidget {
	static const String _pageKey = 'page.loginSection.caregiverSignIn';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
	    body: SafeArea(
			  child: BlocListener<CaregiverSignInCubit, CaregiverSignInState>(
				  listener: (context, state) {
					  if (state.status.isSubmissionFailure) {
					  	if (state.signInError != null)
							  showFailSnackbar(context, state.signInError!.key);
					  	else if (state.passwordResetError != null)
								showFailSnackbar(context, 'authentication.error.emailLink', {
	                'TYPE': '${AppLinkType.passwordReset.index}',
	                'ERR': '${state.passwordResetError!.index}'
	              });
				    }
				  },
				  child: ListView(
						padding: EdgeInsets.symmetric(vertical: AppBoxProperties.screenEdgePadding),
						shrinkWrap: true,
						children: [
							_buildSignInForm(context),
							_buildSignUpButtons(context),
							AuthFloatingButton(
								icon: Icons.arrow_back,
								action: () => Navigator.of(context).pop(),
								text: AppLocales.of(context).translate('page.loginSection.backToStartPage')
							)
						]
					)
			  )
	    ),
    );
  }

  Widget _buildSignInForm(BuildContext context) {
		return BlocBuilder<CaregiverSignInCubit, CaregiverSignInState>(
			bloc: BlocProvider.of<CaregiverSignInCubit>(context),
			builder: (context, state) { 
				return AuthGroup(
					title: AppLocales.of(context).translate('$_pageKey.logInTitle'),
					hint: AppLocales.of(context).translate('$_pageKey.logInHint'),
					isLoading: state.status.isSubmissionInProgress,
					action: PopupMenuList(
						lightTheme: true,
						customIcon: Icons.settings,
						items: _buildAdditionalLoginSettings(context)
					),
					content: Column(
						children: <Widget>[
							AuthenticationInputField<CaregiverSignInCubit, CaregiverSignInState>(
								getField: (state) => state.email,
								changedAction: (cubit, value) => cubit.emailChanged(value),
								labelKey: 'authentication.email',
								icon: Icons.email,
								getErrorKey: (state) => [state.email.error!.key],
								inputType: TextInputType.emailAddress,
								autofillHints: [AutofillHints.email]
							),
							AuthenticationInputField<CaregiverSignInCubit, CaregiverSignInState>(
								getField: (state) => state.password,
								changedAction: (cubit, value) => cubit.passwordChanged(value),
								labelKey: 'authentication.password',
								icon: Icons.lock,
								getErrorKey: (state) => [state.password.error!.key],
								hideInput: true,
								autofillHints: [AutofillHints.password]
							),
							AuthButton(
								button: UIButton.ofType(
									ButtonType.signIn,
									() => BlocProvider.of<CaregiverSignInCubit>(context).logInWithCredentials(),
									Colors.teal
								)
							),
							AuthDivider(),
							AuthButton.google(
								UIButton(
									'authentication.googleSignIn',
									() => BlocProvider.of<CaregiverSignInCubit>(context).logInWithGoogle()
								)
							)
						]
					)
				);
			}
		);
  }

	List<UIButton> _buildAdditionalLoginSettings(BuildContext context) {
		return [
			UIButton(
				'$_pageKey.resetPassword',
				() async {
					if (await context.read<CaregiverSignInCubit>().resetPassword())
						showSuccessSnackbar(context, '$_pageKey.resetEmailSent');
				},
				null,
				Icons.settings_backup_restore
			),
			UIButton(
				'$_pageKey.resetVerificationEmail',
				() async {
					var result = await context.read<CaregiverSignInCubit>().resendVerificationEmail();
					if (result == VerificationAttemptOutcome.emailSent)
						showSuccessSnackbar(context, 'authentication.emailVerificationSent');
					else if (result == VerificationAttemptOutcome.accountAlreadyVerified)
						showInfoSnackbar(context, 'authentication.error.accountAlreadyVerified');
				},
				null,
				Icons.mark_email_read
			),
      UIButton(
        'actions.contactUs',
        () => FlutterEmailSender.send(emailBlueprint),
        null,
        Icons.contact_mail
      ),
		];
  }
	
  Widget _buildSignUpButtons(BuildContext context) {
		return AuthGroup(
			title: AppLocales.of(context).translate('$_pageKey.registerTitle'),
			hint: AppLocales.of(context).translate('$_pageKey.registerHint'),
			content: Column(
				children: <Widget>[
					AuthButton(
						button: UIButton.ofType(
							ButtonType.signUp,
							() => Navigator.of(context).pushNamed(AppPage.caregiverSignUpPage.name),
							Colors.teal
						)
					)
				]
			)
		);
	}

}
