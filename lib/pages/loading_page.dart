import 'package:flutter/material.dart';

import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/widgets/general/app_loader.dart';

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
						AppLoader(),
						Text('${AppLocales.of(context).translate("loading")}...', style: Theme.of(context).textTheme.bodyText1)
					]
				),
			)
		);
	}
}
