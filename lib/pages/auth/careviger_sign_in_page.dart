import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fokus/logic/auth/sign_in/caregiver_sign_in_cubit.dart';
import 'package:fokus/model/ui/button.dart';
import 'package:fokus/widgets/auth/auth_input_field.dart';
import 'package:fokus/widgets/auth/auth_submit_button.dart';
import 'package:fokus/model/ui/auth/confirmed_password.dart';
import 'package:fokus/model/ui/auth/email.dart';
import 'package:fokus/model/ui/auth/name.dart';
import 'package:fokus/model/ui/auth/password.dart';

class CaregiverSignInPage extends StatelessWidget {
	static const String _pageKey = 'page.loginSection.caregiverLogin';
	
  @override
  Widget build(BuildContext context) {
	  return BlocProvider<CaregiverSignInCubit>(
		  create: (_) => CaregiverSignInCubit(),
		  child: Scaffold(
		    body: SafeArea(
			    child: _buildSignInForm(context),
		    ),
		  ),
	  );
  }

  Widget _buildSignInForm(BuildContext context) {
	  return Column(
		  children: <Widget>[
			  AuthenticationInputField<CaregiverSignInCubit, CaregiverSignInState>(
					getField: (state) => state.name,
					changedAction: (cubit, value) => cubit.nameChanged(value),
					labelKey: 'authentication.name',
					getErrorKey: (state) => [state.name.error.key],
			  ),
			  AuthenticationInputField<CaregiverSignInCubit, CaregiverSignInState>(
					getField: (state) => state.email,
					changedAction: (cubit, value) => cubit.emailChanged(value),
					labelKey: 'authentication.email',
					getErrorKey: (state) => [state.email.error.key],
					inputType: TextInputType.emailAddress
			  ),
			  AuthenticationInputField<CaregiverSignInCubit, CaregiverSignInState>(
					getField: (state) => state.password,
					changedAction: (cubit, value) => cubit.passwordChanged(value),
					labelKey: 'authentication.password',
					getErrorKey: (state) => [state.password.error.key, {'LENGTH': Password.minPasswordLength}],
					hideInput: true
			  ),
			  AuthenticationInputField<CaregiverSignInCubit, CaregiverSignInState>(
					getField: (state) => state.confirmedPassword,
					changedAction: (cubit, value) => cubit.confirmedPasswordChanged(value),
					labelKey: 'authentication.confirmPassword',
					getErrorKey: (state) => [state.confirmedPassword.error.key],
					hideInput: true
			  ),
			  AuthenticationSubmitButton<CaregiverSignInCubit, CaregiverSignInState>(
					button: UIButton(ButtonType.signIn, (context) => context.bloc<CaregiverSignInCubit>().signUpFormSubmitted())
			  )
		  ],
	  );
  }
}
