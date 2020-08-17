import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import 'package:fokus/logic/auth/caregiver/sign_up/caregiver_sign_up_cubit.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/widgets/auth/auth_input_field.dart';
import 'package:fokus/widgets/auth/auth_submit_button.dart';
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
					  if (state.status.isSubmissionFailure && state.response != null)
						  Scaffold.of(context)..hideCurrentSnackBar()..showSnackBar(
							  SnackBar(content: Text(AppLocales.of(context).translate(state.response.key))),
						  );
				  },
				  child: _buildSignUpForm(context),
			  )
		  ),
	  );
  }

  Widget _buildSignUpForm(BuildContext context) {
	  return Column(
		  children: <Widget>[
			  AuthenticationInputField<CaregiverSignUpCubit, CaregiverSignUpState>(
					getField: (state) => state.name,
					changedAction: (cubit, value) => cubit.nameChanged(value),
					labelKey: 'authentication.name',
					getErrorKey: (state) => [state.name.error.key],
			  ),
			  AuthenticationInputField<CaregiverSignUpCubit, CaregiverSignUpState>(
					getField: (state) => state.email,
					changedAction: (cubit, value) => cubit.emailChanged(value),
					labelKey: 'authentication.email',
					getErrorKey: (state) => [state.email.error.key],
					inputType: TextInputType.emailAddress
			  ),
			  AuthenticationInputField<CaregiverSignUpCubit, CaregiverSignUpState>(
					getField: (state) => state.password,
					changedAction: (cubit, value) => cubit.passwordChanged(value),
					labelKey: 'authentication.password',
					getErrorKey: (state) => [state.password.error.key, {'LENGTH': Password.minPasswordLength}],
					hideInput: true
			  ),
			  AuthenticationInputField<CaregiverSignUpCubit, CaregiverSignUpState>(
					getField: (state) => state.confirmedPassword,
					changedAction: (cubit, value) => cubit.confirmedPasswordChanged(value),
					labelKey: 'authentication.confirmPassword',
					getErrorKey: (state) => [state.confirmedPassword.error.key],
					hideInput: true
			  ),
			  AuthenticationSubmitButton<CaregiverSignUpCubit, CaregiverSignUpState>(
					button: UIButton.ofType(ButtonType.signUp, () => context.bloc<CaregiverSignUpCubit>().signUpFormSubmitted())
			  ),
			  GoogleSignInButton(
					onPressed: () => context.bloc<CaregiverSignUpCubit>().logInWithGoogle(),
				  text: AppLocales.of(context).translate('authentication.googleSignUp'),
			  )
		  ],
	  );
  }
}
