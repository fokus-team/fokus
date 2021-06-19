import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../../../model/db/user/child.dart';
import '../../../services/app_config/app_config_repository.dart';
import '../../../services/data/data_repository.dart';
import '../../common/auth_bloc/authentication_bloc.dart';
import '../../common/stateful/stateful_cubit.dart';

class SavedChildProfilesCubit extends StatefulCubit<SavedChildProfilesData> {
	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final AppConfigRepository _appConfigRepository = GetIt.I<AppConfigRepository>();
	final AuthenticationBloc authenticationBloc;

  SavedChildProfilesCubit(this.authenticationBloc, ModalRoute pageRoute) : super(pageRoute);

  @override
  Future load() => doLoad(body: () async {
	  var savedIds = _appConfigRepository.getSavedChildProfiles();
	  var children = await _dataRepository.getUsers(ids: savedIds, fields: ['_id', 'name', 'avatar']);
	  return SavedChildProfilesData(savedProfiles: children.map((child) => child as Child).toList());
  });

  Future signIn(ObjectId childId) => submit(body: () async {
	  authenticationBloc.add(AuthenticationChildSignInRequested((await _dataRepository.getUser(id: childId)) as Child));
	  return data!;
  });
}

class SavedChildProfilesData extends Equatable {
	final List<Child> savedProfiles;

	SavedChildProfilesData({required this.savedProfiles});

  @override
	List<Object?> get props => savedProfiles;
}
