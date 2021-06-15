import 'package:bson/bson.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fokus/logic/common/auth_bloc/authentication_bloc.dart';
import 'package:fokus/model/db/user/user.dart';
import 'package:get_it/get_it.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fokus/model/notification/notification_text.dart';
import 'package:fokus/model/notification/notification_button.dart';
import 'package:fokus/services/notifications/notification_service.dart';
import 'package:fokus/services/notifications/onesignal/onesignal_notification_provider.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/notification/notification_group.dart';
import 'package:fokus/model/notification/notification_data.dart';
import 'package:fokus/model/notification/notification_type.dart';
import 'package:fokus/model/notification/notification_channel.dart';
import 'package:fokus/model/notification/notification_icon.dart';

class OneSignalNotificationService extends NotificationService {
	final String _androidSmallIconId = 'ic_stat_onesignal_default';
	@override
	final OneSignalNotificationProvider provider = OneSignalNotificationProvider();
	final _navigatorKey = GetIt.I<GlobalKey<NavigatorState>>();

	@override
	Future sendTaskFinishedNotification(ObjectId planInstanceId, String taskName, ObjectId caregiverId, User child, {required bool completed}) {
		var type = completed ? NotificationType.taskFinished : NotificationType.taskUnfinished;
		return sendNotification(type, caregiverId,
			title: SimpleNotificationText.appBased(type.title, {'CHILD_NAME': child.name!}),
			body: SimpleNotificationText.userBased(taskName),
			icon: NotificationIcon(type.graphicType, child.avatar),
			buttons: completed ? [NotificationButton.rate] : [],
			subject: planInstanceId,
			group: NotificationGroup(type.key, SimpleNotificationText.appBased(type.group))
		);
	}

	@override
	Future sendRewardBoughtNotification(ObjectId rewardId, String rewardName, ObjectId caregiverId, User child) {
		var type = NotificationType.rewardBought;
		return sendNotification(type, caregiverId,
			title: SimpleNotificationText.appBased(type.title, {'CHILD_NAME': child.name!}),
			body: SimpleNotificationText.userBased(rewardName),
			icon: NotificationIcon(type.graphicType, child.avatar),
			subject: rewardId,
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
	Future sendTaskApprovedNotification(ObjectId planId, String taskName, ObjectId childId, int stars, {CurrencyType? currencyType, int? pointCount, String? comment}) {
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
				if (comment != null && comment.isNotEmpty)
					SimpleNotificationText.userBased('\n$comment'),
			]),
			icon: hasPoints ? NotificationIcon(type.graphicType, currencyType?.index) : NotificationIcon.fromName('star'),
			group: NotificationGroup(type.key, SimpleNotificationText.appBased(type.group)),
			subject: planId
		);
	}

	@override
	Future sendTaskRejectedNotification(ObjectId planId, String taskName, ObjectId childId) {
		var type = NotificationType.taskRejected;
		return sendNotification(type, childId,
			title: SimpleNotificationText.appBased(type.title),
			body: SimpleNotificationText.userBased(taskName),
			group: NotificationGroup(type.key, SimpleNotificationText.appBased(type.group)),
			subject: planId
		);
	}

  @override
  Future sendNotification(NotificationType type, ObjectId userId, {required NotificationText title, required NotificationText body,
	    ObjectId? subject, NotificationIcon? icon, required NotificationGroup group, List<NotificationButton> buttons = const []}) async {
	  var tokens = await getUserTokens(userId);
	  if (tokens == null || tokens.isEmpty) {
		  logNoUserToken(userId);
		  return;
	  }
	  var activeUser = BlocProvider.of<AuthenticationBloc>(_navigatorKey.currentState!.context).state.user;
	  var data = NotificationData(type: type, sender: activeUser!.id!, recipient: userId, buttons: buttons, subject: subject);
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
		  androidGroup: group.key,
		  androidGroupMessage: group.title.getTranslations()
	  );
		try {
			await OneSignal.shared.postNotification(notification);
		} on PlatformException catch(e, s) {
			if (_tryHandleError(e, notification, userId))
				return OneSignal.shared.postNotification(notification);
			else
				logger.severe('Notification exception unhandled', e, s);
		}
  }

  bool _tryHandleError(PlatformException exception, OSCreateNotification notification, ObjectId userId) {
		if (exception.details is! Map) return false;
		var details = exception.details as Map;
		if (!details.containsKey('errors')) return false;
		var errors = details['errors'] as Map;
		if (errors.containsKey('invalid_player_ids')) {
			for (var id in errors['invalid_player_ids'] as List) {
				var invalidID = id as String;
				dataRepository.removeNotificationID(invalidID, userId: userId);
				notification.playerIds.remove(invalidID);
			}
			return true;
		}
		return false;
  }
}
