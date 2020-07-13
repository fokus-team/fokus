import 'package:flutter/material.dart';

import 'package:fokus/data/model/user/user.dart';
import 'package:fokus/data/model/user/user_type.dart';
import 'package:fokus/utils/theme_config.dart';

import 'package:fokus/wigets/app_bottom_navigation_bar.dart';
import 'package:fokus/wigets/child_wallet.dart';
import 'package:fokus/wigets/page_theme.dart';

class ChildPanelPage extends StatefulWidget {
	@override
	_ChildPanelPageState createState() => new _ChildPanelPageState();
}

class _ChildPanelPageState extends State<ChildPanelPage> {
	@override
	Widget build(BuildContext context) {
    var user = User(id: null, type: UserType.child);
		user.name = 'Alex';

		return PageTheme.childSection(
	    child: Scaffold(
				body: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						ChildCustomHeader(user),
						Container(
							padding: EdgeInsets.all(8.0),
							child: Text('Dzisiejsze plany', textAlign: TextAlign.left, style: Theme.of(context).textTheme.headline2)
						)
					]
				),
		    bottomNavigationBar: AppBottomNavigationBar.childPage(
			    selectedItemColor: AppColors.childBackgroundColor,
			    currentIndex: 0,
			    user: user,
		    )
			)
		);
	}
}
