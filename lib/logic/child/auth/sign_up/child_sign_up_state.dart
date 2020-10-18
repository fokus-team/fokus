part of 'child_sign_up_cubit.dart';

class ChildSignUpState extends FormzState {
	final Set<int> takenAvatars;

	final UserCode caregiverCode;
	final int avatar;
	final Name name;

	ChildSignUpState({
		this.caregiverCode = const UserCode.pure(),
		this.name = const Name.pure(),
		this.avatar,
		this.takenAvatars = const {},
		FormzStatus status = FormzStatus.pure
	}) : super(status);

	@override
	List<Object> get props => [caregiverCode, name, avatar, status, takenAvatars];

	ChildSignUpState copyWith({UserCode caregiverCode, Name name, int avatar, Set<int> takenAvatars, FormzStatus status, bool clearableAvatar = false}) {
		return ChildSignUpState(
			caregiverCode: caregiverCode ?? this.caregiverCode,
			avatar: clearableAvatar ? avatar : (avatar ?? this.avatar),
			name: name ?? this.name,
			status: status ?? this.status,
			takenAvatars: takenAvatars ?? this.takenAvatars
		);
	}
}
