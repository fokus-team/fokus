import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/task_instance/task_instance_cubit.dart';
import 'package:fokus/logic/timer/timer_cubit.dart';
import 'package:fokus/model/ui/plan/ui_plan_instance.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/duration_utils.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/buttons/double_circular_notched_button.dart';
import 'package:fokus/widgets/cards/item_card.dart';
import 'package:fokus/widgets/cards/sliding_card.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/general/app_loader.dart';
import 'package:fokus/widgets/large_timer.dart';
import 'package:fokus/widgets/task_app_header.dart';
import 'package:lottie/lottie.dart';


class ChildTaskInProgressPage extends StatefulWidget {
	final UIPlanInstance initialPlanInstance;

  const ChildTaskInProgressPage({Key key, @required this.initialPlanInstance}) : super(key: key);

  @override
  _ChildTaskInProgressPageState createState() => _ChildTaskInProgressPageState();
}

class _ChildTaskInProgressPageState extends State<ChildTaskInProgressPage> with TickerProviderStateMixin {
  final String _pageKey = 'page.childSection.taskInProgress';
	Animation<Offset> _offsetAnimation;
	Animation<Offset> _taskListFabAnimation;
	AnimationController _bottomBarController;
	bool _isButtonDisabled = false;
	TimerCubit _timerBreakCubit;

	final GlobalKey<SlidingCardState> _breakCard = GlobalKey<SlidingCardState>();
	final GlobalKey<SlidingCardState> _completingCard = GlobalKey<SlidingCardState>();
	final GlobalKey<SlidingCardState> _rejectCard = GlobalKey<SlidingCardState>();
	final GlobalKey<SlidingCardState> _doneCard = GlobalKey<SlidingCardState>();
	final GlobalKey<TaskAppHeaderState> _header = GlobalKey<TaskAppHeaderState>();


