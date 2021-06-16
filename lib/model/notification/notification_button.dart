import 'dart:convert';

import '../../utils/definitions.dart';
import 'notification_text.dart';

enum NotificationButton {
	rate, view
}

const String _key = 'notification.button';

extension NotificationButtonInfo on NotificationButton {
	String get action => const {
		NotificationButton.rate: 'rate',
		NotificationButton.view: 'view',
	}[this]!;
	SimpleNotificationText get name => const {
		NotificationButton.rate: SimpleNotificationText.appBased('$_key.rate'),
		NotificationButton.view: SimpleNotificationText.appBased('$_key.view'),
	}[this]!;

	Json toJson() => {
		'id': action,
		'text': json.encode(name.getTranslations())
	};
}
