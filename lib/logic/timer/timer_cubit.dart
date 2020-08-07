import 'dart:async';

import 'package:cubit/cubit.dart';
import 'package:equatable/equatable.dart';

import 'package:fokus/services/ticker.dart';

part 'timer_state.dart';

class TimerCubit extends Cubit<TimerState> {
	final Ticker _ticker;
	int Function() _currentValue;
	CountDirection _direction;

	StreamSubscription<int> _tickerSubscription;

	TimerCubit(this._currentValue, [this._direction = CountDirection.up]) : _ticker = Ticker(), super(TimerInitial(_currentValue()));

	void startTimer() {
		int value = _currentValue();
		emit(TimerInProgress(value));
		_tickerSubscription?.cancel();
		_tickerSubscription = _ticker.tick(direction: _direction, initialValue: value).listen((value) => _timerTicked(value));
	}

	void pauseTimer() {
		if (state is TimerInProgress)
			_tickerSubscription.pause();
	}

	void resumeTimer() {
		if (state is TimerInProgress)
			_tickerSubscription.resume();
	}

	void resetTimer({int Function() currentValue, CountDirection direction = CountDirection.up}) {
		this._currentValue = currentValue;
		this._direction = direction;
		_tickerSubscription?.cancel();
		emit(TimerInitial(_currentValue()));
	}

	void _timerTicked(int value) {
		int endValue = _direction == CountDirection.up ? -1 : 0; // up does not have an end value
		if (value != endValue)
	    emit(TimerInProgress(value));
		else {
			emit(TimerComplete(endValue));
			_tickerSubscription.cancel();
		}
	}

	@override
  Future<void> close() {
		_tickerSubscription?.cancel();
		return super.close();
  }
}
