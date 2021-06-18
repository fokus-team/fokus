import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../../../model/db/user/child.dart';
import '../../../services/app_config/app_config_repository.dart';
import '../../../services/data/data_repository.dart';
import '../../common/auth_bloc/authentication_bloc.dart';
import '../../common/stateful/stateful_cubit.dart';

class SavedChildProfilesCubit extends StatefulCubit {
	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final AppConfigRepository _appConfigRepository = GetIt.I<AppConfigRepository>();
	final AuthenticationBloc authenticationBloc;

  SavedChildProfilesCubit(this.authenticationBloc, ModalRoute pageRoute) : super(pageRoute);

  @override
  Future doLoadData() async {
	  var savedIds = _appConfigRepository.getSavedChildProfiles();
	  var children = await _dataRepository.getUsers(ids: savedIds, fields: ['_id', 'name', 'avatar']);
	  emit(SavedChildProfilesState(savedProfiles: children.map((child) => child as Child).toList()));
  }

  Future signIn(ObjectId childId) => submitData(body: () async {
	  authenticationBloc.add(AuthenticationChildSignInRequested((await _dataRepository.getUser(id: childId)) as Child));
  });
}

class SavedChildProfilesState extends StatefulState {
	final List<Child> savedProfiles;

	SavedChildProfilesState({required this.savedProfiles, DataSubmissionState? submissionState}) : super.loaded(submissionState);

	@override
  StatefulState withSubmitState(DataSubmissionState submissionState) => SavedChildProfilesState(savedProfiles: savedProfiles, submissionState: submissionState);

  @override
	List<Object?> get props => super.props..add(savedProfiles);
}
