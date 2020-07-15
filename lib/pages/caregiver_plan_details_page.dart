import 'package:flutter/material.dart';
import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/wigets/caregiver_plan_widget.dart';
import 'package:fokus/wigets/task_widget.dart';

class CaregiverPlanDetailsPage extends StatefulWidget {
  @override
  _CaregiverPlanDetailsPageState createState() =>
      new _CaregiverPlanDetailsPageState();
}

class _CaregiverPlanDetailsPageState extends State<CaregiverPlanDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Podgląd planu"),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            onPressed: null,
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ParentPlanWidget("Sprzątanie pokoju",
                "Cyklicznie co poniedziałek, wtorek i środę"),
            Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 5),
                child: Text(
                  "Zadania obowiązkowe",
                  style: Theme.of(context).textTheme.headline1,
                )),
						TaskWidget("Opróżnij plecak", new TimeDate(0, 0, 0, 0, 5, 0)),
						TaskWidget("Przygotuj książki i zeszyty na kolejny dzień w miejscu zwanym szkołą, którego na pewno nie lubisz i będziesz się tam męczyć", new TimeDate(0, 0, 0, 0, 10, 0)),
						TaskWidget("Spakuj potrzebne rzeczy", new TimeDate(0, 0, 0, 0, 30, 0)),
						Padding(
							padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 5),
							child: Text(
								"Zadania dodatkowe",
								style: Theme.of(context).textTheme.headline1,
							)),
						TaskWidget("Zjedz pączusia 😍😍😀", new TimeDate(0, 0, 0, 0, 30, 0)),
          ],
        ),
      ),
    );
  }
}
