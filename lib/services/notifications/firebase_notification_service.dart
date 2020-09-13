import 'package:bson/bson.dart';
import 'package:fokus/model/ui/localized_text.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:googleapis/fcm/v1.dart';

import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/services/notifications/notification_provider.dart';
import 'package:fokus/services/notifications/notification_service.dart';
import 'package:fokus/model/db/user/user.dart';
import 'package:fokus/model/ui/notification_channel.dart';
import 'package:fokus/widgets/cards/notification_card.dart';
import 'package:fokus/services/app_locales.dart';

class FirebaseNotificationService implements NotificationService {
	final Logger _logger = Logger('FirebaseNotificationService');
	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final NotificationProvider _provider = NotificationProvider();

	static final String _projectId = 'projects/fokus-application';

  @override
  Future sendNotification(NotificationType type, ObjectId userId, {LocalizedText locTitle, String title, LocalizedText locBody, String body}) async {
  	var tokens = (await _dataRepository.getUser(id: userId, fields: ['notificationIDs'])).notificationIDs;
  	if (tokens == null || tokens.isEmpty) {
			_logger.info('Could not send a notification to user with ID ${userId.toHexString()}, there is no notification ID assigned');
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
			_provider.notificationApi.send(request, _projectId);
		}
  }

  @override
  void onUserSignIn(User user) => _provider.onUserSignIn(user);

  @override
  void onUserSignOut(User user) => _provider.onUserSignOut(user);
}
