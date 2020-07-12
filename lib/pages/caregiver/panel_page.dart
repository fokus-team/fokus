import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fokus/data/model/user/caregiver.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/wigets/app_bottom_navigation_bar.dart';
import 'package:fokus/wigets/app_header.dart';
import 'package:fokus/wigets/page_theme.dart';

class CaregiverPanelPage extends StatefulWidget {
	@override
	_CaregiverPanelPageState createState() => new _CaregiverPanelPageState();
}

class _CaregiverPanelPageState extends State<CaregiverPanelPage> {
	@override
	Widget build(BuildContext context) {
		var user = ModalRoute.of(context).settings.arguments as Caregiver;

    return PageTheme.caregiverSection(
	    child: Scaffold(
		    body: Column(
			    crossAxisAlignment: CrossAxisAlignment.start,
			    children: [
				    AppHeader.greetings(user, 'page.caregiverPanel.header.pageHint', [
					    HeaderActionButton.normal(Icons.add, 'page.caregiverPanel.header.addChild', () => { log("Dodaj dziecko") }),
					    HeaderActionButton.normal(Icons.add, 'page.caregiverPanel.header.addCaregiver', () => { log("Dodaj opiekuna") })
				    ]),
				    Container(
						    padding: EdgeInsets.all(8.0),
						    child: Text('Profile dzieci', textAlign: TextAlign.left, style: Theme.of(context).textTheme.headline2)
				    )
			    ]
		    ),
		    bottomNavigationBar: AppBottomNavigationBar.caregiverPage(
			    selectedItemColor: AppColors.mainBackgroundColor,
			    currentIndex: 0,
			    user: user,
		    )
	    ),
    );
	}
}
