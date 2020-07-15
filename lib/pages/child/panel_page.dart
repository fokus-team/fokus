import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/app_navigation_bar.dart';
import 'package:fokus/widgets/child_wallet.dart';
import 'package:fokus/widgets/plan_widget.dart';

class ChildPanelPage extends StatefulWidget {
  @override
  _ChildPanelPageState createState() => new _ChildPanelPageState();
}

class _ChildPanelPageState extends State<ChildPanelPage> {
  // styling vars
  final Color futurePlansColor = Colors.amber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ChildCustomHeader(),
          Container(
              child: Container(
                  child: Flexible(
                      child: ListView(
            physics: BouncingScrollPhysics(),
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(
                      bottom: AppBoxProperties.sectionPadding,
                      right: AppBoxProperties.screenEdgePadding,
                      left: AppBoxProperties.screenEdgePadding),
                  child: Text(
                      '${AppLocales.of(context).translate("page.childSection.panel.content.inProgress")} ',
                      style: Theme.of(context).textTheme.headline1)),
              PlanWidget(
                planName: "Nauka angielskiego",
                isActive: true,
                isInProgress: true,
                tasksCount: 6,
                progressPercentage: 0.2,
                details: "Pozostało: 20 minut",
                buttonAction: () {
                  log(
                    "Button Pressed",
                  );
                },
              ),
              Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: AppBoxProperties.sectionPadding,
                      horizontal: AppBoxProperties.screenEdgePadding),
                  child: Text(
                      '${AppLocales.of(context).translate("page.childSection.panel.content.todaysPlans")} ',
                      style: Theme.of(context).textTheme.headline1)),
              PlanWidget(
                  planName: "Rozpoczęty plan, ale niedokończony",
                  isActive: false,
                  isInProgress: true,
                  tasksCount: 2,
                  details: "Pozostało: 30 minut",
                  progressPercentage: 0.67),
              PlanWidget(
                  planName: "Gra w piłkę nożną",
                  isActive: false,
                  isInProgress: false,
                  tasksCount: 5,
                  details: "Co każdy wtorek, piątek"),
              PlanWidget(
                  planName: "Gra w piłkę nożną",
                  isActive: false,
                  isInProgress: false,
                  tasksCount: 4,
                  details: "Co każdy wtorek, piątek"),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(),
                  Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: AppBoxProperties.cardListPadding,
                          horizontal: AppBoxProperties.screenEdgePadding),
                      child: ClipRRect(
                          borderRadius:
                              BorderRadius.all(Radius.circular(AppBoxProperties.roundedCornersRadius)),
                          child: FlatButton(
                              padding: EdgeInsets.all(
                                  AppBoxProperties.containerPadding),
                              color: futurePlansColor,
                              onPressed: () {
                                log("Pressed future plans");
                              },
                              child: Row(
                                children: <Widget>[
                                  Padding(padding: EdgeInsets.only(right: AppBoxProperties.buttonIconPadding), child:Icon(
                                    Icons.calendar_today,
                                    color: Colors.white,
                                  )),
                                  Text(
                                    '${AppLocales.of(context).translate("page.childSection.panel.content.futurePlans")} ',
                                    style: Theme.of(context).textTheme.button,
                                  )
                                ],
                              ))))
                ],
              )
            ],
          ))))
        ]),
        bottomNavigationBar: AppNavigationBar.childPage(currentIndex: 0));
  }
}
