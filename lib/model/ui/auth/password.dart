import 'package:formz/formz.dart';

enum PasswordValidationError { empty, notLongEnough }

extension PasswordValidationErrorTextKey on PasswordValidationError {
	String get key => const {
		PasswordValidationError.empty: 'authentication.error.passwordEmpty',
		PasswordValidationError.notLongEnough: 'authentication.error.passwordNotLongEnough',
	}[this];
}

class Password extends FormzInput<String, PasswordValidationError> {
	static const int minPasswordLength = 8;
	final bool fullValidation;

	const Password.pure([String value = '', this.fullValidation = true]) : super.pure(value);
	const Password.dirty([String value = '', this.fullValidation = true]) : super.dirty(value);

	static final _lengthRegExp = RegExp(r'^[A-Za-z\d]{' + '$minPasswordLength' + r',}$');

	@override
	PasswordValidationError validator(String value) {
		if(value == null || value.isEmpty)
			return PasswordValidationError.empty;
		if(!fullValidation)
			return null;
		if (!_lengthRegExp.hasMatch(value))
			return PasswordValidationError.notLongEnough;
		return null;
	}
}
