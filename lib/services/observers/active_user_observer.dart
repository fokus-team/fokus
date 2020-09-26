import 'package:fokus/model/db/user/user.dart';

abstract class ActiveUserObserver {
	void onUserSignIn(User user);
	void onUserSignOut(User user);
}
