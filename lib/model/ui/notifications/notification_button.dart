import 'dart:convert';

import 'package:fokus/services/app_locales.dart';

import 'notification_text.dart';

enum NotificationButton {
	rate
}

const String _key = 'notification.button';

extension NotificationButtonInfo on NotificationButton {
	String get action => const {
		NotificationButton.rate: 'rate',
	}[this];
	NotificationText get name => const {
		NotificationButton.rate: NotificationText.appBased('$_key.rate'),
	}[this];

	Map<String, dynamic> toJson() => {
		'id': action,
		'text': json.encode(name.getTranslations())
	};
}
