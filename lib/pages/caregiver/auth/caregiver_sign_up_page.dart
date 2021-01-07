import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/utils/ui/snackbar_utils.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/widgets/auth/auth_button.dart';
import 'package:fokus/widgets/auth/auth_widgets.dart';
import 'package:fokus_auth/fokus_auth.dart';
import 'package:formz/formz.dart';

import 'package:fokus/logic/caregiver/auth/sign_up/caregiver_sign_up_cubit.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/widgets/auth/auth_input_field.dart';
import 'package:fokus/model/ui/auth/confirmed_password.dart';
import 'package:fokus/model/ui/auth/email.dart';
import 'package:fokus/model/ui/auth/name.dart';
import 'package:fokus/model/ui/auth/password.dart';
import 'package:fokus/services/exception/auth_exceptions.dart';

class CaregiverSignUpPage extends StatelessWidget {
	static const String _pageKey = 'page.loginSection.caregiverSignUp';
	
  @override
  Widget build(BuildContext context) {
	  return Scaffold(
		  body: SafeArea(
			  child: BlocListener<CaregiverSignUpCubit, CaregiverSignUpState>(
				  listener: (context, state) {
					  if (state.status.isSubmissionFailure && (state.signInError != null || state.signUpError != null))
							showFailSnackbar(context, state.signUpError?.key ?? state.signInError.key);
					  else if (state.status.isSubmissionSuccess && state.authMethod == AuthMethod.EMAIL)
					  	showSuccessSnackbar(context, 'authentication.emailVerificationSent');
				  },
					child: ListView(
						padding: EdgeInsets.symmetric(vertical: AppBoxProperties.screenEdgePadding),
						shrinkWrap: true,
						children: [
							_buildSignUpForm(context),
							AuthFloatingButton(
								icon: Icons.arrow_back,
								action: () => Navigator.of(context).pop(),
								text: AppLocales.of(context).translate('page.loginSection.backToLoginPage')
							)
						]
					)
			  )
		  ),
	  );
  }

  Widget _buildSignUpForm(BuildContext context) {
	  return BlocBuilder<CaregiverSignUpCubit, CaregiverSignUpState>(
			cubit: BlocProvider.of<CaregiverSignUpCubit>(context),
			builder: (context, state) { 
				return AuthGroup(
					title: AppLocales.of(context).translate('$_pageKey.registerTitle'),
					hint: AppLocales.of(context).translate('$_pageKey.registerHint'),
					isLoading: state.status.isSubmissionInProgress,
					content: Column(
						children: <Widget>[
							AuthenticationInputField<CaregiverSignUpCubit, CaregiverSignUpState>(
								getField: (state) => state.name,
								changedAction: (cubit, value) => cubit.nameChanged(value),
								labelKey: 'authentication.name',
								icon: Icons.person,
								getErrorKey: (state) => [state.name.error.key],
								inputType: TextInputType.name
							),
							AuthenticationInputField<CaregiverSignUpCubit, CaregiverSignUpState>(
								getField: (state) => state.email,
								changedAction: (cubit, value) => cubit.emailChanged(value),
								labelKey: 'authentication.email',
								icon: Icons.email,
								getErrorKey: (state) => [state.email.error.key],
								inputType: TextInputType.emailAddress
							),
							AuthenticationInputField<CaregiverSignUpCubit, CaregiverSignUpState>(
								getField: (state) => state.password,
								changedAction: (cubit, value) => cubit.passwordChanged(value),
								labelKey: 'authentication.password',
								icon: Icons.lock,
								getErrorKey: (state) => [state.password.error.key, {'LENGTH': Password.minPasswordLength}],
								hideInput: true
							),
							AuthenticationInputField<CaregiverSignUpCubit, CaregiverSignUpState>(
								getField: (state) => state.confirmedPassword,
								changedAction: (cubit, value) => cubit.confirmedPasswordChanged(value),
								labelKey: 'authentication.confirmPassword',
								icon: Icons.lock,
								getErrorKey: (state) => [state.confirmedPassword.error.key],
								hideInput: true
							),
							AuthButton(
								button: UIButton.ofType(
									ButtonType.signUp,
									() => BlocProvider.of<CaregiverSignUpCubit>(context).signUpFormSubmitted(),
									Colors.teal
								)
							),
							AuthDivider(),
							AuthButton.google(
								UIButton(
									'authentication.googleSignUp',
									() => BlocProvider.of<CaregiverSignUpCubit>(context).logInWithGoogle()
								)
							)
						]
					)
				);
			}
		);
	}

}
