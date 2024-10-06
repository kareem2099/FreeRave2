import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import '../states/timer_state.dart';

class TimerCubit extends Cubit<TimerState> {
  Timer? _timer;
  final int duration;
  int _timeLeft;

  TimerCubit({required this.duration})
      : _timeLeft = duration,
        super(TimerInitial(timeLeft: duration));

  void startTimer() {
    emit(TimerRunning(timeLeft: _timeLeft));
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        _timeLeft--;
        emit(TimerRunning(timeLeft: _timeLeft));
      } else {
        timer.cancel();
        emit(const TimerFinished());
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    emit(TimerStopped(timeLeft: _timeLeft));
  }

  void pauseTimer() {
    _timer?.cancel();
    emit(TimerPaused(timeLeft: _timeLeft));
  }

  void resumeTimer() {
    startTimer();
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
