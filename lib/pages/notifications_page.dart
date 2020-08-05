import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fokus/utils/icon_sets.dart';

import 'package:fokus/widgets/item_card.dart';
import 'package:fokus/widgets/notification_card.dart';
import 'package:fokus/widgets/segment.dart';

class NotificationsPage extends StatefulWidget {
	@override
	_NotificationsPageState createState() => new _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
	//static const String _pageKey = 'page.caregiverSection.awards';
	
	@override
	Widget build(BuildContext context) {
    return Scaffold(
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: <Widget>[
					AppBar(
            leading: IconButton(
              icon: Icon(Icons.keyboard_arrow_left, size: 32, color: Colors.white),
              onPressed: () => {Navigator.of(context).pop()}
            ),
            title: Text(
              "Powiadomienia",
              style: Theme.of(context).textTheme.headline1.copyWith(color: Colors.white)
            )
          ),
					AppSegments(
						segments: [
              NotificationCard(
                childName: "Aleksandrittobuonaserra",
                notificationType: NotificationType.receivedAward,
                dateTime: DateTime.now(),
                subtitle: "1 godzina gry na konsoli",
                graphic: 10
              ),
              NotificationCard(
                  childName: "Gosia",
                  notificationType: NotificationType.finishedTask,
                  dateTime: DateTime.now(),
                  subtitle: "Sprzątanie pokoju",
                  graphic: 20
              ),
              NotificationCard(
                  childName: "Maciek",
                  notificationType: NotificationType.unfinishedPlan,
                  dateTime: DateTime.now(),
                  subtitle: "Bardzo długie sprzątanie pokoju, oj jakie długie niepotrzebnie, taki plan był no co zrobisz",
                  graphic: 0
              ),
						]
					)
				]
			)
    );
	}
}
