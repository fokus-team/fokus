import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';

import 'package:fokus/model/auth_user.dart';
import 'package:fokus/services/exception/auth_exceptions.dart';

import 'authentication_repository.dart';

class FirebaseAuthRepository implements AuthenticationRepository {
	final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
	final GoogleSignIn _googleSignIn = GoogleSignIn.standard();

	@override
	Stream<AuthUser> get user {
		return _firebaseAuth.onAuthStateChanged.map((firebaseUser) {
			return firebaseUser == null ? AuthUser.empty : firebaseUser.toUser;
		});
	}

	@override
	Future<void> logInWithEmailAndPassword({@required String email, @required String password}) async {
		assert(email != null && password != null);
		try {
			await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password,);
		} on Exception {
			throw EmailLogInFailure();
		}
	}

	@override
	Future<void> signUp({@required String email, @required String password}) async {
		assert(email != null && password != null);
		try {
			await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
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
}

extension on FirebaseUser {
	AuthUser get toUser {
		return AuthUser(id: uid);
	}
}
