import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fokus/logic/auth/child/sign_in/child_sign_in_cubit.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/auth/user_code.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/auth/auth_input_field.dart';
import 'package:fokus/widgets/auth/auth_submit_button.dart';

class ChildSignInPage extends StatelessWidget {
	static const String _pageKey = 'page.loginSection.childSignIn';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
	    body: SafeArea(
			  child: Column(
				  children: <Widget>[
				  	BlocBuilder<ChildSignInCubit, ChildSignInState>(
						  buildWhen: (oldState, newState) => oldState.savedChildren != newState.savedChildren,
						  builder: (context, state) {
							  var cubit = context.bloc<ChildSignInCubit>();
							  if (state.savedChildren == null) {
								  cubit.loadSavedProfiles();
								  return Center(child: CircularProgressIndicator()); // TODO Come up with smarter loading indicator as we have more content below
							  }
							  return Column(
								  children: [
								  	for (var child in state.savedChildren)
										  MaterialButton(
											  child: Text(child.name),
											  color: AppColors.childActionColor,
											  onPressed: () => cubit.signInWithCachedId(child.id),
										  )
								  ],
							  );
						  },
					  ),
				    ..._buildSignInForm(context)
	        ]
			  )
	    ),
    );
  }

	List<Widget> _buildSignInForm(BuildContext context) {
		return [
			AuthenticationInputField<ChildSignInCubit, ChildSignInState>(
				getField: (state) => state.childCode,
				changedAction: (cubit, value) => cubit.childCodeChanged(value),
				labelKey: '$_pageKey.childCode',
				getErrorKey: (state) => [state.childCode.error.key],
			),
			AuthenticationSubmitButton<ChildSignInCubit, ChildSignInState>(
				button: UIButton.ofType(ButtonType.signIn, () => context.bloc<ChildSignInCubit>().signInNewChild())
			),
			MaterialButton(
				child: Text(AppLocales.of(context).translate('$_pageKey.createNewProfile')),
				color: AppColors.childActionColor,
				onPressed: () => Navigator.of(context).pushNamed(AppPage.childSignUpPage.name),
			),
		];
	}
}
