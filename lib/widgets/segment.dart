import 'package:flutter/material.dart';

import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/buttons/help_icon_button.dart';
import 'package:fokus/widgets/general/app_hero.dart';

class Segment extends StatelessWidget {
	final String title;
	final String subtitle;
	final String helpPage;
	final String noElementsMessage;
	final IconData noElementsIcon;
	final Widget noElementsAction;
	final List<Widget> elements;

	Segment({
		@required this.title, 
		this.subtitle, 
		this.helpPage, 
		@required this.elements,
		this.noElementsMessage,
		this.noElementsIcon,
		this.noElementsAction
	});

	Widget buildSectionHeader(BuildContext context) {
		return Padding(
			padding: EdgeInsets.only(
				left: AppBoxProperties.screenEdgePadding, 
				right: AppBoxProperties.screenEdgePadding,
				bottom: 4.0
			),
			child: Row(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				children: <Widget>[
					Expanded(
						child: Column(
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
							]
						)
					),
					if(helpPage != null)
						HelpIconButton(helpPage: helpPage, theme: Brightness.dark)
				]
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
					AppHero(
						title: AppLocales.of(context).translate(noElementsMessage),
						icon: noElementsIcon ?? Icons.local_florist,
						actionWidget: noElementsAction
					)
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
