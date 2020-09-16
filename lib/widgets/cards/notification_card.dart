import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/app_paths.dart';
import 'package:fokus/utils/icon_sets.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/cards/item_card.dart';

import 'package:intl/intl.dart';

const String _pageKey = "page.notifications.content";

enum NotificationType {
  caregiver_receivedReward,
  caregiver_finishedTaskUngraded,
  caregiver_unfinishedPlan,
  child_taskGraded,
  child_receivedBadge
}

extension NotificationTypeExtension on NotificationType {
  String get title => {
    NotificationType.caregiver_receivedReward: "caregiver.receivedReward",
    NotificationType.caregiver_finishedTaskUngraded: "caregiver.finishedTask",
    NotificationType.caregiver_unfinishedPlan: "caregiver.unfinishedPlan",
    NotificationType.child_taskGraded: "child.taskGraded",
    NotificationType.child_receivedBadge: "child.receivedBadge"
  }[this];

  Icon get icon => Icon(
    const {
      NotificationType.caregiver_receivedReward : Icons.star,
      NotificationType.caregiver_finishedTaskUngraded : Icons.assignment_turned_in,
      NotificationType.caregiver_unfinishedPlan : Icons.assignment_late,
      NotificationType.child_taskGraded : Icons.assignment_turned_in,
      NotificationType.child_receivedBadge : Icons.star
    }[this],
    color: Colors.grey
  );

  AssetType get graphicType => const {
	  NotificationType.caregiver_receivedReward: AssetType.avatars,
	  NotificationType.caregiver_finishedTaskUngraded: AssetType.avatars,
	  NotificationType.caregiver_unfinishedPlan: AssetType.avatars,
	  NotificationType.child_taskGraded: AssetType.currencies,
	  NotificationType.child_receivedBadge: AssetType.badges
  }[this];

  AppPage get redirectPage => const {
	  NotificationType.caregiver_receivedReward: AppPage.caregiverChildDashboard,
	  NotificationType.caregiver_finishedTaskUngraded: AppPage.caregiverRatingPage,
	  NotificationType.caregiver_unfinishedPlan: AppPage.caregiverChildDashboard,
	  NotificationType.child_taskGraded: AppPage.caregiverAwards,
	  NotificationType.child_receivedBadge: AppPage.childAchievements
  }[this];
}

class NotificationCard extends ItemCard {
  final DateTime dateTime;

  NotificationCard({
	  @required NotificationType notificationType,
	  String childName = "",
    this.dateTime,
	  int currencyValue = 0,
    String title,
    String subtitle,
    AssetType graphicType,
    int graphic
  }) : super(
    title: AppLocales.instance.translate("$_pageKey.${notificationType.title}", {'CHILD_NAME' : childName}),
    subtitle: subtitle,
    graphicType: graphicType ?? notificationType.graphicType,
    graphic: graphic,
	  graphicHeight: ItemCard.defaultImageHeight * 0.7,
    rightIcon: notificationType.icon,
    chips: [
	    if (notificationType == NotificationType.caregiver_finishedTaskUngraded)
		    AttributeChip.withIcon(
			    content: AppLocales.instance.translate("$_pageKey.caregiver.gradeTask"),
			    color: Colors.red,
			    icon: Icons.assignment
		    )
	    else if (notificationType == NotificationType.child_taskGraded)
		    AttributeChip.withIcon(
			    content: currencyValue.toString(),
			    color: AppColors.currencyColor[CurrencyType.values[graphic]],
			    icon: Icons.add
		    )
    ]
  );


  @override
  List<Widget> buildTextSection(BuildContext context) {
		return [
			Text(
				title,
				style: Theme.of(context).textTheme.bodyText2,
				overflow: TextOverflow.ellipsis,
				maxLines: 1
			),
			if(subtitle != null)
				Padding(
					padding: EdgeInsets.only(top: 2.0, bottom: 4.0),
					child: Text(
						subtitle,
						style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
						overflow: TextOverflow.ellipsis,
						maxLines: titleMaxLines,
						softWrap: false,
					)
				),
			if(dateTime != null)
				Text(
					"${DateFormat.yMd(Localizations.localeOf(context).toString()).add_Hm().format(dateTime)}",
					style: Theme.of(context).textTheme.subtitle2,
					overflow: TextOverflow.ellipsis,
					maxLines: 1,
					softWrap: false,
				),
		];
  }
}
