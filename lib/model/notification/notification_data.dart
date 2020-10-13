import 'package:fokus/model/notification/notification_button.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'notification_type.dart';

class NotificationData {
	final NotificationType type;
	final ObjectId subject;
	final ObjectId recipient;
	final List<NotificationButton> buttons;

  NotificationData(this.type, this.recipient, {this.buttons, this.subject});

	factory NotificationData.fromJson(Map<String, dynamic> json) {
		return NotificationData(
			NotificationType.values[json['type']],
			ObjectId.parse(json['recipient']),
			subject: json['subject'] != null ? ObjectId.parse(json['subject']) : null,
		);
	}

	Map<String, dynamic> toJson() => {
		'type': type.index,
		'recipient': recipient.toJson(),
		if (subject != null)
			'subject': subject.toJson(),
		if (buttons != null)
			'buttons': buttons.reversed.map((button) => button.toJson()).toList()
	};
}
