import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:fokus/utils/ticker.dart';

part 'timer_state.dart';

class TimerCubit extends Cubit<TimerState> {
	final Ticker _ticker;
	int Function() _currentValue;
	CountDirection _direction;
	final bool countUpOnComplete;
	void Function() _onFinish;

	StreamSubscription<int> _tickerSubscription;

	TimerCubit.up(this._currentValue, [this._onFinish]) : _ticker = Ticker(), _direction = CountDirection.up, countUpOnComplete = false, super(TimerInitial(_currentValue()));
	TimerCubit.down(this._currentValue, [this.countUpOnComplete = false, this._onFinish]) : _ticker = Ticker(), this._direction = CountDirection.down, super(TimerInitial(_currentValue()));


	void startTimer({bool paused = false}) {
		int value = _currentValue();
		emit(TimerInProgress(value));
		_tickerSubscription?.cancel();
		_tickerSubscription = _ticker.tick(direction: _direction, initialValue: value).listen((value) => _timerTicked(value));
		if(paused) pauseTimer();
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
			if(_onFinish != null) _onFinish();
			if(countUpOnComplete) {
				resetTimer(currentValue: () => 0, direction: CountDirection.up);
				startTimer();
			}
			else {
				emit(TimerComplete(endValue));
				_tickerSubscription.cancel();
			}
		}
	}

	@override
  Future<void> close() {
		_tickerSubscription?.cancel();
		return super.close();
  }
}
