import 'package:auto_size_text/auto_size_text.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/timer/timer_cubit.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/app_header.dart';
import 'package:fokus/widgets/buttons/double_circular_notched_button.dart';
import 'package:fokus/widgets/cards/item_card.dart';
import 'package:fokus/widgets/cards/sliding_card.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/large_timer.dart';
import 'package:lottie/lottie.dart';

enum TaskInProgressPageState {currentlyCompleting, inBreak, done, rejected}

class ChildTaskInProgressPage extends StatefulWidget {
  @override
  _ChildTaskInProgressPageState createState() => _ChildTaskInProgressPageState();
}

class _ChildTaskInProgressPageState extends State<ChildTaskInProgressPage> with TickerProviderStateMixin {
  final String _pageKey = 'page.childSection.taskInProgress';
  TaskInProgressPageState _state = TaskInProgressPageState.currentlyCompleting;
	AnimationController _buttonController;
	AnimationController _bottomBarController;
	Animation<Offset> _offsetAnimation;
	Animation<Offset> _taskListFabAnimation;
	ConfettiController _confetti;
	final GlobalKey<SlidingCardState> breakCard = GlobalKey<SlidingCardState>();
	final GlobalKey<SlidingCardState> completingCard = GlobalKey<SlidingCardState>();
	final GlobalKey<SlidingCardState> rejectCard = GlobalKey<SlidingCardState>();
	final GlobalKey<SlidingCardState> doneCard = GlobalKey<SlidingCardState>();




