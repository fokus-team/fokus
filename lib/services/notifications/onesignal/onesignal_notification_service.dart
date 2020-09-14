import 'dart:convert';
import 'package:bson/bson.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'package:fokus/model/ui/localized_text.dart';
import 'package:fokus/model/ui/notifications/notification_button.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/services/notifications/notification_service.dart';
import 'package:fokus/services/notifications/onesignal/onesignal_notification_provider.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/cards/notification_card.dart';
import 'package:fokus/model/ui/notifications/notification_channel.dart';

class OneSignalNotificationService extends NotificationService {
	final String _androidSmallIconId = 'ic_stat_name';
	@override
	final OneSignalNotificationProvider provider = OneSignalNotificationProvider();

  @override
  void sendNotification(NotificationType type, ObjectId userId, {LocalizedText locTitle, String title,
	    LocalizedText locBody, String body, List<NotificationButton> buttons = const []}) async {
	  var tokens = await getUserTokens(userId);
	  var translate = (String key, [Map<String, Object> args]) => AppLocales.instance.getTranslations(key, args);
	  var locTranslate = (LocalizedText text) => translate(text.key, text.arguments);
	  if (tokens == null || tokens.isEmpty) {
		  logNoUserToken(userId);
		  return;
	  }
	  var osButtons = buttons.reversed.map((e) => {'id': e.action, 'text': json.encode(translate(e.nameKey))}).toList();
	  var notification = OSCreateNotification(playerIds: tokens, heading: locTranslate(locTitle), content: {'en': body}, androidSmallIcon: _androidSmallIconId,
		  androidAccentColor: AppColors.notificationAccentColor, existingAndroidChannelId: type.channel.id, additionalData: {'buttons': osButtons});
		OneSignal.shared.postNotification(notification);
  }
}
