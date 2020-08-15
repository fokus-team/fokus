import 'package:flutter/material.dart';
import 'package:fokus/utils/app_locales.dart';

class FlexibleAppHeader extends StatelessWidget {
	final Widget flexibleSpaceWidget;
	final String pinnedTitle;
	final double expandedHeight;
	FlexibleAppHeader({this.flexibleSpaceWidget, @required this.pinnedTitle, @required this.expandedHeight});

	@override
	Widget build(BuildContext context) {
		return SliverAppBar(
			leading:
				IconButton(
					icon: Icon(Icons.chevron_left,
					color: Colors.white, size: 42,),
					onPressed: () => Navigator.of(context).pop(),
				),
			title: Text(AppLocales.of(context).translate(pinnedTitle)),
			pinned: true,
			primary: true,
			floating: true,
			expandedHeight: expandedHeight,
			flexibleSpace: FlexibleSpaceBar(
				background: SafeArea(
					child: Padding(
						padding: EdgeInsets.only(left: 48.0),
						child: Column(
							children: <Widget>[
								Container(height: 60,),
								if (flexibleSpaceWidget != null)
									flexibleSpaceWidget
							],
						),
					),
				),
			),
		);
	}
}
