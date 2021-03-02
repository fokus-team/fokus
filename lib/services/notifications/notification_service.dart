import 'dart:math';

import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;

import 'package:fokus/model/db/user/user.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/notification/notification_group.dart';
import 'package:fokus/model/notification/notification_type.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/services/observers/notification/notification_observer.dart';
import 'package:fokus/model/notification/notification_text.dart';
import 'package:fokus/model/notification/notification_button.dart';
import 'package:fokus/model/notification/notification_icon.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/services/notifications/notification_provider.dart';
import 'package:fokus/services/observers/user/active_user_observer.dart';

import '../observers/notification/notification_notifier.dart';

abstract class NotificationService implements ActiveUserObserver, NotificationNotifier {
	NotificationProvider get provider;
	@protected
	final DataRepository dataRepository = GetIt.I<DataRepository>();
	@protected
	final Logger logger = Logger('NotificationService');

	Future sendNotification(NotificationType type, Mongo.ObjectId user, {NotificationText title, NotificationText body,
		NotificationIcon icon, NotificationGroup group, List<NotificationButton> buttons = const []});

	Future sendRewardBoughtNotification(Mongo.ObjectId rewardId, String rewardName, Mongo.ObjectId caregiverId, UIUser child);
	Future sendTaskFinishedNotification(Mongo.ObjectId planInstanceId, String taskName, Mongo.ObjectId caregiverId, UIUser child, {@required bool completed});

	Future sendTaskApprovedNotification(Mongo.ObjectId planId, String taskName, Mongo.ObjectId childId, int stars, [CurrencyType currencyType, int pointCount]);
	Future sendBadgeAwardedNotification(String badgeName, int badgeIcon, Mongo.ObjectId childId);
	Future sendTaskRejectedNotification(Mongo.ObjectId planId, String taskName, Mongo.ObjectId childId);

	void observeNotifications(NotificationObserver observer) => provider.observeNotifications(observer);
	void removeNotificationObserver(NotificationObserver observer) => provider.removeNotificationObserver(observer);

	@protected
	Future<List<String>> getUserTokens(Mongo.ObjectId userId) async => (await dataRepository.getUser(id: userId, fields: ['notificationIDs'])).notificationIDs;
	@protected
	void logNoUserToken(Mongo.ObjectId userId) => logger.info('Could not send a notification, user ${userId.toHexString()} is not logged in on any device');

	@protected
	String formatTaskStars(int count) => String.fromCharCode(0x2B50) * count + String.fromCharCode(0x1F538) * (max(5, count) - count);

	@override
	void onUserSignIn(User user) => provider.onUserSignIn(user);

	@override
	void onUserSignOut(User user) => provider.onUserSignOut(user);
}
