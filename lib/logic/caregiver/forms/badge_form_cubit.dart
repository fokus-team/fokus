import 'package:flutter/widgets.dart';
import 'package:fokus/logic/common/auth_bloc/authentication_bloc.dart';
import 'package:fokus/logic/common/stateful/stateful_cubit.dart';
import 'package:fokus/model/db/gamification/badge.dart';
import 'package:fokus/model/db/user/caregiver.dart';
import 'package:fokus/model/ui/form/badge_form_model.dart';
import 'package:fokus/services/analytics_service.dart';
import 'package:get_it/get_it.dart';
import 'package:fokus/services/data/data_repository.dart';

class BadgeFormCubit extends StatefulCubit {
	final AuthenticationBloc _authBloc;

	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final AnalyticsService _analyticsService = GetIt.I<AnalyticsService>();
	
  BadgeFormCubit(this._authBloc, ModalRoute pageRoute) : super(pageRoute);
  
  void submitBadgeForm(BadgeFormModel badgeForm) async {
  	if (!beginSubmit())
  		return;
		var user = activeUser! as Caregiver;
		var badge = Badge.fromBadgeForm(badgeForm);
		await _dataRepository.createBadge(user.id!, badge);
		_analyticsService.logBadgeCreated(badge);
		_authBloc.add(AuthenticationActiveUserUpdated(Caregiver.copyFrom(user, badges: user.badges!..add(badge))));
    emit(state.submissionSuccess());
  }

  @override
  Future doLoadData() async => emit(StatefulState.loaded());
}
