import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fokus/data/model/user/caregiver.dart';
import 'package:fokus/wigets/app_header.dart';

class CaregiverAwardsPage extends StatefulWidget {
	@override
	_CaregiverAwardsPageState createState() => new _CaregiverAwardsPageState();
}

class _CaregiverAwardsPageState extends State<CaregiverAwardsPage> {
	@override
	Widget build(BuildContext context) {
		var user = ModalRoute.of(context).settings.arguments as Caregiver;

    return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				AppHeader.normal(user, 'page.caregiverAwards.header.title', 'page.caregiverAwards.header.pageHint', [
					HeaderActionButton.normal(Icons.add, 'page.caregiverAwards.header.addAward', () => { log("Dodaj nagrodę") }),
					HeaderActionButton.normal(Icons.add, 'page.caregiverAwards.header.addBadge', () => { log("Dodaj odznakę") })
				]),
				Container(
					padding: EdgeInsets.all(8.0),
					child: Text('Stworzone nagrody', textAlign: TextAlign.left, style: Theme.of(context).textTheme.headline2)
				)
			]
		);
    
	}
}
