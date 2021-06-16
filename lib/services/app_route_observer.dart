import 'dart:async';

import 'package:flutter/widgets.dart';

class AppRouteObserver extends RouteObserver<PageRoute> {
  final Completer<void> _navigatorInitialized = Completer();
  Future<void> get navigatorInitialized => _navigatorInitialized.future;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (!_navigatorInitialized.isCompleted)
      _navigatorInitialized.complete();
  }
}
