enum NotificationButton {
	rate
}

const String _key = 'notification.button';

extension NotificationButtonInfo on NotificationButton {
	String get action => const {
		NotificationButton.rate: 'rate',
	}[this];
	String get nameKey => const {
		NotificationButton.rate: '$_key.rate',
	}[this];
}