	@override
  Widget build(BuildContext context) {
		return BlocBuilder<TaskInstanceCubit, TaskInstanceState>(
			builder: (context, state) {
				bool isInitial = false;
				if(state is TaskInstanceStateInitial) {
					BlocProvider.of<TaskInstanceCubit>(context).loadTaskInstance();
					isInitial = true;
				}
				return  Scaffold(
					appBar: isInitial ? _getHeader(TaskInstanceProvider(null, this.widget.initialPlanInstance)) : _getHeader(state),
					body: isInitial ? Center(child: AppLoader())
						: Padding(
						padding: EdgeInsets.only(bottom: 0.0),
						child: Stack(
							children: _getAllCards(state)
						)
					),
					extendBody: true,
					bottomNavigationBar: isInitial ? SizedBox.shrink() : _getBottomNavBar(),
					floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
					floatingActionButton: isInitial ? SizedBox.shrink()
						: Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: <Widget>[
							_getFab(true, state),
							SlideTransition(
								position: _taskListFabAnimation,
								child: FloatingActionButton.extended(
									label:
									Row(
										children: [
											Icon(Icons.format_list_bulleted,),
											Padding(
												padding: const EdgeInsets.only(left: 8.0),
												child: Text(AppLocales.of(context).translate('actions.return')),
											),
										],
									),
									onPressed: () => Navigator.of(context).pop(),
									heroTag: "fabTasks",
									backgroundColor: AppColors.childTaskColor,
								),
							),
							_getFab(false, state)
						],
					),
				);

			}
		);
  }

  Widget _getHeader(TaskInstanceProvider state) {
		return TaskAppHeader(
			height: 330,
			title: '$_pageKey.header.title',
			appHeaderWidget: ItemCard(
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
						content: AppLocales.of(context).translate('page.childSection.panel.content.taskProgress', {'NUM_TASKS': state.planInstance.completedTaskCount, 'NUM_ALL_TASKS': state.planInstance.taskCount})
					)
				],
			),
			helpPage: 'plan_info',
			key: _header,
			breakPerformingTransition: _breakPerformingTransition,
			state: state
		);
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
								textAlign: TextAlign.center,),
						),
					),
				),
			),
		);
	}

  Widget _getFab(bool cancel, state) {
		return SlideTransition(
			position: _offsetAnimation,
			child: Padding(
				padding: EdgeInsets.only(left: cancel ? 32 : 0),
				child: FloatingActionButton(
					child: Icon(
						cancel ? Icons.close : Icons.check,
					),
					onPressed: cancel ? () => _onRejection(state) : () => _onCompletion(state),
					heroTag: cancel ? "fabClose" :  "fabCheck",
					backgroundColor: cancel ? AppColors.negativeColor : AppColors.positiveColor,
				),
			),
		);
	}

  List<Widget> _getAllCards(TaskInstanceProvider state) {
		return [
			SlidingCard(
				key: _completingCard,
				cardColor: AppColors.childTaskColor,
				content: [
					_getAnimation('assets/animation/jumping_little_man.json'),
					_getTitle(state.taskInstance.name, translate: false),
					if(state.taskInstance.description != null) _getSubtitle(state.taskInstance.description ,alignment: TextAlign.justify, translate: false, topPadding: 8),
				],
				showFirst: state is TaskInstanceStateProgress,
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
				showFirst: state is TaskInstanceStateBreak,
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
				]
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
				]
			)
		];
	}

	Widget _getAnimation(String data) {
		return SizedBox(
			height: 100,
			child: Lottie.asset(data)
		);
	}

	CreateBloc _getTimerBreakCubit(state) {
		if(_timerBreakCubit == null) {
			_timerBreakCubit = TimerCubit.up(() => sumDurations(state.taskInstance.breaks).inSeconds);
		}
		if(state is TaskInstanceStateProgress) return (_) => _timerBreakCubit..startTimer()..pauseTimer();
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
		_taskListFabAnimation= Tween<Offset>(
			begin: Offset(0, 2),
			end: Offset.zero,
		).animate(CurvedAnimation(
			parent: _bottomBarController,
			curve: Curves.easeInOutQuint,
		));
	}

 void _breakPerformingTransition(state) {
  	if(!_isButtonDisabled) setState(() {
  		_isButtonDisabled = true;
  		if(state is TaskInstanceStateProgress) {
				BlocProvider.of<TaskInstanceCubit>(context).switchToBreak();
				_completingCard.currentState.closeCard();
  			_breakCard.currentState.openCard();
  			this._header.currentState.animateButton();
  			_timerBreakCubit.resumeTimer();
			}
  		else if(state is TaskInstanceStateBreak) {
				BlocProvider.of<TaskInstanceCubit>(context).switchToProgress();
				_breakCard.currentState.closeCard();
				_completingCard.currentState.openCard();
				this._header.currentState.animateButton();
				_timerBreakCubit.pauseTimer();
			}
			Timer(Duration(seconds: 2), () {
				_isButtonDisabled = false;
			});
  	});
  }

  void _onCompletion(state) {
		if(state is! TaskInstanceStateRejected && state is! TaskInstanceStateDone)
			setState(() {
				BlocProvider.of<TaskInstanceCubit>(context).markAsDone();
				_closeWidgetsOnFinish(state);
				_doneCard.currentState.openCard();
				this._header.currentState.animateSuccess();
				this._header.currentState.onFinish();
			});
	}

	void _onRejection(state) {
		if(state is! TaskInstanceStateRejected && state is! TaskInstanceStateDone)
			setState(() {
				BlocProvider.of<TaskInstanceCubit>(context).markAsRejected();
				_closeWidgetsOnFinish(state);
				_rejectCard.currentState.openCard();
				this._header.currentState.onFinish();
			});
	}

	void _closeWidgetsOnFinish(state) {
		if(state is TaskInstanceStateProgress)
			_completingCard.currentState.closeCard();
		else _breakCard.currentState.closeCard();
		_bottomBarController.forward();
	}

	@override
  void dispose() {
		_bottomBarController.dispose();
    super.dispose();
  }
}
