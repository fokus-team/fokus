import 'package:flutter/material.dart';
import 'package:fokus/model/db/plan/plan_instance.dart';
import 'package:fokus/widgets/app_header.dart';
import 'package:fokus/widgets/segment.dart';

class CaregiverPlanDetailsPage extends StatefulWidget {
  @override
  _CaregiverPlanDetailsPageState createState() =>
      new _CaregiverPlanDetailsPageState();
}

class _CaregiverPlanDetailsPageState extends State<CaregiverPlanDetailsPage> {
	static const String _pageKey = 'page.caregiverSection.panel';

  @override
  Widget build(BuildContext context) {
		final PlanInstance planInstance = ModalRoute.of(context).settings.arguments;
    return Scaffold(
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: <Widget>[
					AppHeader.normal(title: '$_pageKey.header.title'),
					AppSegments(
						segments: [

						]
					)
				]
			),
    );
  }
}
