import 'package:flutter/widgets.dart';
import 'package:fokus/logic/common/stateful/stateful_cubit.dart';
import 'package:fokus/model/db/user/caregiver.dart';
import 'package:fokus/model/db/user/child.dart';
import 'package:fokus/model/notification/notification_type.dart';
import 'package:fokus/services/ui_data_aggregator.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/model/ui/user/ui_child.dart';
import 'package:fokus/model/db/user/user_role.dart';

class CaregiverPanelCubit extends StatefulCubit {
	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final UIDataAggregator _dataAggregator = GetIt.I<UIDataAggregator>();

  CaregiverPanelCubit(ModalRoute pageRoute) : super(pageRoute);

  Future doLoadData() async {
  	Caregiver _activeUser = activeUser as Caregiver;
	  var children = (await _dataRepository.getUsers(connected: _activeUser.id, role: UserRole.child)).map((e) => e as Child).toList();
	  var uiChildren = await _dataAggregator.loadChildren(children);
	  Map<ObjectId, String>? friends;
	  if (_activeUser.friends != null && _activeUser.friends!.isNotEmpty)
		  friends = await _dataRepository.getUserNames(_activeUser.friends!);
	  emit(CaregiverPanelState(uiChildren, friends));
  }

	@override
	List<NotificationType> notificationTypeSubscription() => [NotificationType.rewardBought];
}

class CaregiverPanelState extends StatefulState {
	final List<UIChild> children;
	final Map<ObjectId, String>? friends;

	CaregiverPanelState(this.children, this.friends) : super.loaded();

	@override
	List<Object?> get props => super.props..addAll([children, friends]);
}
