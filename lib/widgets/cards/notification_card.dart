// @dart = 2.10
import 'package:flutter/material.dart';

import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/notification/notification_type.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/icon_sets.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/cards/item_card.dart';

import 'package:intl/intl.dart';


class NotificationCard extends ItemCard {
	static const String _pageKey = "page.notifications.content";

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
    title: AppLocales.instance.translate("${notificationType.title}", {'CHILD_NAME' : childName}),
    subtitle: subtitle,
    graphicType: graphicType ?? notificationType.graphicType,
    graphic: graphic,
	  graphicHeight: ItemCard.defaultImageHeight * 0.7,
    rightIcon: notificationType.icon,
    chips: [
	    if (notificationType == NotificationType.taskFinished)
		    AttributeChip.withIcon(
			    content: AppLocales.instance.translate("$_pageKey.caregiver.gradeTask"),
			    color: Colors.red,
			    icon: Icons.assignment
		    )
	    else if (notificationType == NotificationType.taskApproved)
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
					"${DateFormat.yMd(AppLocales.instance.locale.toString()).add_Hm().format(dateTime)}",
					style: Theme.of(context).textTheme.subtitle2,
					overflow: TextOverflow.ellipsis,
					maxLines: 1,
					softWrap: false,
				),
		];
  }
}
