import 'package:fokus/model/db/user/user.dart';

import 'active_user_observer.dart';

mixin UserChangeNotifier {
	List<ActiveUserObserver> _userObservers = [];

	void observeUserChanges(ActiveUserObserver observer) => _userObservers.add(observer);
	void onUserSignIn(User user) => _userObservers.forEach((observer) => observer.onUserSignIn(user));
	void onUserSignOut(User user) => _userObservers.forEach((observer) => observer.onUserSignOut(user));
}
