import 'package:flutter/widgets.dart';
import 'package:fokus/logic/auth/auth_bloc/authentication_bloc.dart';
import 'package:fokus/logic/reloadable/reloadable_cubit.dart';
import 'package:fokus/services/app_config/app_config_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/model/ui/user/ui_child.dart';


class PreviousProfilesCubit extends ReloadableCubit {
	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final AppConfigRepository _appConfigRepository = GetIt.I<AppConfigRepository>();
	final AuthenticationBloc authenticationBloc;

  PreviousProfilesCubit(this.authenticationBloc, ModalRoute pageRoute) : super(pageRoute);

  void doLoadData() async {
	  var savedIds = _appConfigRepository.getSavedChildProfiles() ?? [];
	  var children = await _dataRepository.getUsers(ids: savedIds, fields: ['_id', 'name', 'avatar']);
	  emit(PreviousProfilesLoadSuccess(children.map((child) => UIChild.fromDBModel(child)).toList()));
  }

  void signIn(ObjectId childId) async {
		authenticationBloc.add(AuthenticationChildSignInRequested(await _dataRepository.getUser(id: childId)));
	}
}

class PreviousProfilesLoadSuccess extends DataLoadSuccess {
	final List<UIChild> previousProfiles;

	PreviousProfilesLoadSuccess(this.previousProfiles);

	@override
	List<Object> get props => [previousProfiles];
}
