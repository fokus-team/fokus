import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';

import 'loadable_cubit.dart';

abstract class ReloadableCubit<State> extends Cubit<State> implements LoadableCubit, RouteAware {
	@protected
	RouteObserver get routeObserver;

	ReloadableCubit({required State initialState, required ModalRoute route}) : super(initialState) {
		routeObserver.subscribe(this, route);
	}

	@protected
	@mustCallSuper
	void show() => loadData();

	@protected
	void hide();

	@override
	void didPopNext() => loadData();

	@override
	void didPush() => loadData();

	@override
	void didPop() => hide();

	@override
	void didPushNext() => hide();

	@override
	Future<void> close() {
		routeObserver.unsubscribe(this);
		return super.close();
	}
}
