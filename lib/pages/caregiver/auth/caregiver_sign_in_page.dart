import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus_auth/fokus_auth.dart';
import 'package:stateful_bloc/stateful_bloc.dart';

import '../../../logic/caregiver/auth/sign_in/caregiver_sign_in_cubit.dart';
import '../../../model/ui/app_page.dart';
import '../../../model/ui/ui_button.dart';
import '../../../services/app_locales.dart';
import '../../../services/exception/auth_exceptions.dart';
import '../../../utils/ui/snackbar_utils.dart';
import '../../../utils/ui/theme_config.dart';
import '../../../widgets/auth/auth_button.dart';
import '../../../widgets/auth/auth_widgets.dart';
import '../../../widgets/auth/caregiver_sign_in_form.dart';

class CaregiverSignInPage extends StatelessWidget {
	static const String _pageKey = 'page.loginSection.caregiverSignIn';
	final String? initialEmail;

  CaregiverSignInPage(this.initialEmail);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
	    body: SafeArea(
			  child: BlocListener<CaregiverSignInCubit, StatefulState<CaregiverSignInData>>(
				  listener: (context, state) {
					  if (state.submitFailed) {
					  	if (state.data!.signInError != null)
							  showFailSnackbar(context, state.data!.signInError!.key);
					  	else if (state.data!.passwordResetError != null)
								showFailSnackbar(context, 'authentication.error.emailLink', {
	                'TYPE': '${AppLinkType.passwordReset.index}',
	                'ERR': '${state.data!.passwordResetError!.index}'
	              });
				    }
				  },
				  child: ListView(
						padding: EdgeInsets.symmetric(vertical: AppBoxProperties.screenEdgePadding),
						shrinkWrap: true,
						children: [
							CaregiverSignInForm(initialEmail),
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
