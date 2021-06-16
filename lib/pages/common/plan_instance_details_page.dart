import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/common/plan_instance_cubit.dart';
import 'package:fokus/logic/common/timer/timer_cubit.dart';
import 'package:fokus/model/db/plan/plan_instance_state.dart';
import 'package:fokus/model/db/plan/task_status.dart';
import 'package:fokus/model/navigation/plan_instance_params.dart';
import 'package:fokus/model/navigation/task_in_progress_params.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/plan/ui_plan_instance.dart';
import 'package:fokus/utils/navigation_utils.dart';
import 'package:fokus/utils/ui/dialog_utils.dart';
import 'package:fokus/utils/ui/snackbar_utils.dart';
import 'package:fokus/model/ui/plan/ui_task_instance.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/duration_utils.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/widgets/custom_app_bars.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/cards/item_card.dart';
import 'package:fokus/widgets/chips/timer_chip.dart';
import 'package:fokus/widgets/dialogs/general_dialog.dart';
import 'package:fokus/widgets/general/app_loader.dart';
import 'package:fokus/widgets/stateful_bloc_builder.dart';
import 'package:fokus/widgets/segment.dart';

class PlanInstanceDetailsPage extends StatefulWidget {
	final bool showActions;

  PlanInstanceDetailsPage(PlanInstanceParams args) : showActions = args.actions ?? true;

  @override
  _PlanInstanceDetailsPageState createState() => new _PlanInstanceDetailsPageState();
}

class _PlanInstanceDetailsPageState extends State<PlanInstanceDetailsPage> {
	static const String _pageKey = 'page.childSection.planInProgress';

	void navigate(context, UITaskInstance task, UIPlanInstance plan) async {
		if(await BlocProvider.of<PlanInstanceCubit>(context).isOtherPlanInProgressDbCheck(tappedTaskInstance: task.instance.id)) {
			showBasicDialog(
				context,
				GeneralDialog.discard(
					title: AppLocales.of(context).translate('$_pageKey.content.taskInProgressDialog.title'),
					content: AppLocales.of(context).translate('$_pageKey.content.taskInProgressDialog.content'),
				)
			);
		}
		else {
			final result = await navigateChecked(context, AppPage.childTaskInProgress, arguments: TaskInProgressParams(taskId: task.instance.id!, planInstance: plan));
			if(result != null)
				BlocProvider.of<PlanInstanceCubit>(context).uiPlan = result;
		}
	}

