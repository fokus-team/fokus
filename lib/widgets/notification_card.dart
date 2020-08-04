import 'package:flutter/material.dart';
import 'package:fokus/utils/icon_sets.dart';
import 'package:fokus/widgets/item_card.dart';
import 'package:intl/intl.dart';

enum NotificationType{
  receivedAward,
  finishedTask,
  unfinishedTask
}

extension NotificationTypeName on NotificationType {
  String get name => const {
    NotificationType.receivedAward: 'odebrał nagrodę',
    NotificationType.finishedTask: 'wykonał zadanie',
    NotificationType.unfinishedTask: 'nie wykonał zadania',
  }[this];
}

class NotificationCard extends ItemCard {

  //pytanko - ten string do jsona, czy jakoś inaczej rozwiązujemy to
  final DateFormat _dateFormat = DateFormat("dd.MM.yyyy hh:mm");
  final _typeIcon = {
    NotificationType.receivedAward : Icons.star,
    NotificationType.finishedTask : Icons.view_headline,
    NotificationType.unfinishedTask : Icons.cancel
  };
  final Color _iconColor = Colors.grey[500];

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
    chips,
    menuItems,
    actionButton,
    onTapped,
  }) : super(
  title: makeTitle(childName, notificationType),
  subtitle: subtitle,
  graphicType: GraphicAssetType.childAvatars,
  graphic: graphic,
  chips: chips,
  menuItems: menuItems,
  actionButton: actionButton,
  onTapped: onTapped,
  );

  @override
  double get imageHeight => super.imageHeight * 0.7;

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
                  padding: (graphic != null) ? EdgeInsets.all(6.0) : EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                          title,
                          style: Theme.of(context).textTheme.bodyText2,
                          overflow: TextOverflow.ellipsis,
                          maxLines: titleMaxLines
                      ),
                      if(subtitle != null)
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.headline2,
                          overflow: TextOverflow.ellipsis,
                          maxLines: titleMaxLines,
                          softWrap: false,
                        ),
                      if(dateTime != null)
                        Text(
                          _dateFormat.format(dateTime),
                          style: Theme.of(context).textTheme.subtitle2,
                          overflow: TextOverflow.ellipsis,
                          maxLines: titleMaxLines,
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
