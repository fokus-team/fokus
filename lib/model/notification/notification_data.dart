import 'package:fokus/model/notification/notification_button.dart';

import 'notification_type.dart';

class NotificationData {
	final NotificationType type;
	final List<NotificationButton> buttons;

  NotificationData(this.type, [this.buttons]);

	factory NotificationData.fromJson(Map<String, dynamic> json) {
		return NotificationData(NotificationType.values[json['type']]);
	}

	Map<String, dynamic> toJson() => {
		'type': type.index,
		if (buttons != null)
			'buttons': buttons.reversed.map((button) => button.toJson()).toList()
	};
}
