import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fokus/data/model/user/caregiver.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/wigets/app_bottom_navigation_bar.dart';
import 'package:fokus/wigets/app_header.dart';
import 'package:fokus/wigets/page_theme.dart';

class CaregiverPlansPage extends StatefulWidget {
	@override
	_CaregiverPlansPageState createState() => new _CaregiverPlansPageState();
}

class _CaregiverPlansPageState extends State<CaregiverPlansPage> {
	@override
	Widget build(BuildContext context) {
		var user = ModalRoute.of(context).settings.arguments as Caregiver;

    return Scaffold(
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					AppHeader.normal(user, 'page.caregiverSection.plans.header.title', 'page.caregiverSection.plans.header.pageHint', [
						HeaderActionButton.normal(Icons.add, 'page.caregiverSection.plans.header.addPlan', () => { log("Dodaj plan") }),
						HeaderActionButton.normal(Icons.calendar_today, 'page.caregiverSection.plans.header.calendar', () => { log("Kalendarz") }, Colors.amber)
					]),
					Container(
						padding: EdgeInsets.all(8.0),
						child: Text('Stworzone plany', textAlign: TextAlign.left, style: Theme.of(context).textTheme.headline2)
					)
				]
			),
			bottomNavigationBar: AppBottomNavigationBar.caregiverPage(
				currentIndex: 1,
				user: user,
			)
    );
	}
}