	@override
  Widget build(BuildContext context) {
    var showEndButton = !context.watch<PlanInstanceCubit>().uiPlan.instance.state!.ended && widget.showActions;
    return Scaffold(
      body: SimpleStatefulBlocBuilder<PlanInstanceCubit, PlanInstanceCubitState>(
        builder: (context, state) {
          return _getView(
            planInstance: state.uiPlan,
            content: AppSegments(segments: _buildPanelSegments(state))
          );
        },
        loadingBuilder: (context, state) => _getView(
          planInstance: BlocProvider.of<PlanInstanceCubit>(context).uiPlan,
          content: Expanded(child: Center(child: AppLoader()))
        ),
        listener: (context, state) {
          if (state.submitted)
            showSuccessSnackbar(context, '$_pageKey.content.fab.completed');
        },
        popConfig: SubmitPopConfig(),
		  ),
      floatingActionButton: showEndButton ? FloatingActionButton.extended(
        onPressed: _completePlan,
        label: Text(AppLocales.of(context).translate('$_pageKey.content.fab.completePlan')),
        icon: Icon(Icons.rule),
        backgroundColor: AppColors.childActionColor,
        elevation: 4.0
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Column _getView({required UIPlanInstance planInstance, required Widget content}) {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			verticalDirection: VerticalDirection.up,
			children: [
				content,
				_getHeader(planInstance),
			],
		);
	}

  List<Widget> _buildPanelSegments(PlanInstanceCubitState state) {
  	var mandatoryTasks = state.tasks.where((uiTask) => uiTask.task.optional == false).toList();
  	var optionalTasks = state.tasks.where((uiTask) => uiTask.task.optional == true).toList();
    return [
    	if(mandatoryTasks.isNotEmpty)
      _getTasksSegment(
				tasks: mandatoryTasks,
        title: '$_pageKey.content.toDoTasks',
				uiPlanInstance: state.uiPlan,
      ),
			if(optionalTasks.isNotEmpty)
      	_getTasksSegment(
					tasks: optionalTasks,
					title: '$_pageKey.content.additionalTasks',
					uiPlanInstance: state.uiPlan,
				)
    ];
  }

  Segment _getTasksSegment({required List<UITaskInstance> tasks, required String title, required UIPlanInstance uiPlanInstance}) {
    return Segment(
			title: title,
			noElementsMessage: '$_pageKey.content.noTasks',
			elements: <Widget>[
				for(var uiTask in tasks)
					if(uiTask.state == TaskInstanceState.completed)
						_getCompletedTaskCard(uiTask)
					else if(uiTask.state == TaskInstanceState.available)
						ItemCard(
							title: uiTask.task.name!,
							subtitle: uiTask.task.description,
							chips:<Widget>[
								if (uiTask.instance.timer != null && uiTask.instance.timer! > 0) _getTimeChip(uiTask),
								if (uiTask.task.points != null && uiTask.task.points!.quantity != 0) _getCurrencyChip(uiTask)
							],
							onTapped: () => widget.showActions ? navigate(context, uiTask, uiPlanInstance) : null,
							actionButton: ItemCardActionButton(
								color: AppColors.childButtonColor,
								icon: Icons.play_arrow,
								onTapped: () => navigate(context, uiTask, uiPlanInstance),
								disabled: !widget.showActions,
							),
						)
					else if(uiTask.state == TaskInstanceState.rejected)
						ItemCard(
							title: uiTask.task.name!,
							subtitle: uiTask.task.description,
							chips:<Widget>[
								if (uiTask.instance.timer != null && uiTask.instance.timer! > 0) _getTimeChip(uiTask),
								if (uiTask.task.points != null && uiTask.task.points!.quantity != 0) _getCurrencyChip(uiTask)
							],
							onTapped: () => widget.showActions ? navigate(context, uiTask, uiPlanInstance) : null,
							actionButton: ItemCardActionButton(
								color: AppColors.childButtonColor,
								icon: Icons.refresh,
								onTapped: () => navigate(context, uiTask, uiPlanInstance),
								disabled: !widget.showActions
							),
						)
					else if(uiTask.state!.inProgress)
						BlocProvider<TimerCubit>(
							create: (_) => TimerCubit.up(() => uiTask.state == TaskInstanceState.currentlyPerformed ?
								sumDurations(uiTask.instance.duration).inSeconds : sumDurations(uiTask.instance.breaks).inSeconds)..startTimer(),
							child:	ItemCard(
								title: uiTask.task.name!,
								subtitle: uiTask.task.description,
								chips:
								<Widget>[
									if(uiTask.state == TaskInstanceState.currentlyPerformed)
										...[
											TimerChip(
												icon: Icons.access_time,
												color: Colors.lightGreen,
											),
											_getBreaksChip(uiTask)
										]
									else
										...[
											_getDurationChip(uiTask),
											TimerChip(
												icon: Icons.free_breakfast,
												color: Colors.indigo,
											),
										]
								],
								onTapped: () => widget.showActions ? navigate(context, uiTask, uiPlanInstance) : null,
								actionButton: ItemCardActionButton(
									color: AppColors.childActionColor,
									icon: Icons.launch,
									onTapped: () => navigate(context, uiTask, uiPlanInstance),
									disabled: !widget.showActions
								),
							)
						)
					else if(uiTask.state == TaskInstanceState.queued)
						ItemCard(
							title: uiTask.task.name!,
							subtitle: uiTask.task.description,
							chips: <Widget>[
								if (uiTask.instance.timer != null && uiTask.instance.timer! > 0) _getTimeChip(uiTask),
								if (uiTask.task.points != null && uiTask.task.points!.quantity != 0) _getCurrencyChip(uiTask)
							],
							isActive: false,
							actionButton: ItemCardActionButton(
								color: Colors.grey[400]!,
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
			content: _getCardHeader(planInstance)
		);
	}

  Widget _getCardHeader(UIPlanInstance uiPlan) {
		var taskDescriptionKey = 'plans.' + (uiPlan.completedTaskCount! > 0 ? 'taskProgress' : 'noTaskCompleted');
		var card = ItemCard(
			title: uiPlan.plan.name!,
			subtitle: uiPlan.description!,
			isActive: uiPlan.instance.state != PlanInstanceState.completed,
			activeProgressBarColor: AppColors.childActionColor,
			progressPercentage: (uiPlan.instance.state!.inProgress ||  uiPlan.instance.state!.ended)
					? uiPlan.completedTaskCount!.ceilToDouble() / uiPlan.instance.tasks!.length.ceilToDouble() : null,
			chips: [
				if(uiPlan.instance.state!.inProgress)
				...[
					isInProgress(uiPlan.instance.duration) ? TimerChip(color: AppColors.childButtonColor) :
					AttributeChip.withIcon(
						icon: Icons.timer,
						color: Colors.orange,
						content: formatDuration(sumDurations(uiPlan.instance.duration)),
						tooltip: AppLocales.of(context).translate('$_pageKey.content.chips.timer')
					),
					AttributeChip.withIcon(
						icon: Icons.description,
						color: Colors.lightGreen,
						content: AppLocales.of(context).translate(
							taskDescriptionKey,
							{'NUM_TASKS': uiPlan.completedTaskCount!, 'NUM_ALL_TASKS': uiPlan.instance.tasks!.length}
						)
					)
				]
				else
				...[
					AttributeChip.withIcon(
						icon: Icons.timer,
						color: Colors.orange,
						content: formatDuration(sumDurations(uiPlan.instance.duration)),
						tooltip: AppLocales.of(context).translate('$_pageKey.content.chips.timer')
					),
					AttributeChip.withIcon(
						icon: Icons.description,
						color: AppColors.mainBackgroundColor,
						content: AppLocales.of(context).translate('$_pageKey.content.tasks', {'NUM_TASKS': uiPlan.instance.tasks!.length})
					)
				]
			]);
  	if(isInProgress(uiPlan.instance.duration))
  		return BlocProvider<TimerCubit>(
				create: (_) => TimerCubit.up(uiPlan.elapsedActiveTime!)..startTimer(),
				child: card
			);
  	else return card;
	}

	Widget _getCompletedTaskCard(UITaskInstance uiTask) {
		return ItemCard(
			title: uiTask.task.name!,
			subtitle: uiTask.task.description,
			chips:
			<Widget>[
				if(uiTask.instance.status!.state == TaskState.evaluated)
					...[
						AttributeChip.withIcon(
							content: AppLocales.of(context).translate('$_pageKey.content.chips.rating', {
								'RATING' : uiTask.instance.status!.rating!
							}),
							icon: Icons.star,
							color: AppColors.chipRatingColors[uiTask.instance.status!.rating!],
						),
						if (uiTask.task.points != null && uiTask.task.points!.quantity != 0) _getCurrencyChip(uiTask, pointsAwarded: true),
					]
				else if(uiTask.instance.status!.state == TaskState.rejected)
					AttributeChip.withIcon(
						content: AppLocales.of(context).translate('$_pageKey.content.chips.rejected'),
						icon: Icons.close,
						color: Colors.red,
						tooltip: AppLocales.of(context).translate('$_pageKey.content.chips.rejectedTooltip'),
					)
				else if(uiTask.instance.status!.state == TaskState.notEvaluated)
						...[
							AttributeChip.withIcon(
								content: AppLocales.of(context).translate('$_pageKey.content.chips.notEvaluated'),
								icon: Icons.assignment_late,
								color: Colors.amber,
								tooltip: AppLocales.of(context).translate('$_pageKey.content.chips.notEvaluatedTooltip'),
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

	AttributeChip _getCurrencyChip(UITaskInstance uiTask, {String? tooltip, bool pointsAwarded = false}) {
  	return AttributeChip.withCurrency(
			content: pointsAwarded ? uiTask.instance.status!.pointsAwarded.toString() : uiTask.task.points!.quantity.toString(),
			currencyType: uiTask.task.points!.type!,
			tooltip: tooltip ?? uiTask.task.points!.name
		);
	}

	AttributeChip _getBreaksChip(UITaskInstance uiTask) {
		return AttributeChip.withIcon(
			content: AppLocales.of(context).translate('$_pageKey.content.taskTimer.formatBreak', {
				'TIME_NUM' : formatDuration(Duration(seconds: sumDurations(uiTask.instance.breaks).inSeconds))
			}),
			icon: Icons.free_breakfast,
			color: Colors.indigo,
			tooltip: AppLocales.of(context).translate('$_pageKey.content.taskTimer.break'),
		);
	}

	AttributeChip _getDurationChip(UITaskInstance uiTask) {
		return AttributeChip.withIcon(
			content: AppLocales.of(context).translate('$_pageKey.content.taskTimer.formatDuration', {
				'TIME_NUM': formatDuration(Duration(seconds: sumDurations(uiTask.instance.duration).inSeconds))
			}),
			icon: Icons.access_time,
			color: uiTask.instance.timer == null || uiTask.instance.timer! > sumDurations(uiTask.instance.duration).inMinutes ? Colors.lightGreen : Colors.deepOrange,
			tooltip: AppLocales.of(context).translate('$_pageKey.content.taskTimer.duration'),
		);
	}

	AttributeChip _getTimeChip(UITaskInstance uiTask) {
  	return AttributeChip.withIcon(
			content: AppLocales.of(context).translate('$_pageKey.content.taskTimer.format', {
				'HOURS_NUM': (uiTask.instance.timer! ~/ 60).toString(),
				'MINUTES_NUM': (uiTask.instance.timer! % 60).toString()
			}),
			icon: Icons.timer,
			color: Colors.orange,
			tooltip: AppLocales.of(context).translate('$_pageKey.content.taskTimer.label'),
		);
	}

	void _completePlan() {
		showBasicDialog(
			context,
			GeneralDialog.confirm(
				title: AppLocales.of(context).translate('$_pageKey.content.fab.dialogTitle'),
				content: AppLocales.of(context).translate('$_pageKey.content.fab.dialogContent'),
				confirmColor: Colors.red,
				confirmText: 'actions.confirm',
				confirmAction: () => context.read<PlanInstanceCubit>().completePlan()
			),
		);
	}
}
