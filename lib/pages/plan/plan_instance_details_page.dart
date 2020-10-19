import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/common/plan_instance_cubit.dart';
import 'package:fokus/logic/common/timer/timer_cubit.dart';
import 'package:fokus/model/db/plan/plan_instance_state.dart';
import 'package:fokus/model/db/plan/task_status.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/plan/ui_plan_instance.dart';
import 'package:fokus/utils/ui/snackbar_utils.dart';
import 'package:fokus/model/ui/task/ui_task_instance.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/duration_utils.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/widgets/custom_app_bars.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/cards/item_card.dart';
import 'package:fokus/widgets/chips/timer_chip.dart';
import 'package:fokus/widgets/dialogs/general_dialog.dart';
import 'package:fokus/widgets/general/app_loader.dart';
import 'package:fokus/widgets/loadable_bloc_builder.dart';
import 'package:fokus/widgets/segment.dart';

class PlanInstanceDetailsPage extends StatefulWidget {
	final UIPlanInstance initialPlanInstance;
	final bool showActions;

  PlanInstanceDetailsPage(Map<String, dynamic> args) : initialPlanInstance = args['plan'], showActions = args['actions'] ?? true;

  @override
  _PlanInstanceDetailsPageState createState() => new _PlanInstanceDetailsPageState();
}

class _PlanInstanceDetailsPageState extends State<PlanInstanceDetailsPage> {
	final String _pageKey = 'page.childSection.planInProgress';
	bool _wasPlanCompleted = false;
	UIPlanInstance updatedUiPlanInstance;

	void navigate(context, UITaskInstance task, UIPlanInstance plan) async {
		if(await BlocProvider.of<PlanInstanceCubit>(context).isOtherPlanInProgressDbCheck(tappedTaskInstance: task.id)) {
			showDialog(context: context,
				builder: (_) => GeneralDialog.discard(
					title: AppLocales.of(context).translate('$_pageKey.content.taskInProgressDialog.title'),
					content: AppLocales.of(context).translate('$_pageKey.content.taskInProgressDialog.content'),
				)
			);
		}
		else {
			final result = await Navigator.of(context).pushNamed(AppPage.childTaskInProgress.name, arguments: {"TaskId" : task.id, "UIPlanInstance" : plan});
			if(result != null) setState(() {
				_wasPlanCompleted = false;
				updatedUiPlanInstance =  (result as Map<String, dynamic>)['plan'];
			});
		}
	}

	@override
  Widget build(BuildContext context) {
		return Scaffold(
			body: LoadableBlocBuilder<PlanInstanceCubit>(
				builder: (context, state) => _getView(
					planInstance: (state as ChildTasksLoadSuccess).planInstance,
					content: AppSegments(segments: _buildPanelSegments(state))
				),
				loadingBuilder: (context, state) => _getView(
					planInstance: updatedUiPlanInstance ?? widget.initialPlanInstance,
					content: Expanded(child: Center(child: AppLoader()))
				),
			),
			floatingActionButton: widget.initialPlanInstance.state.ended || _wasPlanCompleted || !widget.showActions || (updatedUiPlanInstance!= null && updatedUiPlanInstance.state.ended) ?
				null :
				FloatingActionButton.extended(
				onPressed: _planCompletion,
				label: Text(AppLocales.of(context).translate('$_pageKey.content.fab.completePlan')),
				icon: Icon(Icons.rule),
				backgroundColor: AppColors.childActionColor,
				elevation: 4.0
			),
			floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
		);
  }

