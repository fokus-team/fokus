import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/timer/timer_cubit.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/services/ticker.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/app_header.dart';

import 'chips/attribute_chip.dart';
import 'large_timer.dart';

class TaskAppHeader extends StatefulWidget with PreferredSizeWidget {
	final double height;
	final String title;
	final String text;
	final Widget appHeaderWidget;
	final String helpPage;
	final Function breakPerformingTransition;
	final bool isBreak;

	TaskAppHeader({Key key, @required this.height, this.title, this.text, this.appHeaderWidget, this.helpPage,this.breakPerformingTransition, this.isBreak}) : super(key: key);

	@override
	Size get preferredSize => Size.fromHeight(height);

  @override
  State<StatefulWidget> createState() => TaskAppHeaderState();
}

class TaskAppHeaderState extends State<TaskAppHeader> with TickerProviderStateMixin {
	AnimationController _buttonController;
	ConfettiController _confetti;
	bool isBreakNow;
	CrossAxisAlignment alignment = CrossAxisAlignment.start;
	Animation<Offset> _offsetAnimation;
	AnimationController _slideController;
	final String _pageKey = 'page.childSection.taskInProgress';

  @override
  Widget build(BuildContext context) {
		return Container(
			color: Colors.grey[50],
			child: Column(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				mainAxisSize: MainAxisSize.min,
				children: [
					AppHeader.widget(
						title: this.widget.title,
						text: this.widget.text,
						appHeaderWidget: this.widget.appHeaderWidget,
						helpPage: this.widget.helpPage,
						isConstrained: true,
					),
					_getTimerButtonSection(),
					_getCurrencyBar(),
					_getConfettiCanons()
				],
			)
		);
  }

  Widget _getTimerButtonSection() {
  	return Container(
			child: Padding(
				padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
				child: Row(
					mainAxisAlignment: MainAxisAlignment.spaceBetween,
					children: [
						Align(
							alignment: Alignment.center,
							child: BlocProvider<TimerCubit>(
								create: (_) => TimerCubit(() => 620, CountDirection.down)..startTimer(),
								child: LargeTimer(
									textColor: AppColors.darkTextColor,
									title: '$_pageKey.content.timeLeft',
									align: alignment,
								),
							),
						),
						SlideTransition(
							position: _offsetAnimation,
							child: _getButtonWidget()
						)
					]
				)
			)
		);
	}

	Widget _getCurrencyBar() {
		return Container(
			color: AppColors.childTaskFiller,
			child: Padding(
				padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
				child: Container(
					decoration: AppBoxProperties.elevatedContainer.copyWith(borderRadius: BorderRadius.vertical(top: Radius.circular(4.0))),
					child: Padding(
						padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
						child: Row(
							mainAxisAlignment: MainAxisAlignment.spaceBetween,
							children: [
								Text(AppLocales.of(context).translate('$_pageKey.content.pointsToGet')),
								AttributeChip.withCurrency(
									content: "+30",
									currencyType: CurrencyType.diamond
								)
							]
						)
					)
				)
			)
		);
	}

	Widget _getConfettiCanons() {
  	return Row(
			mainAxisAlignment: MainAxisAlignment.spaceBetween,
			children: [
				ConfettiWidget(
					shouldLoop: true,
					blastDirection: 0,
					confettiController: _confetti,
					numberOfParticles: 5,
					maxBlastForce: 30,
					minBlastForce: 2,
					maximumSize: const Size(16, 8),
					minimumSize: const Size(8, 5)
				),
				ConfettiWidget(
					shouldLoop: true,
					confettiController: _confetti,
					numberOfParticles: 5,
					maxBlastForce: 30,
					minBlastForce: 2,
					maximumSize: const Size(16, 8),
					minimumSize: const Size(8, 5)
				)
			]
		);
	}

	Widget _getButtonWidget() {
		return RaisedButton(
			color: !isBreakNow ? AppColors.childBreakColor : AppColors.childTaskColor,
			padding: EdgeInsets.zero,
			child: AnimatedContainer(
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
								color: AppColors.childTaskFiller,
							),
							Padding(
								padding: const EdgeInsets.only(left: 8),
								//TODO animate text change
								child: Text(
									!isBreakNow ? AppLocales.of(context).translate('$_pageKey.content.breakButton') : AppLocales.of(context).translate('$_pageKey.content.resumeButton'),
									style: Theme.of(context).textTheme.headline2.copyWith(color: AppColors.lightTextColor),
									maxLines: 1,
									softWrap: false
								)
							)
						]
					)
				)
			),
			onPressed: () => this.widget.breakPerformingTransition(),
			elevation: 4.0
		);
	}

  @override
  void initState() {
  	isBreakNow = this.widget.isBreak;
		_buttonController = AnimationController(duration: Duration(milliseconds: 450), vsync: this);
		_confetti = ConfettiController(
			duration: Duration(seconds: 10),
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
