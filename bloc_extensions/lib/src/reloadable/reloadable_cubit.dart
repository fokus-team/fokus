import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'reloadable_base.dart';

/// A cubit that calls [reload] whenever its page becomes visible
///
/// {@macro reloadable_description}
abstract class ReloadableCubit<State> extends Cubit<State> with ReloadableBase {
  ReloadableCubit({
    required State initialState,
    required ModalRoute route,
  }) : super(initialState) {
    routeObserver.subscribe(this, route);
  }

  @protected
  Future reload(ReloadableReason reason);

  @protected
  void show(ReloadableReason reason) => reload(reason);
}
