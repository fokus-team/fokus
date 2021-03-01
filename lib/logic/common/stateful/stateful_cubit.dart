import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';

import 'package:fokus/services/app_route_observer.dart';
import 'package:fokus/services/notifications/notification_service.dart';
import 'package:fokus/services/observers/page_foreground_observer.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/notification/notification_refresh_info.dart';
import 'package:fokus/services/observers/notification/notification_observer.dart';

part 'stateful_state.dart';

enum StatefulOption {
	resetSubmissionState, noAutoLoading, noDataLoading
}

abstract class StatefulCubit<State extends StatefulState> extends Cubit<State> with NotificationObserver implements RouteAware, PageForegroundObserver {
	final _routeObserver = GetIt.I<AppRouteObserver>();
	final NotificationService _notificationService = GetIt.I<NotificationService>();
	@protected
	final List<StatefulOption> options;
	@protected
	bool loadingForFirstTime = true;

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
		  loadingForFirstTime = false;
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
	@nonVirtual
	void onNotificationReceived(NotificationRefreshInfo info) {
		if (notificationTypeSubscription().contains(info.type) && shouldNotificationRefresh(info))
	    reload();
	}

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
		if (notificationTypeSubscription().isNotEmpty)
			_notificationService.observeNotifications(this);
		if (!firstTime)
			reload();
  }

	@override
	void onGoToBackground() {
		_notificationService.removeNotificationObserver(this);
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
