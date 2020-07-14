import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fokus/data/model/user/caregiver.dart';

import 'package:fokus/wigets/app_navigation_bar.dart';
import 'package:fokus/wigets/app_header.dart';

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
					AppHeader.normal(user: user, title: 'page.caregiverSection.statistics.header.title', text: 'page.caregiverSection.statistics.header.pageHint', headerActionButtons: [
						HeaderActionButton.normal(Icons.archive, 'page.caregiverSection.statistics.header.history', () => { log("Historia") }, Colors.amber),
					]),
					Container(
						padding: EdgeInsets.all(8.0),
						child: Text('Podstawowe wykresy', textAlign: TextAlign.left, style: Theme.of(context).textTheme.headline2)
					)
				]
			),
			bottomNavigationBar: AppNavigationBar.caregiverPage(
				currentIndex: 3,
				user: user,
			)
    );
	}
}
