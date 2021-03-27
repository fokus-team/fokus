// @dart = 2.10
part of 'name_change_cubit.dart';

class NameChangeState extends FormzState {
	final Name name;

  const NameChangeState({
	  this.name = const Name.pure(),
	  FormzStatus status = FormzStatus.pure,
	}) : super(status);

	NameChangeState copyWith({Name name, FormzStatus status}) {
		return NameChangeState(
			name: name ?? this.name,
			status: status ?? this.status,
		);
	}

	@override
	List<Object> get props => [name, status];
}
