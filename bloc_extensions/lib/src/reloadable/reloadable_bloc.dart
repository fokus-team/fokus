import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';

import 'reloadable_base.dart';

/// A bloc that creates reload events whenever its page becomes visible
///
/// {@template reloadable_description}
/// In addition to triggering data loading when created
/// it allows to easily reload any required information
/// whenever the next page in the navigator stack is popped.
/// To do this a [RouteObserver] and a [ModalRoute] must be provided.
/// {@endtemplate}
abstract class ReloadableBloc<Event, State> extends Bloc<Event, State>
    with ReloadableBase {
  ReloadableBloc({
    required State initialState,
    required ModalRoute route,
  }) : super(initialState) {
    routeObserver.subscribe(this, route);
  }

  @protected
  Event reloadEvent(ReloadableReason reason);

  @protected
  void show(ReloadableReason reason) => add(reloadEvent(reason));
}
