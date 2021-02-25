import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/child/task_completion/task_completion_cubit.dart';
import 'package:fokus/logic/common/timer/timer_cubit.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/duration_utils.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/widgets/buttons/double_circular_notched_button.dart';
import 'package:fokus/widgets/cards/item_card.dart';
import 'package:fokus/widgets/cards/sliding_card.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/general/app_loader.dart';
import 'package:fokus/widgets/large_timer.dart';
import 'package:fokus/widgets/stateful_bloc_builder.dart';
import 'package:fokus/widgets/task_app_header.dart';
import 'package:lottie/lottie.dart';

enum FabType {
	finish, discard
}

class ChildTaskInProgressPage extends StatefulWidget {

  const ChildTaskInProgressPage({Key key}) : super(key: key);

  @override
  _ChildTaskInProgressPageState createState() => _ChildTaskInProgressPageState();
}

class _ChildTaskInProgressPageState extends State<ChildTaskInProgressPage> with TickerProviderStateMixin {
  final String _pageKey = 'page.childSection.taskInProgress';
	Animation<Offset> _offsetAnimation;
	Animation<Offset> _taskListFabAnimation;
	AnimationController _bottomBarController;
	bool _isButtonDisabled = false;
	bool _isCheckboxDisabled = false;
	TimerCubit _timerBreakCubit;

	final GlobalKey<SlidingCardState> _breakCard = GlobalKey<SlidingCardState>();
	final GlobalKey<SlidingCardState> _completingCard = GlobalKey<SlidingCardState>();
	final GlobalKey<SlidingCardState> _rejectCard = GlobalKey<SlidingCardState>();
	final GlobalKey<SlidingCardState> _doneCard = GlobalKey<SlidingCardState>();
	final GlobalKey<TaskAppHeaderState> _header = GlobalKey<TaskAppHeaderState>();
	
	@override
  Widget build(BuildContext context) {
		return StatefulBlocBuilder<TaskCompletionCubit, TaskCompletionState, TaskCompletionState>(
			listener: _blocListener,
			loadingBuilder: (context, state) => _buildPage(state),
			builder: (context, state) => _buildPage(state)
		);
  }

  Widget _buildPage(TaskCompletionState state) {
	  return WillPopScope(
		  onWillPop: () async {
			  Navigator.of(context).pop(state is TaskCompletionState ? state.planInstance : null);
			  return false;
		  },
		  child: Scaffold(
			  appBar: !state.loaded ? _getHeader(TaskCompletionState(taskInstance: null, planInstance: state.planInstance)) : _getHeader(state),
			  body: !state.loaded ? Center(child: AppLoader()) : Padding(
				  padding: EdgeInsets.only(bottom: 0.0),
				  child: Stack(
					  children: _getAllCards(state)
				  )
			  ),
			  extendBody: true,
			  bottomNavigationBar: !state.loaded ? SizedBox.shrink() : _getBottomNavBar(),
			  floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
			  floatingActionButton: !state.loaded ? SizedBox.shrink() : Row(
				  mainAxisAlignment: MainAxisAlignment.spaceBetween,
				  children: <Widget>[
					  _getFab(FabType.discard),
					  SlideTransition(
						  position: _taskListFabAnimation,
						  child: FloatingActionButton.extended(
							  label: Row(
								  children: [
									  Icon(Icons.format_list_bulleted,),
									  Padding(
										  padding: const EdgeInsets.only(left: 8.0),
										  child: Text(AppLocales.of(context).translate('actions.return')),
									  ),
								  ],
							  ),
							  onPressed: () => Navigator.of(context).pop(state is TaskCompletionState ? state.planInstance : null),
							  heroTag: "fabTasks",
							  backgroundColor: AppColors.childTaskColor,
						  ),
					  ),
					  _getFab(FabType.finish)
				  ],
			  ),
		  ),
	  );
  }

  void _blocListener(BuildContext context, TaskCompletionState state) {
	  if (state is TaskCompletionState && state.submissionInProgress)
		  setState(() {
			  if (state.current == TaskCompletionStateType.finished) {
				  _closeWidgetsOnFinish(state);
				  _doneCard.currentState.openCard();
				  this._header.currentState.animateSuccess();
				  this._header.currentState.onFinish();
			  } if(state.current == TaskCompletionStateType.discarded) {
				  _closeWidgetsOnFinish(state);
				  _rejectCard.currentState.openCard();
				  this._header.currentState.onFinish();
			  } if(state.current == TaskCompletionStateType.inProgress) {
				  _breakCard.currentState.closeCard();
				  _completingCard.currentState.openCard();
				  this._header.currentState.animateButton();
				  _timerBreakCubit.pauseTimer();
			  } else if(state.current == TaskCompletionStateType.inBreak) {
				  _completingCard.currentState.closeCard();
				  _breakCard.currentState.openCard();
				  this._header.currentState.animateButton();
				  _timerBreakCubit.resumeTimer();
			  }
		  });
  }

