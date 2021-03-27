// @dart = 2.10
part of '../../../child/auth/sign_in/child_sign_in_cubit.dart';

class ChildSignInState extends FormzState {
	final UserCode childCode;

  ChildSignInState({
	  this.childCode = const UserCode.pure(),
    FormzStatus status = FormzStatus.pure
  }) : super(status);

  @override
  List<Object> get props => [childCode, status];

  ChildSignInState copyWith({UserCode childCode, FormzStatus status}) {
	  return ChildSignInState(
		  childCode: childCode ?? this.childCode,
		  status: status ?? this.status,
	  );
  }
}
