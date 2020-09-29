import 'package:bson/bson.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/notification/notification_group.dart';
import 'package:fokus/model/notification/notification_type.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:googleapis/fcm/v1.dart';

import 'package:fokus/services/notifications/firebase/firebase_notification_provider.dart';
import 'package:fokus/services/notifications/notification_service.dart';
import 'package:fokus/model/notification/notification_button.dart';
import 'package:fokus/model/notification/notification_channel.dart';
import 'package:fokus/model/notification/notification_icon.dart';
import 'package:fokus/model/notification/notification_text.dart';
import 'package:meta/meta.dart';

class FirebaseNotificationService extends NotificationService {
	@override
	FirebaseNotificationProvider provider = FirebaseNotificationProvider();
	static final String _projectId = 'projects/fokus-application';

	@override
	Future sendTaskFinishedNotification(ObjectId taskId, String taskName, ObjectId caregiverId, UIUser child, {@required bool completed}) => throw UnimplementedError();
	@override
	Future sendRewardBoughtNotification(ObjectId rewardId, String rewardName, ObjectId caregiverId, UIUser child) => throw UnimplementedError();
	@override
	Future sendTaskApprovedNotification(String taskName, ObjectId childId, int stars, [CurrencyType currencyType, int pointCount]) => throw UnimplementedError();
	@override
	Future sendBadgeAwardedNotification(String badgeName, int badgeIcon, ObjectId childId) => throw UnimplementedError();
	@override
	Future sendTaskRejectedNotification(ObjectId taskId, String taskName, ObjectId childId) => throw UnimplementedError();

  @override
  Future sendNotification(NotificationType type, ObjectId userId, {NotificationText title, NotificationText body,
	    NotificationIcon icon, NotificationGroup group, List<NotificationButton> buttons = const []}) async {
  	var tokens = await getUserTokens(userId);
  	if (tokens == null || tokens.isEmpty) {
		  logNoUserToken(userId);
		  return;
	  }
		var request = SendMessageRequest.fromJson({
			'message': {
				'notification': {
					'title': title.translate(),
					'body': body.translate()
				},
				'android': {
					'notification': {
						'channelId': type.channel.id,
						//'titleLocKey': titleKey,
						//'bodyLocKey': body
					}
				},
				'data': {
					'click_action': 'FLUTTER_NOTIFICATION_CLICK',
					'channel': '${type.channel.index}',
					if (title != null)
						...title.toJson('title'),
					if (body != null)
						...body.toJson('body'),
				}
			}
		});
		for (var token in tokens) {
			request.message.token = token;
			provider.notificationApi.send(request, _projectId);
		}
  }
}