  Widget _getHeader(TaskCompletionState state) {
		return TaskAppHeader(
			height: 330,
			title: '$_pageKey.header.title',
			popArgs: state is TaskCompletionState ? state.planInstance : null,
			content: ItemCard(
				title: state.planInstance.name,
				subtitle: state.planInstance.description(context),
				isActive: true,
				progressPercentage: state.planInstance.completedTaskCount.ceilToDouble() / state.planInstance.taskCount.ceilToDouble(),
				activeProgressBarColor: AppColors.childActionColor,
				textMaxLines: 2,
				chips:
				<Widget>[
					AttributeChip.withIcon(
						icon: Icons.description,
						color: AppColors.childBackgroundColor,
						content: AppLocales.of(context).translate('plans.taskProgress', {'NUM_TASKS': state.planInstance.completedTaskCount, 'NUM_ALL_TASKS': state.planInstance.taskCount})
					)
				],
			),
			key: _header,
			breakPerformingTransition: _breakPerformingTransition,
			state: state
		);
	}

  void _breakPerformingTransition(TaskCompletionState state) {
	  if(_isButtonDisabled)
	  	return;
	  _isButtonDisabled = true;
	  var cubit = BlocProvider.of<TaskCompletionCubit>(context);
	  if(state.current == TaskCompletionStateType.inProgress && !state.submissionInProgress)
		  cubit.switchToBreak();
	  else if (state.current == TaskCompletionStateType.inBreak && !state.submissionInProgress)
		  cubit.switchToProgress();
	  Timer(Duration(seconds: 2), () {
		  _isButtonDisabled = false;
	  });
  }

  Widget _getBottomNavBar() {
		return SlideTransition(
			position: _offsetAnimation,
			child: Container(
				height: 50,
				child: BottomAppBar(
					color: AppColors.childTaskFiller,
					shape: DoubleCircularNotchedButton(),
					clipBehavior: Clip.antiAlias,
					child: Padding(
						padding: const EdgeInsets.symmetric(horizontal: 84.0),
						child: Center(
							child: Text(
								AppLocales.of(context).translate('$_pageKey.content.isCompleted'),
								textAlign: TextAlign.center,
							),
						),
					),
				),
			),
		);
	}

  Widget _getFab(FabType type) {
		var cubit = BlocProvider.of<TaskCompletionCubit>(context);
		return SlideTransition(
			position: _offsetAnimation,
			child: Padding(
				padding: EdgeInsets.only(left: type == FabType.discard ? 32 : 0),
				child: FloatingActionButton(
					child: Icon(
						type == FabType.discard ? Icons.close : Icons.check,
					),
					onPressed: () => type == FabType.discard ? cubit.markAsDiscarded() : cubit.markAsFinished(),
					heroTag: type == FabType.discard ? "fabClose" :  "fabCheck",
					backgroundColor: type == FabType.discard ? AppColors.negativeColor : AppColors.positiveColor,
				),
			),
		);
	}

  List<Widget> _getAllCards(TaskCompletionState state) {
		return [
			SlidingCard(
				key: _completingCard,
				cardColor: AppColors.childTaskColor,
				content: [
					_getAnimation('assets/animation/jumping_little_man.json'),
					_getTitle(state.taskInstance.name, translate: false),
					if(state.taskInstance.description != null)
						_getSubtitle(state.taskInstance.description ,alignment: TextAlign.justify, translate: false, topPadding: 8),
					if(state.taskInstance.subtasks != null && state.taskInstance.subtasks.isNotEmpty)
						_getSubtasks(state.taskInstance.subtasks)
				],
				showFirst: state.current == TaskCompletionStateType.inProgress,
			),
			SlidingCard(
				key: _breakCard,
				cardColor: AppColors.childBreakColor,
				content: [
					_getAnimation('assets/animation/meditating_little_man.json'),
					_getTitle('$_pageKey.cards.break.title'),
					Padding(
						padding: const EdgeInsets.symmetric(horizontal: 8.0),
						child: BlocProvider<TimerCubit>(
							create: _getTimerBreakCubit(state),
							child:LargeTimer(
								textColor: AppColors.lightTextColor,
								title: '$_pageKey.content.breakTime',
								align: CrossAxisAlignment.center,
							),
						)
					)
				],
				showFirst: state.current == TaskCompletionStateType.inBreak,
			),
			SlidingCard(
				key: _rejectCard,
				cardColor: Colors.red,
				content: [
					SizedBox(
						height: 100,
						child: Icon(Icons.close, size: 80, color: AppColors.childTaskFiller,)
					),
					_getTitle('$_pageKey.cards.rejected.title'),
					_getSubtitle('$_pageKey.cards.rejected.content1'),
				],
				showFirst: state.current == TaskCompletionStateType.discarded,
			),
			SlidingCard(
				key: _doneCard,
				cardColor: AppColors.childBackgroundColor,
				content: [
					_getAnimation('assets/animation/cheering_little_man.json'),
					_getTitle('$_pageKey.cards.done.title'),
					_getSubtitle('$_pageKey.cards.done.content1'),
					Padding(
							padding: const EdgeInsets.only(top: 16.0),
							child: Text(
								AppLocales.of(context).translate('$_pageKey.cards.done.content2'),
								style: Theme.of(context).textTheme.subtitle2.copyWith(color: AppColors.lightTextColor, fontWeight: FontWeight.bold),
								textAlign: TextAlign.center,
							)
					)
				],
				showFirst: state.current == TaskCompletionStateType.finished,
			)
		];
	}

