import 'package:fokus/model/notification/notification_button.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'notification_type.dart';

class NotificationData {
	final NotificationType type;
	final ObjectId subject;
	final List<NotificationButton> buttons;

  NotificationData(this.type, {this.buttons, this.subject});

	factory NotificationData.fromJson(Map<String, dynamic> json) {
		return NotificationData(
			NotificationType.values[json['type']],
			subject: json['subject'] != null ? ObjectId.parse(json['subject']) : null,
		);
	}

	Map<String, dynamic> toJson() => {
		'type': type.index,
		if (subject != null)
			'subject': subject.toJson(),
		if (buttons != null)
			'buttons': buttons.reversed.map((button) => button.toJson()).toList()
	};
}
