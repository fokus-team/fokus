import 'package:flutter/material.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:lottie/lottie.dart';

import 'package:fokus/data/model/user/caregiver.dart';
import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/dialog_utils.dart';

class RolesPage extends StatefulWidget {
  @override
  _RolesPageState createState() => new _RolesPageState();
}

class _RolesPageState extends State<RolesPage> {
  @override
  Widget build(BuildContext context) {
    var user = ModalRoute.of(context).settings.arguments as Caregiver;
		TextStyle roleButtonsStyle = TextStyle(
			fontSize: 18,
			color: AppColors.lightTextColor
		);
    return Scaffold(
      backgroundColor: AppColors.mainBackgroundColor,
      body: Center(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					crossAxisAlignment: CrossAxisAlignment.center,
					children: <Widget>[
						Lottie.asset('assets/animation/sunflower_with_title_rotate_only.json', width: 280),
						Container(
							width: 240,
							padding: EdgeInsets.all(4.0),
							child: FlatButton(
								onPressed: () => { Navigator.of(context).pushNamed('/caregiver-panel-page', arguments: user) },
								color: AppColors.caregiverButtonColor,
								padding: EdgeInsets.all(20.0),
								child: Row(
									mainAxisAlignment: MainAxisAlignment.center,
									children: <Widget>[
										Text(
											'${AppLocales.of(context).translate("page.roles.introduction")} ',
											style: roleButtonsStyle.copyWith(fontWeight: FontWeight.normal)
										),
										Text(
											'${AppLocales.of(context).translate("page.roles.caregiver")} ',
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
						Container(
							width: 240,
							padding: EdgeInsets.all(4.0),
							child: FlatButton(
								onPressed: () => { Navigator.of(context).pushNamed('/child-panel-page') },
								color: AppColors.childButtonColor,
								padding: EdgeInsets.all(20.0),
								child: Row(
									mainAxisAlignment: MainAxisAlignment.center,
									children: <Widget>[
										Text(
											'${AppLocales.of(context).translate("page.roles.introduction")} ',
											style: roleButtonsStyle.copyWith(fontWeight: FontWeight.normal)
										),
										Text(
											'${AppLocales.of(context).translate("page.roles.child")} ',
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
						Container(
							width: 232,
							child: RawMaterialButton(
								onPressed: () => {
									showHelpDialog(context, 'first_steps')
								},
								child: Center(
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
						)
					]
				),
			)
    );
  }
}
