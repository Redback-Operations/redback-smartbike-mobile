
# based on the workout entries or other tables, create a new calculation :
# averages, min, max, mean, etc


def calculate_avg_workout_speed(workout_entries):
    """
    Calculate the average speed of workout entries.
    
    Parameters:
    - workout_entries: QuerySet or list of WorkoutEntry instances
    
    Returns:
    - average_speed: Average speed of workout entries
    """
    total_speed = 0
    count = 0
    for entry in workout_entries:
        if entry.speed is not None:
            total_speed += entry.speed
            count += 1
    if count == 0:
        return 0  # Return 0 if no speed data is available
    average_speed = total_speed / count
    return average_speed
