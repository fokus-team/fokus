// @dart = 2.10
enum NotificationChannel {
	general, prizes, grades, plans
}

const String _key = 'notification.channel';

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
