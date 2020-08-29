import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;

import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/gamification/ui_currency.dart';
import 'package:fokus/model/ui/form/task_form_model.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/dialog_utils.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/app_header.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/dialogs/general_dialog.dart';
import 'package:fokus/widgets/cards/item_card.dart';
import 'package:fokus/widgets/buttons/popup_menu_list.dart';
import 'package:fokus/widgets/segment.dart';
import 'package:fokus/widgets/cards/task_card.dart';

class CaregiverPlanDetailsPage extends StatefulWidget {
  @override
  _CaregiverPlanDetailsPageState createState() =>
      new _CaregiverPlanDetailsPageState();
}

class _CaregiverPlanDetailsPageState extends State<CaregiverPlanDetailsPage> {
	static const String _pageKey = 'page.caregiverSection.planDetails';
	Mongo.ObjectId planID;

  @override
  Widget build(BuildContext context) {
		Map<String, Mongo.ObjectId> args = ModalRoute.of(context).settings.arguments;
		if(args != null)
			planID = args['planID'];

		return Scaffold(
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					AppHeader.widget(
						title: '$_pageKey.header.title',
						appHeaderWidget: ItemCard(
							title: planID != null ? planID.toString() : "Sprzątanie pokoju",
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
						helpPage: 'plan_info',
						popupMenuWidget: PopupMenuList(
							lightTheme: true,
							items: [
								UIButton.ofType(ButtonType.edit, () => Navigator.of(context).pushNamed(AppPage.caregiverPlanForm.name, arguments: Mongo.ObjectId.parse('5f3ad3cf4ea005fba95da86b'))),
								UIButton.ofType(ButtonType.delete, () => showBasicDialog(
									context,
									GeneralDialog.confirm(
										title: AppLocales.of(context).translate('alert.deletePlan'),
										content: AppLocales.of(context).translate('alert.confirmPlanDeletion'),
										confirmText: 'actions.delete',
										confirmAction: () => Navigator.of(context).pop(),
										confirmColor: Colors.red
									)
								))
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
				title: '$_pageKey.content.mandatoryTasks'
			),
			_getAdditionalTasksSegment(
				title: '$_pageKey.content.additionalTasks'
			)
		];
	}

	Segment _getTasksSegment({String title, String noElementsMessage}) {
		return Segment(
			title: title,
			noElementsMessage: '$_pageKey.content.noTasks',
			elements: <Widget>[
				Padding(
					padding: EdgeInsets.symmetric(horizontal: AppBoxProperties.screenEdgePadding),
					child: TaskCard(
						index: 0,
						task: TaskFormModel(
							key: ValueKey(DateTime.now()),
							title: "Opróżnij plecak",
							timer: 568,
							pointsValue: 80,
							pointCurrency: UICurrency(type: CurrencyType.diamond, title: "Punkty")
						)
					)
				),
				Padding(
					padding: EdgeInsets.symmetric(horizontal: AppBoxProperties.screenEdgePadding),
					child: TaskCard(
						index: 1,
						task: TaskFormModel(
							key: ValueKey(DateTime.now()),
							title: "Przygotuj książki i zeszyty na kolejny dzień według bardzo długiego planu zajęć",
							timer: 60,
							pointsValue: 100,
							pointCurrency: UICurrency(type: CurrencyType.diamond, title: "Punkty")
						)
					)
				),
				Padding(
					padding: EdgeInsets.symmetric(horizontal: AppBoxProperties.screenEdgePadding),
					child: TaskCard(
						index: 2,
						task: TaskFormModel(
							key: ValueKey(DateTime.now()),
							title: "Spakuj potrzebne rzeczy"
						)
					)
				),
				Padding(
					padding: EdgeInsets.symmetric(horizontal: AppBoxProperties.screenEdgePadding),
					child: TaskCard(
						index: 3,
						task: TaskFormModel(
							key: ValueKey(DateTime.now()),
							title: "Spakuj potrzebne rzeczy part 2",
							timer: 20
						)
					)
				)
			]
		);
	}

	Segment _getAdditionalTasksSegment({String title, String noElementsMessage}) {
		return Segment(
			title: title,
			noElementsMessage: '$_pageKey.content.noTasks',
			elements: <Widget>[
				Padding(
					padding: EdgeInsets.symmetric(horizontal: AppBoxProperties.screenEdgePadding),
					child: TaskCard(
						task: TaskFormModel(
							key: ValueKey(DateTime.now()),
							title: "Opcjonalne zadanko",
							timer: 20,
							optional: true,
							pointsValue: 300,
							pointCurrency: UICurrency(type: CurrencyType.ruby, title: "Klejnoty")
						)
					)
				)
			]
		);
	}
}
