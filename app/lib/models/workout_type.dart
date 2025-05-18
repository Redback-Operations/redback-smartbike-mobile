class WorkoutType {
  final String name;
  final int duration;
  final String level;
  final String type;
  final String sessionId;

  WorkoutType({
    required this.name,
    required this.duration,
    required this.level,
    required this.type,
    required this.sessionId,
  });

  // for 'vr_workout.dart when we send the entire instance of this to backend
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'duration': duration,
      'level': level,
      'type': type,
      'sessionId': sessionId,
    };
  }
}
