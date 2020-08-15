import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/app_header.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/dialogs/dialog.dart';
import 'package:fokus/widgets/item_card.dart';
import 'package:fokus/widgets/popup_menu_list.dart';
import 'package:fokus/widgets/segment.dart';

class CaregiverPlanDetailsPage extends StatefulWidget {
  @override
  _CaregiverPlanDetailsPageState createState() =>
      new _CaregiverPlanDetailsPageState();
}

class _CaregiverPlanDetailsPageState extends State<CaregiverPlanDetailsPage> {
	static const String _pageKey = 'page.caregiverSection.planDetails';

  @override
  Widget build(BuildContext context) {
		return Scaffold(
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					AppHeader.widget(
						title: '$_pageKey.header.title',
						appHeaderWidget: ItemCard(
							title: "Sprzątanie pokoju",
							subtitle: "Co każdy poniedziałek, środę, czwartek i piątek",
							chips:
							<Widget>[
								AttributeChip.withIcon(
									content: AppLocales.of(context).translate('page.caregiverSection.plans.content.tasks', {'NUM_TASKS': 1}),
									color: Colors.indigo,
									icon: Icons.layers
								)
							],
						),
						showHelp: true,
						popupMenuWidget: PopupMenuList(
							lightTheme: true,
							items: [
								UIButton.ofType(ButtonType.edit,(context) => log("Tapped edit")),
								UIButton.ofType(
									ButtonType.delete,
									(context) => showDialog(
										context: context,
										//TODO: replace with Dialog made by Miko - blocked by pull request
										builder: (context) => AppDialog(
											titleKey: 'alert.deletePlan',
											textKey: 'alert.confirmPlanDeletion',
											buttons: [
												DialogButton(ButtonType.close, () => Navigator.of(context).pop()),
												DialogButton(ButtonType.ok, () => Navigator.of(context).pop())
											],
										),
									)
								)
							],
						)
					),
					AppSegments(segments: _buildPanelSegments())
				],
			),
		);

	}

	List<Segment> _buildPanelSegments() {
		return [
			_getTasksSegment(
				title: '$_pageKey.content.mandatoryTasks',
			),
			_getAdditionalTasksSegment(title: '$_pageKey.content.additionalTasks')
		];
	}

	Segment _getTasksSegment({String title, String noElementsMessage}) {
		return Segment(
			title: title,
			noElementsMessage: '$_pageKey.content.noTasks',
			elements: <Widget>[
				ItemCard(
					title: "Opróżnij plecak",
					chips:
					<Widget>[
						AttributeChip.withIcon(
							icon: Icons.access_time,
							color: AppColors.caregiverBackgroundColor,
							content: "8 minut"
						)
					],
				),
				ItemCard(
					title: "Przygotuj książki i zeszyty na kolejny dzień według bardzo długiego planu zajęć",
					chips:<Widget>[
						AttributeChip.withIcon(
							icon: Icons.access_time,
							color: AppColors.caregiverBackgroundColor,
							content: "6 minut"
						)
					],
				),
				ItemCard(
					title: "Spakuj potrzebne rzeczy",
					chips:
					<Widget>[
						AttributeChip.withIcon(
							icon: Icons.access_time,
							color: AppColors.caregiverBackgroundColor,
							content: "5 minut"
						)
					],
				),
				ItemCard(
					title: "Spakuj potrzebne rzeczy",
					chips:
					<Widget>[
						AttributeChip.withIcon(
							icon: Icons.access_time,
							color: AppColors.caregiverBackgroundColor,
							content: "5 minut"
						)
					],
				),
				ItemCard(
					title: "Spakuj potrzebne rzeczy",
					chips:
					<Widget>[
						AttributeChip.withIcon(
							icon: Icons.access_time,
							color: AppColors.caregiverBackgroundColor,
							content: "5 minut"
						)
					],
				),
				ItemCard(
					title: "Spakuj potrzebne rzeczy",
					chips:
					<Widget>[
						AttributeChip.withIcon(
							icon: Icons.access_time,
							color: AppColors.caregiverBackgroundColor,
							content: "5 minut"
						)
					],
				),
				ItemCard(
					title: "Spakuj potrzebne rzeczy",
					chips:
					<Widget>[
						AttributeChip.withIcon(
							icon: Icons.access_time,
							color: AppColors.caregiverBackgroundColor,
							content: "5 minut"
						)
					],
				),
			]
		);
	}

	Segment _getAdditionalTasksSegment({String title, String noElementsMessage}) {
		return Segment(
			title: title,
			noElementsMessage: '$_pageKey.content.noTasks',
			elements: <Widget>[
				ItemCard(
					title: "Opróżnij plecak 2",
					chips:
					<Widget>[
						AttributeChip.withIcon(
							icon: Icons.access_time,
							color: AppColors.caregiverBackgroundColor,
							content: "8 minut"
						)
					],
				),
				ItemCard(
					title: "Przygotuj książki i zeszyty na kolejny dzień według bardzo długiego planu zajęć",
					chips:
					<Widget>[
						AttributeChip.withIcon(
							icon: Icons.access_time,
							color: AppColors.caregiverBackgroundColor,
							content: "8 minut"
						)
					],
				)
			]
		);
	}
}
