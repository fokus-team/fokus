import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/model/notification/notification_type.dart';
import 'package:fokus/services/app_route_observer.dart';
import 'package:fokus/services/notifications/notification_service.dart';
import 'package:fokus/services/observers/data_update_observer.dart';

part 'stateful_state.dart';

enum StatefulOption {
	skipOnPopNextReload, repeatableSubmission, noAutoLoading, noDataLoading
}

abstract class StatefulCubit extends Cubit<StatefulState> with DataUpdateObserver implements RouteAware {
	final _routeObserver = GetIt.I<AppRouteObserver>();
	final NotificationService _notificationService = GetIt.I<NotificationService>();
	@protected
	final List<StatefulOption> options;

  StatefulCubit(ModalRoute pageRoute, {this.options = const [], StatefulState initialState}) :
        super(initialState ?? StatefulState.notLoaded()) {
	  _subscribeToUserChanges();
	  _routeObserver.subscribe(this, pageRoute);
  }

  Future loadData() async {
	  if (state.loadingInProgress)
	  	return;
	  emit(StatefulState.notLoaded(DataLoadingState.loadingInProgress));
	  return doLoadData();
  }

  @protected
  Future doLoadData();

	void reload() => emit(StatefulState.notLoaded());

	void resetSubmissionState() => emit(state.withSubmitState(DataSubmissionState.notSubmitted));

	@override
	void onDataUpdated(NotificationType type) => reload();

	bool hasOption(StatefulOption option) => options.contains(option);

	void _subscribeToUserChanges() {
		if (dataTypeSubscription().isNotEmpty)
			_notificationService.observeDataUpdates(this);
	}

	bool beginSubmit() {
		if (!state.isNotSubmitted)
			return false;
		emit(state.withSubmitState(DataSubmissionState.submissionInProgress));
		return true;
	}

	@override
	Future<void> close() {
		_routeObserver.unsubscribe(this);
		return super.close();
	}

	@override
	void didPopNext() {
		_subscribeToUserChanges();
		if (!options.contains(StatefulOption.skipOnPopNextReload))
	    reload();
	}

	@override
	void didPop() => _notificationService.removeDataUpdateObserver(this);

	@override
	void didPush() {}

	@override
	void didPushNext() => _notificationService.removeDataUpdateObserver(this);
}
