import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/timer/timer_cubit.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/app_header.dart';

import 'chips/attribute_chip.dart';
import 'large_timer.dart';

class SizedAppHeader extends StatefulWidget with PreferredSizeWidget {
	final double height;
	final String title;
	final String text;
	final List<HeaderActionButton> headerActionButtons;
	final AppHeaderType headerType;
	final Widget appHeaderWidget;
	final String helpPage;
	final Widget popupMenuWidget;
	final TabBar tabs;
	final String timerCubitTitle;
	final Function breakPerformingTransition;
	final bool isBreak;

	SizedAppHeader({Key key, @required this.height, this.title, this.text, this.headerActionButtons, this.headerType, this.appHeaderWidget, this.helpPage, this.popupMenuWidget, this.tabs, this.timerCubitTitle, this.breakPerformingTransition, this.isBreak}) : super(key: key);
	SizedAppHeader.widget({Key key, double height, String title, String text, List<HeaderActionButton> headerActionButtons, Widget appHeaderWidget, String helpPage, Widget popupMenuWidget, TabBar tabs, String timerCubitTitle, Function breakPerformingTransition, isBreak}) : this(
		title: title,
		text: text,
		headerActionButtons: headerActionButtons,
		headerType: AppHeaderType.widget,
		appHeaderWidget: appHeaderWidget,
		helpPage: helpPage,
		popupMenuWidget: popupMenuWidget,
		tabs: tabs,
		height: height,
		key: key,
		timerCubitTitle: timerCubitTitle,
		breakPerformingTransition: breakPerformingTransition,
		isBreak: isBreak
	);

	@override
	Size get preferredSize => Size.fromHeight(height);

  @override
  State<StatefulWidget> createState() => SizedAppHeaderState();
}

class SizedAppHeaderState extends State<SizedAppHeader> with TickerProviderStateMixin {
	AnimationController _buttonController;
	ConfettiController _confetti;
	bool isBreakNow;
	CrossAxisAlignment alignment = CrossAxisAlignment.start;
	Animation<Offset> _offsetAnimation;
	AnimationController _slideController;

  @override
  Widget build(BuildContext context) {
		return Column(
			mainAxisAlignment: MainAxisAlignment.spaceBetween,
			children: [
				AppHeader.widget(
					title: this.widget.title,
					text: this.widget.text,
					headerActionButtons: this.widget.headerActionButtons,
					appHeaderWidget: this.widget.appHeaderWidget,
					helpPage: this.widget.helpPage,
					popupMenuWidget: this.widget.popupMenuWidget,
					tabs: this.widget.tabs,
					isConstrained: true,
				),
				Container(
					decoration: BoxDecoration(
						color: Colors.white,
						border: Border.all(color: Colors.white),
					),
				  child: Padding(
				  	padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
				  	child: Row(
							mainAxisAlignment: MainAxisAlignment.spaceBetween,
				  		children: [
				  			Align(
									alignment: Alignment.center,
				  			  child: BlocProvider<TimerCubit>(
				  			  	create: (_) => TimerCubit(() => 0)..startTimer(),
				  			  	child: LargeTimer(
				  			  		textColor: Colors.black,
				  			  		title: this.widget.timerCubitTitle,
										align: alignment,
				  			  	),
				  			  ),
				  			),
				  			SlideTransition(
				  			position: _offsetAnimation,
				  				child: RaisedButton(
				  					padding: EdgeInsets.all(0),
				  					child: AnimatedContainer(
				  						decoration: ShapeDecoration(
				  							shape: RoundedRectangleBorder(
				  								borderRadius: BorderRadius.circular(4)
				  							),
				  							color: !isBreakNow ? Colors.blueGrey : Colors.lightBlue,
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
				  			    						//TODO animate text change
				  			    						child: Text(
				  										!isBreakNow ? "Przerwa" : "Wznów",
				  										style: Theme.of(context).textTheme.headline2.copyWith(color: Colors.white),
				  										maxLines: 1,
				  										softWrap: false,
				  									),
				  			    					)
				  			    				],
				  			    			),
				  			    		),
				  			    	),
				  			    	onPressed: () => this.widget.breakPerformingTransition(),
				  			    	elevation: 4.0
				  			    ),
				  			  ),
				  		],
				  	),
				  ),
				),
				Expanded(
				  child: Container(
				  	decoration: BoxDecoration(
							border: Border.all(color: Colors.white),
				  		color: Colors.white,
				  	),
				  ),
				),
				Container(
					decoration: BoxDecoration(
						color: Colors.white,
						border: Border.all(color: Colors.white),
					),
				  child: Padding(
				  	padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
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
				),
				Row(
					mainAxisAlignment: MainAxisAlignment.spaceBetween,
					children: [
						ConfettiWidget(
							shouldLoop: true,
							blastDirection: 0,
							confettiController: _confetti,
							numberOfParticles: 5,
							maxBlastForce: 30,
							minBlastForce: 2,
						),
						ConfettiWidget(
							shouldLoop: true,
							confettiController: _confetti,
							numberOfParticles: 5,
							maxBlastForce: 30,
							minBlastForce: 2,
						),
					],
				)
			],
		);
  }

  @override
  void initState() {
  	isBreakNow = this.widget.isBreak;
		_buttonController = AnimationController(duration: Duration(milliseconds: 450), vsync: this);
		_confetti = ConfettiController(
			duration: Duration(seconds: 10)
		);
		_slideController = AnimationController(
			duration: const Duration(seconds: 1),
			vsync: this,
		);
		_offsetAnimation = Tween<Offset>(
			begin: Offset.zero,
			end: Offset(2, 0),
		).animate(CurvedAnimation(
			parent: _slideController,
			curve: Curves.easeInOutQuint,
		));
    super.initState();
  }
  void animateButton() {
  	if(!isBreakNow)
			_buttonController.forward();
  	else 	_buttonController.reverse();
		isBreakNow = !isBreakNow;
	}

	void animateSuccess() {
		_confetti.play();
	}

	void closeButton() {
		_slideController.forward();
	}

	@override
  void dispose() {
  	_confetti.dispose();
  	_buttonController.dispose();
  	_slideController.dispose();
    super.dispose();
  }
}
