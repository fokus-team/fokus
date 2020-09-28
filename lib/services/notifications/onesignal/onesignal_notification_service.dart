import 'package:bson/bson.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/notification/notification_group.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/utils/icon_sets.dart';
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
	final String _androidSmallIconId = 'ic_stat_onesignal_default';
	@override
	final OneSignalNotificationProvider provider = OneSignalNotificationProvider();

	@override
	Future sendPlanUnfinishedNotification(ObjectId planId, String planName, ObjectId caregiverId, UIUser child) {
		var type = NotificationType.planUnfinished;
		return sendNotification(type, caregiverId,
			title: NotificationText.appBased(type.title, {'CHILD_NAME': child.name}),
			body: NotificationText.userBased(planName),
			icon: NotificationIcon(AssetType.avatars, child.avatar),
			subject: planId,
			group: NotificationGroup(type.key, NotificationText.appBased(type.group))
		);
	}

	@override
	Future sendRewardBoughtNotification(ObjectId rewardId, String rewardName, ObjectId caregiverId, UIUser child) {
		var type = NotificationType.rewardBought;
		return sendNotification(type, caregiverId,
			title: NotificationText.appBased(type.title, {'CHILD_NAME': child.name}),
			body: NotificationText.userBased(rewardName),
			icon: NotificationIcon(AssetType.avatars, child.avatar),
			subject: rewardId,
			group: NotificationGroup(type.key, NotificationText.appBased(type.group))
		);
	}

	@override
	Future sendTaskFinishedNotification(ObjectId taskId, String taskName, ObjectId caregiverId, UIUser child) {
		var type = NotificationType.taskFinished;
		return sendNotification(type, caregiverId,
			title: NotificationText.appBased(type.title, {'CHILD_NAME': child.name}),
			body: NotificationText.userBased(taskName),
			icon: NotificationIcon(AssetType.avatars, child.avatar),
			buttons: [NotificationButton.rate],
			subject: taskId,
			group: NotificationGroup(type.key, NotificationText.appBased(type.group))
		);
	}

	@override
	Future sendBadgeAwardedNotification(String badgeName, int badgeIcon, ObjectId childId) {
		var type = NotificationType.badgeAwarded;
		return sendNotification(type, childId,
			title: NotificationText.appBased(type.title),
			body: NotificationText.userBased(badgeName),
			icon: NotificationIcon(AssetType.badges, badgeIcon),
			group: NotificationGroup(type.key, NotificationText.appBased(type.group)),
			buttons: [NotificationButton.view],
		);
	}

	@override
	Future sendPointsReceivedNotification(CurrencyType currencyType, int quantity, String taskName, ObjectId childId) {
		var type = NotificationType.pointsReceived;
		return sendNotification(type, childId,
			title: NotificationText.appBased('${type.title}WithCount', {'POINTS': '$quantity'}),
			body: NotificationText.userBased(taskName),
			icon: NotificationIcon(AssetType.currencies, currencyType.index),
			group: NotificationGroup(type.key, NotificationText.appBased(type.group))
		);
	}

  @override
  Future sendNotification(NotificationType type, ObjectId userId, {NotificationText title, NotificationText body,
	    ObjectId subject, NotificationIcon icon, NotificationGroup group, List<NotificationButton> buttons = const []}) async {
	  var tokens = await getUserTokens(userId);
	  if (tokens == null || tokens.isEmpty) {
		  logNoUserToken(userId);
		  return;
	  }
	  var data = NotificationData(type, buttons: buttons, subject: subject);
	  var osButtons = buttons.map((button) => OSActionButton(id: button.action, text: button.action)).toList();
	  var notification = OSCreateNotification(
		  playerIds: tokens,
		  heading: title.getTranslations(),
		  content: body.getTranslations(),
			androidSmallIcon: _androidSmallIconId,
		  androidAccentColor: AppColors.notificationAccentColor,
		  existingAndroidChannelId: type.channel.id,
		  androidLargeIcon: icon.getPath,
		  buttons: osButtons,
		  additionalData: data.toJson(),
		  androidGroup: group?.key,
		  androidGroupMessage: group?.title?.getTranslations());
		return OneSignal.shared.postNotification(notification);
  }
}
