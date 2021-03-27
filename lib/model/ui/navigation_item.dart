// @dart = 2.10
import 'package:flutter/material.dart';

import 'app_page.dart';

class AppBottomNavigationItem {
  final AppPage navigationRoute;
  final String title;
  final Icon icon;

  AppBottomNavigationItem({
	  @required this.navigationRoute,
    @required this.title,
    @required this.icon,
  });
}
