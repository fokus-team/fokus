import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/child/auth/prev_profiles_cubit.dart';

import 'package:fokus/logic/common/reloadable/reloadable_cubit.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/widgets/general/app_avatar.dart';
import 'package:fokus/widgets/auth/auth_button.dart';
import 'package:fokus/widgets/auth/auth_widgets.dart';

class ChildProfilesPage extends StatelessWidget {
	static const String _pageKey = 'page.loginSection.childProfiles';

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
		return BlocBuilder<PreviousProfilesCubit, LoadableState>(
			builder: (context, state) {
				var cubit = BlocProvider.of<PreviousProfilesCubit>(context);
				if (state is DataLoadInitial)
					cubit.loadData();

				return AuthGroup(
					title: AppLocales.of(context).translate('$_pageKey.profileLogInTitle'),
					hint: AppLocales.of(context).translate('$_pageKey.profileLogInHint'),
					isLoading: !(state is DataLoadSuccess),
					action: IconButton(
						icon: Icon(Icons.person_add, size: 26.0, color: Colors.white),
						tooltip: AppLocales.of(context).translate('$_pageKey.addProfile'),
						onPressed: () => { Navigator.of(context).pushNamed(AppPage.childSignInPage.name) },
					),
					padding: EdgeInsets.zero,
					content: Column(
						children: <Widget>[
							(state is PreviousProfilesLoadSuccess && state.previousProfiles.isNotEmpty) ?
								Material(
									type: MaterialType.transparency,
									child: ListView(
										padding: EdgeInsets.symmetric(vertical: 10.0),
										shrinkWrap: true,
										children: [
											for (var child in state.previousProfiles)
												ListTile(
													onTap: () => cubit.signIn(child.id),
													leading: FittedBox(child: AppAvatar(child.avatar)),
													title: Text(child.name, style: Theme.of(context).textTheme.headline3),
													trailing: FlatButton(
														child: Icon(Icons.arrow_forward),
														color: Colors.orange,
														textColor: Colors.white,
														padding: EdgeInsets.all(12),
														materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
														minWidth: 20,
														onPressed: () => {}
													),
													contentPadding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
												)
										]
									)
								)
								: Center(
									child: Padding(
										padding: EdgeInsets.symmetric(vertical: AppBoxProperties.screenEdgePadding),
										child: Column(
											children: [
												Text(
													AppLocales.of(context).translate('$_pageKey.noSavedProfiles'),
													style: Theme.of(context).textTheme.subtitle2
												),
												Padding(
													padding: EdgeInsets.all(8.0),
													child: AuthButton(
														button: UIButton(
															'$_pageKey.addProfile',
															() => { Navigator.of(context).pushNamed(AppPage.childSignInPage.name) },
															Colors.orange
														)
													)
												)
											]
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
