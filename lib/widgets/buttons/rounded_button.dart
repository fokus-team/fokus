// @dart = 2.10
import 'package:flutter/material.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/theme_config.dart';

class RoundedButton extends StatelessWidget {
  final UIButton button;

  RoundedButton({@required this.button});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppBoxProperties.cardListPadding,
        horizontal: 10.0
      ),
      child: FlatButton.icon(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999.0)
        ),
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0).copyWith(right: 16.0),
        color: button.color,
        onPressed: button.action,
				disabledColor: Colors.grey,
				icon: Icon(button.icon, color: Colors.white),
				label: Text(AppLocales.of(context).translate(button.textKey), style: Theme.of(context).textTheme.button)
      )
    );
  }

}
