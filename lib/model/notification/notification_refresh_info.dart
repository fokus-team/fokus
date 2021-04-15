import 'package:fokus/model/notification/notification_type.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class NotificationRefreshInfo {
	NotificationType get type;
	ObjectId? get subject;
}
