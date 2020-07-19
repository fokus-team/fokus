import 'package:flutter/material.dart';
import 'package:fokus/widgets/app_navigation_bar.dart';
import 'package:fokus/widgets/app_header.dart';

class ChildPanelPage extends StatefulWidget {
	@override
	_ChildPanelPageState createState() => new _ChildPanelPageState();
}

class _ChildPanelPageState extends State<ChildPanelPage> {
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					ChildCustomHeader(),
					Container(
						padding: EdgeInsets.all(8.0),
						child: Text('Dzisiejsze plany', textAlign: TextAlign.left, style: Theme.of(context).textTheme.headline2)
					)
				]
			),
			bottomNavigationBar: AppNavigationBar.childPage(currentIndex: 0)
		);
	}
}
