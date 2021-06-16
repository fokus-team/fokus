import '../../../model/db/user/user.dart';
import 'user_notifier.dart';

class AuthenticatedUserNotifier extends UserNotifier {
	void userSignInEvent(User user) => userObservers.forEach((observer) => observer.onUserSignIn(user));
	void userSignOutEvent(User user) => userObservers.forEach((observer) => observer.onUserSignOut(user));
	void userUpdatedEvent(User user) => activeUser = user;
}