	Widget _getAnimation(String data) {
		return SizedBox(
			height: 100,
			child: Lottie.asset(data)
		);
	}

	TimerCubit Function(BuildContext) _getTimerBreakCubit(state) {
		if(_timerBreakCubit == null) {
			_timerBreakCubit = TimerCubit.up(() => sumDurations(state.taskInstance.breaks).inSeconds);
		}
		if(state.current == TaskCompletionStateType.inProgress) return (_) => _timerBreakCubit..startTimer(paused: true);
		else return (_) => _timerBreakCubit..startTimer();
	}

	Widget _getTitle(String title, {bool translate = true}) {
		return Text(
			translate ? AppLocales.of(context).translate(title) : title,
			style: Theme.of(context).textTheme.headline1.copyWith(color: AppColors.lightTextColor),
			textAlign: TextAlign.center
		);
	}

	Widget _getSubtitle(String subtitle, {bool translate = true, TextAlign alignment = TextAlign.center, double topPadding = 24.0}) {
		return Padding(
			padding: EdgeInsets.only(top: topPadding),
			child: Text(
				translate ? AppLocales.of(context).translate(subtitle) : subtitle,
				style: Theme.of(context).textTheme.subtitle1.copyWith(color: AppColors.lightTextColor, fontWeight: FontWeight.bold),
				textAlign: alignment,
			)
		);
	}

	Widget _getSubtasks(List<MapEntry<String, bool>> subtasks, {double topPadding = 24.0}) {
		return Padding(
			padding: EdgeInsets.only(top: topPadding),
			child: Column(
				children: [
					for (int i = 0; i < subtasks.length; i++)
						Padding(
							padding: const EdgeInsets.only(top: 12.0),
							child: Card(
								color: subtasks[i].value ? Colors.grey[350] : Theme.of(context).cardColor,
								shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppBoxProperties.roundedCornersRadius)),
								child: InkWell(
									splashColor: Colors.blueGrey[150],
									onTap: () => {},
									child: CheckboxListTile(
											value: subtasks[i].value,
											title: Padding(
												padding: const EdgeInsets.symmetric(vertical: 4.0),
												child: Text(
													subtasks[i].key,
													style: Theme.of(context).textTheme.subtitle1.copyWith(color: AppColors.darkTextColor, decoration: subtasks[i].value ? TextDecoration.lineThrough : TextDecoration.none),
												),
											),
											onChanged: (val) {
												setState(() {
													if(!_isCheckboxDisabled) {
														_isCheckboxDisabled = true;
														BlocProvider.of<TaskCompletionCubit>(context).updateChecks(i, MapEntry(subtasks[i].key, val));
														Timer(Duration(milliseconds: 200), () {
															_isCheckboxDisabled = false;
														});
													}
												});
											},
											activeColor: Colors.blue,
											checkColor: Colors.white,
										),
								),
							),
						)
				],
			),
		);
	}

  @override
  void initState() {
		super.initState();
		_bottomBarController = AnimationController(
			duration: const Duration(seconds: 1),
			vsync: this,
		);
		_offsetAnimation = Tween<Offset>(
			begin: Offset.zero,
			end: Offset(0, 2),
		).animate(CurvedAnimation(
			parent: _bottomBarController,
			curve: Curves.easeInOutQuint,
		));
		_taskListFabAnimation = Tween<Offset>(
			begin: Offset(0, 2),
			end: Offset.zero,
		).animate(CurvedAnimation(
			parent: _bottomBarController,
			curve: Curves.easeInOutQuint,
		));
	}

	void _closeWidgetsOnFinish(state) {
	  _completingCard.currentState.closeCard();
		_breakCard.currentState.closeCard();
		_bottomBarController.forward();
	}

	@override
  void dispose() {
		_bottomBarController.dispose();
    super.dispose();
  }
}
