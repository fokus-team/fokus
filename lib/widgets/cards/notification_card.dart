import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../model/currency_type.dart';
import '../../model/notification/notification_type.dart';
import '../../services/app_locales.dart';
import '../../utils/ui/icon_sets.dart';
import '../../utils/ui/theme_config.dart';
import '../chips/attribute_chip.dart';
import 'item_card.dart';


class NotificationCard extends ItemCard {
	static const String _pageKey = "page.notifications.content";

  final DateTime? dateTime;

  NotificationCard({
	  required NotificationType notificationType,
	  String childName = "",
    this.dateTime,
	  int currencyValue = 0,
    String? title,
    String? subtitle,
    AssetType? graphicType,
    int? graphic
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
			    color: AppColors.currencyColor[CurrencyType.values[graphic!]],
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
						subtitle!,
						style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
						overflow: TextOverflow.ellipsis,
						maxLines: titleMaxLines,
						softWrap: false,
					)
				),
			if(dateTime != null)
				Text(
					"${DateFormat.yMd(AppLocales.instance.locale.toString()).add_Hm().format(dateTime!)}",
					style: Theme.of(context).textTheme.subtitle2,
					overflow: TextOverflow.ellipsis,
					maxLines: 1,
					softWrap: false,
				),
		];
  }
}
