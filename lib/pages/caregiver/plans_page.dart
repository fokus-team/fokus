import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fokus/utils/app_locales.dart';

import 'package:fokus/widgets/app_header.dart';
import 'package:fokus/widgets/app_navigation_bar.dart';
import 'package:fokus/widgets/item_card.dart';
import 'package:fokus/widgets/attribute_chip.dart';
import 'package:fokus/widgets/segment.dart';

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
				children: <Widget>[
					AppHeader.normal(title: 'page.caregiverSection.plans.header.title', text: 'page.caregiverSection.plans.header.pageHint', headerActionButtons: [
						HeaderActionButton.normal(Icons.add, 'page.caregiverSection.plans.header.addPlan', () => { log("Dodaj plan") }),
						HeaderActionButton.normal(Icons.calendar_today, 'page.caregiverSection.plans.header.calendar', () => { log("Kalendarz") }, Colors.amber)
					]),
					Segment(
						title: 'page.caregiverSection.plans.content.addedPlansTitle',
						noElementsMessage: 'page.caregiverSection.plans.content.noPlansAdded',
						noElementsAction: RaisedButton(
							child: Text(
								AppLocales.of(context).translate('page.caregiverSection.plans.header.addPlan'),
								style: Theme.of(context).textTheme.button
							),
							onPressed: () => {},
						),
						elements: <Widget>[
							ItemCard(
								title: "Sprzątanie pokoju", 
								subtitle: "Co każdą sobotę",
								onTapped: () => {log("go to details page")},
								chips: <Widget>[
									AttributeChip.withIcon(content: "4 zadania", color: Colors.indigo, icon: Icons.layers)
								],
							)
						]
					)
				]
			),
			bottomNavigationBar: AppNavigationBar.caregiverPage(currentIndex: 1)
    );
	}
}
