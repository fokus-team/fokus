import 'package:flutter/material.dart';
import 'package:flutter_cubit/flutter_cubit.dart';

import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/cubit_utils.dart';
import 'package:fokus/data/model/app_page.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/bloc/active_user/active_user_cubit.dart';

class CaregiverPanelPage extends StatefulWidget {
	@override
	_CaregiverPanelPageState createState() => new _CaregiverPanelPageState();
}

class _CaregiverPanelPageState extends State<CaregiverPanelPage> {
	@override
	Widget build(BuildContext context) {
		var activeUserCubit = CubitProvider.of<ActiveUserCubit>(context);
		var userName = (activeUserCubit.state as ActiveUserPresent).name;

    return CubitUtils.navigateOnState<ActiveUserCubit, ActiveUserState, NoActiveUser>(
	    navigation: (navigator) => navigator.pushReplacementNamed(AppPage.rolesPage.name),
      child: Scaffold(
				body: Center(
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.center,
						mainAxisAlignment: MainAxisAlignment.center,
					  children: <Widget>[
					    Text(AppLocales.of(context).translate('page.caregiverPanel.header.title', {'name': userName})),
						  FlatButton(
							  onPressed: () => activeUserCubit.logoutUser(),
							  child: Text('Log out'),
							  textColor: AppColors.lightTextColor,
							  color: AppColors.caregiverButtonColor,
						  )
					  ],
					),
				),
			),
    );
	}
}
