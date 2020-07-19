import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:fokus/widgets/app_header.dart';
import 'package:fokus/widgets/app_navigation_bar.dart';
import 'package:fokus/widgets/segment.dart';

class CaregiverStatisticsPage extends StatefulWidget {
	@override
	_CaregiverStatisticsPageState createState() => new _CaregiverStatisticsPageState();
}

class _CaregiverStatisticsPageState extends State<CaregiverStatisticsPage> {
	static const String _commonKey = 'page.caregiverSection.statistics';
	
	@override
	Widget build(BuildContext context) {
    return Scaffold(
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: <Widget>[
					AppHeader.normal(title: '$_commonKey.header.title', text: '$_commonKey.header.pageHint', headerActionButtons: [
						HeaderActionButton.normal(Icons.archive, '$_commonKey.header.history', () => { log("Historia") }, Colors.amber),
					]),
					AppSegments(
						segments: [
							Segment(
								title: '$_commonKey.content.basicStatisticsTitle',
								subtitle: '$_commonKey.content.basicStatisticsSubtitle',
								elements: []
							)
						]
					)
				]
			),
			bottomNavigationBar: AppNavigationBar.caregiverPage(currentIndex: 3)
    );
	}
}
