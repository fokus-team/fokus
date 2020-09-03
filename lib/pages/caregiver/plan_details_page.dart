import 'package:flutter/material.dart';
import 'package:fokus/logic/caregiver_tasks_cubit.dart';
import 'package:fokus/model/ui/plan/ui_plan.dart';
import 'package:fokus/model/ui/task/ui_task.dart';
import 'package:fokus/widgets/loadable_bloc_builder.dart';

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

  @override
  Widget build(BuildContext context) {
		return Scaffold(
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					LoadableBlocBuilder<CaregiverTasksCubit>(
						builder: (context, state) => AppSegments(segments: _buildPanelSegments(state)),
					)
				],
			),
		);

	}

	List<Widget> _buildPanelSegments(CaregiverTasksLoadSuccess state) {
  	UIPlan uiPlan = state.uiPlan;
  	List<UITask> mandatoryTasks = state.tasks.where((task) => task.optional == false).toList();
		List<UITask> optionalTasks = state.tasks.where((task) => task.optional == true).toList();

		return [
			_getCardHeader(uiPlan),
			_getTasksSegment(
				title: '$_pageKey.content.mandatoryTasks',
				tasks: mandatoryTasks
			),
			_getAdditionalTasksSegment(
				title: '$_pageKey.content.additionalTasks',
				tasks: optionalTasks
			)
		];
	}

	Segment _getTasksSegment({String title, String noElementsMessage, List<UITask> tasks}) {
		return Segment(
			title: title,
			noElementsMessage: '$_pageKey.content.noTasks',
			elements: <Widget>[
				for (var task in tasks)
					Padding(
						padding: EdgeInsets.symmetric(horizontal: AppBoxProperties.screenEdgePadding),
						child: TaskCard(
							index: tasks.indexOf(task),
							task: TaskFormModel(
								key: ValueKey(DateTime.now()),
								title: task.name,
								timer: task.timer,
								pointsValue: task.points != null ? task.points.quantity : null,
								pointCurrency:  task.points != null ? UICurrency(type: task.points.type, title: task.points.title) : null
							)
						)
					)
			]
		);
	}

	Segment _getAdditionalTasksSegment({String title, String noElementsMessage, List<UITask> tasks}) {
		return Segment(
			title: title,
			noElementsMessage: '$_pageKey.content.noTasks',
			elements: <Widget>[
				for (var task in tasks)
					Padding(
						padding: EdgeInsets.symmetric(horizontal: AppBoxProperties.screenEdgePadding),
						child: TaskCard(
							task: TaskFormModel(
								key: ValueKey(DateTime.now()),
								title: task.name,
								timer: task.timer,
								optional: true,
								pointsValue: task.points != null ? task.points.quantity : null,
								pointCurrency:  task.points != null ? UICurrency(type: task.points.type, title: task.points.title) : null
							)
						)
					)
			]
		);
	}

	Widget _getCardHeader(UIPlan plan) {
		return AppHeader.widget(
			title: '$_pageKey.header.title',
			appHeaderWidget: ItemCard(
				title: plan.name,
				subtitle: plan.description(context),
				chips: <Widget>[
					AttributeChip.withIcon(
						content: AppLocales.of(context).translate('page.caregiverSection.plans.content.tasks', {'NUM_TASKS': plan.taskCount}),
						color: Colors.indigo,
						icon: Icons.layers
					)
				]
			),
			helpPage: 'plan_info',
			popupMenuWidget: PopupMenuList(
				lightTheme: true,
				items: [
					UIButton.ofType(ButtonType.edit, () => Navigator.of(context).pushNamed(AppPage.caregiverPlanForm.name, arguments: plan.id)),
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
		);
	}
}
