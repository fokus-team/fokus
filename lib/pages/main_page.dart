import 'package:flutter/material.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:lottie/lottie.dart';

import 'package:fokus/data/model/user/caregiver.dart';
import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/wigets/help_dialog.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => new _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
		var user = ModalRoute.of(context).settings.arguments as Caregiver;
    return Scaffold(
      backgroundColor: ThemeConfig.mainBackgroundColor,
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
                child: Lottie.asset('assets/animation/sunflower_with_title_rotate_only.json', width: 280)),
            Center(
                child: Container(
                    width: 240,
                    padding: EdgeInsets.all(4.0),
                    child: FlatButton(
                        onPressed: () => { Navigator.of(context).pushNamed('/caregiver-panel-page', arguments: user) },
                        color: ThemeConfig.caregiverButtonColor,
                        padding: EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('${AppLocales.of(context).translate("page.main.introduction")} ',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                    color: ThemeConfig.lightTextColor)),
                            Text('${AppLocales.of(context).translate("page.main.caregiver")} ',
                                style: TextStyle(
                                    fontSize: 18, 
                                    fontWeight: FontWeight.bold,
                                    color: ThemeConfig.lightTextColor)),
                            Icon(Icons.arrow_forward, color: ThemeConfig.lightTextColor, size: 26)
                          ],
                        )))),
            Center(
                child: Container(
                    width: 240,
                    padding: EdgeInsets.all(4.0),
                    child: FlatButton(
                        onPressed: () => { Navigator.of(context).pushNamed('/child-panel-page') },
                        color: ThemeConfig.childButtonColor,
                        padding: EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('${AppLocales.of(context).translate("page.main.introduction")} ',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                    color: ThemeConfig.lightTextColor)),
                            Text('${AppLocales.of(context).translate("page.main.child")} ',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeConfig.lightTextColor)),
                            Icon(Icons.arrow_forward, color: ThemeConfig.lightTextColor, size: 26)
                          ],
                        )))),
            Container(
              width: 232,
              child: RawMaterialButton(
                  onPressed: () => {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => HelpDialog(helpPage: 'first_steps')
                    )
                  },
                  child: Center(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 4.0),
                          child: Icon(Icons.help_outline, color: ThemeConfig.lightTextColor)
                        ),
                        Text('${AppLocales.of(context).translate("page.main.help")}', style: Theme.of(context).textTheme.bodyText2,)
                      ]
                    )
                  )
                )
            )
          ]),
    );
  }
}
