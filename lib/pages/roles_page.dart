import 'package:flutter/material.dart';
import 'package:fokus/widgets/auth/auth_widgets.dart';
import 'package:lottie/lottie.dart';

import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/dialog_utils.dart';
import 'package:fokus/utils/theme_config.dart';

class RolesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackgroundColor,
      body: SingleChildScrollView(
				child: Column(
			    mainAxisAlignment: MainAxisAlignment.center,
			    crossAxisAlignment: CrossAxisAlignment.center,
			    children: <Widget>[
			      Lottie.asset('assets/animation/sunflower_with_title_rotate_only.json', width: 280),
			      _roleButton(context, UserRole.caregiver),
			      _roleButton(context, UserRole.child),
						AuthFloatingButton(
							icon: Icons.help_outline,
							action: () => showHelpDialog(context, 'first_steps'),
							text: AppLocales.of(context).translate('page.loginSection.roles.help')
						)
			    ]
			  ),
			),
    );
  }

  Widget _roleButton(BuildContext context, UserRole role) {
	  TextStyle roleButtonsStyle = TextStyle(
			fontSize: 20,
			color: AppColors.lightTextColor,
		  fontWeight: FontWeight.normal
	  );
	  return Container(
		  padding: EdgeInsets.symmetric(horizontal: AppBoxProperties.screenEdgePadding + 6.0).copyWith(bottom: 8.0),
		  child: FlatButton(
			  onPressed: () => Navigator.of(context).pushNamed(role.signInPage.name),
			  color: role == UserRole.caregiver ? AppColors.caregiverButtonColor : AppColors.childButtonColor,
			  padding: EdgeInsets.all(20.0),
			  child: Row(
				  mainAxisAlignment: MainAxisAlignment.center,
				  children: <Widget>[
					  Text(
						  '${AppLocales.of(context).translate("page.loginSection.roles.introduction")} ',
						  style: roleButtonsStyle
					  ),
					  Text(
						  '${AppLocales.of(context).translate("page.loginSection.roles.${role.name}")} ',
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
	    ),
	  );
  }
}
