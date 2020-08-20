enum EmailSignUpError { emailAlreadyUsed, emailInvalid }

extension EmailSignUpErrorTextKey on EmailSignUpError {
	String get key => const {
		EmailSignUpError.emailAlreadyUsed: 'authentication.error.emailAlreadyUsed',
		EmailSignUpError.emailInvalid: 'authentication.error.emailInvalid',
	}[this];
	String get errorCode => const {
		EmailSignUpError.emailAlreadyUsed: 'ERROR_EMAIL_ALREADY_IN_USE',
		EmailSignUpError.emailInvalid: 'ERROR_INVALID_EMAIL',
	}[this];
}

class EmailSignUpFailure implements Exception {
	final EmailSignUpError reason;

  EmailSignUpFailure({this.reason});
}

enum EmailSignInError { wrongPassword, userNotFound, userDisabled }

extension EmailSignInErrorTextKey on EmailSignInError {
	String get key => const {
		EmailSignInError.wrongPassword: 'authentication.error.incorrectData',
		EmailSignInError.userNotFound: 'authentication.error.incorrectData',
		EmailSignInError.userDisabled: 'authentication.error.userDisabled',
	}[this];
	String get errorCode => const {
		EmailSignInError.wrongPassword: 'ERROR_WRONG_PASSWORD',
		EmailSignInError.userNotFound: 'ERROR_USER_NOT_FOUND',
		EmailSignInError.userDisabled: 'ERROR_USER_DISABLED',
	}[this];
}

class EmailSignInFailure implements Exception {
	final EmailSignInError reason;

  EmailSignInFailure({this.reason});
}

class GoogleSignInFailure implements Exception {}

class SignOutFailure implements Exception {}
