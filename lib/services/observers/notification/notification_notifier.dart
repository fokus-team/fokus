import 'package:fokus/services/observers/notification/notification_observer.dart';

abstract class NotificationNotifier {
	void observeNotifications(NotificationObserver observer);
	void removeNotificationObserver(NotificationObserver observer);
}
