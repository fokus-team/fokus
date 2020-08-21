import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

part 'loadable_state.dart';

abstract class ReloadableCubit extends Cubit<LoadableState> implements RouteAware {
	final _routeObserver = GetIt.I<RouteObserver<PageRoute>>();

  ReloadableCubit(ModalRoute pageRoute) : super(DataLoadInitial()) {
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
