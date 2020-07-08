import 'package:flutter/material.dart';
import 'package:fokus/data/model/user/child.dart';
import 'package:fokus/utils/app_locales.dart';

class ChildPanelPage extends StatefulWidget {
	@override
	_ChildPanelPageState createState() => new _ChildPanelPageState();
}

class _ChildPanelPageState extends State<ChildPanelPage> {
	@override
	Widget build(BuildContext context) {
    
    return Scaffold(
			body: Center(child: Text('Child panel')),
		);

	}
}
