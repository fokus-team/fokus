import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';

import 'reloadable_base.dart';

/// {@template reloadable_bloc}
/// A bloc that creates reload events whenever its page becomes visible
/// {@endtemplate}
///
/// {@template reloadable_description}
/// Solves the issue of outdated content when user loads back the page.
/// Automatically triggers data loading when first created
/// and whenever the next page in the navigator stack is popped.
/// It works by integrating with Flutters route observer subscription mechanism.
/// {@endtemplate}
///
/// Example usage:
/// ```dart
/// class PageBloc extends ReloadableBloc<PageEvent, PageState> {
///   @override
///   final RouteObserver routeObserver;
///
///   PageBloc(this.routeObserver, ModalRoute route) : super(
///     initialState: PageState(),
///     route: route,
///   );
///
///   @override
///   Event reloadEvent(ReloadableReason reason) => ReloadEvent(reason);
///
///   @override
///   Stream<PageEvent> mapEventToState(PageEvent event) async* {
///     if (event is ReloadEvent) {...}
///   }
/// }
/// ```
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
