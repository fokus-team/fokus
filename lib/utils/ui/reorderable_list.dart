// @dart = 2.10
import 'package:flutter/material.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'theme_config.dart';


Widget buildReorderableList<Type>({Widget header, Widget Function(Type) child, List<Type> items, Key Function(Type) getKey,
		void Function(Type, int) onReorderStarted, void Function(Type, int, int, List<Type>) onReorderFinished}) {
	return ImplicitlyAnimatedReorderableList<Type>(
		shrinkWrap: true,
		physics: NeverScrollableScrollPhysics(),
		items: items,
		areItemsTheSame: (a, b) => getKey(a) == getKey(b),
		onReorderStarted: onReorderStarted,
		onReorderFinished: onReorderFinished,
		insertDuration: AnimationsProperties.insertDuration,
		removeDuration: AnimationsProperties.removeDuration,
		reorderDuration: AnimationsProperties.dragDuration,
		itemBuilder: (_context, itemAnimation, item, index) {
			return Reorderable(
				key: getKey(item),
				builder: (context, dragAnimation, inDrag) {
					final offsetAnimation = Tween<Offset>(begin: Offset(-2.0, 0.0), end: Offset(0.0, 0.0)).animate(CurvedAnimation(
						curve: Interval(0.6, 1, curve: Curves.easeOutCubic),
						parent: itemAnimation,
					));
					return SizeTransition(
						axis: Axis.vertical,
						sizeFactor: CurvedAnimation(
							curve: Interval(0, 0.5, curve: Curves.easeOutCubic),
							parent: itemAnimation,
						),
						child: SlideTransition(
							position: offsetAnimation,
							child: Transform.scale(
								scale: 1.0 + 0.05*dragAnimation.value,
								child: child(item)
							)
						)
					);
				}
			);
		},
		header: header,
	);
}
