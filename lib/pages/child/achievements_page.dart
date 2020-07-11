import 'package:flutter/material.dart';

import 'package:fokus/data/model/user/user.dart';
import 'package:fokus/data/model/user/user_type.dart';

import 'package:fokus/wigets/child_wallet.dart';

class ChildAchievementsPage extends StatefulWidget {
	@override
	_ChildAchievementsPageState createState() => new _ChildAchievementsPageState();
}

class _ChildAchievementsPageState extends State<ChildAchievementsPage> {
	@override
	Widget build(BuildContext context) {
    var user = User(id: null, type: UserType.child);
		user.name = 'Alex';

    return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				ChildCustomHeader(user),
				Container(
					padding: EdgeInsets.all(8.0),
					child: Text('Moje osiągnięcia', textAlign: TextAlign.left, style: Theme.of(context).textTheme.headline2)
				)
			]
		);
    
	}
}
