import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fokus/logic/child_badges_cubit.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/app_paths.dart';
import 'package:fokus/utils/dialog_utils.dart';
import 'package:fokus/utils/icon_sets.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/app_navigation_bar.dart';
import 'package:fokus/widgets/app_header.dart';
import 'package:fokus/widgets/general/app_hero.dart';
import 'package:fokus/widgets/loadable_bloc_builder.dart';
import 'package:fokus/widgets/segment.dart';

class ChildAchievementsPage extends StatefulWidget {
	@override
	_ChildAchievementsPageState createState() => new _ChildAchievementsPageState();
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
				children: [
					ChildCustomHeader(),
		      LoadableBlocBuilder<ChildBadgesCubit>(
				    builder: (context, state) => 
							AppSegments(
								segments: [
									Segment(
										title: '$_pageKey.content.achievementsTitle',
										subtitle: '$_pageKey.content.achievementsHint',
										customContent: _buildBadgeShelfs(state)
									)
								]
							),
						wrapWithExpanded: true,
		      )
				]
			),
			bottomNavigationBar: AppNavigationBar.childPage(currentIndex: 2)
		);
	}

	Widget _buildBadgeShelfs(ChildBadgesLoadSuccess state) {
		if(state.badges.isNotEmpty) {
			return Padding(
				padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: AppBoxProperties.screenEdgePadding),
				child: Builder(
					builder: (context) {
						List<Widget> rows = [];
						for (var i = 0; i < state.badges.length; i += badgesPerShelf) {
							rows.add(Row(
								children: state.badges.sublist(i, i+badgesPerShelf > state.badges.length ? state.badges.length : i+badgesPerShelf)
								.map((badge) =>
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
