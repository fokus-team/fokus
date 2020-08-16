import 'package:meta/meta.dart';

import 'package:fokus/model/auth_user.dart';

abstract class AuthenticationRepository {
	Stream<AuthenticatedUser> get user;

	Future<void> signInWithEmail({@required String email, @required String password});
	Future<void> signUpWithEmail({@required String email, @required String password, String name = ''});
	Future<void> signInWithGoogle();
	Future<void> signOut();
}
