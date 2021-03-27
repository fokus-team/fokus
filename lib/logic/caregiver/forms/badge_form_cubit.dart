// @dart = 2.10
import 'package:flutter/widgets.dart';
import 'package:fokus/logic/common/auth_bloc/authentication_bloc.dart';
import 'package:fokus/logic/common/stateful/stateful_cubit.dart';
import 'package:fokus/model/db/gamification/badge.dart';
import 'package:fokus/model/ui/form/badge_form_model.dart';
import 'package:fokus/model/ui/gamification/ui_badge.dart';
import 'package:fokus/model/ui/user/ui_caregiver.dart';
import 'package:fokus/services/analytics_service.dart';
import 'package:get_it/get_it.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/model/ui/user/ui_user.dart';

class BadgeFormCubit extends StatefulCubit {
	final ActiveUserFunction _activeUser;
	final AuthenticationBloc _authBloc;

	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final AnalyticsService _analyticsService = GetIt.I<AnalyticsService>();
	
  BadgeFormCubit(this._activeUser, this._authBloc, ModalRoute pageRoute) : super(pageRoute);
  
  void submitBadgeForm(BadgeFormModel badgeForm) async {
  	if (!beginSubmit())
  		return;
		UICaregiver user = _activeUser();
		var badge = Badge.fromBadgeForm(badgeForm);
		await _dataRepository.createBadge(user.id, badge);
		_analyticsService.logBadgeCreated(badge);
		_authBloc.add(AuthenticationActiveUserUpdated(UICaregiver.from(user, badges: user.badges..add(UIBadge.fromDBModel(badge)))));
    emit(state.submissionSuccess());
  }

  @override
  Future doLoadData() async => emit(StatefulState.loaded());
}
