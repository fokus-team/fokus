import 'package:flutter/material.dart';
import 'package:fokus/widgets/app_navigation_bar.dart';
import 'package:fokus/widgets/app_header.dart';
import 'package:fokus/widgets/segment.dart';

class ChildAchievementsPage extends StatefulWidget {
	@override
	_ChildAchievementsPageState createState() => new _ChildAchievementsPageState();
}

class _ChildAchievementsPageState extends State<ChildAchievementsPage> {
  static const String _pageKey = 'page.childSection.achievements';

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					ChildCustomHeader(),
					AppSegments(
						segments: [
							Segment(
								title: '$_pageKey.content.achievementsTitle',
								noElementsMessage: '$_pageKey.content.noAchievementsMessage',
								elements: <Widget>[]
							),
						]
					)
				]
			),
			bottomNavigationBar: AppNavigationBar.childPage(currentIndex: 2)
		);
	}
}
