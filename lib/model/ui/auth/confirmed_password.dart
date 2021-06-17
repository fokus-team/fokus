import 'package:formz/formz.dart';
import 'package:meta/meta.dart';

import 'password.dart';

enum RepeatedPasswordValidationError { noPasswordMatch }

extension RepeatedPassErrorTextKey on RepeatedPasswordValidationError {
	String get key => const {
		RepeatedPasswordValidationError.noPasswordMatch: 'authentication.error.noPasswordMatch',
	}[this]!;
}

@immutable
class ConfirmedPassword extends FormzInput<String, RepeatedPasswordValidationError> {
	final Password original;

	const ConfirmedPassword.pure({Password? original, String value = ''}) : original = original ?? const Password.pure(), super.pure(value);
	const ConfirmedPassword.dirty({required this.original, required String value}) : super.dirty(value);

	ConfirmedPassword copyDirty({Password? original, String? value}) {
		return ConfirmedPassword.dirty(
				original: original ?? this.original,
				value: value ?? this.value
		);
	}

	ConfirmedPassword copyPure({Password? original, String? value}) {
		return ConfirmedPassword.pure(
				original: original ?? this.original,
				value: value ?? this.value
		);
	}

	@override
  bool operator ==(Object other) {
		return super==(other) && other is ConfirmedPassword &&  original == other.original;
  }

	@override
	int get hashCode => super.hashCode ^ original.hashCode;

  @override
	RepeatedPasswordValidationError? validator(String? value) =>
		  value == original.value ? null : RepeatedPasswordValidationError.noPasswordMatch;
}
