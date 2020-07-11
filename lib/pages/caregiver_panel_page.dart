import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/data/model/app_page.dart';
import 'package:fokus/data/model/user/caregiver.dart';
import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/data/repository/settings/app_config_repository.dart';

class CaregiverPanelPage extends StatefulWidget {
	@override
	_CaregiverPanelPageState createState() => new _CaregiverPanelPageState();
}

class _CaregiverPanelPageState extends State<CaregiverPanelPage> {
	@override
	Widget build(BuildContext context) {
		var user = ModalRoute.of(context).settings.arguments as Caregiver;

    return Scaffold(
			body: Center(
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.center,
					mainAxisAlignment: MainAxisAlignment.center,
				  children: <Widget>[
				    Text(AppLocales.of(context).translate('page.caregiverPanel.header.title', {'name': user.name})),
					  FlatButton(
						  onPressed: () => _logoutUserTest(context),
						  child: Text('Log out'),
						  textColor: AppColors.lightTextColor,
						  color: AppColors.caregiverButtonColor,
					  )
				  ],
				),
			),
		);
	}

	void _logoutUserTest(BuildContext context) {
		GetIt.I<AppConfigRepository>().removeLastUser();
		Navigator.of(context).pushReplacementNamed(AppPage.rolesPage.name);
	}
}
