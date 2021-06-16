import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../utils/definitions.dart';

import '../../../utils/ticker.dart';

part 'timer_state.dart';

class TimerCubit extends Cubit<TimerState> {
	final Ticker _ticker;
	ElapsedTime _elapsedTIme;
	CountDirection _direction;
	final bool countUpOnComplete;
	final void Function()? _onFinish;

	StreamSubscription<int>? _tickerSubscription;

	TimerCubit.up(this._elapsedTIme, [this._onFinish]) : _ticker = Ticker(), _direction = CountDirection.up, countUpOnComplete = false, super(TimerInitial(_elapsedTIme()));
	TimerCubit.down(this._elapsedTIme, [this.countUpOnComplete = false, this._onFinish]) : _ticker = Ticker(), _direction = CountDirection.down, super(TimerInitial(_elapsedTIme()));


	void startTimer({bool paused = false}) {
		var value = _elapsedTIme();
		emit(TimerInProgress(value));
		_tickerSubscription?.cancel();
		_tickerSubscription = _ticker.tick(direction: _direction, initialValue: value).listen(_timerTicked);
		if(paused) pauseTimer();
	}

	void pauseTimer() {
		if (state is TimerInProgress)
			_tickerSubscription!.pause();
	}

	void resumeTimer() {
		if (state is TimerInProgress)
			_tickerSubscription!.resume();
	}

	void resetTimer({required ElapsedTime elapsedTIme, CountDirection direction = CountDirection.up}) {
		_elapsedTIme = elapsedTIme;
		_direction = direction;
		_tickerSubscription?.cancel();
		emit(TimerInitial(_elapsedTIme()));
	}

	void _timerTicked(int value) {
		var endValue = _direction == CountDirection.up ? -1 : 0; // up does not have an end value
		if (value != endValue)
	    emit(TimerInProgress(value));
		else {
			if(_onFinish != null) _onFinish!();
			if(countUpOnComplete) {
				resetTimer(elapsedTIme: () => 0, direction: CountDirection.up);
				startTimer();
			}
			else {
				emit(TimerComplete(endValue));
				_tickerSubscription?.cancel();
			}
		}
	}

	@override
  Future<void> close() {
		_tickerSubscription?.cancel();
		return super.close();
  }
}
