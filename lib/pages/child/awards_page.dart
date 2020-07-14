import 'package:flutter/material.dart';

import 'package:fokus/data/model/user/user.dart';
import 'package:fokus/data/model/user/user_role.dart';
import 'package:fokus/wigets/app_navigation_bar.dart';
import 'package:fokus/wigets/child_wallet.dart';

class ChildAwardsPage extends StatefulWidget {
	@override
	_ChildAwardsPageState createState() => new _ChildAwardsPageState();
}

class _ChildAwardsPageState extends State<ChildAwardsPage> {
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					ChildCustomHeader(),
					Container(
						padding: EdgeInsets.all(8.0),
						child: Text('Dostępne nagrody', textAlign: TextAlign.left, style: Theme.of(context).textTheme.headline2)
					)
				]
			),
			bottomNavigationBar: AppNavigationBar.childPage(currentIndex: 1)
		);
	}
}
