import 'package:flutter/material.dart';
import 'package:fokus/services/app_locales.dart';

class CaregiverRatingPage extends StatefulWidget {
  @override
  _CaregiverRatingPageState createState() => new _CaregiverRatingPageState();
}

class _CaregiverRatingPageState extends State<CaregiverRatingPage> {
	static const String _pageKey = 'page.caregiverSection.rating.content';

  @override
  Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: Text(AppLocales.of(context).translate('page.caregiverSection.rating.header.title')))
		);
	}

}
