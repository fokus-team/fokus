import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fokus/widgets/item_card.dart';
import 'package:fokus/widgets/segment.dart';

class ChildPlanInProgressPage extends StatefulWidget {
  @override
  _ChildPlanInProgressPageState createState() => new _ChildPlanInProgressPageState();
}

const String _pageKey = 'page.childSection.planInProgress';

class _ChildPlanInProgressPageState extends State<ChildPlanInProgressPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
			body: Column(
      	crossAxisAlignment: CrossAxisAlignment.start,
      	children: [AppSegments(segments: _buildPanelSegments())],
    ));
  }

  List<Segment> _buildPanelSegments() {
    return [
      _getTasksSegment(
				title: '$_pageKey.content.toDoTasks',
			),
			_getAddTasksSegment(
				title: '$_pageKey.content.additionalTasks')
    ];
  }

  Segment _getTasksSegment({String title, String noElementsMessage}) {
		return Segment(
			title: title,
			noElementsMessage: '$_pageKey.content.noTasks',
			elements: <Widget>[
				ItemCard(
					title: "Opróżnij plecak",
					subtitle: "Czas: 2:10",
					actionButton: ItemCardActionButton(
						color: Colors.lightGreen, icon: Icons.check, onTapped: () => log("Tapped finished activity")
					),
				),
				ItemCard(
					title: "Przygotuj książki i zeszyty na kolejny dzień według bardzo długiego planu zajęć",
					subtitle: "6 minut",
					actionButton: ItemCardActionButton(
						color: Colors.teal, icon: Icons.play_arrow, onTapped:() => log("tapped start task")
					),
				),
				ItemCard(
					title: "Spakuj potrzebne rzeczy",
					subtitle: "6 minut",
					actionButton: ItemCardActionButton(
						color: Colors.grey, icon: Icons.keyboard_arrow_up
					),
				)
			]
		);
	}

	Segment _getAddTasksSegment({String title, String noElementsMessage}) {
		return Segment(
			title: title,
			noElementsMessage: '$_pageKey.content.noTasks',
			elements: <Widget>[
				ItemCard(
					title: "Opróżnij plecak 2",
					subtitle: "Czas: 5:10",
					actionButton: ItemCardActionButton(
						color: Colors.lightGreen, icon: Icons.check, onTapped: () => log("Tapped finished activity")
					),
				),
				ItemCard(
					title: "Przygotuj książki i zeszyty na kolejny dzień według bardzo długiego planu zajęć",
					subtitle: "6 minut",
					actionButton: ItemCardActionButton(
						color: Colors.teal, icon: Icons.play_arrow, onTapped:() => log("tapped start task")
					),
				)
			]
		);
	}
}
