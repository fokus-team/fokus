import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/large_timer.dart';
import 'package:lottie/lottie.dart';

enum TaskInProgressPageState {currentlyCompleting, inBreak, done}

class ChildTaskInProgressPage extends StatefulWidget {
  @override
  _ChildTaskInProgressPageState createState() => _ChildTaskInProgressPageState();
}

class _ChildTaskInProgressPageState extends State<ChildTaskInProgressPage> with TickerProviderStateMixin {
  final String _pageKey = 'page.childSection.taskInProgress';
  TaskInProgressPageState _state = TaskInProgressPageState.currentlyCompleting;
  bool _canBounce = true;
	AnimationController _animationController;
	var _controller = ScrollController(
		keepScrollOffset: false
	);
	AnimationController _slideControllerCompletion;
	AnimationController _slideControllerBreak;
	Animation<Offset> _offsetAnimationCompletion;
	Animation<Offset> _offsetAnimationBreak;
	ScrollController _scrollControllerCompletion;
	ScrollController _scrollControllerBreak;


	@override
  Widget build(BuildContext context) {
  	return Scaffold(
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Container(
						child: Stack(
							children: [
								Column(
								  children: [
								    Padding(
								      padding: const EdgeInsets.only(top: 325),
								      child: SlideTransition(
								      	position: _offsetAnimationCompletion,
								      	child: NotificationListener<OverscrollIndicatorNotification>(
								      		onNotification: (overscroll) {
								      			overscroll.disallowGlow();
								      			return false;
								      		},
								      		child: Padding(
								      			padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 0),
								      			child: ConstrainedBox(
																constraints: BoxConstraints(
																	maxHeight: MediaQuery.of(context).size.height*0.39
																),
								      			  child: ListView(
								    						shrinkWrap: false,
								    					controller: _scrollControllerCompletion,
								      			  	physics: ClampingScrollPhysics(),
								      			  	padding: EdgeInsets.all(0),
								      			  	children: [
								      			  		Container(
								      			  			decoration: AppBoxProperties.elevatedContainer.copyWith(color: Colors.lightBlue, borderRadius: BorderRadius.vertical(bottom: Radius.circular(4))),
								      			  			child: Padding(
								      			  				padding: const EdgeInsets.all(12.0),
								      			  				child: Column(
								      			  					children: [
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
								      			  							),
								      			  						)
								      			  					],
								      			  				),
								      			  			),
								      			  		),
								      			  		SizedBox(
								      			  			height: 60,
								      			  		)
								      			  	]
								      			  ),
								      			),
								      		),
								      	),
								      ),
								    ),
								  ],
								),
								Column(
									children: [
										Padding(
											padding: const EdgeInsets.only(top: 325),
											child: SlideTransition(
												position: _offsetAnimationBreak,
												child: NotificationListener<OverscrollIndicatorNotification>(
													onNotification: (overscroll) {
														overscroll.disallowGlow();
														return false;
													},
													child: Padding(
														padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 0),
														child: ConstrainedBox(
															constraints: BoxConstraints(
																maxHeight: MediaQuery.of(context).size.height*0.39
															),
															child: ListView(
																shrinkWrap: false,
																controller: _scrollControllerBreak,
																physics: ClampingScrollPhysics(),
																padding: EdgeInsets.all(0),
																children: [
																	Container(
																		decoration: AppBoxProperties.elevatedContainer.copyWith(color: Colors.blueGrey, borderRadius: BorderRadius.vertical(bottom: Radius.circular(4))),
																		child: Padding(
																			padding: const EdgeInsets.all(12.0),
																			child: Column(
																				children: [
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
																				],
																			),
																		),
																	),
																	SizedBox(
																		height: 60,
																	)
																]
															),
														),
													),
												),
											),
										),
									],
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
								  						  				progress: _animationController,
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
								  	],
								  ),
								)
							],
						),
					)
				]
			),
			bottomNavigationBar: Container(
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
			floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
			floatingActionButton: Row(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				children: <Widget>[
					Padding(
						padding: EdgeInsets.only(left: 32),
						child: FloatingActionButton(
							child: Icon(
								Icons.close,
							),
							onPressed: () {},
							heroTag: "fabClose",
							backgroundColor: Colors.red,
						),
					),
					FloatingActionButton(
						child: Icon(
							Icons.check,
						),
						onPressed: () {},
						heroTag: "fabCheck",
						backgroundColor: Colors.lightGreen,
					),
				],
			),
		);
  }

  @override
  void initState() {
		super.initState();
		_animationController = AnimationController(duration: Duration(milliseconds: 450), vsync: this);
		_controller.addListener(() {
			setState(() {
				if (!_canBounce && (_controller.position.userScrollDirection == ScrollDirection.reverse)) _canBounce = true;
				else _canBounce = false;
			});
		});
		_slideControllerCompletion = AnimationController(
			duration: const Duration(seconds: 2),
			vsync: this,
		);
		_slideControllerBreak= AnimationController(
			duration: const Duration(seconds: 2),
			vsync: this,
		);
		_offsetAnimationCompletion = Tween<Offset>(
			begin: Offset(0, -1),
			end: Offset.zero,
		).animate(CurvedAnimation(
			parent: _slideControllerCompletion,
			curve: Curves.easeInOutQuint,
		));
		_offsetAnimationBreak = Tween<Offset>(
			begin: Offset(0, -2),
			end: Offset.zero,
		).animate(CurvedAnimation(
			parent: _slideControllerBreak,
			curve: Curves.easeInOutQuint,
		));
		_scrollControllerCompletion = ScrollController();
		_scrollControllerBreak = ScrollController();
		WidgetsBinding.instance.addPostFrameCallback((_) {
			_slideControllerCompletion.forward();
			_scrollControllerCompletion.jumpTo(_scrollControllerCompletion.position.maxScrollExtent);
			_scrollControllerCompletion.animateTo(
				_scrollControllerCompletion.position.minScrollExtent,
				duration: Duration(milliseconds: 3000),
				curve: Curves.easeInOutQuint
			);
		});
	}

 void _breakPerformingTransition() {
  	setState(() {
  		if(_state == TaskInProgressPageState.currentlyCompleting) {
  			_state = TaskInProgressPageState.inBreak;
				_animationController.forward();
				_scrollControllerCompletion.animateTo(
					_scrollControllerCompletion.position.maxScrollExtent,
					duration: Duration(milliseconds: 1000),
					curve: Curves.easeInOutQuint
				);
				_scrollControllerBreak.animateTo(
					_scrollControllerBreak.position.minScrollExtent,
					duration: Duration(milliseconds: 3000),
					curve: Curves.easeInOutQuint
				);
				_slideControllerCompletion.reverse();
				_slideControllerBreak.forward();
			}
  		else if(_state == TaskInProgressPageState.inBreak) {
				_state = TaskInProgressPageState.currentlyCompleting;
				_animationController.reverse();
				_slideControllerCompletion.forward();
				_slideControllerBreak.reverse();
				_scrollControllerCompletion.animateTo(
					_scrollControllerCompletion.position.minScrollExtent,
					duration: Duration(milliseconds: 3000),
					curve: Curves.easeInOutQuint
				);
				_scrollControllerBreak.animateTo(
					_scrollControllerBreak.position.maxScrollExtent,
					duration: Duration(milliseconds: 1000),
					curve: Curves.easeInOutQuint
				);

			}
  	});
  }
}
