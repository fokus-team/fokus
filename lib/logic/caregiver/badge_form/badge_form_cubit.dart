import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fokus/logic/common/auth_bloc/authentication_bloc.dart';
import 'package:fokus/model/db/gamification/badge.dart';
import 'package:fokus/model/ui/form/badge_form_model.dart';
import 'package:fokus/model/ui/gamification/ui_badge.dart';
import 'package:fokus/model/ui/user/ui_caregiver.dart';
import 'package:fokus/services/analytics_service.dart';
import 'package:get_it/get_it.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/model/ui/user/ui_user.dart';

part 'badge_form_state.dart';

class BadgeFormCubit extends Cubit<BadgeFormState> {
	final ActiveUserFunction _activeUser;
	final AuthenticationBloc _authBloc;

	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final AnalyticsService _analyticsService = GetIt.I<AnalyticsService>();
	
  BadgeFormCubit(Object argument, this._activeUser, this._authBloc) : super(BadgeFormInitial());
  
  void submitBadgeForm(BadgeFormModel badgeForm) async {
  	if (state is! BadgeFormInitial)
  		return;
		emit(BadgeFormSubmissionInProgress(state));
		UICaregiver user = _activeUser();
		var badge = Badge.fromBadgeForm(badgeForm);
		await _dataRepository.createBadge(user.id, badge);
		_analyticsService.logBadgeCreated(badge);
		_authBloc.add(AuthenticationActiveUserUpdated(UICaregiver.from(user, badges: user.badges..add(UIBadge.fromDBModel(badge)))));
		emit(BadgeFormSubmissionSuccess(state));
  }

}
