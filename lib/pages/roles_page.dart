import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/logic/active_user/active_user_cubit.dart';
import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/dialog_utils.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:lottie/lottie.dart';

class RolesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _directLogin(
	    child: Scaffold(
        backgroundColor: AppColors.mainBackgroundColor,
        body: Center(
					child: Column(
				    mainAxisAlignment: MainAxisAlignment.center,
				    crossAxisAlignment: CrossAxisAlignment.center,
				    children: <Widget>[
				      Lottie.asset('assets/animation/sunflower_with_title_rotate_only.json', width: 280),
				      _roleButton(context, UserRole.caregiver),
				      _roleButton(context, UserRole.child),
				      Container(
				        child: RawMaterialButton(
									highlightColor: Colors.transparent,
									splashColor: Colors.transparent,
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
				                AppLocales.of(context).translate('page.loginSection.roles.help'),
				                style: Theme.of(context).textTheme.button,
				              )
				            ]
				          )
				        )
				      )
				    ]
				  ),
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
			constraints: new BoxConstraints(
				minWidth: 240,
				maxWidth: 260,
			),
		  padding: EdgeInsets.all(4.0),
		  child: FlatButton(
			  onPressed: () => BlocProvider.of<ActiveUserCubit>(context).loginUserByRole(role),
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

  // Temporary until we have a login page
  Widget _directLogin({Widget child}) {
  	return BlocListener<ActiveUserCubit, ActiveUserState>(
		  child: child,
		  listener: (context, state) {
		    if (state is ActiveUserPresent)
		      Navigator.of(context).pushReplacementNamed(state.user.role.panelPage.name);
		  }
	  );
  }
}
