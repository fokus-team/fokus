import 'package:bson/bson.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'package:fokus/model/notification/notification_text.dart';
import 'package:fokus/model/notification/notification_button.dart';
import 'package:fokus/services/notifications/notification_service.dart';
import 'package:fokus/services/notifications/onesignal/onesignal_notification_provider.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/notification/notification_group.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
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
			title: SimpleNotificationText.appBased(type.title, {'CHILD_NAME': child.name}),
			body: SimpleNotificationText.userBased(planName),
			icon: NotificationIcon(type.graphicType, child.avatar),
			subject: planId,
			group: NotificationGroup(type.key, SimpleNotificationText.appBased(type.group))
		);
	}

	@override
	Future sendRewardBoughtNotification(ObjectId rewardId, String rewardName, ObjectId caregiverId, UIUser child) {
		var type = NotificationType.rewardBought;
		return sendNotification(type, caregiverId,
			title: SimpleNotificationText.appBased(type.title, {'CHILD_NAME': child.name}),
			body: SimpleNotificationText.userBased(rewardName),
			icon: NotificationIcon(type.graphicType, child.avatar),
			subject: rewardId,
			group: NotificationGroup(type.key, SimpleNotificationText.appBased(type.group))
		);
	}

	@override
	Future sendTaskFinishedNotification(ObjectId taskId, String taskName, ObjectId caregiverId, UIUser child) {
		var type = NotificationType.taskFinished;
		return sendNotification(type, caregiverId,
			title: SimpleNotificationText.appBased(type.title, {'CHILD_NAME': child.name}),
			body: SimpleNotificationText.userBased(taskName),
			icon: NotificationIcon(type.graphicType, child.avatar),
			buttons: [NotificationButton.rate],
			subject: taskId,
			group: NotificationGroup(type.key, SimpleNotificationText.appBased(type.group))
		);
	}

	@override
	Future sendBadgeAwardedNotification(String badgeName, int badgeIcon, ObjectId childId) {
		var type = NotificationType.badgeAwarded;
		return sendNotification(type, childId,
			title: SimpleNotificationText.appBased(type.title),
			body: SimpleNotificationText.userBased(badgeName),
			icon: NotificationIcon(type.graphicType, badgeIcon),
			group: NotificationGroup(type.key, SimpleNotificationText.appBased(type.group)),
			buttons: [NotificationButton.view],
		);
	}

	@override
	Future sendTaskApprovedNotification(String taskName, ObjectId childId, int stars, [CurrencyType currencyType, int pointCount]) {
		var type = NotificationType.taskApproved;
		var hasPoints = pointCount != null && pointCount > 0;
		return sendNotification(type, childId,
			title: ComplexNotificationText([
				SimpleNotificationText.appBased('${type.title}Prefix'),
				SimpleNotificationText.userBased(taskName)
			]),
			body: ComplexNotificationText([
				SimpleNotificationText.appBased('${type.title}Stars', {'STARS': formatTaskStars(stars)}),
				if (hasPoints)
					SimpleNotificationText.appBased('${type.title}Count', {'COUNT': '$pointCount'}),
			]),
			icon: hasPoints ? NotificationIcon(type.graphicType, currencyType.index) : NotificationIcon.fromName('star'),
			group: NotificationGroup(type.key, SimpleNotificationText.appBased(type.group))
		);
	}

	@override
	Future sendTaskRejectedNotification(ObjectId taskId, String taskName, ObjectId childId) {
		var type = NotificationType.taskRejected;
		return sendNotification(type, childId,
			title: SimpleNotificationText.appBased(type.title),
			body: SimpleNotificationText.userBased(taskName),
			group: NotificationGroup(type.key, SimpleNotificationText.appBased(type.group)),
			subject: taskId
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
		  androidLargeIcon: icon?.getPath,
		  buttons: osButtons,
		  additionalData: data.toJson(),
		  androidGroup: group?.key,
		  androidGroupMessage: group?.title?.getTranslations());
		return OneSignal.shared.postNotification(notification);
  }
}
