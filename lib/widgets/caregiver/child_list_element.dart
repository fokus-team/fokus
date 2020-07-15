import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';

import 'package:fokus/widgets/child_wallet.dart';

class ChildListElement extends StatelessWidget {
	final String name;
	final int todayPlanCount;
	final int pointCount;

	ChildListElement({
		@required this.name,
		@required this.todayPlanCount,
		@required this.pointCount
	});

	Image headerImage() {
		// TODO Handling the avatars (based on type and avatar parameters), returning sunflower for now
		return Image.asset('assets/image/sunflower_logo.png', height: 80);
	}

	@override
	Widget build(BuildContext context) {
		return Card(
			shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppBoxProperties.roundedCornersRadius)),
			margin: EdgeInsets.symmetric(
				vertical: AppBoxProperties.cardListPadding,
				horizontal: AppBoxProperties.screenEdgePadding
			),
			child: IntrinsicHeight(
				child: Row(
					mainAxisAlignment: MainAxisAlignment.spaceBetween,
					crossAxisAlignment: CrossAxisAlignment.start,
					children: <Widget>[
						Row(
							children: <Widget>[
								Padding(
									padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
									child: headerImage()
								),
								Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: <Widget>[
										Padding(
											padding: EdgeInsets.only(top: 6.0),
											child: Text(
												name,
												style: Theme.of(context).textTheme.headline3
											)
										),
										Text(
											AppLocales.of(context).translate('page.caregiverSection.panel.content.plansTodayCount', {'NUM_PLANS': todayPlanCount.toString()}) + ' ' +
											AppLocales.of(context).translate('page.caregiverSection.panel.content.plansToday'),
											style: Theme.of(context).textTheme.subtitle2
										),
										Padding(
											padding: EdgeInsets.only(bottom: 4.0),
											child: Row(
												children: <Widget>[
													ChildPointsChip(quantity: pointCount)
												],
											)
										),
									],
								)
							]
						),
						InkWell(
							customBorder: new CircleBorder(),
							child: PopupMenuButton<int>(
								icon: Icon(
									Icons.more_vert,
									size: 26.0
								),
								onSelected: (int value) => {
									log("Akcja: #" + value.toString())
								},
								itemBuilder: (context) => [
									PopupMenuItem(value: 1, child: Text(AppLocales.of(context).translate('actions.details'))),
									PopupMenuItem(value: 2, child: Text(AppLocales.of(context).translate('actions.edit'))),
									PopupMenuItem(value: 3, child: Text(AppLocales.of(context).translate('actions.delete'))),
								],
							)
						)
					]
				)
			)
		);
	}

}
