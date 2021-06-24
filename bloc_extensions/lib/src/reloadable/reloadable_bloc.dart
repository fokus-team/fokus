import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';

import 'reloadable_base.dart';

/// {@template reloadable_bloc}
/// A bloc that creates reload events whenever its page becomes visible
/// {@endtemplate}
///
/// {@template reloadable_description}
/// In addition to triggering data loading when created
/// it allows to easily reload any required information
/// whenever the next page in the navigator stack is popped.
/// To do this a [RouteObserver] and a [ModalRoute] must be provided.
/// {@endtemplate}
abstract class ReloadableBloc<Event, State> extends Bloc<Event, State>
    with ReloadableBase {
  /// {@macro reloadable_bloc}
  ///
  /// {@template reloadable_constructor_description}
  /// Takes in the [initialState] to be set and the current
  /// [route] that will be bound to the reload events.
  /// {@endtemplate}
  ReloadableBloc({
    required State initialState,
    required ModalRoute route,
  }) : super(initialState) {
    routeObserver.subscribe(this, route);
  }

  /// Creates an instance of reload event
  ///
  /// {@template reloadable_call}
  /// Takes in a [reason] for triggering this reload which is
  /// either [ReloadableReason.push] or [ReloadableReason.popNext]
  /// {@endtemplate}
  @protected
  Event reloadEvent(ReloadableReason reason);

  @protected
  void show(ReloadableReason reason) => add(reloadEvent(reason));
}
