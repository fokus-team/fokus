enum EmailSignUpError { emailAlreadyUsed }

extension EmailSignUpErrorTextKey on EmailSignUpError {
	String get key => const {
		EmailSignUpError.emailAlreadyUsed: 'authentication.error.emailAlreadyUsed',
	}[this];
}

class EmailSignUpFailure implements Exception {
	final EmailSignUpError reason;

  EmailSignUpFailure({this.reason});
}

enum EmailSignInError { incorrectData, userDisabled }

extension EmailSignInErrorTextKey on EmailSignInError {
	String get key => const {
		EmailSignInError.incorrectData: 'authentication.error.incorrectData',
		EmailSignInError.userDisabled: 'authentication.error.userDisabled',
	}[this];
}

class EmailSignInFailure implements Exception {
	final EmailSignInError reason;

  EmailSignInFailure({this.reason});
}

class GoogleSignInFailure implements Exception {}

class SignOutFailure implements Exception {}
