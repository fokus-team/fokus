import 'package:fokus/model/notification/notification_type.dart';

mixin DataUpdateObserver {
	List<NotificationType> dataTypeSubscription() => [];

	void onDataUpdated(NotificationType type);
}
