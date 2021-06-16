import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/common/auth_bloc/authentication_bloc.dart';
import '../../model/currency_type.dart';
import '../../model/db/user/user_role.dart';
import '../../model/notification/notification_type.dart';
import '../../services/app_locales.dart';
import '../../widgets/cards/notification_card.dart';
import '../../widgets/segment.dart';

class NotificationsPage extends StatefulWidget {
	@override
	_NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {

  final _caregiverNotificationsMock = [
    NotificationCard(
      childName: "Aleksandrittobuonaserra",
      notificationType: NotificationType.rewardBought,
      dateTime: DateTime.now(),
      subtitle: "1 godzina gry na konsoli",
      graphic: 10
    ),
    NotificationCard(
      childName: "Gosia",
      notificationType: NotificationType.taskFinished,
      dateTime: DateTime.now(),
      subtitle: "Sprzątanie pokoju",
      graphic: 20
    ),
    NotificationCard(
      childName: "Maciek",
      notificationType: NotificationType.taskUnfinished,
      dateTime: DateTime.now(),
      subtitle: "Bardzo długie sprzątanie pokoju, oj jakie długie niepotrzebnie, taki plan był no co zrobisz",
      graphic: 0
    )
  ];

  final _childNotificationsMock = [
    NotificationCard(
      notificationType: NotificationType.taskApproved,
      dateTime: DateTime.now(),
      subtitle: "Spakowanie plecaka",
      graphic: CurrencyType.amethyst.index,
      currencyValue: 30
    ),
    NotificationCard(
      notificationType: NotificationType.badgeAwarded,
      dateTime: DateTime.now(),
      subtitle: "Król pakowania plecaka",
      graphic: 0
    )
  ];
	
	@override
	Widget build(BuildContext context) {
    // ignore: close_sinks
    var authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    var currentUser = authenticationBloc.state.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocales.of(context).translate("page.notifications.header.title"))
      ),
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: <Widget>[
					AppSegments(
						segments: currentUser!.role == UserRole.caregiver ? _caregiverNotificationsMock : _childNotificationsMock
					)
				]
			)
    );
	}
}
