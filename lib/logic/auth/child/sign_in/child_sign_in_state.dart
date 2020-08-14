part of 'child_sign_in_cubit.dart';

class ChildSignInState extends FormzState {
	final List<UIChild> savedChildren;

	final UserCode childCode;

  ChildSignInState({
	  this.savedChildren,
	  this.childCode = const UserCode.pure(),
    FormzStatus status = FormzStatus.pure
  }) : super(status);

  @override
  List<Object> get props => [childCode, savedChildren];

  ChildSignInState copyWith({UserCode childCode, FormzStatus status}) {
	  return ChildSignInState(
		  childCode: childCode ?? this.childCode,
		  status: status ?? this.status,
		  savedChildren: savedChildren
	  );
  }
}
