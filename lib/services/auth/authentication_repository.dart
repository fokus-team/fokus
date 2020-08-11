import 'package:meta/meta.dart';

import 'package:fokus/model/auth_user.dart';

abstract class AuthenticationRepository {
	Stream<AuthenticatedUser> get user;

	Future<void> logInWithEmailAndPassword({@required String email, @required String password});
	Future<void> signUp({@required String email, @required String password, String name = ''});
	Future<void> logInWithGoogle();
	Future<void> logOut();
}
