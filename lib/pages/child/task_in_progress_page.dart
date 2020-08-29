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

enum TaskInProgressPageState {currentlyPerforming, inBreak, done}

class ChildTaskInProgressPage extends StatefulWidget {
  @override
  _ChildTaskInProgressPageState createState() => _ChildTaskInProgressPageState();
}

class _ChildTaskInProgressPageState extends State<ChildTaskInProgressPage> with SingleTickerProviderStateMixin {
  final String _pageKey = 'page.childSection.taskInProgress';
  TaskInProgressPageState _state = TaskInProgressPageState.currentlyPerforming;
  bool _canBounce = true;
	AnimationController _animationController;
	var _controller = ScrollController(
		keepScrollOffset: false
	);

	@override
  Widget build(BuildContext context) {
  	return Scaffold(
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
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
					  			child: Padding(
					  				padding: const EdgeInsets.symmetric(vertical: 8.0),
					  				child: Row(
					  					mainAxisAlignment: MainAxisAlignment.spaceBetween,
					  					children: [
					  						AnimatedIcon(
					  							icon: AnimatedIcons.pause_play,
					  							size: 28,
					  							progress: _animationController,
					  							color: Colors.white,
					  						),
					  						AutoSizeText(
					  							"Przerwa",
					  							style: Theme.of(context).textTheme.headline2.copyWith(color: Colors.white),
					  							maxLines: 1,
					  							minFontSize: 12,
					  							softWrap: false,
					  							overflowReplacement: SizedBox.shrink(),
					  						)
					  					],
					  				),
					  			),
					  			shape: RoundedRectangleBorder(
					  				borderRadius: BorderRadius.circular(36)
					  			),
					  			color: Colors.blueGrey,
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
					NotificationListener<OverscrollIndicatorNotification>(
							onNotification: (overscroll) {
								overscroll.disallowGlow();
								return false;
							},
						child: Flexible(
							child: Padding(
								padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
								child: ListView(
									padding: EdgeInsets.all(0),
									physics: ClampingScrollPhysics(),
									children: [
										Container(
											decoration: AppBoxProperties.elevatedContainer.copyWith(color: Colors.lightBlue, borderRadius: BorderRadius.vertical(bottom: Radius.circular(4))),
											child: Padding(
												padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8.0),
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
																"Ewentualny opiswentualny opiswentualny opiswentualny wentualny opiswentualny opiswentualny opiswentualny opiswentualny opiswentualny opiswentualny opiswentualny opiswentualny opisopiswentualny opiswentualny opiswentualny opiswentualny opiswentualny opiswentualny opiswentualny opiswentualny opiswentualny opiswentualny opiswentualny opiswentualny opiswentualny opiswentualny opis",
																style: Theme.of(context).textTheme.subtitle1.copyWith(color: Colors.white),
																textAlign: TextAlign.justify,
															),
														)
													],
												),
											),
										),
										SizedBox(
											height: 40,
										)
									]
								),
							),
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
	}

 void _breakPerformingTransition() {
  	setState(() {
  		if(_state == TaskInProgressPageState.currentlyPerforming) {
  			_state = TaskInProgressPageState.inBreak;
				_animationController.forward();
			}
  		else if(_state == TaskInProgressPageState.inBreak) {
				_state = TaskInProgressPageState.currentlyPerforming;
				_animationController.reverse();
			}
  	});
  }
}
