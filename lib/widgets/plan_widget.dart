import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';

class PlanWidget extends StatelessWidget {
  final String planName, details;
  final bool isActive, isInProgress;
  final int tasksCount;
  final double progressPercentage;
  final Function buttonAction;

  // styling vars
  final double playButtonSize = 40.0;
  final double tasksIconSize = 26.0;
  final TextStyle blueTextStyle =
      new TextStyle(fontSize: 16, color: Colors.blue);
  final double futurePlansButtonWidth = 80.0;
  final int titleMaxLines = 3;
  final Color activeButtonColor = Colors.teal;
  final Color buttonIconColor = Colors.white;
  final Color disabledButtonColor = Color.fromARGB(255, 200, 200, 200);
  final Color inactiveProgressBar = Color.fromARGB(255, 240, 240, 240);
  final Color inProgressButtonColor = Colors.amber;
  final Icon notInProgressIcon = new Icon(Icons.play_arrow);
  final Icon inProgressIcon = new Icon(Icons.launch);

  PlanWidget(
      {@required this.planName,
      @required this.isActive,
      @required this.isInProgress,
      @required this.tasksCount,
      @required this.details,
      this.buttonAction = null,
      this.progressPercentage = 0});

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
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <
                  Widget>[
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                      padding:
                          EdgeInsets.all(AppBoxProperties.containerPadding),
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
                                    vertical:
                                        AppBoxProperties.columnChildrenPadding),
                                child: Text(
                                  this.details,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      .copyWith(
                                          color:
                                              chooseDetailsTextColor(context)),
                                )),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                    padding: EdgeInsets.only(
                                        right:
                                            AppBoxProperties.buttonIconPadding),
                                    child: Icon(
                                      Icons.speaker_notes,
                                      color: Colors.blue,
                                      size: tasksIconSize,
                                    )),
                                Text(
                                    ' ${AppLocales.of(context).translate("page.childSection.panel.content.tasks", {
                                      'NUM_TASKS': this.tasksCount
                                    })}',
                                    style: blueTextStyle)
                              ],
                            )
                          ])),
                  Row(
                    children: <Widget>[
                      Expanded(child: addProgressIndicatorIfAvailable())
                    ],
                  )
                ],
              ),
            ),
            ClipRRect(
                borderRadius: BorderRadius.horizontal(
                    right:
                        Radius.circular(AppBoxProperties.roundedCornersRadius)),
                child: FlatButton(
                    onPressed: this.buttonAction,
                    color: chooseButtonColor(),
                    disabledColor: disabledButtonColor,
                    child: Center(
                      child: chooseButtonIcon(),
                    )))
          ]),
        ));
  }

  Color chooseButtonColor() {
    if (this.isInProgress && this.isActive) return inProgressButtonColor;
    return activeButtonColor;
  }

  Color chooseDetailsTextColor(context) {
    if (this.isInProgress)
      return Theme.of(context).textTheme.subtitle1.color;
    else
      return Colors.grey;
  }

  Icon chooseButtonIcon() {
    return this.isInProgress && this.isActive
        ? Icon(inProgressIcon.icon,
            color: buttonIconColor, size: playButtonSize)
        : Icon(notInProgressIcon.icon,
            color: buttonIconColor, size: playButtonSize);
  }

  Widget addProgressIndicatorIfAvailable() {
    if (!isInProgress)
      return Container();
    else
      return ClipRRect(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5)),
          child: Container(
            height: 15,
            child: LinearProgressIndicator(
                value: this.progressPercentage,
                backgroundColor: this.inactiveProgressBar,
                valueColor:
                    new AlwaysStoppedAnimation<Color>(Colors.lightGreen)),
          ));
  }
}
