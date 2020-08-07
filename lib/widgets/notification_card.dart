import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fokus/utils/icon_sets.dart';
import 'package:fokus/widgets/attribute_chip.dart';
import 'package:fokus/widgets/item_card.dart';
import 'package:intl/intl.dart';

enum NotificationType{
  receivedAward,
  finishedTask,
  unfinishedPlan
}

extension NotificationTypeName on NotificationType {
  String get name => const {
    NotificationType.receivedAward: 'odebrał nagrodę',
    NotificationType.finishedTask: 'wykonał zadanie',
    NotificationType.unfinishedPlan: 'nie skończył planu',
  }[this];
}

class NotificationCard extends ItemCard {

  final _typeIcon = {
    NotificationType.receivedAward : Icons.star,
    NotificationType.finishedTask : Icons.view_headline,
    NotificationType.unfinishedPlan : Icons.cancel
  };
  final Color _iconColor = Colors.grey;

  final String childName;
  final NotificationType notificationType;
  final DateTime dateTime;

  static String makeTitle(String name, NotificationType type) => "$name ${type.name}";

  //TODO check what should be required
  NotificationCard({
    this.childName,
    this.notificationType,
    this.dateTime,
    subtitle,
    graphic,
    chip
  }) : super(
    title: makeTitle(childName, notificationType),
    subtitle: subtitle,
    graphicType: GraphicAssetType.childAvatars,
    graphic: graphic,
    chips: [if (chip != null) chip]
  );

  @override
  double get imageHeight => super.imageHeight * 0.7;

  static Widget gradeTheTaskChip = GestureDetector(
      onTap: () => {log("open the grading page")},
      child: AttributeChip.withIcon(
        content: "Oceń zadanie",
        color: Colors.red,
        icon: Icons.assignment
      )
  );

  static Widget taskGradedChip = AttributeChip.withIcon(
    content: "Oceniono",
    color: Colors.grey[750],
    icon: Icons.check
  );

  @override
  Widget buildContentSection(BuildContext context){
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if(graphic != null)
            Padding(
                padding: EdgeInsets.all(6.0),
                child: headerImage()
            ),
          Expanded(
              flex: 1,
              child: Padding(
                  padding: (graphic != null) ? EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0) : EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyText2,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1
                      ),
                      if(subtitle != null)
                        Padding(
                          padding: EdgeInsets.only(top: 2.0, bottom: 4.0),
                          child: Text(
                            subtitle,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            maxLines: titleMaxLines,
                            softWrap: false,
                          )
                        ),
                      if(dateTime != null)
                        Text(
                          "${DateFormat.yMd(Localizations.localeOf(context).toString()).format(dateTime)} ${DateFormat.Hm(Localizations.localeOf(context).toString()).format(dateTime)}",
                          style: Theme.of(context).textTheme.subtitle2,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: false,
                        ),
                      if(chips != null && chips.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Wrap(
                            spacing: 2,
                            runSpacing: 4,
                            children: chips
                          )
                        )
                    ],
                  )
              )
          ),
          if(notificationType != null)
            Padding(
                padding: EdgeInsets.all(6.0),
                child: Icon(_typeIcon[notificationType], color: _iconColor)
            )
        ]
    );
  }
}
