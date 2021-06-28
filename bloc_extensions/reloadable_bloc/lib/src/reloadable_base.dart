import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// Contains reasons for triggering reloadable actions
enum ReloadableReason {
  /// Current route has been pushed triggering the first loading
  push,

  /// Next route has been popped triggering the a reload
  popNext,

  /// Current route has been popped and removed
  pop,

  /// Next route has been pushed hiding this one
  pushNext,

  /// Can be used for custom user calls
  other,
}

/// A base holding common functionality used by both reloadable cubit and bloc.
mixin ReloadableBase<State> on BlocBase<State> implements RouteAware {
  /// A registered route observer instance
  ///
  /// Providing an observer is necessary for this
  /// class to detect when a reload might be needed.
  @protected
  RouteObserver get routeObserver;

  /// Called whenever the current [Route] is shown on screen
  ///
  /// The [reason] (either [ReloadableReason.push] or
  /// [ReloadableReason.popNext]) for being shown is provided.
  /// This function is the right place for any operations that have
  /// to be performed whenever the current page appears on the screen.
  /// Default implementation of this function always triggers a reload.
  /// To customize this behaviour override it and decide when to call super.
  @protected
  void show(ReloadableReason reason);

  /// Called whenever the current [Route] stops being shown on screen
  ///
  /// The [reason] (either [ReloadableReason.pop] or
  /// [ReloadableReason.pushNext]) for being hidden is provided.
  /// This function is the right place for any operations that have
  /// to be performed whenever the current page disappears from the screen.
  @protected
  void hide(ReloadableReason reason) {}

  @override
  void didPopNext() => show(ReloadableReason.popNext);

  @override
  void didPush() => show(ReloadableReason.push);

  @override
  void didPop() => hide(ReloadableReason.pop);

  @override
  void didPushNext() => hide(ReloadableReason.pushNext);

  @override
  Future<void> close() {
    routeObserver.unsubscribe(this);
    return super.close();
  }
}
