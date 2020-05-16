import 'package:flutter/material.dart';
import 'package:fokus/utils/app_locales.dart';

class MainPage extends StatefulWidget {
	@override
	_MainPageState createState() => new _MainPageState();
}

class _MainPageState extends State<MainPage> {
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text('Fokus'),
			),
			body: Center(child: Text(AppLocales.of(context).translate("mainPage.text"))),
		);
	}
}
