import 'package:bloc/bloc.dart';
import 'package:bloc_extensions/bloc_extensions.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'reloadable_base.dart';

/// {@template reloadable_cubit}
/// A cubit that calls [reload] whenever its page becomes visible
/// {@endtemplate}
///
/// {@macro reloadable_description}
///
/// Example usage:
/// ```dart
/// class PageCubit extends ReloadableCubit<PageState> {
///   @override
///   final RouteObserver routeObserver;
///
///   PageCubit(this.routeObserver, ModalRoute route) : super(
///     initialState: PageState(),
///     route: route,
///   );
///
///   @override
///   Future reload(ReloadableReason reason) {...}
/// }
/// ```
abstract class ReloadableCubit<State> extends Cubit<State> with ReloadableBase {
  /// {@macro reloadable_cubit}
  ///
  /// {@macro reloadable_constructor_description}
  ReloadableCubit({
    required State initialState,
    required ModalRoute route,
  }) : super(initialState) {
    routeObserver.subscribe(this, route);
  }

  /// Performs the cubit reload
  ///
  /// {@macro reloadable_call}
  @protected
  Future reload(ReloadableReason reason);

  @protected
  void show(ReloadableReason reason) => reload(reason);
}
