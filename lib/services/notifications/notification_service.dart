import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/notification/notification_type.dart';
import 'package:fokus/model/ui/gamification/ui_points.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/model/db/user/user.dart';
import 'package:fokus/model/notification/notification_text.dart';
import 'package:fokus/model/notification/notification_button.dart';
import 'package:fokus/model/notification/notification_icon.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/services/notifications/notification_provider.dart';
import 'package:fokus/services/observers/active_user_observer.dart';

abstract class NotificationService implements ActiveUserObserver {
	NotificationProvider get provider;
	@protected
	final DataRepository dataRepository = GetIt.I<DataRepository>();
	@protected
	final Logger logger = Logger('NotificationService');

	Future sendNotification(NotificationType type, ObjectId user, {NotificationText title,
		NotificationText body, NotificationIcon icon, List<NotificationButton> buttons = const []});

	Future sendRewardBoughtNotification(String rewardName, ObjectId caregiverId, int avatar);
	Future sendTaskFinishedNotification(ObjectId taskId, String taskName, ObjectId caregiverId, int avatar);
	Future sendPlanUnfinishedNotification(ObjectId planId, String planName, ObjectId caregiverId, int avatar);

	Future sendPointsReceivedNotification(CurrencyType currencyType, int quantity, String taskName, ObjectId childId);
	Future sendBadgeAwardedNotification(String badgeName, int badgeIcon, ObjectId childId);

	@protected
	Future<List<String>> getUserTokens(ObjectId userId) async => (await dataRepository.getUser(id: userId, fields: ['notificationIDs'])).notificationIDs;
	@protected
	void logNoUserToken(ObjectId userId) => logger.info('Could not send a notification, user ${userId.toHexString()} has no notification ID assigned');

	@override
	void onUserSignIn(User user) => provider.onUserSignIn(user);

	@override
	void onUserSignOut(User user) => provider.onUserSignOut(user);
}
