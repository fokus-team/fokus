import 'package:fokus/model/db/user/user.dart';
import 'package:fokus/model/ui/localized_text.dart';
import 'package:fokus/services/notifications/notification_provider.dart';
import 'package:fokus/services/observers/active_user_observer.dart';
import 'package:fokus/widgets/cards/notification_card.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class NotificationService implements ActiveUserObserver {
	NotificationProvider get provider;

	void sendNotification(NotificationType type, ObjectId user, {LocalizedText locTitle, String title, LocalizedText locBody, String body});

	@override
	void onUserSignIn(User user) => provider.onUserSignIn(user);

	@override
	void onUserSignOut(User user) => provider.onUserSignOut(user);
}
