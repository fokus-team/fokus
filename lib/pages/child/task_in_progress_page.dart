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
	final GlobalKey<SlidingCardState> breakCard = GlobalKey<SlidingCardState>();
	final GlobalKey<SlidingCardState> completingCard = GlobalKey<SlidingCardState>();
	final GlobalKey<SlidingCardState> rejectCard = GlobalKey<SlidingCardState>();
	final GlobalKey<SlidingCardState> doneCard = GlobalKey<SlidingCardState>();
	final GlobalKey<TaskAppHeaderState> header = GlobalKey<TaskAppHeaderState>();



	@override
  Widget build(BuildContext context) {
  	return Scaffold(
			appBar: TaskAppHeader(
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
				key: header,
				breakPerformingTransition: _breakPerformingTransition,
				isBreak: false
			),
			body: Stack(
				children: [
					SlidingCard(
						key: completingCard,
						cardColor: Colors.lightBlue,
						content: [
							SizedBox(
								height: 100,
								child: Lottie.asset('assets/animation/jumping_little_man.json')
							),
							Text(
								"Tytuł zadania",
								style: Theme.of(context).textTheme.headline1.copyWith(color: Colors.white),
								textAlign: TextAlign.center
							),
							Padding(
								padding: const EdgeInsets.only(top: 8.0),
								child: Text(
									"oszdfdfdfdfdfdfdfdfdfdfdsfdsffdsdfsfdsfsfdsfsdsadddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddfsfsfsdfsdfsfsfdsoszdfdfdfdfdfdfdfdfdfdfdsfdsffdsdfsfdsfsfdsfsdsadddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddfsfsfsdfsdfsfsfdsoszdfdfdfdfdfdfdfdfdfdfdsfdsffdsdfsfdsfsfdsfsdsadddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddfsfsfsdfsdfsfsfdsoszdfdfdfdfdfdfdfdfdfdfdsfdsffdsdfsfdsfsfdsfsdsadddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddfsfsfsdfsdfsfsfds",
									style: Theme.of(context).textTheme.subtitle1.copyWith(color: Colors.white),
									textAlign: TextAlign.justify,
								)
							)
						]
					),
					SlidingCard(
						key: breakCard,
						cardColor: Colors.blueGrey,
						content: [
							SizedBox(
								height: 100,
								child: Lottie.asset('assets/animation/meditating_little_man.json')
							),
							Text(
								AppLocales.of(context).translate('$_pageKey.cards.break.title'),
								style: Theme.of(context).textTheme.headline1.copyWith(color: Colors.white),
								textAlign: TextAlign.center
							),
							Padding(
								padding: const EdgeInsets.only(top: 8.0),
								child: BlocProvider<TimerCubit>(
								create: (_) => TimerCubit(() => 0)..startTimer(),
									child:LargeTimer(
										textColor: Colors.white,
										title: '$_pageKey.content.breakTime',
										align: CrossAxisAlignment.center,
									),
								),
							)
						]
					),
					SlidingCard(
						key: doneCard,
						cardColor: Colors.lightGreen,
						content: [
							SizedBox(
								height: 100,
								child: Lottie.asset('assets/animation/cheering_little_man.json')
							),
							Text(
								AppLocales.of(context).translate('$_pageKey.cards.done.title'),
								style: Theme.of(context).textTheme.headline1.copyWith(color: Colors.white),
								textAlign: TextAlign.center
							),
							Padding(
								padding: const EdgeInsets.only(top: 24.0),
								child: Text(
									AppLocales.of(context).translate('$_pageKey.cards.done.content1'),
									style: Theme.of(context).textTheme.subtitle1.copyWith(color: Colors.white),
									textAlign: TextAlign.justify,
								)
							),
							Padding(
								padding: const EdgeInsets.only(top: 16.0),
								child: Text(
									AppLocales.of(context).translate('$_pageKey.cards.done.content2'),
									style: Theme.of(context).textTheme.subtitle2.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
									textAlign: TextAlign.justify,
								)
							)
						]
					),
					SlidingCard(
						key: rejectCard,
						cardColor: Colors.amber,
						content: [
							SizedBox(
								height: 100,
								child: Icon(Icons.close, size: 100, color: Colors.white,)
							),
							Text(
								AppLocales.of(context).translate('$_pageKey.cards.rejected.title'),
								style: Theme.of(context).textTheme.headline1.copyWith(color: Colors.white),
								textAlign: TextAlign.center
							),
							Padding(
								padding: const EdgeInsets.only(top: 24.0),
								child: Text(
									AppLocales.of(context).translate('$_pageKey.cards.rejected.content1'),
									style: Theme.of(context).textTheme.subtitle1.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
									textAlign: TextAlign.center,
								)
							),
						]
					),
				]
			),
			bottomNavigationBar: SlideTransition(
				position: _offsetAnimation,
			  child: Container(
			  	height: 50,
			  	child: BottomAppBar(
			  		color: Colors.white,
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
			),
			floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
			floatingActionButton: Row(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				children: <Widget>[
					SlideTransition(
						position: _offsetAnimation,
					  child: Padding(
					  	padding: EdgeInsets.only(left: 32),
					  	child: FloatingActionButton(
					  		child: Icon(
					  			Icons.close,
					  		),
					  		onPressed: _onRejection,
					  		heroTag: "fabClose",
					  		backgroundColor: Colors.red,
					  	),
					  ),
					),
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
					  	backgroundColor: Colors.lightBlue,
					  ),
					),
					SlideTransition(
						position: _offsetAnimation,
					  child: FloatingActionButton(
					  	child: Icon(
					  		Icons.check,
					  	),
					  	onPressed: _onCompletion,
					  	heroTag: "fabCheck",
					  	backgroundColor: Colors.lightGreen,
					  ),
					),
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
		_taskListFabAnimation= Tween<Offset>(
			begin: Offset(0, 2),
			end: Offset.zero,
		).animate(CurvedAnimation(
			parent: _bottomBarController,
			curve: Curves.easeInOutQuint,
		));
		WidgetsBinding.instance.addPostFrameCallback((_) {
			completingCard.currentState.jumpToEnd();
			breakCard.currentState.jumpToEnd();
			doneCard.currentState.jumpToEnd();
			rejectCard.currentState.jumpToEnd();
			if(_state == TaskInProgressPageState.currentlyCompleting)
				completingCard.currentState.openCard();
			else breakCard.currentState.openCard();
		});
	}

 void _breakPerformingTransition() {
  	setState(() {
  		if(_state == TaskInProgressPageState.currentlyCompleting) {
  			completingCard.currentState.closeCard();
  			breakCard.currentState.openCard();
  			_state = TaskInProgressPageState.inBreak;
  			this.header.currentState.animateButton();
			}
  		else if(_state == TaskInProgressPageState.inBreak) {
				breakCard.currentState.closeCard();
				completingCard.currentState.openCard();
				_state = TaskInProgressPageState.currentlyCompleting;
				this.header.currentState.animateButton();
			}
  	});
  }

  void _onCompletion() {
		if(_state != TaskInProgressPageState.rejected && _state != TaskInProgressPageState.done)
			setState(() {
				_closeWidgetsOnFinish();
				_state = TaskInProgressPageState.done;
				doneCard.currentState.openCard();
				this.header.currentState.animateSuccess();
				this.header.currentState.closeButton();
			});
	}

	void _onRejection() {
		if(_state != TaskInProgressPageState.rejected && _state != TaskInProgressPageState.done)
			setState(() {
				_closeWidgetsOnFinish();
				_state = TaskInProgressPageState.rejected;
				rejectCard.currentState.openCard();
				this.header.currentState.closeButton();
			});
	}

	void _closeWidgetsOnFinish() {
		if(_state == TaskInProgressPageState.currentlyCompleting)
			completingCard.currentState.closeCard();
		else breakCard.currentState.closeCard();
		_bottomBarController.forward();
	}

	@override
  void dispose() {
		_bottomBarController.dispose();
    super.dispose();
  }
}
