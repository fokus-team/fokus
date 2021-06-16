import 'package:flutter/material.dart';
import '../../../model/db/user/user.dart';

import 'user_observer.dart';

class UserNotifier implements UserObserver {
	User? activeUser;
	
	@protected
	List<UserObserver> userObservers = [];

	UserNotifier() {
		observeUserChanges(this);
	}

	void observeUserChanges(UserObserver observer) => userObservers.add(observer);

  @override
  void onUserSignIn(User user) => activeUser = user;

  @override
  void onUserSignOut(User user) => activeUser = null;
}
