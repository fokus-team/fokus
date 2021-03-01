import 'package:fokus/model/notification/notification_refresh_info.dart';
import 'package:fokus/model/notification/notification_type.dart';

mixin NotificationObserver {
	List<NotificationType> notificationTypeSubscription() => [];

	bool shouldNotificationRefresh(NotificationRefreshInfo info) => true;
	void onNotificationReceived(NotificationRefreshInfo info);
}
