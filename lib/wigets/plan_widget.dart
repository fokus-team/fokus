import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';

class PlanWidget extends StatelessWidget {
  final String planName;
  final bool isActive;
  final int tasksCount;
  // styling vars
	final double playButtonSize = 40.0;
	final double tasksIconSize = 26.0;
	final TextStyle blueTextStyle = new TextStyle(fontSize: 16, color: Colors.blue);
	final double futurePlansButtonWidth = 80.0;
	final int titleMaxLines = 3;
	final Color activeButtonColor = Colors.teal;
	final Color disabledButtonColor = Colors.grey;


  PlanWidget(this.planName, this.isActive, this.tasksCount);

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppBoxProperties.roundedCornersRadius)),
        margin: EdgeInsets.symmetric(
            vertical: AppBoxProperties.cardListPadding,
            horizontal: AppBoxProperties.screenEdgePadding),
        child: IntrinsicHeight(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                    child: Padding(
                  padding: EdgeInsets.all(AppBoxProperties.containerPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        this.planName,
                        style: Theme.of(context).textTheme.headline2,
                        overflow: TextOverflow.ellipsis,
                        maxLines: titleMaxLines,
                      ),
                      Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: AppBoxProperties.columnChildrenPadding),
                          child: Text(
                            "Ok",
                            style: Theme.of(context).textTheme.subtitle1,
                          )),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(
                                  right: AppBoxProperties.buttonIconPadding),
                              child: Icon(
                                Icons.speaker_notes,
                                color: Colors.blue,
																size: tasksIconSize,
                              )),
                          Text(this.tasksCount.toString() + ' ${AppLocales.of(context).translate("page.child.childPanel.tasks")} ',
                              style: blueTextStyle)
                        ],
                      )
                    ],
                  ),
                )),
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.horizontal(
                          right: Radius.circular(
                              AppBoxProperties.roundedCornersRadius)),
                      color: chooseColor(),
                    ),
                    width: futurePlansButtonWidth,
                    child: Center(
                        child: IconButton(
                      color: Colors.white,
                      disabledColor: Colors.white,
                      icon: Icon(Icons.play_arrow),
                      iconSize: playButtonSize,
                      onPressed: () {},
                    )))
              ]),
        ));
  }

  Color chooseColor() {
    return this.isActive ? activeButtonColor : disabledButtonColor;
  }
}
