import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fokus/widgets/app_header.dart';
import 'package:fokus/widgets/app_navigation_bar.dart';

class CaregiverAwardsPage extends StatefulWidget {
	@override
	_CaregiverAwardsPageState createState() => new _CaregiverAwardsPageState();
}

class _CaregiverAwardsPageState extends State<CaregiverAwardsPage> {
	@override
	Widget build(BuildContext context) {
    return Scaffold(
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					AppHeader.normal(title: 'page.caregiverSection.awards.header.title', text: 'page.caregiverSection.awards.header.pageHint', headerActionButtons: [
						HeaderActionButton.normal(Icons.add, 'page.caregiverSection.awards.header.addAward', () => { log("Dodaj nagrodę") }),
						HeaderActionButton.normal(Icons.add, 'page.caregiverSection.awards.header.addBadge', () => { log("Dodaj odznakę") })
					]),
					Container(
						padding: EdgeInsets.all(8.0),
						child: Text('Stworzone nagrody', textAlign: TextAlign.left, style: Theme.of(context).textTheme.headline2)
					)
				]
			),
			bottomNavigationBar: AppNavigationBar.caregiverPage(currentIndex: 2)
    );
	}
}
