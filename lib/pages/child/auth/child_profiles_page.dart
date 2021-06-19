import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:round_spot/round_spot.dart' as round_spot;

import '../../../logic/child/auth/saved_child_profiles_cubit.dart';
import '../../../model/ui/app_page.dart';
import '../../../model/ui/ui_button.dart';
import '../../../services/app_locales.dart';
import '../../../utils/ui/theme_config.dart';
import '../../../widgets/auth/auth_button.dart';
import '../../../widgets/auth/auth_widgets.dart';
import '../../../widgets/general/app_avatar.dart';
import '../../../widgets/stateful_bloc_builder.dart';

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
					  StatefulBlocBuilder<SavedChildProfilesCubit, SavedChildProfilesData>(
						  builder: (context, state) => _buildSavedProfiles(context, state: state.data!),
						  loadingBuilder: (context, state) => _buildSavedProfiles(context),
				    ),
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

	AuthGroup _buildSavedProfiles(BuildContext context, {SavedChildProfilesData? state}) {
	  return AuthGroup(
			title: AppLocales.of(context).translate('$_pageKey.profileLogInTitle'),
			hint: AppLocales.of(context).translate('$_pageKey.profileLogInHint'),
			isLoading: state == null,
		  action: IconButton(
			  icon: Icon(Icons.person_add, size: 26.0, color: Colors.white),
			  tooltip: AppLocales.of(context).translate('$_pageKey.addProfile'),
			  onPressed: () => { Navigator.of(context).pushNamed(AppPage.childSignInPage.name) },
		  ),
			padding: EdgeInsets.zero,
			content: Column(
				children: <Widget>[
					if (state != null && state.savedProfiles.isNotEmpty)
						Material(
							type: MaterialType.transparency,
							child: round_spot.Detector(
								areaID: 'child-profiles',
							  child: ListView(
							  	padding: EdgeInsets.symmetric(vertical: 10.0),
							  	shrinkWrap: true,
							  	children: [
							  		for (var child in state.savedProfiles)
							  			ListTile(
							  				onTap: () => context.read<SavedChildProfilesCubit>().signIn(child.id!),
							  				leading: FittedBox(child: AppAvatar(child.avatar)),
							  				title: Text(child.name!, style: Theme.of(context).textTheme.headline3),
							  				trailing: TextButton(
							  					child: Icon(Icons.arrow_forward),
							  					style: TextButton.styleFrom(
														backgroundColor: Colors.orange,
														padding: EdgeInsets.all(12),
														primary: Colors.white
													),
							  					onPressed: () => context.read<SavedChildProfilesCubit>().signIn(child.id!)
							  				),
							  				contentPadding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
							  			)
							  	]
							  ),
							)
						)
					else
						Center(
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

}
