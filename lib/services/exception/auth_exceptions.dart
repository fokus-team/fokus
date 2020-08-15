enum EmailSignInError { incorrectData, userDisabled }
enum EmailSignUpError { emailAlreadyUsed }

class EmailSignUpFailure implements Exception {
	final EmailSignUpError reason;

  EmailSignUpFailure({this.reason});
}

class EmailSignInFailure implements Exception {
	final EmailSignInError reason;

  EmailSignInFailure({this.reason});
}

class GoogleSignInFailure implements Exception {}

class SignOutFailure implements Exception {}
