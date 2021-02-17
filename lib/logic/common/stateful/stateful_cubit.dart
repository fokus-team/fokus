import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/model/notification/notification_type.dart';
import 'package:fokus/services/app_route_observer.dart';
import 'package:fokus/services/notifications/notification_service.dart';
import 'package:fokus/services/observers/page_foreground_observer.dart';
import 'package:fokus/model/pages/plan_form_params.dart';
import 'package:fokus/services/observers/data_update_observer.dart';

part 'stateful_state.dart';

enum StatefulOption {
	noOnPopNextReload, repeatableSubmission, noAutoLoading, noDataLoading
}

abstract class StatefulCubit<State extends StatefulState> extends Cubit<State> with DataUpdateObserver implements RouteAware, PageForegroundObserver {
	final _routeObserver = GetIt.I<AppRouteObserver>();
	final NotificationService _notificationService = GetIt.I<NotificationService>();
	@protected
	final List<StatefulOption> options;

	StreamSubscription<ConnectivityResult> _connectionListener;

  StatefulCubit(ModalRoute pageRoute, {this.options = const [], StatefulState initialState}) :
        super(initialState ?? StatefulState.notLoaded()) {
	  onGoToForeground(firstTime: true);
	  _routeObserver.subscribe(this, pageRoute);
  }

  Future loadData() async {
	  if (state.loadingInProgress)
	  	return;
	  emit(state.loading());
	  try {
		  await doLoadData();
	  } on Exception catch (e) {
		  emit(state.withLoadState(DataLoadingState.loadFailure));
		  throw e;
	  }
  }

  @protected
  Future doLoadData();

	void reload() => emit(state.notLoaded());

	void resetSubmissionState() => emit(state.notSubmitted());

	@override
	void onDataUpdated(NotificationType type) => reload();

	bool hasOption(StatefulOption option) => options.contains(option);

	bool beginSubmit([State state]) {
		state ??= this.state;
		if (!state.isNotSubmitted)
			return false;
		emit(state.submit());
		return true;
	}

	@override
	Future<void> close() {
		_routeObserver.unsubscribe(this);
		return super.close();
	}

	@override
  void onGoToForeground({bool firstTime = false}) {
		if (dataTypeSubscription().isNotEmpty)
			_notificationService.observeDataUpdates(this);
		if (_connectionListener == null)
			_connectionListener = Connectivity().onConnectivityChanged.listen((event) {
				if (event != ConnectivityResult.none)
					reload();
			});
		if (!firstTime && !options.contains(StatefulOption.noOnPopNextReload))
			reload();
  }

	@override
	void onGoToBackground() {
		if (_connectionListener != null) {
			_connectionListener.cancel();
			_connectionListener = null;
		}
		_notificationService.removeDataUpdateObserver(this);
	}

  @override
	void didPopNext() => onGoToForeground();

	@override
	void didPop() => onGoToBackground();

	@override
	void didPush() {}

	@override
	void didPushNext() => onGoToBackground();
}
