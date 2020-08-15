import 'package:formz/formz.dart';

enum UserCodeValidationError { toShort, toLong, noSuchUser }

extension UserCodeValidationErrorTextKey on UserCodeValidationError {
	String get key => const {
		UserCodeValidationError.toShort: 'authentication.userCodeToShort',
		UserCodeValidationError.toLong: 'authentication.userCodeToLong',
		UserCodeValidationError.noSuchUser: 'authentication.noSuchUser',
	}[this];
}

class UserCode extends FormzInput<String, UserCodeValidationError> {
	static const int userCodeLength = 24;
	final bool exists;

	const UserCode.pure() : exists = true, super.pure('');
	const UserCode.dirty([String value = '', this.exists = true]) : super.dirty(value);

	@override
	UserCodeValidationError validator(String value) {
		if (!exists)
			return UserCodeValidationError.noSuchUser;
	  if (value.length == userCodeLength)
	  	return null;
	  return value.length < userCodeLength ? UserCodeValidationError.toShort : UserCodeValidationError.toLong;
	}
}
