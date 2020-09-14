import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fokus/logic/auth/auth_bloc/authentication_bloc.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/widgets/cards/notification_card.dart';
import 'package:fokus/widgets/segment.dart';

class NotificationsPage extends StatefulWidget {
	@override
	_NotificationsPageState createState() => new _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {

  var _caregiverNotificationsMock = [
    NotificationCard(
        childName: "Aleksandrittobuonaserra",
        notificationType: NotificationType.caregiver_receivedReward,
        dateTime: DateTime.now(),
        subtitle: "1 godzina gry na konsoli",
        graphic: 10
    ),
    NotificationCard(
        childName: "Gosia",
        notificationType: NotificationType.caregiver_finishedTaskUngraded,
        dateTime: DateTime.now(),
        subtitle: "Sprzątanie pokoju",
        graphic: 20
    ),
    NotificationCard(
        childName: "Gosia",
        notificationType: NotificationType.caregiver_finishedTaskGraded,
        dateTime: DateTime.now(),
        subtitle: "Spakowanie plecaka",
        graphic: 20
    ),
    NotificationCard(
        childName: "Maciek",
        notificationType: NotificationType.caregiver_unfinishedPlan,
        dateTime: DateTime.now(),
        subtitle: "Bardzo długie sprzątanie pokoju, oj jakie długie niepotrzebnie, taki plan był no co zrobisz",
        graphic: 0
    )
  ];

  var _childNotificationsMock = [
    NotificationCard(
        notificationType: NotificationType.child_taskGraded,
        dateTime: DateTime.now(),
        subtitle: "Spakowanie plecaka",
        currencyType: CurrencyType.amethyst,
        currencyValue: 30
    ),
    NotificationCard(
        notificationType: NotificationType.child_receivedBadge,
        dateTime: DateTime.now(),
        subtitle: "Król pakowania plecaka",
        graphic: 0
    )
  ];
	
	@override
	Widget build(BuildContext context) {
    var authenticationBloc = context.bloc<AuthenticationBloc>();
    var currentUser = authenticationBloc.state.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocales.of(context).translate("page.notifications.header.title"))
      ),
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: <Widget>[
					AppSegments(
						segments: currentUser.role == UserRole.caregiver ? _caregiverNotificationsMock : _childNotificationsMock
					)
				]
			)
    );
	}
}
