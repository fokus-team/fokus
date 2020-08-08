import 'package:flutter/material.dart';

import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/dialog_utils.dart';
import 'package:fokus/utils/theme_config.dart';

class Segment extends StatelessWidget {
	final String title;
	final String subtitle;
	final String helpPage;
	final String noElementsMessage;
	final Widget noElementsAction;
	final List<Widget> elements;

	Segment({
		@required this.title, 
		this.subtitle, 
		this.helpPage, 
		@required this.elements,
		this.noElementsMessage,
		this.noElementsAction
	});

	Widget buildSectionHeader(BuildContext context) {
		return Padding(
			padding: EdgeInsets.only(
				left: AppBoxProperties.screenEdgePadding, 
				right: AppBoxProperties.screenEdgePadding
			),
			child: Row(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				children: <Widget>[
					Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: <Widget>[
							Text(
								AppLocales.of(context).translate(title),
								style: Theme.of(context).textTheme.headline2,
								overflow: TextOverflow.clip,
								maxLines: 2
							),
							if(subtitle != null)
								Text(
									AppLocales.of(context).translate(subtitle),
									style: Theme.of(context).textTheme.subtitle2,
									overflow: TextOverflow.ellipsis,
									maxLines: 3
								)
						],
					),
					if(helpPage != null)
						Tooltip(
							message: AppLocales.of(context).translate('actions.help'),
							child: InkWell(
								customBorder: new CircleBorder(),
								onTap: () => { showHelpDialog(context, helpPage) },
								child: Padding(
									padding: EdgeInsets.all(8.0),
									child:Icon(
										Icons.help_outline,
										size: 26.0,
										color: AppColors.darkTextColor
									)
								)
							)
						)
				],
			),
		);
	}

	Widget buildNoElementsInfo(BuildContext context) {
		return Padding(
			padding: EdgeInsets.symmetric(vertical: 20.0),
			child: Center(
				child: Column(
					children: <Widget>[
						Text(
							AppLocales.of(context).translate(noElementsMessage),
							maxLines: 3,
							overflow: TextOverflow.ellipsis
						),
						if(noElementsAction != null)
							noElementsAction
					]
				)
			)
		);
	}

	@override
	Widget build(BuildContext context) {
		return ListView(
			shrinkWrap: true,
			padding: EdgeInsets.only(top: AppBoxProperties.sectionPadding),
			physics: BouncingScrollPhysics(),
			children: <Widget>[
				buildSectionHeader(context),
				if(elements.length > 0)
					...elements
				else if(noElementsMessage != null)
					buildNoElementsInfo(context)
			]
		);
	}

}

class AppSegments extends StatelessWidget {
	final List<Widget> segments;

	AppSegments({@required this.segments});
	
	@override
	Widget build(BuildContext context) {
		return Container(
			child: Expanded(
				child: ListView(
					padding: EdgeInsets.zero,
					physics: BouncingScrollPhysics(),
					children: <Widget>[
						...segments,
						SizedBox(height: 30.0)
					]
				)
			)
		);
	}

}