  Column _getView({UIPlanInstance planInstance, Widget content}) {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			verticalDirection: VerticalDirection.up,
			children: [
				content,
				_getHeader(planInstance),
			],
		);
	}

  List<Widget> _buildPanelSegments(ChildTasksLoadSuccess state) {
  	var mandatoryTasks = state.tasks.where((task) => task.optional == false).toList();
  	var optionalTasks = state.tasks.where((task) => task.optional == true).toList();
    return [
    	if(mandatoryTasks.isNotEmpty)
      _getTasksSegment(
				tasks: mandatoryTasks,
        title: '$_pageKey.content.toDoTasks',
				uiPlanInstance: state.planInstance,
      ),
			if(optionalTasks.isNotEmpty)
      	_getTasksSegment(
					tasks: optionalTasks,
					title: '$_pageKey.content.additionalTasks',
					uiPlanInstance: state.planInstance,
				)
    ];
  }

  Segment _getTasksSegment({List<UITaskInstance> tasks,String title, UIPlanInstance uiPlanInstance}) {
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
								if (task.timer != null && task.timer > 0) getTimeChip(task),
								if (task.points != null && task.points.quantity != 0) getCurrencyChip(task)
							],
							actionButton: ItemCardActionButton(
								color: AppColors.childButtonColor,
								icon: Icons.play_arrow,
								onTapped: () => navigate(context, task, uiPlanInstance),
								disabled: !widget.showActions,
							),
						)
					else if(task.taskUiType == TaskUIType.rejected)
						ItemCard(
							title: task.name,
							subtitle: task.description,
							chips:<Widget>[
								if (task.timer != null && task.timer > 0) getTimeChip(task),
								if (task.points != null && task.points.quantity != 0) getCurrencyChip(task)
							],
							actionButton: ItemCardActionButton(
								color: AppColors.childButtonColor,
								icon: Icons.refresh,
								onTapped: () => navigate(context, task, uiPlanInstance),
								disabled: !widget.showActions
							),
						)
					else if(task.taskUiType.inProgress)
						BlocProvider<TimerCubit>(
							create: (_) => TimerCubit.up(() => task.taskUiType == TaskUIType.currentlyPerformed ? sumDurations(task.duration).inSeconds : sumDurations(task.breaks).inSeconds)..startTimer(),
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
									color: AppColors.childActionColor,
									icon: Icons.launch,
									onTapped: () => navigate(context, task, uiPlanInstance),
									disabled: !widget.showActions
								),
							)
						)
					else if(task.taskUiType == TaskUIType.queued)
						ItemCard(
							title: task.name,
							subtitle: task.description,
							chips: <Widget>[
								if (task.timer != null && task.timer > 0) getTimeChip(task),
								if (task.points != null && task.points.quantity != 0) getCurrencyChip(task)
							],
							isActive: false,
							actionButton: ItemCardActionButton(
								color: Colors.grey[400],
								icon: Icons.keyboard_arrow_up,
								disabled: !widget.showActions
							),
						)
			]
		);
  }

	CustomContentAppBar _getHeader(UIPlanInstance planInstance) {
		return CustomContentAppBar(
			title: '$_pageKey.header.title',
			content: getCardHeader(planInstance),
			helpPage: 'plan_info'
		);
	}

  Widget getCardHeader(UIPlanInstance _planInstance) {
		var taskDescriptionKey = 'plans.' + (_planInstance.completedTaskCount > 0 ? 'taskProgress' : 'noTaskCompleted');
		var card = ItemCard(
			title: _planInstance.name,
			subtitle: _planInstance.description(context),
			isActive: _planInstance.state != PlanInstanceState.completed,
			activeProgressBarColor: AppColors.childActionColor,
			progressPercentage: _planInstance.state.inProgress ? _planInstance.completedTaskCount.ceilToDouble() / _planInstance.taskCount.ceilToDouble() : null,
			chips: [
				if(_planInstance.state.inProgress)
				...[
					isInProgress(_planInstance.duration) ? TimerChip(color: AppColors.childButtonColor) :
					AttributeChip.withIcon(
						icon: Icons.timer,
						color: Colors.orange,
						content: formatDuration(sumDurations(_planInstance.duration))
					),
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
  	if(isInProgress(_planInstance.duration))
  		return BlocProvider<TimerCubit>(
				create: (_) => TimerCubit.up(_planInstance.elapsedActiveTime)..startTimer(),
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
						if (task.points != null && task.points.quantity != 0) getCurrencyChip(task, pointsAwarded: true),
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
						]
			],
			actionButton: ItemCardActionButton(
				color: AppColors.childBackgroundColor,
				icon: Icons.check,
				disabled: !widget.showActions
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
			color: task.timer == null || task.timer > sumDurations(task.duration).inMinutes ? Colors.lightGreen : Colors.deepOrange,
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

	void _planCompletion() {
		showDialog(context: context,
			builder: (_) => GeneralDialog.confirm(
				title: AppLocales.of(context).translate('$_pageKey.content.fab.dialogTitle'),
				content: AppLocales.of(context).translate('$_pageKey.content.fab.dialogContent'),
				confirmColor: Colors.red,
				confirmText: 'actions.confirm',
				confirmAction: () {
					BlocProvider.of<PlanInstanceCubit>(context).completePlan();
					Navigator.pop(context);
					setState(() {
						_wasPlanCompleted = true;
					});
					showSuccessSnackbar(context, '$_pageKey.content.fab.completed');
				}
			),
		);
	}
}
