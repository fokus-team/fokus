import 'package:fokus/model/ui/user/ui_user.dart';

mixin ActiveUserUpdateObserver {
	bool userUpdateCondition(UIUser oldUser, UIUser newUser) => true;

	void onUserUpdated(UIUser user);
}
