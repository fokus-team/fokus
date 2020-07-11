import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fokus/data/model/user/caregiver.dart';
import 'package:fokus/wigets/app_header.dart';

class CaregiverPlansPage extends StatefulWidget {
	@override
	_CaregiverPlansPageState createState() => new _CaregiverPlansPageState();
}

class _CaregiverPlansPageState extends State<CaregiverPlansPage> {
	@override
	Widget build(BuildContext context) {
		var user = ModalRoute.of(context).settings.arguments as Caregiver;

    return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				AppHeader.normal(user, 'page.caregiverPlans.header.title', 'page.caregiverPlans.header.pageHint', [
					HeaderActionButton.normal(Icons.add, 'page.caregiverPlans.header.addPlan', () => { log("Dodaj plan") }),
					HeaderActionButton.normal(Icons.add, 'page.caregiverPlans.header.calendar', () => { log("Kalendarz") }, Colors.amber)
				]),
				Container(
					padding: EdgeInsets.all(8.0),
					child: Text('Stworzone plany', textAlign: TextAlign.left, style: Theme.of(context).textTheme.headline2)
				)
			]
		);
    
	}
}
