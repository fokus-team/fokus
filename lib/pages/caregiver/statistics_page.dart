import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fokus/data/model/user/caregiver.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/wigets/app_bottom_navigation_bar.dart';
import 'package:fokus/wigets/app_header.dart';
import 'package:fokus/wigets/page_theme.dart';

class CaregiverStatisticsPage extends StatefulWidget {
	@override
	_CaregiverStatisticsPageState createState() => new _CaregiverStatisticsPageState();
}

class _CaregiverStatisticsPageState extends State<CaregiverStatisticsPage> {
	@override
	Widget build(BuildContext context) {
		var user = ModalRoute.of(context).settings.arguments as Caregiver;

    return Scaffold(
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					AppHeader.normal(user, 'page.caregiverSection.statistics.header.title', 'page.caregiverSection.statistics.header.pageHint', [
						HeaderActionButton.normal(Icons.archive, 'page.caregiverSection.statistics.header.history', () => { log("Historia") }, Colors.amber),
					]),
					Container(
						padding: EdgeInsets.all(8.0),
						child: Text('Podstawowe wykresy', textAlign: TextAlign.left, style: Theme.of(context).textTheme.headline2)
					)
				]
			),
			bottomNavigationBar: AppBottomNavigationBar.caregiverPage(
				currentIndex: 3,
				user: user,
			)
    );
	}
}
