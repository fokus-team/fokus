import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/model/notification/notification_type.dart';
import 'package:fokus/services/app_route_observer.dart';
import 'package:fokus/services/notifications/notification_service.dart';
import 'package:fokus/services/observers/data_update_observer.dart';

part 'loadable_state.dart';

enum ReloadableOption {
	doNotReloadOnPopNext
}

abstract class ReloadableCubit extends Cubit<LoadableState> with DataUpdateObserver implements RouteAware {
	final _routeObserver = GetIt.I<AppRouteObserver>();
	final NotificationService _notificationService = GetIt.I<NotificationService>();
	@protected
	final List<ReloadableOption> options;

  ReloadableCubit(ModalRoute pageRoute, {this.options = const []}) : super(DataLoadInitial()) {
	  _subscribeToUserChanges();
	  _routeObserver.subscribe(this, pageRoute);
  }

  void loadData() {
	  if (!(state is DataLoadInitial)) return;
	  emit(DataLoadInProgress());
	  doLoadData();
  }

  @protected
  void doLoadData();

  void reload() => emit(DataLoadInitial());

	@override
	void onDataUpdated(NotificationType type) => reload();

	void _subscribeToUserChanges() {
		if (dataTypeSubscription().isNotEmpty)
			_notificationService.observeDataUpdates(this);
	}

	@override
	Future<void> close() {
		_routeObserver.unsubscribe(this);
		return super.close();
	}

	@override
	void didPopNext() {
		_subscribeToUserChanges();
		if (!options.contains(ReloadableOption.doNotReloadOnPopNext))
	    reload();
	}

	@override
	void didPop() => _notificationService.removeDataUpdateObserver(this);

	@override
	void didPush() {}

	@override
	void didPushNext() => _notificationService.removeDataUpdateObserver(this);
}
