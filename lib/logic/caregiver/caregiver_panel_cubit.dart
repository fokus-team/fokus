import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../../model/db/user/caregiver.dart';
import '../../model/db/user/child.dart';
import '../../model/db/user/user_role.dart';
import '../../model/notification/notification_type.dart';
import '../../model/ui/child_card_model.dart';
import '../../services/data/data_repository.dart';
import '../../services/model_helpers/ui_data_aggregator.dart';
import '../common/stateful/stateful_cubit.dart';

class CaregiverPanelCubit extends StatefulCubit<CaregiverPanelData> {
	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final UIDataAggregator _dataAggregator = GetIt.I<UIDataAggregator>();

  CaregiverPanelCubit(ModalRoute pageRoute) : super(pageRoute);

  @override
  Future load() => doLoad(body: () async {
  	var _activeUser = activeUser as Caregiver;
	  var children = (await _dataRepository.getUsers(connected: _activeUser.id, role: UserRole.child)).map((e) => e as Child).toList();
	  var uiChildren = await _dataAggregator.loadChildCards(children);
	  Map<ObjectId, String>? friends;
	  if (_activeUser.friends != null && _activeUser.friends!.isNotEmpty)
		  friends = await _dataRepository.getUserNames(_activeUser.friends!);
	  return CaregiverPanelData(uiChildren, friends);
  });

	@override
	List<NotificationType> notificationTypeSubscription() => [NotificationType.rewardBought];
}

class CaregiverPanelData extends Equatable {
	final List<ChildCardModel> childCards;
	final Map<ObjectId, String>? friends;

	CaregiverPanelData(this.childCards, this.friends);

	@override
	List<Object?> get props => [childCards, friends];
}
