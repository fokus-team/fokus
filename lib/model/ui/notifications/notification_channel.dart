import 'package:fokus/widgets/cards/notification_card.dart';

enum NotificationChannel {
	general, prizes, grades, plans
}

const String _key = 'notification.hannel';

extension NotificationChannelInfo on NotificationChannel {
	String get id => const {
		NotificationChannel.general: 'general',
		NotificationChannel.prizes: 'prizes',
		NotificationChannel.grades: 'grades',
		NotificationChannel.plans: 'plans',
	}[this];
	String get nameKey => const {
		NotificationChannel.general: '$_key.name.general',
		NotificationChannel.prizes: '$_key.name.prizes',
		NotificationChannel.grades: '$_key.name.grades',
		NotificationChannel.plans: '$_key.name.plans',
	}[this];
	String get descriptionKey => const {
		NotificationChannel.general: '$_key.description.general',
		NotificationChannel.prizes: '$_key.description.prizes',
		NotificationChannel.grades: '$_key.description.grades',
		NotificationChannel.plans: '$_key.description.plans',
	}[this];
}

extension NotificationTypeExtension on NotificationType {
	NotificationChannel get channel => const {
		NotificationType.caregiver_finishedTaskGraded: NotificationChannel.grades,
		NotificationType.caregiver_finishedTaskUngraded: NotificationChannel.grades,
		NotificationType.child_taskGraded: NotificationChannel.grades,
		NotificationType.caregiver_receivedAward: NotificationChannel.prizes,
		NotificationType.child_receivedBadge: NotificationChannel.prizes,
		NotificationType.caregiver_unfinishedPlan: NotificationChannel.plans,
	}[this];
}
