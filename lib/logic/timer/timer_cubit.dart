import 'dart:async';

import 'package:cubit/cubit.dart';
import 'package:equatable/equatable.dart';

import 'package:fokus/services/ticker.dart';

part 'timer_state.dart';

class TimerCubit extends Cubit<TimerState> {
	final Ticker _ticker;
	int _value;
	CountDirection _direction;

	StreamSubscription<int> _tickerSubscription;

	TimerCubit(this._value, [this._direction = CountDirection.up]) : _ticker = Ticker(), super(TimerInitial(_value));

	void startTimer() {
		int value = state.value;
		emit(TimerInProgress(value));
		_tickerSubscription?.cancel();
		_tickerSubscription = _ticker.tick(direction: _direction, value: value).listen((value) => _timerTicked(value));
	}

	void pauseTimer() {
		if (state is TimerInProgress)
			_tickerSubscription.pause();
	}

	void resumeTimer() {
		if (state is TimerInProgress)
			_tickerSubscription.resume();
	}

	void resetTimer({int value, CountDirection direction = CountDirection.up}) {
		this._value = value;
		this._direction = direction;
		_tickerSubscription?.cancel();
		emit(TimerInitial(_value));
	}

	void _timerTicked(int value) {
		int endValue = _direction == CountDirection.up ? -1 : 0; // up does not have an end value
	  value != endValue ? emit(TimerInProgress(value)) : emit(TimerComplete(endValue));
	}

	@override
  Future<Function> close() {
		_tickerSubscription?.cancel();
		return super.close();
  }
}
