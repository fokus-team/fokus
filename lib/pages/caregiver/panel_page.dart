import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fokus/model/app_page.dart';
import 'package:fokus/logic/active_user/active_user_cubit.dart';
import 'package:fokus/utils/cubit_utils.dart';
import 'package:fokus/widgets/app_header.dart';
import 'package:fokus/widgets/app_navigation_bar.dart';
import 'package:fokus/widgets/caregiver/child_list_element.dart';
import 'package:fokus/widgets/caregiver/caregiver_list_element.dart';
import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';

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
              child: Container(
								child: Flexible(
									child: ListView(
										physics: BouncingScrollPhysics(),
										children: <Widget>[
											Padding(
												padding: EdgeInsets.only(
													right: AppBoxProperties.screenEdgePadding,
													left: AppBoxProperties.screenEdgePadding
												),
												child: Text(
													'${AppLocales.of(context).translate("page.caregiverSection.panel.content.childProfiles")} ',
													style: Theme.of(context).textTheme.headline2
												)
											),
											ChildListElement(name: "Gosia", todayPlanCount: 1, pointCount: 125),
											ChildListElement(name: "Mateusz", todayPlanCount: 0, pointCount: 998883324),
											Padding(
												padding: EdgeInsets.only(
													top: AppBoxProperties.sectionPadding,
													right: AppBoxProperties.screenEdgePadding,
													left: AppBoxProperties.screenEdgePadding
												),
												child: Text(
													'${AppLocales.of(context).translate("page.caregiverSection.panel.content.caregiverProfiles")} ',
													style: Theme.of(context).textTheme.headline2
												)
											),
											CaregiverListElement(name: "Dawid")
										]
									)
								)
							)
						)
					]
				),
				bottomNavigationBar: AppNavigationBar.caregiverPage(currentIndex: 0)
	    )
    );
	}
}
