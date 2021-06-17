import '../../../model/db/user/user.dart';
import 'user_notifier.dart';

class AuthenticatedUserNotifier extends UserNotifier {
	set activeUser(User? user) => this.user = user;

	void userSignInEvent(User user) => userObservers.forEach((observer) => observer.onUserSignIn(user));
	void userSignOutEvent(User user) => userObservers.forEach((observer) => observer.onUserSignOut(user));
}
