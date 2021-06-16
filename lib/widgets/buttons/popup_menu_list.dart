import 'package:flutter/material.dart';
import '../../model/ui/ui_button.dart';
import '../../services/app_locales.dart';

class PopupMenuList extends StatelessWidget {
  final List<UIButton> items;
	final bool lightTheme;
	final bool includeDivider;
	final IconData customIcon;
	final String? tooltip;

	PopupMenuList({required this.items, this.lightTheme = false, this.includeDivider = false, this.customIcon = Icons.more_vert, this.tooltip});

  @override
  Widget build(BuildContext context) {
    return InkWell(
			customBorder: CircleBorder(),
			child: PopupMenuButton(
				tooltip: tooltip,
				onSelected: (Function a) => a(),
				icon: lightTheme ? Icon(customIcon, size: 26.0, color: Colors.white,) : Icon(customIcon, size: 26.0, color: Colors.black),
				itemBuilder: (BuildContext context) => _menuItemFactory(items,  context),
			)
		);
  }

  List<PopupMenuEntry<Function>> _menuItemFactory(List<UIButton> items, context) {
		var popupMenuEntries = <PopupMenuEntry<Function>>[];
  	for (var item in items) {
			popupMenuEntries.add(
				PopupMenuItem(
					value: item.action,
					child: Row(
						children: <Widget>[
							Padding(
								padding: EdgeInsets.only(right: 10.0),
								child: Icon(item.icon, color: Colors.grey[600])
							),
							Text(AppLocales.of(context).translate(item.textKey)),
						]
					)
				)
			);
			if(includeDivider && popupMenuEntries.length > 1)
				popupMenuEntries.insert(popupMenuEntries.length-1, PopupMenuDivider());
		}
  	return popupMenuEntries;
	}
}
