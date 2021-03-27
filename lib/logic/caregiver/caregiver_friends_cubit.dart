// @dart = 2.10
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/common/auth_bloc/authentication_bloc.dart';
import 'package:fokus/logic/common/formz_state.dart';
import 'package:fokus/logic/common/user_code_verifier.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/model/ui/auth/user_code.dart';
import 'package:fokus/model/ui/user/ui_caregiver.dart';
import 'package:fokus_auth/fokus_auth.dart';
import 'package:formz/formz.dart';

import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:mongo_dart/mongo_dart.dart';

class CaregiverFriendsCubit extends Cubit<CaregiverFriendsState> with UserCodeVerifier<CaregiverFriendsState> {
	final ActiveUserFunction _activeUser;
	final AuthenticationBloc _authBloc;

  CaregiverFriendsCubit(this._activeUser, this._authBloc) : super(CaregiverFriendsState());

  Future addNewFriend() async {
	  if (this.state.status != FormzStatus.pure)
		  return;
	  var state = await _validateFields();
	  if (!state.status.isValidated) {
		  emit(state);
		  return;
	  }
	  emit(state.copyWith(status: FormzStatus.submissionInProgress));
    UICaregiver user = _activeUser();
  	var caregiverId = getIdFromCode(state.caregiverCode.value);
		var caregiverFriends = List.of(user.friends) ?? [];
		
		if(caregiverFriends.contains(caregiverId)) {
			emit(state.copyWith(status: FormzStatus.submissionFailure, error: 'caregiverAlreadyBefriendedError'));
		} else if(user.id == caregiverId) {
			emit(state.copyWith(status: FormzStatus.submissionFailure, error: 'enteredOwnCaregiverCodeError'));
		} else {
			var friends = caregiverFriends..add(caregiverId);
			await dataRepository.updateUser(user.id, friends: friends);
			_authBloc.add(AuthenticationActiveUserUpdated(UICaregiver.from(user, friends: friends)));
			emit(state.copyWith(status: FormzStatus.submissionSuccess));
		}
  }

	Future clearCode() async {
	  var state = this.state;
		emit(state.copyWith(caregiverCode: UserCode.pure('')));
	}

  Future<CaregiverFriendsState> _validateFields() async {
	  var state = this.state;
	  var caregiverField = UserCode.dirty(state.caregiverCode.value.trim());
	  if (caregiverField.valid && !(await verifyUserCode(state.caregiverCode.value.trim(), UserRole.caregiver)))
		  caregiverField = UserCode.dirty(state.caregiverCode.value.trim(), false);
	  state = state.copyWith(caregiverCode: caregiverField);
	  return state.copyWith(status: Formz.validate([state.caregiverCode]));
  }

	void caregiverCodeChanged(String value) => emit(state.copyWith(caregiverCode: UserCode.pure(value), status: FormzStatus.pure));
	
	void removeFriend(ObjectId friendID) async {
    UICaregiver user = _activeUser();
		var caregiverFriends = user.friends ?? [];
		await dataRepository.updateUser(user.id, friends: caregiverFriends..remove(friendID));
	}
}

class CaregiverFriendsState extends FormzState {
	final UserCode caregiverCode;
	final String error;

  CaregiverFriendsState({
	  this.caregiverCode = const UserCode.pure(),
		this.error,
    FormzStatus status = FormzStatus.pure
  }) : super(status);

  @override
  List<Object> get props => [caregiverCode, error, status];

  CaregiverFriendsState copyWith({UserCode caregiverCode, String error, FormzStatus status}) {
	  return CaregiverFriendsState(
		  caregiverCode: caregiverCode ?? this.caregiverCode,
			error: error ?? this.error,
		  status: status ?? this.status,
	  );
  }
}
