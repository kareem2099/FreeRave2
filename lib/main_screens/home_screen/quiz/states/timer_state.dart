import 'package:equatable/equatable.dart';

abstract class TimerState extends Equatable {
  final int timeLeft;

  const TimerState({required this.timeLeft});

  @override
  List<Object> get props => [timeLeft];
}

class TimerInitial extends TimerState {
  const TimerInitial({required int timeLeft}) : super(timeLeft: timeLeft);
}

class TimerRunning extends TimerState {
  const TimerRunning({required int timeLeft}) : super(timeLeft: timeLeft);
}

class TimerStopped extends TimerState {
  const TimerStopped({required int timeLeft}) : super(timeLeft: timeLeft);
}

class TimerPaused extends TimerState {
  const TimerPaused({required int timeLeft}) : super(timeLeft: timeLeft);
}

class TimerFinished extends TimerState {
  const TimerFinished() : super(timeLeft: 0);
}
