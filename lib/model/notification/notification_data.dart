import 'package:mongo_dart/mongo_dart.dart';

import '../../utils/definitions.dart';
import 'notification_button.dart';
import 'notification_refresh_info.dart';
import 'notification_type.dart';

class NotificationData implements NotificationRefreshInfo {
	@override
  final NotificationType type;
	@override
  final ObjectId? subject;
	final ObjectId sender;
	final ObjectId recipient;
	final List<NotificationButton>? buttons;

  NotificationData({required this.type, required this.sender, required this.recipient, this.buttons, this.subject});

	factory NotificationData.fromJson(Json json) {
		return NotificationData(
			type: NotificationType.values[json['type']],
			sender: ObjectId.parse(json['sender']),
			recipient: ObjectId.parse(json['recipient']),
			subject: json['subject'] != null ? ObjectId.parse(json['subject']) : null,
		);
	}

	Json toJson() => {
		'type': type.index,
		'sender': sender.toJson(),
		'recipient': recipient.toJson(),
		if (subject != null)
			'subject': subject!.toJson(),
		if (buttons != null)
		'buttons': buttons!.reversed.map((button) => button.toJson()).toList()
	};
}
