import 'package:mongo_dart/mongo_dart.dart';

import 'notification_type.dart';

abstract class NotificationRefreshInfo {
	NotificationType get type;
	ObjectId? get subject;
}
