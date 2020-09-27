import 'package:flutter/widgets.dart';
import 'package:fokus/model/ui/gamification/ui_badge.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/logic/reloadable/reloadable_cubit.dart';
import 'package:fokus/services/data/data_repository.dart';

class ChildBadgesCubit extends ReloadableCubit {
	final ActiveUserFunction _activeUser;
	final DataRepository _dataRepository = GetIt.I<DataRepository>();

  ChildBadgesCubit(this._activeUser, ModalRoute pageRoute) : super(pageRoute);

  void doLoadData() async {
	  var child = _activeUser();
		var badges = await _dataRepository.getChildBadges(childId: child.id);
	  emit(ChildBadgesLoadSuccess(badges.map((badge) => UIChildBadge.fromDBModel(badge)).toList()));
  }
}

class ChildBadgesLoadSuccess extends DataLoadSuccess {
	final List<UIChildBadge> badges;

	ChildBadgesLoadSuccess(this.badges);

	@override
	List<Object> get props => [badges];
}
