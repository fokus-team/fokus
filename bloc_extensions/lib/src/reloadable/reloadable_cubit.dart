import 'package:bloc/bloc.dart';
import 'package:bloc_extensions/src/reloadable/reloadable_base.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

abstract class ReloadableCubit<State> extends Cubit<State> with ReloadableBase {
	ReloadableCubit({required State initialState, required ModalRoute route}) : super(initialState) {
		routeObserver.subscribe(this, route);
	}

	@protected
	Future reload(ReloadReason reason);

	@protected
	void show(ReloadReason reason) => reload(reason);
}
