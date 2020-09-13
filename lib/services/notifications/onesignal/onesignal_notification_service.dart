import 'package:bson/bson.dart';

import 'package:fokus/model/ui/localized_text.dart';
import 'package:fokus/services/notifications/notification_service.dart';
import 'package:fokus/services/notifications/onesignal/onesignal_notification_provider.dart';
import 'package:fokus/widgets/cards/notification_card.dart';

class OneSignalNotificationService extends NotificationService {
	@override
	final OneSignalNotificationProvider provider = OneSignalNotificationProvider();

  @override
  void sendNotification(NotificationType type, ObjectId user, {LocalizedText locTitle, String title, LocalizedText locBody, String body}) {

  }
}
