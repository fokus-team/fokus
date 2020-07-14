import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fokus/widgets/app_header.dart';
import 'package:fokus/widgets/app_navigation_bar.dart';

class CaregiverPlansPage extends StatefulWidget {
	@override
	_CaregiverPlansPageState createState() => new _CaregiverPlansPageState();
}

class _CaregiverPlansPageState extends State<CaregiverPlansPage> {
	@override
	Widget build(BuildContext context) {
    return Scaffold(
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					AppHeader.normal(title: 'page.caregiverSection.plans.header.title', text: 'page.caregiverSection.plans.header.pageHint', headerActionButtons: [
						HeaderActionButton.normal(Icons.add, 'page.caregiverSection.plans.header.addPlan', () => { log("Dodaj plan") }),
						HeaderActionButton.normal(Icons.calendar_today, 'page.caregiverSection.plans.header.calendar', () => { log("Kalendarz") }, Colors.amber)
					]),
					Container(
						padding: EdgeInsets.all(8.0),
						child: Text('Stworzone plany', textAlign: TextAlign.left, style: Theme.of(context).textTheme.headline2)
					)
				]
			),
			bottomNavigationBar: AppNavigationBar.caregiverPage(currentIndex: 1)
    );
	}
}
