import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:fokus/model/currency_type.dart';
import 'package:fokus/utils/app_paths.dart';
import 'package:fokus/utils/icon_sets.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/item_card.dart';

import 'package:intl/intl.dart';

enum NotificationType{
  caregiver_receivedAward,
  caregiver_finishedTaskUngraded,
  caregiver_finishedTaskGraded,
  caregiver_unfinishedPlan,
  child_taskGraded,
  child_receivedBadge
}

extension NotificationTypeExtension on NotificationType {
  String get title => const {
    NotificationType.caregiver_receivedAward: ' odebrał nagrodę',
    NotificationType.caregiver_finishedTaskUngraded: ' wykonał zadanie',
    NotificationType.caregiver_finishedTaskGraded: ' wykonał zadanie',
    NotificationType.caregiver_unfinishedPlan: ' nie skończył planu',
    NotificationType.child_taskGraded: 'Dostałeś punkty za zadanie!',
    NotificationType.child_receivedBadge: 'Otrzymałeś odznakę!'
  }[this];

  Icon get icon => Icon(
    const {
      NotificationType.caregiver_receivedAward : Icons.star,
      NotificationType.caregiver_finishedTaskUngraded : Icons.view_headline,
      NotificationType.caregiver_finishedTaskGraded : Icons.view_headline,
      NotificationType.caregiver_unfinishedPlan : Icons.cancel,
      NotificationType.child_taskGraded : Icons.view_headline,
      NotificationType.child_receivedBadge : Icons.star
    }[this],
    color: Colors.grey
  );

  GraphicAssetType get graphicType => const {
    NotificationType.caregiver_receivedAward: GraphicAssetType.childAvatars,
    NotificationType.caregiver_finishedTaskUngraded: GraphicAssetType.childAvatars,
    NotificationType.caregiver_finishedTaskGraded: GraphicAssetType.childAvatars,
    NotificationType.caregiver_unfinishedPlan: GraphicAssetType.childAvatars,
    NotificationType.child_taskGraded: GraphicAssetType.badgeIcons, // actually currency icon
    NotificationType.child_receivedBadge: GraphicAssetType.badgeIcons
  }[this];

  List<Widget> get chips => {
    NotificationType.caregiver_finishedTaskUngraded: [
      GestureDetector(
        onTap: () => {log("open the grading page")},
        child: AttributeChip.withIcon(
          content: "Oceń zadanie",
          color: Colors.red,
          icon: Icons.assignment
        )
      )
    ],
    NotificationType.caregiver_finishedTaskGraded: [
      AttributeChip.withIcon(
        content: "Oceniono",
        color: Colors.grey[750],
        icon: Icons.check
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

  static String makeTitle(String name, NotificationType type) => name + type.title;

  //TODO check what should be required
  NotificationCard({
    this.childName = "",
    this.notificationType,
    this.dateTime,
    this.currencyType,
    this.currencyValue = 0,
    title,
    subtitle,
    graphicType,
    graphic,
    chips
  }) : super(
    title: title ?? makeTitle(childName, notificationType),
    subtitle: subtitle,
    graphicType: graphicType ?? notificationType.graphicType,
    graphic: graphic,
    chips: chips ?? notificationType.chips ?? []
  ){
    if(notificationType == NotificationType.child_taskGraded) {
      this.chips.add(
        AttributeChip.withIcon(
          content: currencyValue.toString(),
          color: AppColors.currencyColor[currencyType],
          icon: Icons.add
        )
      );
    }
  }

  @override
  double get imageHeight => super.imageHeight * 0.7;

  @override
  double get badgeImageHeight => imageHeight;

  @override
  Widget headerImage(){
    if(currencyType == null)
      return super.headerImage();
    else
      return SvgPicture.asset(currencySvgPath(currencyType), height: imageHeight);
  }

  @override
  Widget buildContentSection(BuildContext context){
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
                          "${DateFormat.yMd(Localizations.localeOf(context).toString()).format(dateTime)} ${DateFormat.Hm(Localizations.localeOf(context).toString()).format(dateTime)}",
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
          if(notificationType != null)
            Padding(
                padding: EdgeInsets.all(6.0),
                child: notificationType.icon
            )
        ]
    );
  }
}
