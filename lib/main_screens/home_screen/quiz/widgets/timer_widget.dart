import 'package:flutter/material.dart';
import 'dart:async';

class TimerWidget extends StatefulWidget {
  final int initialTime;
  final TextStyle? textStyle;
  final Color? warningColor;

  const TimerWidget({
    Key? key,
    required this.initialTime,
    this.textStyle,
    this.warningColor,
  }) : super(key: key);

  @override
  TimerWidgetState createState() => TimerWidgetState();
}

class TimerWidgetState extends State<TimerWidget> {
  late int _timeLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.initialTime;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      'Time left: $_timeLeft',
      style: widget.textStyle ??
          TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _timeLeft <= 10 ? (widget.warningColor ?? Colors.red) : Colors.black,
          ),
    );
  }
}
