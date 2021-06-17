import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../utils/definitions.dart';

import '../../../utils/ticker.dart';

part 'timer_state.dart';

class TimerCubit extends Cubit<TimerState> {
  final Ticker _ticker;
  ElapsedTime elapsedTime;
  CountDirection _direction;
  final bool countUpOnComplete;
  final void Function()? onFinish;

  StreamSubscription<int>? _tickerSubscription;

  TimerCubit.up({required this.elapsedTime, this.onFinish})
      : _ticker = Ticker(),
        _direction = CountDirection.up,
        countUpOnComplete = false,
        super(TimerInitial(elapsedTime()));
  TimerCubit.down({
    required this.elapsedTime,
    this.countUpOnComplete = false,
    this.onFinish,
  })  : _ticker = Ticker(),
        _direction = CountDirection.down,
        super(TimerInitial(elapsedTime()));

  void startTimer({bool paused = false}) {
    var value = elapsedTime();
    emit(TimerInProgress(value));
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker
        .tick(direction: _direction, initialValue: value)
        .listen(_timerTicked);
    if (paused) pauseTimer();
  }

  void pauseTimer() {
    if (state is TimerInProgress) _tickerSubscription!.pause();
  }

  void resumeTimer() {
    if (state is TimerInProgress) _tickerSubscription!.resume();
  }

  void resetTimer({
    required ElapsedTime elapsedTIme,
    CountDirection direction = CountDirection.up,
  }) {
    elapsedTime = elapsedTIme;
    _direction = direction;
    _tickerSubscription?.cancel();
    emit(TimerInitial(elapsedTime()));
  }

  void _timerTicked(int value) {
    var endValue = _direction == CountDirection.up
        ? -1
        : 0; // up does not have an end value
    if (value != endValue)
      emit(TimerInProgress(value));
    else {
      if (onFinish != null) onFinish!();
      if (countUpOnComplete) {
        resetTimer(elapsedTIme: () => 0, direction: CountDirection.up);
        startTimer();
      } else {
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
