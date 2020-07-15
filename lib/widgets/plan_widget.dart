import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';

class PlanWidget extends StatelessWidget {
  final String planName, details;
  final bool isActive, inProgress;
  final int tasksCount;
  final double progressPercentage;

  // styling vars
  final double playButtonSize = 40.0;
  final double tasksIconSize = 26.0;
  final TextStyle blueTextStyle =
      new TextStyle(fontSize: 16, color: Colors.blue);
  final double futurePlansButtonWidth = 80.0;
  final int titleMaxLines = 3;
  final Color activeButtonColor = Colors.teal;
  // TODO: lighter grey in styles
  final Color disabledButtonColor = Colors.grey;
  final Color inProgressButtonColor = Colors.amber;
  final Icon notInProgressIcon = new Icon(Icons.play_arrow);
  final Icon inProgressIcon = new Icon(Icons.launch);

  PlanWidget(this.planName, this.isActive, this.tasksCount, this.inProgress,
      this.progressPercentage, this.details);

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.all(AppBoxProperties.containerPadding),

                          child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: <Widget>[
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
                                  style: Theme.of(context).textTheme.subtitle1,
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
                                    this.tasksCount.toString() +
                                        ' ${AppLocales.of(context).translate("page.childSection.panel.content.tasks")} ',
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
                      icon: chooseIcon(),
                      iconSize: playButtonSize,
                      onPressed: () {},
                    )))
              ]),
        ));
  }

  Color chooseColor() {
    if (this.inProgress) return inProgressButtonColor;
    return this.isActive ? activeButtonColor : disabledButtonColor;
  }

  Icon chooseIcon() {
    return this.inProgress ? inProgressIcon : notInProgressIcon;
  }

  Widget addProgressIndicatorIfAvailable() {
    if (!inProgress)
      return Container();
    else
      return ClipRRect(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5)),
              child: Container(
                height: 15,
                child: LinearProgressIndicator(
                    value: this.progressPercentage,
                    backgroundColor: Color.fromARGB(255, 224, 224, 224),
                    valueColor:
                        new AlwaysStoppedAnimation<Color>(Colors.lightGreen)),
              ));
  }
}
