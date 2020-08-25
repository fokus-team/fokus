import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/child_tasks_cubit.dart';
import 'package:fokus/logic/timer/timer_cubit.dart';
import 'package:fokus/model/db/plan/plan_instance_state.dart';
import 'package:fokus/model/db/plan/task_status.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/plan/ui_plan_instance.dart';
import 'package:fokus/model/ui/task/ui_task_instance.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/duration_utils.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/app_header.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/cards/item_card.dart';
import 'package:fokus/widgets/chips/timer_chip.dart';
import 'package:fokus/widgets/loadable_bloc_builder.dart';
import 'package:fokus/widgets/segment.dart';

class ChildPlanInProgressPage extends StatefulWidget {
  @override
  _ChildPlanInProgressPageState createState() => new _ChildPlanInProgressPageState();
}

class _ChildPlanInProgressPageState extends State<ChildPlanInProgressPage> {
	final String _pageKey = 'page.childSection.planInProgress';

  @override
  Widget build(BuildContext context) {
		return Scaffold(
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					LoadableBlocBuilder<ChildTasksCubit>(
						builder: (context, state) => AppSegments(segments: _buildPanelSegments(state))
					)
				],
			)
		);
  }

  List<Widget> _buildPanelSegments(ChildTasksLoadSuccess state) {
  	var mandatoryTasks = state.tasks.where((task) => task.optional == false).toList();
  	var optionalTasks = state.tasks.where((task) => task.optional == true).toList();
    return [
			AppHeader.widget(
				title: '$_pageKey.header.title',
				appHeaderWidget: getCardHeader(state.planInstance),
				helpPage: 'plan_info'
			),
    	if(mandatoryTasks.isNotEmpty)
      _getTasksSegment(
				tasks: mandatoryTasks,
        title: '$_pageKey.content.toDoTasks',
      ),
			if(optionalTasks.isNotEmpty)
      	_getTasksSegment(tasks: optionalTasks, title: '$_pageKey.content.additionalTasks')
    ];
  }

  Segment _getTasksSegment({List<UITaskInstance> tasks,String title, String noElementsMessage}) {
    return Segment(
			title: title,
			noElementsMessage: '$_pageKey.content.noTasks',
			elements: <Widget>[
				for(var task in tasks)
					if(task.taskUiType == TaskUIType.completed)
						getCompletedTaskCard(task)
					else if(task.taskUiType == TaskUIType.available)
						ItemCard(
							title: task.name,
							subtitle: task.description,
							chips:<Widget>[
								if (task.timer > 0) getTimeChip(task),
								if (task.points.quantity != 0) getCurrencyChip(task)
							],
							actionButton:	ItemCardActionButton(color: Colors.teal, icon: Icons.play_arrow, onTapped: () => Navigator.of(context).pushNamed(AppPage.childTaskInProgress.name, arguments: task.id)),
						)
					else if(task.taskUiType == TaskUIType.stopped)
							ItemCard(
								title: task.name,
								subtitle: task.description,
								chips:<Widget>[
									getDurationChip(task),
									getBreaksChip(task),
									if (task.timer > 0) getTimeChip(task),
									if (task.points.quantity != 0) getCurrencyChip(task)
								],
								actionButton:	ItemCardActionButton(color: Colors.teal, icon: Icons.play_arrow, onTapped: () => Navigator.of(context).pushNamed(AppPage.childTaskInProgress.name, arguments: task.id)),
							)
					else if(task.taskUiType.inProgress)
						BlocProvider<TimerCubit>(
							create: (_) => TimerCubit(task.elapsedTimePassed)..startTimer(),
							child:	ItemCard(
								title: task.name,
								subtitle: task.description,
								chips:
								<Widget>[
									if(task.taskUiType == TaskUIType.currentlyPerformed)
										...[
											TimerChip(
												icon: Icons.access_time,
												color: Colors.lightGreen,
											),
											getBreaksChip(task)
										]
									else
										...[
											getDurationChip(task),
											TimerChip(
												icon: Icons.free_breakfast,
												color: Colors.indigo,
											),
										]
								],
								actionButton: ItemCardActionButton(
									color: AppColors.childActionColor, icon: Icons.launch, onTapped: () => Navigator.of(context).pushNamed(AppPage.childTaskInProgress.name, arguments: task.id)
								),
							)
						)
					else if(task.taskUiType == TaskUIType.queued)
						ItemCard(
							title: task.name,
							subtitle: task.description,
							chips: <Widget>[
								if (task.timer > 0) getTimeChip(task),
								if (task.points.quantity != 0) getCurrencyChip(task)
							],
							actionButton: ItemCardActionButton(color: Colors.grey, icon: Icons.keyboard_arrow_up),
						)
			]
		);
  }

  Widget getCardHeader(UIPlanInstance _planInstance) {
		var taskDescriptionKey = 'page.childSection.panel.content.' + (_planInstance.completedTaskCount > 0 ? 'taskProgress' : 'noTaskCompleted');
		var card = ItemCard(
			title: _planInstance.name,
			subtitle: _planInstance.description(context),
			isActive: _planInstance.state != PlanInstanceState.completed,
			progressPercentage: _planInstance.state.inProgress ? _planInstance.completedTaskCount / _planInstance.taskCount : null,
			chips: [
				if(_planInstance.state == PlanInstanceState.active)
				...[
					TimerChip(color: AppColors.childButtonColor),
					AttributeChip.withIcon(
						icon: Icons.description,
						color: Colors.lightGreen,
						content: AppLocales.of(context).translate(taskDescriptionKey, {'NUM_TASKS': _planInstance.completedTaskCount, 'NUM_ALL_TASKS': _planInstance.taskCount})
					)
				]
				else
					AttributeChip.withIcon(
						icon: Icons.description,
						color: AppColors.mainBackgroundColor,
						content: AppLocales.of(context).translate('$_pageKey.content.tasks', {'NUM_TASKS': _planInstance.taskCount})
					)
			]);
  	if(_planInstance.state == PlanInstanceState.active)
  		return BlocProvider<TimerCubit>(
				create: (_) => TimerCubit(_planInstance.elapsedActiveTime)..startTimer(),
				child: card
			);
  	else return card;
	}

	Widget getCompletedTaskCard(UITaskInstance task) {
		return ItemCard(
			title: task.name,
			subtitle: task.description,
			chips:
			<Widget>[
				getDurationChip(task),
				getBreaksChip(task),
				if(task.status.state == TaskState.evaluated)
					...[
						AttributeChip.withIcon(
							content: AppLocales.of(context).translate('$_pageKey.content.chips.rating', {
								'RATING' : task.status.rating
							}),
							icon: Icons.star,
							color: AppColors.chipRatingColors[task.status.rating],
							tooltip:'$_pageKey.content.taskTimer.break',
						),
						if (task.points.quantity != 0) getCurrencyChip(task, pointsAwarded: true),
					]
				else if(task.status.state == TaskState.rejected)
					AttributeChip.withIcon(
						content: AppLocales.of(context).translate('$_pageKey.content.chips.rejected'),
						icon: Icons.close,
						color: Colors.red,
						tooltip:'$_pageKey.content.chips.rejectedTooltip',
					)
				else if(task.status.state == TaskState.notEvaluated)
						...[
							AttributeChip.withIcon(
								content: AppLocales.of(context).translate('$_pageKey.content.chips.notEvaluated'),
								icon: Icons.assignment_late,
								color: Colors.amber,
								tooltip:'$_pageKey.content.chips.notEvaluatedTooltip',
							),
							if (task.points.quantity != 0) getCurrencyChip(task, tooltip: '$_pageKey.content.chips.pointsPossible')
						]
			],
			actionButton: ItemCardActionButton(
				color: AppColors.childBackgroundColor, icon: Icons.check, onTapped: () => log("Tapped finished activity")
			),
		);
	}

	AttributeChip getCurrencyChip(UITaskInstance task, {String tooltip, bool pointsAwarded = false}) {
  	return AttributeChip.withCurrency(
			content: pointsAwarded ? task.status.pointsAwarded.toString() : task.points.quantity.toString(),
			currencyType: task.points.type,
			tooltip: tooltip
		);
	}

	AttributeChip getBreaksChip(UITaskInstance task) {
		return AttributeChip.withIcon(
			content: AppLocales.of(context).translate('$_pageKey.content.taskTimer.formatBreak', {
				'TIME_NUM' : formatDuration(Duration(seconds: sumDurations(task.breaks).inSeconds))
			}),
			icon: Icons.free_breakfast,
			color: Colors.indigo,
			tooltip:'$_pageKey.content.taskTimer.break',
		);
	}

	AttributeChip getDurationChip(UITaskInstance task) {
		return AttributeChip.withIcon(
			content: AppLocales.of(context).translate('$_pageKey.content.taskTimer.formatDuration', {
				'TIME_NUM': formatDuration(Duration(seconds: sumDurations(task.duration).inSeconds))
			}),
			icon: Icons.access_time,
			color: task.timer > sumDurations(task.duration).inMinutes ? Colors.lightGreen : Colors.deepOrange,
			tooltip: '$_pageKey.content.taskTimer.duration',
		);
	}

	AttributeChip getTimeChip(UITaskInstance task) {
  	return AttributeChip.withIcon(
			content: AppLocales.of(context).translate('$_pageKey.content.taskTimer.format', {
				'HOURS_NUM': (task.timer ~/ 60).toString(),
				'MINUTES_NUM': (task.timer % 60).toString()
			}),
			icon: Icons.timer,
			color: Colors.orange,
			tooltip: '$_pageKey.content.taskTimer.label',
		);
	}
}
