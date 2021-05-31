import 'package:flutter/material.dart';
import 'package:round_spot/round_spot.dart' as round_spot;

import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/widgets/general/app_hero.dart';

class Segment extends StatelessWidget {
	final String title;
	final Map<String, Object>? titleArgs;
	final String? subtitle;
	final UIButton? headerAction;
	final String? noElementsMessage;
	final IconData? noElementsIcon;
	final Widget? noElementsAction;
	final List<Widget>? elements;
	final Widget? customContent;

	Segment({
		required this.title,
		this.titleArgs,
		this.subtitle, 
		this.headerAction, 
		this.elements,
		this.noElementsMessage,
		this.noElementsIcon,
		this.noElementsAction,
		this.customContent
	});

	Widget buildSectionHeader(BuildContext context) {
		return Padding(
			padding: EdgeInsets.only(
				left: AppBoxProperties.screenEdgePadding, 
				right: AppBoxProperties.screenEdgePadding,
				bottom: 8.0
			),
			child: Row(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				crossAxisAlignment: CrossAxisAlignment.center,
				children: <Widget>[
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: <Widget>[
								Text(
									AppLocales.of(context).translate(title, titleArgs),
									style: Theme.of(context).textTheme.headline2,
									overflow: TextOverflow.clip,
									maxLines: 2
								),
								if(subtitle != null)
									Text(
										AppLocales.of(context).translate(subtitle!),
										style: Theme.of(context).textTheme.subtitle2,
										overflow: TextOverflow.ellipsis,
										maxLines: 3
									)
							]
						)
					),
					if(headerAction != null)
						Tooltip(
							message: AppLocales.of(context).translate(headerAction!.textKey),
							child: Padding(
								padding: EdgeInsets.only(left: 10.0),
								child: MaterialButton(
									visualDensity: VisualDensity.compact,
									materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
									child: Icon(headerAction!.icon, color: Colors.white, size: 30),
									color: headerAction!.color ?? AppColors.caregiverButtonColor,
									onPressed: headerAction!.action,
									padding: EdgeInsets.all(12.0),
									shape: CircleBorder(),
									minWidth: 0
								)
							)
						)
				]
			)
		);
	}

	@override
	Widget build(BuildContext context) {
		return ListView(
			shrinkWrap: true,
			padding: EdgeInsets.only(top: AppBoxProperties.sectionPadding),
			physics: NeverScrollableScrollPhysics(),
			children: <Widget>[
				buildSectionHeader(context),
				if(customContent != null)
					customContent!
				else if(elements != null && elements!.length > 0)
					...elements!
				else if(noElementsMessage != null)
					AppHero(
						title: AppLocales.of(context).translate(noElementsMessage!),
						icon: noElementsIcon,
						actionWidget: Padding(padding: EdgeInsets.only(bottom: 16.0), child: noElementsAction),
					)
			]
		);
	}
}

class AppSegments extends StatelessWidget {
	final List<Widget> segments;
	final bool fullBody;

	AppSegments({required this.segments, this.fullBody = false});
	
	@override
	Widget build(BuildContext context) {
		return Container(
			child: fullBody ? _buildList() : Expanded(child: _buildList())
		);
	}

	Widget _buildList() {
		return round_spot.Detector(
			areaID: 'main-scroll-area',
			child: ListView(
				padding: EdgeInsets.zero,
				physics: BouncingScrollPhysics(),
				children: <Widget>[
					...segments,
					SizedBox(height: 80.0)
				]
			)
		);
	}

}
