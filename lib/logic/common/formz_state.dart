import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

abstract class FormzState extends Equatable {
	final FormzStatus status;

  const FormzState(this.status);
}
