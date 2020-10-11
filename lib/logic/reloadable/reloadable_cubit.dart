import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:fokus/logic/auth/auth_bloc/authentication_bloc.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/services/observers/active_user_update_observer.dart';
import 'package:get_it/get_it.dart';

part 'loadable_state.dart';

abstract class ReloadableCubit extends Cubit<LoadableState> with ActiveUserUpdateObserver implements RouteAware {
	final _routeObserver = GetIt.I<RouteObserver<PageRoute>>();
	final _navigatorKey = GetIt.I<GlobalKey<NavigatorState>>();

  ReloadableCubit(ModalRoute pageRoute, {bool observeUserUpdates = false}) : super(DataLoadInitial()) {
	  _routeObserver.subscribe(this, pageRoute);
	  if (observeUserUpdates)
	    _navigatorKey.currentState.context.bloc<AuthenticationBloc>().observeUserUpdates(this);
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
	void onUserUpdated(UIUser user) => doLoadData();

	@override
	Future<void> close() {
		_routeObserver.unsubscribe(this);
		return super.close();
	}

	@override
	void didPopNext() => reload();

	@override
	void didPop() {}

	@override
	void didPush() {}

	@override
	void didPushNext() {}
}
