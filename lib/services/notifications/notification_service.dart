import 'dart:math';

import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart' show ObjectId;

import '../../model/currency_type.dart';
import '../../model/db/user/user.dart';
import '../../model/notification/notification_button.dart';
import '../../model/notification/notification_group.dart';
import '../../model/notification/notification_icon.dart';
import '../../model/notification/notification_text.dart';
import '../../model/notification/notification_type.dart';
import '../data/data_repository.dart';
import '../observers/notification/notification_notifier.dart';
import '../observers/notification/notification_observer.dart';
import '../observers/user/user_notifier.dart';
import '../observers/user/user_observer.dart';
import 'notification_provider.dart';

abstract class NotificationService implements UserObserver, NotificationNotifier {
	NotificationProvider get provider;
	@protected
	final DataRepository dataRepository = GetIt.I<DataRepository>();
	@protected
	final Logger logger = Logger('NotificationService');
	final UserNotifier _userNotifier = GetIt.I<UserNotifier>();

	NotificationService() {
		_userNotifier.observeUserChanges(this);
	}

	Future sendNotification(NotificationType type, ObjectId user, {required NotificationText title, required NotificationText body,
		ObjectId? subject, NotificationIcon? icon, required NotificationGroup group, List<NotificationButton> buttons = const []});

	Future sendRewardBoughtNotification(ObjectId rewardId, String rewardName, ObjectId caregiverId, User child);
	Future sendTaskFinishedNotification(ObjectId planInstanceId, String taskName, ObjectId caregiverId, User child, {required bool completed});

	Future sendTaskApprovedNotification(ObjectId planId, String taskName, ObjectId childId, int stars, {CurrencyType? currencyType, int? pointCount, String? comment});
	Future sendBadgeAwardedNotification(String badgeName, int badgeIcon, ObjectId childId);
	Future sendTaskRejectedNotification(ObjectId planId, String taskName, ObjectId childId);

	@override
  void observeNotifications(NotificationObserver observer) => provider.observeNotifications(observer);
	@override
  void removeNotificationObserver(NotificationObserver observer) => provider.removeNotificationObserver(observer);

	@protected
	Future<List<String>?> getUserTokens(ObjectId userId) async => (await dataRepository.getUser(id: userId, fields: ['notificationIDs']))!.notificationIDs;
	@protected
	void logNoUserToken(ObjectId userId) => logger.info('Could not send a notification, user ${userId.toHexString()} is not logged in on any device');

	@protected
	String formatTaskStars(int count) => String.fromCharCode(0x2B50) * count + String.fromCharCode(0x1F538) * (max(5, count) - count);

	@override
	void onUserSignIn(User user) => provider.onUserSignIn(user);

	@override
	void onUserSignOut(User user) => provider.onUserSignOut(user);
}
