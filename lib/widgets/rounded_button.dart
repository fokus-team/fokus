import 'dart:developer';
import 'package:flutter/material.dart';

import 'package:fokus/utils/theme_config.dart';

class RoundedButton extends StatelessWidget {
  final IconData iconData;
  final String text;
  final Color color;

  RoundedButton({this.iconData, this.text, this.color = Colors.blue});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppBoxProperties.cardListPadding,
        horizontal: AppBoxProperties.screenEdgePadding,
      ),
      child: FlatButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBoxProperties.roundedCornersRadius),
        ),
        padding: EdgeInsets.all(AppBoxProperties.containerPadding),
        color: color,
        onPressed: () => log("buttonPressed"),
        child: Row(
          children: <Widget>[
            if (iconData != null)
              Padding(
                padding: EdgeInsets.only(
                    right: AppBoxProperties.buttonIconPadding),
                child: Icon(
                  this.iconData,
                  color: Colors.white,
                ),
              ),
            Text(
              this.text,
              style: Theme.of(context).textTheme.button,
            )
          ],
        ),
      ),
    );
  }
}
