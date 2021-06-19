import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import '../../../model/db/gamification/badge.dart';
import '../../../model/db/user/caregiver.dart';
import '../../../model/ui/form/badge_form_model.dart';
import '../../../services/analytics_service.dart';
import '../../../services/data/data_repository.dart';
import '../../common/auth_bloc/authentication_bloc.dart';
import '../../common/cubit_base.dart';

class BadgeFormCubit extends CubitBase {
	final AuthenticationBloc _authBloc;

	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final AnalyticsService _analyticsService = GetIt.I<AnalyticsService>();
	
  BadgeFormCubit(this._authBloc, ModalRoute pageRoute) : super(pageRoute);
  
  Future submitBadgeForm(BadgeFormModel badgeForm) => submit(body: () async {
	  var user = activeUser! as Caregiver;
	  var badge = Badge.fromBadgeForm(badgeForm);
	  await _dataRepository.createBadge(user.id!, badge);
	  _analyticsService.logBadgeCreated(badge);
	  _authBloc.add(AuthenticationActiveUserUpdated(Caregiver.copyFrom(user, badges: user.badges!..add(badge))));
  });
}
