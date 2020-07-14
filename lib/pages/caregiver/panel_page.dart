import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_cubit/flutter_cubit.dart';
import 'package:fokus/bloc/active_user/active_user_cubit.dart';
import 'package:fokus/data/model/app_page.dart';
import 'package:fokus/data/model/user/caregiver.dart';
import 'package:fokus/utils/cubit_utils.dart';

import 'package:fokus/wigets/app_navigation_bar.dart';
import 'package:fokus/wigets/app_header.dart';

class CaregiverPanelPage extends StatefulWidget {
	@override
	_CaregiverPanelPageState createState() => new _CaregiverPanelPageState();
}

class _CaregiverPanelPageState extends State<CaregiverPanelPage> {
	@override
	Widget build(BuildContext context) {
    return CubitUtils.navigateOnState<ActiveUserCubit, ActiveUserState, NoActiveUser>(
			navigation: (navigator) => navigator.pushReplacementNamed(AppPage.rolesPage.name),
			child: Scaffold(
				body: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						AppHeader.greetings(text: 'page.caregiverSection.panel.header.pageHint', headerActionButtons: [
							HeaderActionButton.normal(Icons.add, 'page.caregiverSection.panel.header.addChild', () => { log("Dodaj dziecko") }),
							HeaderActionButton.normal(Icons.add, 'page.caregiverSection.panel.header.addCaregiver', () => { log("Dodaj opiekuna") })
						]),
						Container(
								padding: EdgeInsets.all(8.0),
								child: Text('Profile dzieci', textAlign: TextAlign.left, style: Theme.of(context).textTheme.headline2)
						)
					]
				),
				bottomNavigationBar: AppNavigationBar.caregiverPage(currentIndex: 0)
	    )
    );
	}
}
