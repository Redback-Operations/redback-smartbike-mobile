import 'package:flutter/material.dart';
import '../models/workout_type.dart';

class WorkoutTypeProvider with ChangeNotifier {
  WorkoutType? _workoutType;

  WorkoutType? get workoutType => _workoutType;

  void updateWorkoutType({
    String? name,
    int? duration,
    String? level,
    String? type,
    String? sessionId,
  }) {
    _workoutType = WorkoutType(
      name: name ?? '',
      duration: duration ?? 0,
      level: level ?? '',
      type: type ?? '',
      sessionId: sessionId ?? '',
    );
    notifyListeners();
  }
}
