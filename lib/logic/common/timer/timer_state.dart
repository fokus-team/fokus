part of 'timer_cubit.dart';

abstract class TimerState extends Equatable {
	final int value;

  const TimerState(this.value);

	@override
  List<Object> get props => [value];
}

class TimerInitial extends TimerState {
	TimerInitial(int value) : super(value);
}

class TimerInProgress extends TimerState {
	TimerInProgress(int value) : super(value);
}

class TimerPause extends TimerState {
	TimerPause(int value) : super(value);
}

class TimerComplete extends TimerState {
	TimerComplete(int value) : super(value);
}
