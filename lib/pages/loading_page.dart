import 'package:flutter/material.dart';

import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';

class LoadingPage extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: AppColors.mainBackgroundColor,
			body: Center(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					crossAxisAlignment: CrossAxisAlignment.center,
					children: <Widget>[
						// TODO Change Circular Indicator to our sunflower animation
						Padding(padding: EdgeInsets.only(bottom: 20.0), child: CircularProgressIndicator(backgroundColor: Colors.white)),
						Text('${AppLocales.of(context).translate("loading")}...', style: Theme.of(context).textTheme.bodyText1)
					]
				),
			)
		);
	}
}
