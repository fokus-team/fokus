import 'package:bson/bson.dart';
import 'package:get_it/get_it.dart';
import 'package:googleapis/fcm/v1.dart';

import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/services/notifications/notification_provider.dart';
import 'package:fokus/services/notifications/notification_service.dart';

class FirebaseNotificationService implements NotificationService {
	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final NotificationProvider _provider = NotificationProvider();

	static final String _projectId = 'projects/fokus-application';

  @override
  Future sendNotification(ObjectId userId, String title, String text) async {
  	var tokens = (await _dataRepository.getUser(id: userId, fields: ['notificationIDs'])).notificationIDs;
		var request = SendMessageRequest.fromJson({
			'message': {
				'notification': {
					'title': title,
					'body': text
				}
			}
		});
		for (var token in tokens) {
			request.message.token = token;
			_provider.notificationApi.send(request, _projectId);
		}
  }
}
