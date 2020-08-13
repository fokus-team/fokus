import 'package:formz/formz.dart';

enum UserCodeValidationError { toShort, toLong }

extension UserCodeValidationErrorTextKey on UserCodeValidationError {
	String get key => const {
		UserCodeValidationError.toShort: 'authentication.userCodeToShort',
		UserCodeValidationError.toLong: 'authentication.userCodeToLong',
	}[this];
}

class UserCode extends FormzInput<String, UserCodeValidationError> {
	static const int userCodeLength = 24;

	const UserCode.pure() : super.pure('');
	const UserCode.dirty([String value = '']) : super.dirty(value);

	@override
	UserCodeValidationError validator(String value) {
	  if (value.length == userCodeLength)
	  	return null;
	  return value.length < userCodeLength ? UserCodeValidationError.toShort : UserCodeValidationError.toLong;
	}
}
