import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';

import 'package:fokus/model/auth_user.dart';
import 'package:fokus/services/exception/auth_exceptions.dart';

import 'authentication_repository.dart';

class FirebaseAuthRepository implements AuthenticationRepository {
	final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
	final GoogleSignIn _googleSignIn = GoogleSignIn.standard();

	String signedUpUserName;

	@override
	Stream<AuthenticatedUser> get user {
		return _firebaseAuth.onAuthStateChanged.map((firebaseUser) {
			return firebaseUser == null ? AuthenticatedUser.empty : _asAuthUser(firebaseUser);
		});
	}

	@override
	Future<void> logInWithEmailAndPassword({@required String email, @required String password}) async {
		assert(email != null && password != null);
		try {
			await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
		} on Exception {
			throw EmailLogInFailure();
		}
	}

	@override
	Future<void> signUp({@required String email, @required String password, String name = ''}) async {
		assert(email != null && password != null);
		signedUpUserName = name;
		var updateInfo = UserUpdateInfo();
		updateInfo.displayName = name;
		try {
			await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password).then((user) => user.user.updateProfile(updateInfo));
		} on Exception {
			throw SignUpFailure();
		}
	}

	@override
	Future<void> logInWithGoogle() async {
		try {
			final googleUser = await _googleSignIn.signIn();
			final googleAuth = await googleUser.authentication;
			final credential = GoogleAuthProvider.getCredential(
				accessToken: googleAuth.accessToken,
				idToken: googleAuth.idToken,
			);
			await _firebaseAuth.signInWithCredential(credential);
		} on Exception {
			throw GoogleLogInFailure();
		}
	}

	@override
	Future<void> logOut() async {
		try {
			await Future.wait([
				_firebaseAuth.signOut(),
				_googleSignIn.signOut(),
			]);
		} on Exception {
			throw LogOutFailure();
		}
	}

	AuthenticatedUser _asAuthUser(FirebaseUser user) {
	  var authUser = AuthenticatedUser(id: user.uid, email: user.email, name: user.displayName ?? signedUpUserName);
	  signedUpUserName = null;
	  return authUser;
	}
}
