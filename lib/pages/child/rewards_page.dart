import 'package:flutter/material.dart';
import 'package:fokus/widgets/app_navigation_bar.dart';
import 'package:fokus/widgets/app_header.dart';
import 'package:fokus/widgets/segment.dart';

class ChildRewardsPage extends StatefulWidget {
	@override
	_ChildRewardsPageState createState() => new _ChildRewardsPageState();
}

class _ChildRewardsPageState extends State<ChildRewardsPage> {
  static const String _pageKey = 'page.childSection.rewards';

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
								title: '$_pageKey.content.rewardsTitle',
								noElementsMessage: '$_pageKey.content.noRewardsMessage',
								elements: <Widget>[]
							),
						]
					)
				]
			),
			bottomNavigationBar: AppNavigationBar.childPage(currentIndex: 1)
		);
	}
}
