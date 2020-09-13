import 'package:bson/bson.dart';

import 'package:fokus/model/ui/localized_text.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/services/notifications/notification_service.dart';
import 'package:fokus/services/notifications/onesignal/onesignal_notification_provider.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/cards/notification_card.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:fokus/model/ui/notification_channel.dart';

class OneSignalNotificationService extends NotificationService {
	final String _androidSmallIconId = 'ic_stat_name';
	@override
	final OneSignalNotificationProvider provider = OneSignalNotificationProvider();

  @override
  void sendNotification(NotificationType type, ObjectId userId, {LocalizedText locTitle, String title, LocalizedText locBody, String body}) async {
	  var tokens = await getUserTokens(userId);
	  var translate = (LocalizedText text) => AppLocales.instance.getTranslations(text.key, text.arguments);
	  if (tokens == null || tokens.isEmpty) {
		  logNoUserToken(userId);
		  return;
	  }
	  var notification = OSCreateNotification(playerIds: tokens, heading: translate(locTitle), content: {'en': body}, androidSmallIcon: _androidSmallIconId,
		  androidAccentColor: AppColors.notificationAccentColor, existingAndroidChannelId: type.channel.id, buttons: [OSActionButton(id: '1', text: 'Oceń')]);
		OneSignal.shared.postNotification(notification);
  }
}
