import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fokus/logic/auth/caregiver/sign_in/caregiver_sign_in_cubit.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/button.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/auth/auth_input_field.dart';
import 'package:fokus/widgets/auth/auth_submit_button.dart';
import 'package:fokus/model/ui/auth/email.dart';
import 'package:fokus/model/ui/auth/password.dart';

class CaregiverSignInPage extends StatelessWidget {
	static const String _pageKey = 'page.loginSection.caregiverSignIn';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
	    body: SafeArea(
			  child: _buildSignInForm(context)
	    ),
    );
  }

  Widget _buildSignInForm(BuildContext context) {
		return Column(
			children: <Widget>[
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
					getErrorKey: (state) => [state.password.error.key],
					hideInput: true,
				),
				AuthenticationSubmitButton<CaregiverSignInCubit, CaregiverSignInState>(
					button: UIButton(ButtonType.signIn, (context) => context.bloc<CaregiverSignInCubit>().logInWithCredentials())
				),
				MaterialButton(
					child: Text(AppLocales.of(context).translate('actions.signUp')),
					color: AppColors.caregiverButtonColor,
					onPressed: () => Navigator.of(context).pushNamed(AppPage.caregiverSignUpPage.name),
				),
				GoogleSignInButton(
					onPressed: () => context.bloc<CaregiverSignInCubit>().logInWithGoogle(),
					text: AppLocales.of(context).translate('$_pageKey.googleSignIn'),
				)
			],
		);
  }
}
