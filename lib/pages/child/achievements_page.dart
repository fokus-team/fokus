import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/common/auth_bloc/authentication_bloc.dart';
import '../../model/db/user/child.dart';
import '../../services/app_locales.dart';
import '../../utils/ui/app_paths.dart';
import '../../utils/ui/dialog_utils.dart';
import '../../utils/ui/icon_sets.dart';
import '../../utils/ui/theme_config.dart';
import '../../widgets/app_navigation_bar.dart';
import '../../widgets/custom_app_bars.dart';
import '../../widgets/general/app_hero.dart';
import '../../widgets/segment.dart';

class ChildAchievementsPage extends StatefulWidget {
	@override
	_ChildAchievementsPageState createState() => _ChildAchievementsPageState();
}

class _ChildAchievementsPageState extends State<ChildAchievementsPage> {
  static const String _pageKey = 'page.childSection.achievements';
	double badgeMargin = 20.0;
	int badgesPerShelf = 3;

	@override
	Widget build(BuildContext context) {
		if(MediaQuery.of(context).size.width <= 370) {
			badgesPerShelf = 2;
			badgeMargin = 30.0;
		}
		return Scaffold(
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				verticalDirection: VerticalDirection.up,
				children: [
					AppSegments(
						segments: [
							Segment(
								title: '$_pageKey.content.achievementsTitle',
								subtitle: '$_pageKey.content.achievementsHint',
								customContent: _buildBadgeShelves()
							)
						]
					),
					CustomChildAppBar()
				]
			),
			bottomNavigationBar: AppNavigationBar.childPage(currentIndex: 2)
		);
	}

	Widget _buildBadgeShelves() {
		return BlocBuilder<AuthenticationBloc, AuthenticationState>(
			buildWhen: (oldState, newState) => newState.signedIn,
			builder: (context, state) {
				var badges = (state.user as Child).badges ?? [];
				if(badges.isNotEmpty) {
					return Padding(
						padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: AppBoxProperties.screenEdgePadding),
						child: Builder(
							builder: (context) {
								var rows = <Widget>[];
								for (var i = 0; i < badges.length; i += badgesPerShelf) {
									rows.add(Row(
										children: badges.sublist(i, i+badgesPerShelf > badges.length ? badges.length : i+badgesPerShelf).map((badge) =>
											Expanded(
												flex: (100.0/badgesPerShelf).round(),
												child: GestureDetector(
													onTap: () => showBadgeDialog(context, badge),
													child: SvgPicture.asset(
														AssetType.badges.getPath(badge.icon),
														width: (MediaQuery.of(context).size.width - 2 * AppBoxProperties.screenEdgePadding)/badgesPerShelf - 2 * badgeMargin
													)
												)
											)
										).toList()
									));
									rows.add(_buildShelf());
								}
								return Column(children: rows);
							}
						)
					);
				}
				return AppHero(
					title: AppLocales.of(context).translate('$_pageKey.content.noAchievementsMessage'),
					icon: Icons.local_florist
				);
			}
		);
	}

	Widget _buildShelf() {
		return Container(
			width: double.infinity,
			margin: EdgeInsets.only(bottom: 16.0),
			height: 16.0,
			decoration: BoxDecoration(
				color: Colors.brown,
				borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.0))
			)
		);
	}

}
