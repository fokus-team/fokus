import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

enum ReloadReason {
	push, popNext, other
}

mixin ReloadableBase<State> on BlocBase<State> implements RouteAware {
	@protected
	RouteObserver get routeObserver;

	@protected
	void show(ReloadReason reason);

	@protected
	void hide() {}

	@override
	@nonVirtual
	void didPopNext() => show(ReloadReason.popNext);

	@override
	@nonVirtual
	void didPush() => show(ReloadReason.push);

	@override
	@nonVirtual
	void didPop() => hide();

	@override
	@nonVirtual
	void didPushNext() => hide();

	@override
	Future<void> close() {
		routeObserver.unsubscribe(this);
		return super.close();
	}
}
