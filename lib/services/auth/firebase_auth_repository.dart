import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import 'package:fokus/model/auth_user.dart';
import 'package:fokus/services/exception/auth_exceptions.dart';

import 'authentication_repository.dart';

class FirebaseAuthRepository implements AuthenticationRepository {
	final Logger _logger = Logger('FirebaseAuthRepository');

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
	Future<void> signInWithEmail({@required String email, @required String password}) async {
		assert(email != null && password != null);
		try {
			await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
		} catch (e) {
			EmailSignInError reason;
			if (e is PlatformException) {
				if (e.code == 'ERROR_WRONG_PASSWORD' || e.code == 'ERROR_USER_NOT_FOUND')
					reason = EmailSignInError.incorrectData;
				else if (e.code == 'ERROR_USER_DISABLED')
					reason = EmailSignInError.userDisabled;
				else
					_handleException('Sign In', e);
			}
			throw EmailSignInFailure(reason: reason);
		}
	}

	@override
	Future<void> signUpWithEmail({@required String email, @required String password, String name = ''}) async {
		assert(email != null && password != null);
		signedUpUserName = name;
		var updateInfo = UserUpdateInfo();
		updateInfo.displayName = name;
		try {
			await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password).then((user) => user.user.updateProfile(updateInfo));
		} catch (e) {
			EmailSignUpError reason;
			if (e is PlatformException) {
				if (e.code == 'ERROR_EMAIL_ALREADY_IN_USE')
					reason = EmailSignUpError.emailAlreadyUsed;
				else
					_handleException('Sign Up', e);
			}
			throw EmailSignUpFailure(reason: reason);
		}
	}

	@override
	Future<void> signInWithGoogle() async {
		try {
			final googleUser = await _googleSignIn.signIn();
			final googleAuth = await googleUser.authentication;
			final credential = GoogleAuthProvider.getCredential(
				accessToken: googleAuth.accessToken,
				idToken: googleAuth.idToken,
			);
			await _firebaseAuth.signInWithCredential(credential);
		} catch (e) {
			throw GoogleSignInFailure();
		}
	}

	@override
	Future<void> signOut() async {
		try {
			await Future.wait([
				_firebaseAuth.signOut(),
				_googleSignIn.signOut(),
			]);
		} catch (e) {
			throw SignOutFailure();
		}
	}

	AuthenticatedUser _asAuthUser(FirebaseUser user) {
	  var authUser = AuthenticatedUser(id: user.uid, email: user.email, name: user.displayName ?? signedUpUserName);
	  signedUpUserName = null;
	  return authUser;
	}

	void _handleException(String method, PlatformException exception) {
		_logger.warning('Firebase $method response: ${exception.code} ${exception.message}');
	}
}
