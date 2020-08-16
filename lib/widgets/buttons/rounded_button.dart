import 'package:flutter/material.dart';
import 'package:fokus/utils/theme_config.dart';

class RoundedButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
	final bool dense;
	final Function onPressed;

  RoundedButton({
		this.icon, 
		@required this.text, 
		this.color = Colors.teal,
		this.dense = false,
		this.onPressed
	});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: dense ? AppBoxProperties.cardListPadding/2 : AppBoxProperties.cardListPadding,
        horizontal: dense ? AppBoxProperties.screenEdgePadding/2 : AppBoxProperties.screenEdgePadding
      ),
      child: FlatButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBoxProperties.roundedCornersRadius)
        ),
        padding: EdgeInsets.all(AppBoxProperties.containerPadding),
				materialTapTargetSize: dense ? MaterialTapTargetSize.shrinkWrap : MaterialTapTargetSize.padded,
        color: color,
        onPressed: onPressed,
        child: Row(
          children: <Widget>[
            if (icon != null)
              Padding(
                padding: EdgeInsets.only(right: AppBoxProperties.buttonIconPadding),
                child: Icon(this.icon, color: Colors.white)
              ),
            Text(this.text, style: Theme.of(context).textTheme.button)
          ]
        )
      )
    );
  }

}
