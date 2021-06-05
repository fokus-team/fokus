import 'package:fokus/model/db/user/user.dart';

abstract class UserObserver {
	void onUserSignIn(User user);
	void onUserSignOut(User user);
}
