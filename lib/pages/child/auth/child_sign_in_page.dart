import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fokus/logic/auth/child/sign_in/child_sign_in_cubit.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/auth/user_code.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/app_avatar.dart';
import 'package:fokus/widgets/auth/auth_button.dart';
import 'package:fokus/widgets/auth/auth_input_field.dart';
import 'package:fokus/widgets/auth/auth_widgets.dart';

class ChildSignInPage extends StatelessWidget {
	static const String _pageKey = 'page.loginSection.childSignIn';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
	    body: SafeArea(
			  child: ListView(
					padding: EdgeInsets.symmetric(vertical: AppBoxProperties.screenEdgePadding),
					shrinkWrap: true,
					children: [
						_buildSavedProfiles(context),
						AuthFloatingButton(
							icon: Icons.arrow_back,
							action: () => Navigator.of(context).pop(),
							text: AppLocales.of(context).translate('page.loginSection.backToStartPage')
						)
					]
				)
	    )
    );
  }

	Widget _buildSavedProfiles(BuildContext context) {
		return BlocBuilder<ChildSignInCubit, ChildSignInState>(
			buildWhen: (oldState, newState) => oldState.savedChildren != newState.savedChildren,
			builder: (context, state) {
				var cubit = context.bloc<ChildSignInCubit>();
				if (state.savedChildren == null) {
					cubit.loadSavedProfiles();
				}
				return AuthGroup(
					title: AppLocales.of(context).translate('$_pageKey.profileLogInTitle'),
					hint: AppLocales.of(context).translate('$_pageKey.profileLogInHint'),
					isLoading: (state.savedChildren == null),
					padding: EdgeInsets.zero,
					content: Column(
						children: <Widget>[
							(state.savedChildren != null && state.savedChildren.isNotEmpty) ?
								Material(
									type: MaterialType.transparency,
									child: ListView(
										padding: EdgeInsets.symmetric(vertical: 10.0),
										shrinkWrap: true,
										children: [
											for (var child in state.savedChildren)
												ListTile(
													onTap: () => cubit.signInWithCachedId(child.id),
													leading: FittedBox(child: AppAvatar(child.avatar)),
													title: Text(child.name, style: Theme.of(context).textTheme.headline3),
													trailing: Icon(Icons.arrow_forward),
													contentPadding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
												)
										]
									)
								)
								: Center(
									child: Padding(
										padding: EdgeInsets.symmetric(vertical: AppBoxProperties.screenEdgePadding),
										child: Text(
											AppLocales.of(context).translate('$_pageKey.noSavedProfiles'),
											style: Theme.of(context).textTheme.subtitle2
										)
									)
								),
							Padding(
								padding: EdgeInsets.all(8.0),
								child: AuthButton(
									button: UIButton(
										'$_pageKey.addProfile',
										() => { Navigator.of(context).pushNamed(AppPage.childSignUpPage.name) },
										Colors.orange
									)
								)
							)
						]
					)
				);
			}
		);
	}

}
