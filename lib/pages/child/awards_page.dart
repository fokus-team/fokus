import 'package:flutter/material.dart';

import 'package:fokus/data/model/user/user.dart';
import 'package:fokus/data/model/user/user_type.dart';
import 'package:fokus/utils/theme_config.dart';

import 'package:fokus/wigets/app_bottom_navigation_bar.dart';
import 'package:fokus/wigets/child_wallet.dart';
import 'package:fokus/wigets/page_theme.dart';

class ChildAwardsPage extends StatefulWidget {
	@override
	_ChildAwardsPageState createState() => new _ChildAwardsPageState();
}

class _ChildAwardsPageState extends State<ChildAwardsPage> {
	@override
	Widget build(BuildContext context) {
    var user = User(id: null, type: UserType.child);
		user.name = 'Alex';

		return Scaffold(
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					ChildCustomHeader(user),
					Container(
						padding: EdgeInsets.all(8.0),
						child: Text('Dostępne nagrody', textAlign: TextAlign.left, style: Theme.of(context).textTheme.headline2)
					)
				]
			),
			bottomNavigationBar: AppBottomNavigationBar.childPage(
				currentIndex: 1,
				user: user,
			)
		);
	}
}