	@override
  Widget build(BuildContext context) {
  	return Scaffold(
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Container(
						child: Stack(
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
											"Trwa przerwa, odpocznij chwilę!",
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
											"Zadanie wykonane!",
											style: Theme.of(context).textTheme.headline1.copyWith(color: Colors.white),
											textAlign: TextAlign.center
										),
										Padding(
											padding: const EdgeInsets.only(top: 24.0),
											child: Text(
												"Punkty otrzymasz po zatwierdzeniu przez opiekuna.",
												style: Theme.of(context).textTheme.subtitle1.copyWith(color: Colors.white),
												textAlign: TextAlign.justify,
											)
										),
										Padding(
											padding: const EdgeInsets.only(top: 16.0),
											child: Text(
												"Kontynuuj wykonywanie zadań!",
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
											"Zadanie anulowane",
											style: Theme.of(context).textTheme.headline1.copyWith(color: Colors.white),
											textAlign: TextAlign.center
										),
										Padding(
											padding: const EdgeInsets.only(top: 24.0),
											child: Text(
												"Możesz ponownie wykonać to zadanie \nlub przejść do następnego!",
												style: Theme.of(context).textTheme.subtitle1.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
												textAlign: TextAlign.center,
											)
										),
									]
								),
								Container(
									decoration: BoxDecoration(
										color: Colors.white,
									),
								  child: Column(
								  	children: [
											AppHeader.widget(
												title: '$_pageKey.header.title',
												appHeaderWidget: ItemCard(
													title: "Sprzątanie pokoju",
													subtitle: "Co każdy poniedziałek, środę, czwartek i piątek",
													isActive: true,
													progressPercentage: 0.4,
													activeProgressBarColor: AppColors.childActionColor,
													chips:
													<Widget>[
														AttributeChip.withIcon(
															icon: Icons.description,
															color: AppColors.childBackgroundColor,
															content: AppLocales.of(context).translate('page.childSection.panel.content.taskProgress', {'NUM_TASKS': 2, 'NUM_ALL_TASKS': 5})
														)
													],
												),
												helpPage: 'plan_info'
											),
								  		Padding(
								  			padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
								  			child: Row(
								  				mainAxisAlignment: MainAxisAlignment.spaceBetween,
								  				children: [
								  					BlocProvider<TimerCubit>(
								  						create: (_) => TimerCubit(() => 0)..startTimer(),
								  						child:LargeTimer(
								  							textColor: Colors.black,
								  							title: '$_pageKey.content.timeLeft',
								  						),
								  					),
								  					RaisedButton(
															padding: EdgeInsets.all(0),
								  						child: AnimatedContainer(
																decoration: ShapeDecoration(
																	shape: RoundedRectangleBorder(
																		borderRadius: BorderRadius.circular(4)
																	),
																	color: _state == TaskInProgressPageState.currentlyCompleting ? Colors.blueGrey : Colors.lightBlue,
																),
																duration: Duration(milliseconds: 1500),
								  						  child: Padding(
								  						  	padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
								  						  	child: Row(
								  						  		mainAxisAlignment: MainAxisAlignment.spaceBetween,
								  						  		children: [
								  						  			AnimatedIcon(
								  						  				icon: AnimatedIcons.pause_play,
								  						  				size: 28,
								  						  				progress: _buttonController,
								  						  				color: Colors.white,
								  						  			),
								  						  			Padding(
								  						  			  padding: const EdgeInsets.only(left: 8),
								  						  			  child: AutoSizeText(
																				_state == TaskInProgressPageState.currentlyCompleting ? "Przerwa" : "Wznów",
								  						  			  	style: Theme.of(context).textTheme.headline2.copyWith(color: Colors.white),
								  						  			  	maxLines: 1,
								  						  			  	minFontSize: 12,
								  						  			  	softWrap: false,
								  						  			  	overflowReplacement: SizedBox.shrink(),
								  						  			  ),
								  						  			)
								  						  		],
								  						  	),
								  						  ),
								  						),
								  						onPressed: () => _breakPerformingTransition(),
								  						elevation: 4.0
								  					),
								  				],
								  			),
								  		),
								  		Padding(
								  			padding: const EdgeInsets.symmetric(horizontal: 16.0),
								  			child: Container(
								  				decoration: AppBoxProperties.elevatedContainer.copyWith(borderRadius: BorderRadius.vertical(top: Radius.circular(4))),
								  				child: Padding(
								  					padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
								  					child: Row(
								  						mainAxisAlignment: MainAxisAlignment.spaceBetween,
								  						children: [
								  							Text(
								  								"Do zdobycia:"
								  							),
								  							AttributeChip.withCurrency(
								  								content: "+30",
								  								currencyType: CurrencyType.diamond
								  							)
								  						],
								  					),
								  				),
								  			),
								  		),
											Row(
												mainAxisAlignment: MainAxisAlignment.spaceBetween,
											  children: [
											    ConfettiWidget(
														shouldLoop: true,
											    	blastDirection: 0,
											    	confettiController: _confetti,
											    ),
													ConfettiWidget(
														shouldLoop: true,
														confettiController: _confetti,
													),
											  ],
											),
								  	],
								  ),
								)
							],
						),
					)
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
			  		    	"Wykonano zadanie?",
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
					  		    Text("Powrót do listy zadań"),
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
		_buttonController = AnimationController(duration: Duration(milliseconds: 450), vsync: this);
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
		_confetti = ConfettiController(
			duration: Duration(seconds: 10)
		);
		WidgetsBinding.instance.addPostFrameCallback((_) {
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
				_buttonController.forward();
			}
  		else if(_state == TaskInProgressPageState.inBreak) {
				breakCard.currentState.closeCard();
				completingCard.currentState.openCard();
				_state = TaskInProgressPageState.currentlyCompleting;
				_buttonController.reverse();
			}
  	});
  }

  void _onCompletion() {
		if(_state != TaskInProgressPageState.rejected && _state != TaskInProgressPageState.done)
			setState(() {
				_closeWidgetsOnFinish();
				_state = TaskInProgressPageState.done;
				doneCard.currentState.openCard();
				_confetti.play();
			});
	}

	void _onRejection() {
		if(_state != TaskInProgressPageState.rejected && _state != TaskInProgressPageState.done)
			setState(() {
				_closeWidgetsOnFinish();
				_state = TaskInProgressPageState.rejected;
				rejectCard.currentState.openCard();
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
		_buttonController.dispose();
		_bottomBarController.dispose();
		_confetti.dispose();
    super.dispose();
  }
}
