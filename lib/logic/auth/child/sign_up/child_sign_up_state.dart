part of 'child_sign_up_cubit.dart';

class ChildSignUpState extends FormzState {
	final UserCode caregiverCode;
	final Name name;

	ChildSignUpState({
		this.caregiverCode = const UserCode.pure(),
		this.name = const Name.pure(),
		FormzStatus status = FormzStatus.pure
	}) : super(status);

	@override
	List<Object> get props => [caregiverCode, name];

	ChildSignUpState copyWith({UserCode caregiverCode, Name name, FormzStatus status}) {
		return ChildSignUpState(
			caregiverCode: caregiverCode ?? this.caregiverCode,
			name: name ?? this.name,
			status: status ?? this.status,
		);
	}
}
