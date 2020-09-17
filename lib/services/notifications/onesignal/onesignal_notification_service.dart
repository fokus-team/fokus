import 'package:bson/bson.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'package:fokus/model/notification/notification_text.dart';
import 'package:fokus/model/notification/notification_button.dart';
import 'package:fokus/services/notifications/notification_service.dart';
import 'package:fokus/services/notifications/onesignal/onesignal_notification_provider.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/model/notification/notification_data.dart';
import 'package:fokus/model/notification/notification_type.dart';
import 'package:fokus/model/notification/notification_channel.dart';
import 'package:fokus/model/notification/notification_icon.dart';

class OneSignalNotificationService extends NotificationService {
	final String _androidSmallIconId = 'ic_stat_name';
	@override
	final OneSignalNotificationProvider provider = OneSignalNotificationProvider();

  @override
  Future sendNotification(NotificationType type, ObjectId userId, {NotificationText title,
	    NotificationText body, ObjectId subject, NotificationIcon icon, List<NotificationButton> buttons = const []}) async {
	  var tokens = await getUserTokens(userId);
	  if (tokens == null || tokens.isEmpty) {
		  logNoUserToken(userId);
		  return;
	  }
	  var data = NotificationData(type, buttons: buttons, subject: subject);
	  var osButtons = buttons.map((button) => OSActionButton(id: button.action, text: button.action)).toList();
	  var notification = OSCreateNotification(playerIds: tokens, heading: title.getTranslations(), content: body.getTranslations(),
			androidSmallIcon: _androidSmallIconId, androidAccentColor: AppColors.notificationAccentColor, existingAndroidChannelId: type.channel.id,
			  androidLargeIcon: icon.getPath, buttons: osButtons, additionalData: data.toJson());
		return OneSignal.shared.postNotification(notification);
  }
}
