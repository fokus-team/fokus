// @dart = 2.10
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/theme_config.dart';

class ButtonSheetConfirmButton extends StatelessWidget {
	final Function callback;

	ButtonSheetConfirmButton({@required this.callback});

	@override
	Widget build(BuildContext context) {
		return Tooltip(
			message: AppLocales.of(context).translate('actions.confirm'),
			child: Padding(
				padding: EdgeInsets.only(right: 10.0),
				child: MaterialButton(
					visualDensity: VisualDensity.compact,
					materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
					child: Icon(Icons.done, color: Colors.white, size: 30),
					color: AppColors.caregiverButtonColor,
					onPressed: callback(),
					padding: EdgeInsets.all(12.0),
					shape: CircleBorder(),
					minWidth: 0
				)
			)
		);
	}

}
