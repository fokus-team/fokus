import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';

import 'reloadable_base.dart';

abstract class ReloadableBloc<Event, State> extends Bloc<Event, State> with ReloadableBase {
	ReloadableBloc({required State initialState, required ModalRoute route}) : super(initialState) {
		routeObserver.subscribe(this, route);
	}

	@protected
	Event reloadEvent(ReloadReason reason);

	@protected
	void show(ReloadReason reason) => add(reloadEvent(reason));
}
