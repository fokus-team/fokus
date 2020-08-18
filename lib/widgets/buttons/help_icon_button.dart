
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/dialog_utils.dart';
import 'package:fokus/utils/theme_config.dart';

class HelpIconButton extends StatelessWidget {
	final String helpPage;
	final Brightness theme;

	HelpIconButton({@required this.helpPage, this.theme = Brightness.light});

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
						color: (theme == Brightness.light) ? AppColors.lightTextColor : AppColors.darkTextColor
					)
				)
			)
		);
	}
	
}
