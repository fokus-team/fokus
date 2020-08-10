import 'package:formz/formz.dart';

enum PasswordValidationError { notLongEnough }

extension PasswordValidationErrorTextKey on PasswordValidationError {
	String get key => const {
		PasswordValidationError.notLongEnough: 'authentication.passwordNotLongEnough',
	}[this];
}

class Password extends FormzInput<String, PasswordValidationError> {
	static const int minPasswordLength = 8;
	final bool validate;

	const Password.pure([this.validate = true]) : super.pure('');
	const Password.dirty([String value = '', this.validate = true]) : super.dirty(value);

	static final _lengthRegExp = RegExp(r'^[A-Za-z\d]{' + '$minPasswordLength' + r',}$');

	@override
	PasswordValidationError validator(String value) {
		if (!validate)
			return null;
		if (!_lengthRegExp.hasMatch(value))
			return PasswordValidationError.notLongEnough;
		return null;
	}
}
