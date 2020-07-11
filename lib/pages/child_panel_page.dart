import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/data/model/app_page.dart';
import 'package:fokus/data/model/user/child.dart';
import 'package:fokus/data/repository/settings/app_config_repository.dart';
import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';

class ChildPanelPage extends StatefulWidget {
	@override
	_ChildPanelPageState createState() => new _ChildPanelPageState();
}

class _ChildPanelPageState extends State<ChildPanelPage> {
	@override
	Widget build(BuildContext context) {
		var user = ModalRoute.of(context).settings.arguments as Child;

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
					    color: AppColors.childButtonColor,
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
