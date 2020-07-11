import 'package:flutter/material.dart';
import 'package:fokus/data/model/user/user.dart';
import 'package:fokus/data/model/user/user_role.dart';
import 'package:fokus/data/repository/database/data_repository.dart';
import 'package:fokus/data/repository/settings/app_config_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';

import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/dialog_utils.dart';
import 'package:fokus/data/model/app_page.dart';
import 'package:fokus/utils/theme_config.dart';

class RolesPage extends StatefulWidget {
  @override
  _RolesPageState createState() => new _RolesPageState();
}

class _RolesPageState extends State<RolesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackgroundColor,
      body: Center(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					crossAxisAlignment: CrossAxisAlignment.center,
					children: <Widget>[
						Lottie.asset('assets/animation/sunflower_with_title_rotate_only.json', width: 280),
						_roleButton(UserRole.caregiver),
						_roleButton(UserRole.child),
						Container(
							child: RawMaterialButton(
								onPressed: () => {
									showHelpDialog(context, 'first_steps')
								},
								child: Row(
									crossAxisAlignment: CrossAxisAlignment.center,
									mainAxisAlignment: MainAxisAlignment.center,
									children: <Widget>[
										Padding(
											padding: EdgeInsets.only(right: AppBoxProperties.buttonIconPadding),
											child: Icon(Icons.help_outline, color: AppColors.lightTextColor)
										),
										Text(
											AppLocales.of(context).translate('page.roles.help'),
											style: Theme.of(context).textTheme.button,
										)
									]
								)
							)
						)
					]
				),
			)
    );
  }

  Widget _roleButton(UserRole role) {
	  TextStyle roleButtonsStyle = TextStyle(
			fontSize: 18,
			color: AppColors.lightTextColor,
		  fontWeight: FontWeight.normal
	  );
	  var rolePage = role == UserRole.caregiver ? AppPage.caregiverPanel : AppPage.childPanel;
	  return _loginUserTest(role, (user) =>
	    Container(
			  width: 240,
			  padding: EdgeInsets.all(4.0),
			  child: FlatButton(
				  onPressed: () {
				    GetIt.I<AppConfigRepository>().setLastUser(user.id);
				  	Navigator.of(context).pushNamed(rolePage.name, arguments: user);
				  },
				  color: role == UserRole.caregiver ? AppColors.caregiverButtonColor : AppColors.childButtonColor,
				  padding: EdgeInsets.all(20.0),
				  child: Row(
					  mainAxisAlignment: MainAxisAlignment.center,
					  children: <Widget>[
						  Text(
							  '${AppLocales.of(context).translate("page.roles.introduction")} ',
							  style: roleButtonsStyle
						  ),
						  Text(
							  '${AppLocales.of(context).translate("page.roles.${role.name}")} ',
							  style: roleButtonsStyle.copyWith(fontWeight: FontWeight.bold)
						  ),
						  Padding(
							  padding: EdgeInsets.only(left: AppBoxProperties.buttonIconPadding),
							  child: Icon(
								  Icons.arrow_forward,
								  color: AppColors.lightTextColor,
								  size: 26
							  )
						  )
					  ],
				  )
			  )
	    ),
	  );
  }

  Widget _loginUserTest(UserRole role, Widget Function(User) childBuilder) {
	  return FutureBuilder<User>(
		  future: GetIt.I<DataRepository>().fetchUserByRole(role),
		  builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
			  if (snapshot.hasData)
				  return childBuilder(snapshot.data);
			  return Container();
		  }
	  );
  }
}
