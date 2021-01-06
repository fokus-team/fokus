import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/child/task_instance/task_instance_cubit.dart';
import 'package:fokus/logic/common/timer/timer_cubit.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/duration_utils.dart';
import 'package:fokus/widgets/custom_app_bars.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:logging/logging.dart';
import 'package:vibration/vibration.dart';
import 'chips/attribute_chip.dart';
import 'large_timer.dart';

class TaskAppHeader extends StatefulWidget with PreferredSizeWidget {
	final double height;
	final String title;
	final Widget content;
	final String helpPage;
	final Function breakPerformingTransition;
	final TaskInstanceLoaded state;

	TaskAppHeader({Key key, @required this.height, @required this.state, this.title, this.content, this.helpPage,this.breakPerformingTransition}) : super(key: key);

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
	bool _shouldUpdate = false;
	TimerCubit _timerCompletionCubit;
	List<int> vibrationPattern = [0, 500, 100, 250, 50, 1000];
	Timer _updateTimer;
	final Logger _logger = Logger('TaskAppHeader');

	@override
  Widget build(BuildContext context) {
		return Container(
			color: Colors.grey[50],
			child: Column(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				mainAxisSize: MainAxisSize.min,
				children: [
					CustomContentAppBar(
						title: this.widget.title,
						content: this.widget.content,
						helpPage: this.widget.helpPage,
						isConstrained: true
					),
					if(this.widget.state.taskInstance != null)
					...[
						_getTimerButtonSection(),
						_getCurrencyBar(),
						_getConfettiCanons()
					]
				]
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
						Expanded(child: _getTimerSection()),
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
						padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
						child: this.widget.state.taskInstance.points != null ? Row(
							mainAxisAlignment: MainAxisAlignment.spaceBetween,
							children: [
								Text(AppLocales.of(context).translate('$_pageKey.content.pointsToGet')),
								AttributeChip.withCurrency(
									content: "+" + this.widget.state.taskInstance.points.quantity.toString(),
									currencyType: this.widget.state.taskInstance.points.type,
									tooltip: this.widget.state.taskInstance.points.title
								)
							]
						) :
						Row(
							mainAxisAlignment: MainAxisAlignment.center,
						  children: [
						    Text(AppLocales.of(context).translate('$_pageKey.content.motivate')),
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
		if(isBreakNow == null) setState(() {
			isBreakNow = this.widget.state is TaskInstanceInBreak;
			_buttonController = AnimationController(duration: Duration(milliseconds: 450), vsync: this);
			if(isBreakNow) _buttonController.forward();
		});
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
			onPressed: () => {
				this.widget.breakPerformingTransition(this.widget.state),
				this.widget.state is TaskInstanceInProgress ? _timerCompletionCubit.pauseTimer() : _timerCompletionCubit.resumeTimer()
			},
			elevation: 4.0
		);
	}

	Widget _getTimerSection() {
		return Align(
			alignment: Alignment.centerLeft,
			child: BlocProvider<TimerCubit>(
				create: _getTimerFun(),
				child: LargeTimer(
					textColor: AppColors.darkTextColor,
					title: _shouldUpdate ? _getTimerTitle() : _getTimerTitle(),
					align: alignment,
				),
			)
		);
	}

	void _timeUpdate(Duration duration) {
		_updateTimer = Timer(duration, () {
			setState(() {
			  _shouldUpdate = true;
			});
		});
	}

	TimerCubit Function(BuildContext) _getTimerFun() {
  	if(_timerCompletionCubit == null) {
			if(this.widget.state.taskInstance.timer != null) {
				if(_getTimerInSeconds() - _getDuration() > 0) {
					int time = _getTimerInSeconds() - _getDuration();
					_timeUpdate(Duration(seconds: time));
					_timerCompletionCubit = TimerCubit.down(() => time, true, _onTimerFinish);
				}
				else _timerCompletionCubit = TimerCubit.up(() => _getDuration() - _getTimerInSeconds());
			}
			else _timerCompletionCubit = TimerCubit.up(() => _getDuration());
		}
  	if(this.widget.state is TaskInstanceInProgress)
			return (_) => _timerCompletionCubit..startTimer();
  	else return (_) => _timerCompletionCubit..startTimer(paused: true);
	}

	int _getDuration() {
  	return sumDurations(this.widget.state.taskInstance.duration).inSeconds;
	}

	int _getTimerInSeconds() {
  	return this.widget.state.taskInstance.timer*60;
	}


	String _getTimerTitle() {
		if(this.widget.state.taskInstance.timer != null) {
			if(this.widget.state.taskInstance.timer*60 - sumDurations(this.widget.state.taskInstance.duration).inSeconds > 0)
				return '$_pageKey.content.timeLeft';
			else return '$_pageKey.content.latency';
		}
		else return '$_pageKey.content.completionTime';
	}

  @override
  void initState() {
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
		setState(() {
			isBreakNow = !isBreakNow;
		});
	}

	void animateSuccess() {
		_confetti.play();
	}

	void onFinish() {
  	_timerCompletionCubit.pauseTimer();
		_slideController.forward();
	}

	@override
  void dispose() {
		if(_updateTimer != null)
			_updateTimer.cancel();
		_confetti.dispose();
  	_buttonController.dispose();
  	_slideController.dispose();
    super.dispose();
  }

  void _onTimerFinish() async {
		try {
		  if (await Vibration.hasVibrator()) {
		  	if (await Vibration.hasAmplitudeControl()) {
		  		Vibration.vibrate(amplitude: 1024, pattern: vibrationPattern);
		  	}
		  	else Vibration.vibrate(pattern: vibrationPattern);
		  }
		} on Exception catch (e, stacktrace) {
			_logger.warning("Vibration failed.", e, stacktrace);
		}
	}
}
