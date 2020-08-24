import 'package:flutter/material.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/services/app_locales.dart';

class PopupMenuList extends StatelessWidget {
  final List<UIButton> items;
	final bool lightTheme;

	PopupMenuList({this.items, this.lightTheme = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
			customBorder: new CircleBorder(),
			child: PopupMenuButton(
				onSelected: (Function a) => a(),
				icon: lightTheme ? Icon(Icons.more_vert, size: 26.0, color: Colors.white,) : Icon(Icons.more_vert, size: 26.0, color: Colors.black),
				itemBuilder: (BuildContext context) => _menuItemFactory(items,  context),
			)
		);
  }

  List<PopupMenuEntry<Function>> _menuItemFactory(List<UIButton> items, context) {
		List<PopupMenuEntry<Function>> popupMenuEntries = [];
  	for (var item in items) {
			popupMenuEntries.add(
				PopupMenuItem(
					value: item.action,
					child: Text(
						AppLocales.of(context).translate(item.textKey),
					),
				)
			);
		}
  	return popupMenuEntries;
	}
}
