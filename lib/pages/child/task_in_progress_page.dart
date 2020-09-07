import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/timer/timer_cubit.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/buttons/double_circular_notched_button.dart';
import 'package:fokus/widgets/cards/item_card.dart';
import 'package:fokus/widgets/cards/sliding_card.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/large_timer.dart';
import 'package:fokus/widgets/task_app_header.dart';
import 'package:lottie/lottie.dart';

enum TaskInProgressPageState {currentlyCompleting, inBreak, done, rejected}

class ChildTaskInProgressPage extends StatefulWidget {
  @override
  _ChildTaskInProgressPageState createState() => _ChildTaskInProgressPageState();
}

class _ChildTaskInProgressPageState extends State<ChildTaskInProgressPage> with TickerProviderStateMixin {
  final String _pageKey = 'page.childSection.taskInProgress';
  TaskInProgressPageState _state = TaskInProgressPageState.currentlyCompleting;
	Animation<Offset> _offsetAnimation;
	Animation<Offset> _taskListFabAnimation;
	AnimationController _bottomBarController;

	final GlobalKey<SlidingCardState> _breakCard = GlobalKey<SlidingCardState>();
	final GlobalKey<SlidingCardState> _completingCard = GlobalKey<SlidingCardState>();
	final GlobalKey<SlidingCardState> _rejectCard = GlobalKey<SlidingCardState>();
	final GlobalKey<SlidingCardState> _doneCard = GlobalKey<SlidingCardState>();
	final GlobalKey<TaskAppHeaderState> _header = GlobalKey<TaskAppHeaderState>();


	@override
  Widget build(BuildContext context) {
  	return Scaffold(
			appBar: _getHeader(),
			body: Stack(
				children: _getAllCards()
			),
			bottomNavigationBar: _getBottomNavBar(),
			floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
			floatingActionButton: Row(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				children: <Widget>[
					_getFab(true),
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
					_getFab(false)
				],
			),
		);
  }

  Widget _getHeader() {
		return TaskAppHeader(
			height: 330,
			title: '$_pageKey.header.title',
			appHeaderWidget: ItemCard(
				title: "Sprzątanie pokoju",
				subtitle: "Co każdy poniedziałek, środę, czwartek i piątek",
				isActive: true,
				progressPercentage: 0.4,
				activeProgressBarColor: AppColors.childActionColor,
				textMaxLines: 2,
				chips:
				<Widget>[
					AttributeChip.withIcon(
						icon: Icons.description,
						color: AppColors.childBackgroundColor,
						content: AppLocales.of(context).translate('page.childSection.panel.content.taskProgress', {'NUM_TASKS': 2, 'NUM_ALL_TASKS': 5})
					)
				],
			),
			helpPage: 'plan_info',
			key: _header,
			breakPerformingTransition: _breakPerformingTransition,
			isBreak: false
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

  Widget _getFab(bool cancel) {
		return SlideTransition(
			position: _offsetAnimation,
			child: Padding(
				padding: EdgeInsets.only(left: cancel ? 32 : 0),
				child: FloatingActionButton(
					child: Icon(
						cancel ? Icons.close : Icons.check,
					),
					onPressed: cancel ? _onRejection : _onCompletion,
					heroTag: cancel ? "fabClose" :  "fabCheck",
					backgroundColor: cancel ? AppColors.negativeColor : AppColors.positiveColor,
				),
			),
		);
	}

  List<Widget> _getAllCards() {
		return [
			SlidingCard(
				key: _completingCard,
				cardColor: AppColors.childTaskColor,
				content: [
					_getAnimation('assets/animation/jumping_little_man.json'),
					_getTitle("Tytuł zadania", translate: false),
					_getSubtitle("oszdfdfdfdfdfdfdfdfdfdfdsfdsffdsdfsfdsfsfdsfsdsadddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddfsfsfsdfsdfsfsfdsoszdfdfdfdfdfdfdfdfdfdfdsfdsffdsdfsfdsfsfdsfsdsadddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddfsfsfsdfsdfsfsfdsoszdfdfdfdfdfdfdfdfdfdfdsfdsffdsdfsfdsfsfdsfsdsadddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddfsfsfsdfsdfsfsfdsoszdfdfdfdfdfdfdfdfdfdfdsfdsffdsdfsfdsfsfdsfsdsadddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddfsfsfsdfsdfsfsfds",alignment: TextAlign.justify, translate: false, topPadding: 8),
				]
			),
			SlidingCard(
				key: _breakCard,
				cardColor: AppColors.childBreakColor,
				content: [
					_getAnimation('assets/animation/meditating_little_man.json'),
					_getTitle('$_pageKey.cards.break.title'),
					Padding(
						padding: const EdgeInsets.only(top: 8.0),
						child: BlocProvider<TimerCubit>(
							create: (_) => TimerCubit(() => 0)..startTimer(),
							child:LargeTimer(
								textColor: AppColors.lightTextColor,
								title: '$_pageKey.content.breakTime',
								align: CrossAxisAlignment.center,
							),
						),
					)
				]
			),
			SlidingCard(
				key: _rejectCard,
				cardColor: AppColors.childActionColor,
				content: [
					SizedBox(
							height: 100,
							child: Icon(Icons.close, size: 100, color: AppColors.childTaskFiller,)
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
		WidgetsBinding.instance.addPostFrameCallback((_) {
			_completingCard.currentState.jumpToEnd();
			_breakCard.currentState.jumpToEnd();
			_doneCard.currentState.jumpToEnd();
			_rejectCard.currentState.jumpToEnd();
			if(_state == TaskInProgressPageState.currentlyCompleting)
				_completingCard.currentState.openCard();
			else _breakCard.currentState.openCard();
		});
	}

 void _breakPerformingTransition() {
  	setState(() {
  		if(_state == TaskInProgressPageState.currentlyCompleting) {
  			_completingCard.currentState.closeCard();
  			_breakCard.currentState.openCard();
  			_state = TaskInProgressPageState.inBreak;
  			this._header.currentState.animateButton();
			}
  		else if(_state == TaskInProgressPageState.inBreak) {
				_breakCard.currentState.closeCard();
				_completingCard.currentState.openCard();
				_state = TaskInProgressPageState.currentlyCompleting;
				this._header.currentState.animateButton();
			}
  	});
  }

  void _onCompletion() {
		if(_state != TaskInProgressPageState.rejected && _state != TaskInProgressPageState.done)
			setState(() {
				_closeWidgetsOnFinish();
				_state = TaskInProgressPageState.done;
				_doneCard.currentState.openCard();
				this._header.currentState.animateSuccess();
				this._header.currentState.closeButton();
			});
	}

	void _onRejection() {
		if(_state != TaskInProgressPageState.rejected && _state != TaskInProgressPageState.done)
			setState(() {
				_closeWidgetsOnFinish();
				_state = TaskInProgressPageState.rejected;
				_rejectCard.currentState.openCard();
				this._header.currentState.closeButton();
			});
	}

	void _closeWidgetsOnFinish() {
		if(_state == TaskInProgressPageState.currentlyCompleting)
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
