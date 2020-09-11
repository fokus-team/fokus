import 'package:mongo_dart/mongo_dart.dart';

abstract class NotificationService {
	void sendNotification(ObjectId user, String title, String text);
}
