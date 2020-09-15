import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:fokus/model/currency_type.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/app_paths.dart';
import 'package:fokus/utils/icon_sets.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/cards/item_card.dart';

import 'package:intl/intl.dart';

const String _pageKey = "page.notifications.content";

enum NotificationType{
  caregiver_receivedReward,
  caregiver_finishedTaskUngraded,
  caregiver_finishedTaskGraded,
  caregiver_unfinishedPlan,
  child_taskGraded,
  child_receivedBadge
}

extension NotificationTypeExtension on NotificationType {
  String get title => {
    NotificationType.caregiver_receivedReward: "caregiver.receivedReward",
    NotificationType.caregiver_finishedTaskUngraded: "caregiver.finishedTask",
    NotificationType.caregiver_finishedTaskGraded: "caregiver.finishedTask",
    NotificationType.caregiver_unfinishedPlan: "caregiver.unfinishedPlan",
    NotificationType.child_taskGraded: "child.taskGraded",
    NotificationType.child_receivedBadge: "child.receivedBadge"
  }[this];

  Icon get icon => Icon(
    const {
      NotificationType.caregiver_receivedReward : Icons.star,
      NotificationType.caregiver_finishedTaskUngraded : Icons.assignment_turned_in,
      NotificationType.caregiver_finishedTaskGraded : Icons.assignment_turned_in,
      NotificationType.caregiver_unfinishedPlan : Icons.assignment_late,
      NotificationType.child_taskGraded : Icons.assignment_turned_in,
      NotificationType.child_receivedBadge : Icons.star
    }[this],
    color: Colors.grey
  );

  AssetType get graphicType => const {
    NotificationType.caregiver_receivedReward: AssetType.avatars,
    NotificationType.caregiver_finishedTaskUngraded: AssetType.avatars,
    NotificationType.caregiver_finishedTaskGraded: AssetType.avatars,
    NotificationType.caregiver_unfinishedPlan: AssetType.avatars,
    NotificationType.child_taskGraded: AssetType.badges, // actually currency icon
    NotificationType.child_receivedBadge: AssetType.badges
  }[this];

  List<Widget> chips(BuildContext context, CurrencyType currencyType, int currencyValue) => {
    NotificationType.caregiver_finishedTaskUngraded: [
      GestureDetector(
        onTap: () => {log("open the grading page")},
        child: AttributeChip.withIcon(
          content: AppLocales.of(context).translate("$_pageKey.caregiver.gradeTask"),
          color: Colors.red,
          icon: Icons.assignment
        )
      )
    ],
    NotificationType.caregiver_finishedTaskGraded: [
      AttributeChip.withIcon(
        content: AppLocales.of(context).translate("$_pageKey.caregiver.graded"),
        color: Colors.grey[750],
        icon: Icons.check
      )
    ],
    NotificationType.child_taskGraded: [
      AttributeChip.withIcon(
          content: currencyValue.toString(),
          color: AppColors.currencyColor[currencyType],
          icon: Icons.add
      )
    ]
  }[this];
}

class NotificationCard extends ItemCard {

  final String childName;
  final NotificationType notificationType;
  final DateTime dateTime;
  final CurrencyType currencyType;
  final int currencyValue;

  String getTitle(BuildContext context) => title ?? AppLocales.of(context).translate("$_pageKey.${notificationType.title}", {'CHILD_NAME' : childName});
  List<Widget> getChips(BuildContext context) => chips ?? notificationType.chips(context, currencyType, currencyValue);

  NotificationCard({
    this.childName = "",
    @required this.notificationType,
    this.dateTime,
    this.currencyType,
    this.currencyValue = 0,
    String title,
    String subtitle,
    AssetType graphicType,
    int graphic,
    List<Widget> chips
  }) : super(
    title: title,
    subtitle: subtitle,
    graphicType: graphicType ?? notificationType.graphicType,
    graphic: graphic,
    chips: chips
  );

  @override
  double get graphicHeight => super.graphicHeight * 0.7;

  @override
  Widget headerImage(){
    if(currencyType == null)
      return super.headerImage();
    else
      return SvgPicture.asset(AssetType.currencies.getPath(currencyType.index), height: graphicHeight);
  }

  @override
  Widget buildContentSection(BuildContext context){
    List<Widget> chips = getChips(context);
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if(graphic != null || currencyType != null)
            Padding(
                padding: EdgeInsets.all(6.0),
                child: headerImage()
            ),
          Expanded(
              flex: 1,
              child: Padding(
                  padding: (graphic != null || currencyType != null) ? EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0) : EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        getTitle(context),
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
                      if(chips != null && chips.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Wrap(
                            spacing: 2,
                            runSpacing: 4,
                            children: chips
                          )
                        )
                    ],
                  )
              )
          ),
          Padding(
              padding: EdgeInsets.all(6.0),
              child: notificationType.icon
          )
        ]
    );
  }
}
