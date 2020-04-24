import 'package:flutter/material.dart';
import 'package:fokus/utils/app_locales.dart';

class MainPage extends StatefulWidget {
	MainPage({Key key, this.title}) : super(key: key);

	final String title;

	@override
	_MainPageState createState() => new _MainPageState();
}

class _MainPageState extends State<MainPage> {
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text(widget.title),
			),
			body: Center(
					child: Column(
				children: [
					Text(AppLocales.of(context).translate("mainPage.text")),
					Text(AppLocales.of(context).translate("title")),
				],
			)),
		);
	}
}
