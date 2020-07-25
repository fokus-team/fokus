
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/dialog_utils.dart';
import 'package:fokus/utils/theme_config.dart';

enum HelpIconButtonTheme { light, dark } 

class HelpIconButton extends StatelessWidget {
	final String helpPage;
	final HelpIconButtonTheme theme;

	HelpIconButton({@required this.helpPage, this.theme = HelpIconButtonTheme.light});

	@override
	Widget build(BuildContext context) {
		return Tooltip(
			message: AppLocales.of(context).translate('actions.help'),
			child: InkWell(
				customBorder: new CircleBorder(),
				onTap: () => { showHelpDialog(context, helpPage) },
				child: Padding(
					padding: EdgeInsets.all(8.0),
					child: Icon(
						Icons.help_outline,
						size: 26.0,
						color: (theme == HelpIconButtonTheme.light) ? AppColors.lightTextColor : AppColors.darkTextColor
					)
				)
			)
		);
	}
	
}
