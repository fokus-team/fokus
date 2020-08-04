import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/widgets/attribute_chip.dart';
import 'package:fokus/widgets/flexible_app_header.dart';
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
			body: CustomScrollView(
      	slivers: [
      		FlexibleAppHeader(
						expandedHeight: 200,
						pinnedTitle: '$_pageKey.header.title',
						flexibleSpaceWidget: ItemCard(
							title: "Sprzątanie pokoju w odstępach kilkudziesięciukilku minutowych oraz wielogodzinowych melancholijnych spotkaniach przy otwartym oknie pośród gwiazd Betlejem skąpanych w mroku piekła i nieba oraz genialnym muzykowaniem z najlepszymi ludźmi",
							subtitle: "Co każdy poniedziałek, wtorek i czwartek",
							isActive: true,
							progressPercentage: 0.4,
							chips:
							<Widget>[AttributeChip.withIcon(
								icon: Icons.description,
								color: Colors.lightGreen,
								content: AppLocales.of(context).translate('page.childSection.panel.content.taskProgress', {'NUM_TASKS': 2, 'NUM_ALL_TASKS': 5})
							)],
							titleMaxLines: 1,
							activeProgressBarColor: Colors.amber,
						),
					),
        	SliverList(
						delegate: SliverChildListDelegate(_buildPanelSegments())
					)
				]
			)
		);
  }

  List<Segment> _buildPanelSegments() {
    return [
      _getTasksSegment(
        title: '$_pageKey.content.toDoTasks',
      ),
      _getAddTasksSegment(title: '$_pageKey.content.additionalTasks')
    ];
  }

  Segment _getTasksSegment({String title, String noElementsMessage}) {
    return Segment(title: title, noElementsMessage: '$_pageKey.content.noTasks', elements: <Widget>[
      ItemCard(
        title: "Opróżnij plecak",
				chips:
				<Widget>[AttributeChip.withIcon(
					icon: Icons.timer,
					color: Colors.lightGreen,
					content: "Czas: 2:10"
				)],
        actionButton: ItemCardActionButton(
            color: Colors.lightGreen, icon: Icons.check, onTapped: () => log("Tapped finished activity")),
      ),
      ItemCard(
        title: "Przygotuj książki i zeszyty na kolejny dzień według bardzo długiego planu zajęć",
				chips:<Widget>[
					AttributeChip.withIcon(
						icon: Icons.access_time,
						color: Colors.amber,
						content: "6 minut"
					)
				],
        actionButton:	ItemCardActionButton(color: Colors.teal, icon: Icons.play_arrow, onTapped: () => log("tapped start task")),
      ),
      ItemCard(
        title: "Spakuj potrzebne rzeczy",
				chips:
				<Widget>[AttributeChip.withIcon(
					icon: Icons.access_time,
					color: Colors.amber,
					content: "5 minut"
				)],
        actionButton: ItemCardActionButton(color: Colors.grey, icon: Icons.keyboard_arrow_up),
      ),
			ItemCard(
				title: "Spakuj potrzebne rzeczy",
				chips:
				<Widget>[AttributeChip.withIcon(
					icon: Icons.access_time,
					color: Colors.amber,
					content: "5 minut"
				)],
				actionButton: ItemCardActionButton(color: Colors.grey, icon: Icons.keyboard_arrow_up),
			),
			ItemCard(
				title: "Spakuj potrzebne rzeczy",
				chips:
				<Widget>[AttributeChip.withIcon(
					icon: Icons.access_time,
					color: Colors.amber,
					content: "5 minut"
				)],
				actionButton: ItemCardActionButton(color: Colors.grey, icon: Icons.keyboard_arrow_up),
			),
			ItemCard(
				title: "Spakuj potrzebne rzeczy",
				chips:
				<Widget>[AttributeChip.withIcon(
					icon: Icons.access_time,
					color: Colors.amber,
					content: "5 minut"
				)],
				actionButton: ItemCardActionButton(color: Colors.grey, icon: Icons.keyboard_arrow_up),
			),
			ItemCard(
				title: "Spakuj potrzebne rzeczy",
				chips:
				<Widget>[AttributeChip.withIcon(
					icon: Icons.access_time,
					color: Colors.amber,
					content: "5 minut"
				)],
				actionButton: ItemCardActionButton(color: Colors.grey, icon: Icons.keyboard_arrow_up),
			)
    ]);
  }

  Segment _getAddTasksSegment({String title, String noElementsMessage}) {
    return Segment(title: title, noElementsMessage: '$_pageKey.content.noTasks', elements: <Widget>[
      ItemCard(
        title: "Opróżnij plecak 2",
				chips:
				<Widget>[AttributeChip.withIcon(
					icon: Icons.timer,
					color: Colors.lightGreen,
					content: "Czas: 5:24"
				)],
        actionButton: ItemCardActionButton(
            color: Colors.lightGreen, icon: Icons.check, onTapped: () => log("Tapped finished activity")),
      ),
      ItemCard(
        title: "Przygotuj książki i zeszyty na kolejny dzień według bardzo długiego planu zajęć",
				chips:
				<Widget>[AttributeChip.withIcon(
					icon: Icons.access_time,
					color: Colors.amber,
					content: "8 minut"
				)],
        actionButton:
            ItemCardActionButton(color: Colors.teal, icon: Icons.play_arrow, onTapped: () => log("tapped start task")),
      )
    ]);
  }
}
