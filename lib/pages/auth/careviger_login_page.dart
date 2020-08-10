import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fokus/logic/auth/login/caregiver_login_cubit.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/button.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/auth/auth_input_field.dart';
import 'package:fokus/widgets/auth/auth_submit_button.dart';
import 'package:fokus/model/ui/auth/email.dart';
import 'package:fokus/model/ui/auth/password.dart';

class CaregiverLoginPage extends StatelessWidget {
	static const String _pageKey = 'page.loginSection.caregiverLogin';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CaregiverLoginCubit>(
			create: (_) => CaregiverLoginCubit(),
	    child: Scaffold(
		    body: SafeArea(
				  child: _buildLoginForm(context)
		    ),
	    )
    );
  }

  Widget _buildLoginForm(BuildContext context) {
		return Column(
			children: <Widget>[
				AuthenticationInputField<CaregiverLoginCubit, CaregiverLoginState>(
					getField: (state) => state.email,
					changedAction: (cubit, value) => cubit.emailChanged(value),
					labelKey: 'authentication.email',
					getErrorKey: (state) => [state.email.error.key, ],
					inputType: TextInputType.emailAddress
				),
				AuthenticationInputField<CaregiverLoginCubit, CaregiverLoginState>(
					getField: (state) => state.password,
					changedAction: (cubit, value) => cubit.passwordChanged(value),
					labelKey: 'authentication.password',
					getErrorKey: (state) => [state.password.error.key],
					hideInput: true,
				),
				AuthenticationSubmitButton<CaregiverLoginCubit, CaregiverLoginState>(
					button: UIButton(ButtonType.login, (context) => context.bloc<CaregiverLoginCubit>().logInWithCredentials())
				),
				MaterialButton(
					child: Text(AppLocales.of(context).translate('actions.signIn')),
					color: AppColors.caregiverButtonColor,
					onPressed: () => Navigator.of(context).pushNamed(AppPage.caregiverSignInPage.name),
				)
			],
		);
  }
}
