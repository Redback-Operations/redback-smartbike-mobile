import 'dart:math';

class WorkoutValues {
  static final Random _random = Random();

  static final double _baseTemperature = 36.8;
  static double _currentSpeed = 5.0;
  static int _timeSinceLastSpeedChange = 0;
  static double _totalDistance = 0.0;
  static int _totalElapsedTime = 0;

  static double generateSpeed(int timeElapsed) {
    if (_timeSinceLastSpeedChange >= 3) {
      _currentSpeed =
          _random.nextDouble() * 5 + 5; // Generate a new random speed
      _timeSinceLastSpeedChange = 0; // Reset time since last speed change
    } else {
      _timeSinceLastSpeedChange +=
          timeElapsed; // Increment time since last speed change
    }
    return _currentSpeed;
  }

  static double generateDistance(double speed, int timeElapsed) {
    double distance = speed /
        3600 *
        timeElapsed; // Convert speed from km/h to km/s and multiply by time elapsed in seconds
    _totalDistance +=
        distance; // Add distance covered during this interval to the total distance
    return _totalDistance;
  }

  static double generateTemperature(double speed, int timeElapsed) {
    // Calculate temperature based on time and distance
    double temperature = _baseTemperature + (timeElapsed / 600) + (speed / 20);
    temperature =
        temperature.clamp(36.8, 38.4); // Clamp between 36.8°C and 38.4°C
    return temperature;
  }

  static int generateHeartRate(double speed) {
    // Calculate heart rate based on speed (assume linear relationship)
    double baseHeartRate = _random.nextDouble() * 40 +
        80; // Generate a base heart rate between 80 and 120 BPM
    double heartRate =
        baseHeartRate + (speed * 2); // Increase heart rate slightly with speed
    return heartRate.toInt();
  }

  static int generateIncline(int timeElapsed) {
    _totalElapsedTime += timeElapsed; // Compounding the total elapsed time

    int baseIncline = (_totalElapsedTime ~/ 30) % 8; // Calculate base incline

    // If totalElapsedTime is at least 15, perform the incline logic
    if (_totalElapsedTime >= 15) {
      baseIncline += 1; // Increase incline by 1
    }

    // Cap incline at 8
    return baseIncline > 8 ? 8 : baseIncline;
  }

  static int generateRPM(double speed) {
    // Calculate RPM based on speed and wheel size (assume 26-inch wheel)
    double wheelSize = 26.0; // Assume 26-inch wheel
    double mph = speed * 0.621371; // Convert speed from km/h to mph
    double rpm = mph * 5280 * 12 / (3.141597 * wheelSize) / 60; // Calculate RPM
    return rpm.toInt();
  }

  static void resetValues() {
    _currentSpeed = 5.0; // Reset current speed to its initial value
    _totalDistance = 0.0; // Reset total distance to its initial value
  }
}
