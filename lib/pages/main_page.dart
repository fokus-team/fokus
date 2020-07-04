import 'package:flutter/material.dart';
import 'package:fokus/data/model/user/caregiver.dart';
import 'package:fokus/utils/app_locales.dart';

class MainPage extends StatefulWidget {
	@override
	_MainPageState createState() => new _MainPageState();
}

class _MainPageState extends State<MainPage> {
	@override
	Widget build(BuildContext context) {
		var user = ModalRoute.of(context).settings.arguments as Caregiver;

		return Scaffold(
			appBar: AppBar(
				title: Text(AppLocales.of(context).translate('page.caregiverPanel.header.title', {'name': user.name})),
			),
			body: Center(child: Text(AppLocales.of(context).translate('page.caregiverPanel.content'), style: TextStyle(fontSize: 30))),
		);
	}
}
