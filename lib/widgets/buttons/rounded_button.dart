import 'package:flutter/material.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/theme_config.dart';

class RoundedButton extends StatelessWidget {
  final UIButton button;

  RoundedButton({required this.button});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppBoxProperties.cardListPadding,
        horizontal: 10.0
      ),
      child: TextButton.icon(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999.0)
          ),
          backgroundColor: button.color,
          onSurface: Colors.grey,
          padding: EdgeInsets.symmetric(horizontal: 16.0)
        ),
        onPressed: button.action,
				icon: Icon(button.icon, color: Colors.white),
				label: Text(AppLocales.of(context).translate(button.textKey), style: Theme.of(context).textTheme.button)
      )
    );
  }
}
