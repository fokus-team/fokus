import 'package:bson/bson.dart';
import 'package:fokus/model/ui/notifications/notification_button.dart';
import 'package:googleapis/fcm/v1.dart';

import 'package:fokus/services/notifications/firebase/firebase_notification_provider.dart';
import 'package:fokus/services/notifications/notification_service.dart';
import 'package:fokus/model/ui/notifications/notification_channel.dart';
import 'package:fokus/widgets/cards/notification_card.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/model/ui/localized_text.dart';

class FirebaseNotificationService extends NotificationService {
	@override
	FirebaseNotificationProvider provider = FirebaseNotificationProvider();
	static final String _projectId = 'projects/fokus-application';

  @override
  Future sendNotification(NotificationType type, ObjectId userId, {LocalizedText locTitle,
	    String title, LocalizedText locBody, String body, List<NotificationButton> buttons = const []}) async {
  	var tokens = await getUserTokens(userId);
  	if (tokens == null || tokens.isEmpty) {
		  logNoUserToken(userId);
		  return;
	  }
	  var translate = (LocalizedText text) => AppLocales.instance.translate(text.key, text.arguments);
		var request = SendMessageRequest.fromJson({
			'message': {
				'notification': {
					'title': locTitle != null ? translate(locTitle) : title,
					'body': locBody != null ? translate(locBody) : body
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
					if (locTitle != null)
						...locTitle.toJson('title'),
					if (locBody != null)
						...locBody.toJson('body'),
				}
			}
		});
		for (var token in tokens) {
			request.message.token = token;
			provider.notificationApi.send(request, _projectId);
		}
  }
}
