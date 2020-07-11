import 'package:flutter/material.dart';
import 'package:flutter_cubit/flutter_cubit.dart';

import 'package:fokus/bloc/active_user/active_user_cubit.dart';
import 'package:fokus/data/model/app_page.dart';
import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';

class ChildPanelPage extends StatefulWidget {
	@override
	_ChildPanelPageState createState() => new _ChildPanelPageState();
}

class _ChildPanelPageState extends State<ChildPanelPage> {
	@override
	Widget build(BuildContext context) {
		var activeUserCubit = CubitProvider.of<ActiveUserCubit>(context);
		var userName = (activeUserCubit.state as ActiveUserPresent).name;

    return CubitListener<ActiveUserCubit, ActiveUserState>(
	    listener: (context, state) => state is NoActiveUser ? Navigator.of(context).pushNamed(AppPage.rolesPage.name) : {},
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
						    color: AppColors.childButtonColor,
					    )
				    ],
			    ),
		    ),
			),
    );
	}
}
