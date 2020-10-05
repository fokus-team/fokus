import 'package:flutter/widgets.dart';
import 'package:fokus/model/ui/gamification/ui_badge.dart';
import 'package:fokus/model/ui/user/ui_child.dart';

import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/logic/reloadable/reloadable_cubit.dart';

class ChildBadgesCubit extends ReloadableCubit {
	final ActiveUserFunction _activeUser;

  ChildBadgesCubit(this._activeUser, ModalRoute pageRoute) : super(pageRoute);

  void doLoadData() {
	  UIChild child = _activeUser();
	  emit(ChildBadgesLoadSuccess(child.badges));
  }
}

class ChildBadgesLoadSuccess extends DataLoadSuccess {
	final List<UIChildBadge> badges;

	ChildBadgesLoadSuccess(this.badges);

	@override
	List<Object> get props => [badges];
}
