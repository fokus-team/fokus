import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../services/app_locales.dart';
import '../../utils/ui/dialog_utils.dart';
import '../../utils/ui/theme_config.dart';

class HelpIconButton extends StatelessWidget {
	final String helpPage;
	final Brightness theme;

	HelpIconButton({required this.helpPage, this.theme = Brightness.light});

	@override
	Widget build(BuildContext context) {
		return Tooltip(
			message: AppLocales.of(context).translate('actions.help'),
			child: InkWell(
				customBorder: CircleBorder(),
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
