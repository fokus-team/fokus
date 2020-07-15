import 'package:flutter/material.dart';
import 'package:fokus/widgets/app_navigation_bar.dart';
import 'package:fokus/widgets/child_wallet.dart';

class ChildAchievementsPage extends StatefulWidget {
	@override
	_ChildAchievementsPageState createState() => new _ChildAchievementsPageState();
}

class _ChildAchievementsPageState extends State<ChildAchievementsPage> {
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					ChildCustomHeader(),
					Container(
						padding: EdgeInsets.all(8.0),
						child: Text('Moje osiągnięcia', textAlign: TextAlign.left, style: Theme.of(context).textTheme.headline2)
					)
				]
			),
			bottomNavigationBar: AppNavigationBar.childPage(currentIndex: 2)
		);
	}
}
