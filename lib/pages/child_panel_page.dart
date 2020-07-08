import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fokus/data/model/user/caregiver.dart';
import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/wigets/plan_widget.dart';

class ChildPanelPage extends StatefulWidget {
  @override
  _ChildPanelPageState createState() => new _ChildPanelPageState();
}

class _ChildPanelPageState extends State<ChildPanelPage> {
  // styling vars
  final Color futurePlansColor = Colors.amber;

  @override
  Widget build(BuildContext context) {
    var user = ModalRoute.of(context).settings.arguments as Caregiver;

    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: AppColors.childBackgroundColor,
          unselectedItemColor: AppColors.mainGray,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.format_align_justify),
                activeIcon: Icon(Icons.format_align_justify),
                title: Text('${AppLocales.of(context).translate("page.child.bottomNavBar.plans")} ')),
            BottomNavigationBarItem(
                icon: Icon(Icons.star),
                activeIcon: Icon(Icons.star),
                title: Text('${AppLocales.of(context).translate("page.child.bottomNavBar.rewards")} ')),
            BottomNavigationBarItem(
                icon: Icon(Icons.flag),
                activeIcon: Icon(Icons.flag),
                title: Text('${AppLocales.of(context).translate("page.child.bottomNavBar.achievements")} '))
          ],
        ),
        body: Container(
            child: SafeArea(
                child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.symmetric(
                    vertical: AppBoxProperties.sectionPadding,
                    horizontal: AppBoxProperties.screenEdgePadding),
                child: Text('${AppLocales.of(context).translate("page.child.childPanel.todaysPlans")} ',
                    style: Theme.of(context).textTheme.headline1)),
            PlanWidget(
                "Gra w piłkę nożną pośrodku ulicy skąpanej w promieniach błogiego słońca wyróżniającego się słodkim zapachem nieba",
                false,
                2),
            PlanWidget("Gra w piłkę nożną", true, 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(),
                Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: AppBoxProperties.cardListPadding,
                        horizontal: AppBoxProperties.screenEdgePadding),
                    child: Container(
                        padding:
                            EdgeInsets.all(AppBoxProperties.buttonIconPadding),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(
                              AppBoxProperties.roundedCornersRadius)),
                          color: futurePlansColor,
                        ),
                        child: ButtonBar(children: <Widget>[
                          Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                          ),
                          Text(
														'${AppLocales.of(context).translate("page.child.childPanel.futurePlans")} ',
                            style: Theme.of(context).textTheme.button,
                          )
                        ])))
              ],
            )
          ],
        ))));
  }
}
