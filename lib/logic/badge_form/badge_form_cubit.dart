import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fokus/model/db/gamification/badge.dart';
import 'package:fokus/model/ui/form/badge_form_model.dart';
import 'package:get_it/get_it.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/model/ui/user/ui_user.dart';

part 'badge_form_state.dart';

class BadgeFormCubit extends Cubit<BadgeFormState> {
	final ActiveUserFunction _activeUser;
	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	
  BadgeFormCubit(Object argument, this._activeUser) : super(BadgeFormInitial());
  
  void submitBadgeForm(BadgeFormModel badgeForm) async {
		emit(BadgeFormSubmissionInProgress(state));
		var userId = _activeUser().id;
		var badge = Badge.fromBadgeForm(badgeForm);
		await _dataRepository.createBadge(userId, badge);
		emit(BadgeFormSubmissionSuccess(state));
  }

}
