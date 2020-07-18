import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_cubit/flutter_cubit.dart';

import 'package:fokus/logic/children_list/children_list_cubit.dart';
import 'package:fokus/model/app_page.dart';
import 'package:fokus/logic/active_user/active_user_cubit.dart';
import 'package:fokus/utils/cubit_utils.dart';
import 'package:fokus/widgets/app_header.dart';
import 'package:fokus/widgets/app_navigation_bar.dart';

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
						CubitBuilder<ChildrenListCubit, ChildrenListState>(
							cubit: CubitProvider.of<ChildrenListCubit>(context),
							builder: (context, state) {
								if (state is ChildrenListLoadSuccess)
									return Flexible(
										child: ListView(
											children: state.children.map((child) => Text(child.toString())).toList(),
										),
									);
								return Container();
							},
						)
					]
				),
				bottomNavigationBar: AppNavigationBar.caregiverPage(currentIndex: 0)
	    )
    );
	}
}
