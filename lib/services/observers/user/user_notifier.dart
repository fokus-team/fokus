import 'package:flutter/material.dart';
import '../../../model/db/user/user.dart';

import 'user_observer.dart';

class UserNotifier implements UserObserver {
	@protected
	User? user;

	User? get activeUser => user;
	
	@protected
	List<UserObserver> userObservers = [];

	UserNotifier() {
		observeUserChanges(this);
	}

	void observeUserChanges(UserObserver observer) => userObservers.add(observer);

  @override
  void onUserSignIn(User user) => this.user = user;

  @override
  void onUserSignOut(User user) => this.user = null;
}
