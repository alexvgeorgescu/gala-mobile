import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

class OtpTimerCubit extends Cubit<int> {
  Timer? _timer;

  OtpTimerCubit() : super(0);

  void start(int seconds) {
    _timer?.cancel();
    emit(seconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state > 0) {
        emit(state - 1);
      } else {
        _timer?.cancel();
      }
    });
  }

  bool get isExpired => state == 0;

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
