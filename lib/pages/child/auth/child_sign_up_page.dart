import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fokus/logic/auth/child/sign_up/child_sign_up_cubit.dart';
import 'package:fokus/model/ui/button.dart';
import 'package:fokus/widgets/auth/auth_input_field.dart';
import 'package:fokus/widgets/auth/auth_submit_button.dart';
import 'package:fokus/model/ui/auth/user_code.dart';
import 'package:fokus/model/ui/auth/name.dart';

class ChildSignUpPage extends StatelessWidget {
	static const String _pageKey = 'page.loginSection.childSignUp';
	
  @override
  Widget build(BuildContext context) {
	  return Scaffold(
		  body: SafeArea(
			  child: _buildSignUpForm(context),
		  ),
	  );
  }

  Widget _buildSignUpForm(BuildContext context) {
	  return Column(
		  children: <Widget>[
			  AuthenticationInputField<ChildSignUpCubit, ChildSignUpState>(
				  getField: (state) => state.caregiverCode,
				  changedAction: (cubit, value) => cubit.caregiverCodeChanged(value),
				  labelKey: '$_pageKey.caregiverCode',
				  getErrorKey: (state) => [state.caregiverCode.error.key],
			  ),
			  AuthenticationInputField<ChildSignUpCubit, ChildSignUpState>(
				  getField: (state) => state.name,
				  changedAction: (cubit, value) => cubit.nameChanged(value),
				  labelKey: 'authentication.name',
				  getErrorKey: (state) => [state.name.error.key],
			  ),
			  AuthenticationSubmitButton<ChildSignUpCubit, ChildSignUpState>(
					button: UIButton(ButtonType.signUp, (context) => context.bloc<ChildSignUpCubit>().signUpFormSubmitted())
			  ),
		  ],
	  );
  }
}
