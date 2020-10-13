import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/theme_config.dart';

class ButtonSheetBarButtons extends StatelessWidget {
	final List<UIButton> buttons;

	ButtonSheetBarButtons({
		this.buttons
	});

	@override
	Widget build(BuildContext context) {
		return Row(
			mainAxisAlignment: MainAxisAlignment.spaceEvenly,
			children: buttons.map((UIButton element) =>
				buildBottomSheetBarButton(element.color, element.icon, AppLocales.of(context).translate(element.textKey), element.action)
			).toList()
		);
	}

	Widget buildBottomSheetBarButton(Color color, IconData icon, String text, Function onPressed) {
		return Expanded(
			child: RaisedButton(
				shape: ContinuousRectangleBorder(),
				padding: EdgeInsets.symmetric(vertical: 12.0),
				color: color,
				child: Row(
					mainAxisAlignment: MainAxisAlignment.center,
					children: <Widget>[
						Padding(
							padding: EdgeInsets.only(right: AppBoxProperties.buttonIconPadding),
							child: Icon(icon, color: Colors.white)
						),
						Text(text, style: TextStyle(fontWeight: FontWeight.normal, color: Colors.white))
					]
				),
				materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
				onPressed: onPressed
			)
		);
	}

}
