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
	static const String _pageKey = 'page.caregiverSection.plans';
	
	@override
	Widget build(BuildContext context) {
    return Scaffold(
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: <Widget>[
					AppHeader.normal(title: '$_pageKey.header.title', text: '$_pageKey.header.pageHint', headerActionButtons: [
						HeaderActionButton.normal(Icons.add, '$_pageKey.header.addPlan', () => { log("Dodaj plan") }),
						HeaderActionButton.normal(Icons.calendar_today, '$_pageKey.header.calendar', () => { log("Kalendarz") }, Colors.amber)
					]),
					AppSegments(
						segments: [
							Segment(
								title: '$_pageKey.content.addedPlansTitle',
								noElementsMessage: '$_pageKey.content.noPlansAdded',
								noElementsAction: RaisedButton(
									child: Text(
										AppLocales.of(context).translate('$_pageKey.header.addPlan'),
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
					)
				]
			),
			bottomNavigationBar: AppNavigationBar.caregiverPage(currentIndex: 1)
    );
	}
}
