import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import 'package:fokus/logic/auth/caregiver/sign_in/caregiver_sign_in_cubit.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/auth/auth_input_field.dart';
import 'package:fokus/model/ui/auth/email.dart';
import 'package:fokus/services/exception/auth_exceptions.dart';
import 'package:fokus/model/ui/auth/password.dart';
import 'package:fokus/utils/snackbar_utils.dart';
import 'package:fokus/widgets/auth/auth_button.dart';
import 'package:fokus/widgets/auth/auth_widgets.dart';

class CaregiverSignInPage extends StatelessWidget {
	static const String _pageKey = 'page.loginSection.caregiverSignIn';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
	    body: SafeArea(
			  child: BlocListener<CaregiverSignInCubit, CaregiverSignInState>(
				  listener: (context, state) {
					  if (state.status.isSubmissionFailure && state.signInError != null)
							showFailSnackbar(context, state.signInError.key);
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
			cubit: BlocProvider.of<CaregiverSignInCubit>(context),
			builder: (context, state) { 
				return AuthGroup(
					title: AppLocales.of(context).translate('$_pageKey.logInTitle'),
					hint: AppLocales.of(context).translate('$_pageKey.logInHint'),
					isLoading: state.status.isSubmissionInProgress,
					content: Column(
						children: <Widget>[
							AuthenticationInputField<CaregiverSignInCubit, CaregiverSignInState>(
								getField: (state) => state.email,
								changedAction: (cubit, value) => cubit.emailChanged(value),
								labelKey: 'authentication.email',
								icon: Icons.email,
								getErrorKey: (state) => [state.email.error.key],
								inputType: TextInputType.emailAddress
							),
							AuthenticationInputField<CaregiverSignInCubit, CaregiverSignInState>(
								getField: (state) => state.password,
								changedAction: (cubit, value) => cubit.passwordChanged(value),
								labelKey: 'authentication.password',
								icon: Icons.lock,
								getErrorKey: (state) => [state.password.error.key],
								hideInput: true
							),
							AuthButton(
								button: UIButton.ofType(
									ButtonType.signIn,
									() => context.bloc<CaregiverSignInCubit>().logInWithCredentials(),
									Colors.teal
								)
							),
							AuthDivider(),
							AuthButton.google(
								UIButton(
									'authentication.googleSignIn',
									() => context.bloc<CaregiverSignInCubit>().logInWithGoogle()
								)
							)
						]
					)
				);
			}
		);
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
