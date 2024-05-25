from .data_wrangling.clean_data import clean_missing_values, remove_duplicates
from .data_wrangling.transform_functions import calculate_avg_workout_speed
import logging
from .models import WorkoutType, WorkoutEntry, WorkoutAnalysis
from django.db.models import Avg, Max, Sum, Max, Min
from datetime import timedelta

logger = logging.getLogger(__name__)

# functions to trigger data processing after a workout is saved ; 1 function should perform 1 action ideally; 
# for example in data cleaning we perform 1 action, update the table rows accordingly, so that the 2nd clean action can work on the updated data

def clean_workout_data(workout):
    try:
        session_id = workout.session_id
        entries = WorkoutEntry.objects.filter(session_id=session_id)
        
        # clean data
        logger.debug('Cleaning missing values')
        cleaned_data = clean_missing_values(entries)

        return cleaned_data
        
    except Exception as e:
        logger.error(f'Error in clean_workout_data function: {e}')
        raise

def analyse_avg_speed(workout):
    try:
        session_id = workout.session_id
        entries = WorkoutEntry.objects.filter(session_id=session_id)

        # Analysis:
        logger.debug('Calculating average speed')
        avg_speed = calculate_avg_workout_speed(entries)
        print(f"Average Speed for session {session_id}: {avg_speed}")

        return avg_speed
    except Exception as e:
        logger.error(f'Error in analyse_avg_speed function: {e}')
        raise

def analyse_max_speed(workout):
    try:
        session_id = workout.session_id
        entries = WorkoutEntry.objects.filter(session_id=session_id)

        # Analysis:
        logger.debug('Calculating max speed')
        max_speed = max(entry.speed for entry in entries)
        workout.max_speed = max_speed
        print(f"Max Speed for session {session_id}: {max_speed}")

        return max_speed
    except Exception as e:
        logger.error(f'Error in analyse_max_speed function: {e}')
        raise

def analyse_total_distance(workout):
    try:
        session_id = workout.session_id
        entries = WorkoutEntry.objects.filter(session_id=session_id)

        # Analysis:
        logger.debug('Calculating total distance')
        tot_dist = sum(entry.distance for entry in entries)
        workout.total_distance = tot_dist
        print(f"Total distance for session {session_id}: {tot_dist}")

        return tot_dist
    except Exception as e:
        logger.error(f'Error in analyse_total_distance function: {e}')
        raise

def analyse_avg_heart_rate(workout):
    try:
        session_id = workout.session_id
        entries = WorkoutEntry.objects.filter(session_id=session_id)

        # Analysis:
        logger.debug('Calculating avg heart rate')
        total_heart_rate = sum(entry.heart_rate for entry in entries)
        avg_heart_rate = avg_heart_rate = total_heart_rate / entries.count()
        workout.avg_heart_rate = avg_heart_rate
        print(f"Avg heart rate for session {session_id}:  avg heart rate:{avg_heart_rate}")

        return avg_heart_rate
    except Exception as e:
        logger.error(f'Error in analyse_avg_heart_rate function: {e}')
        raise

def analyse_workout_duration(workout):
    try:
        session_id = workout.session_id
        entries = WorkoutEntry.objects.filter(session_id=session_id)

        # Analysis:
        logger.debug('Calculating workout duration')
        min_timestamp = min(entry.timestamp for entry in entries)
        max_timestamp = max(entry.timestamp for entry in entries)
        wrk_dur = max_timestamp - min_timestamp

        # duration in seconds, passed as int to WorkoutAnalysis 
        total_seconds = int(wrk_dur.total_seconds())
        workout.workout_duration = total_seconds

        print(f"Workout duration for session {session_id}: workout duration: {total_seconds}")

        return total_seconds
    except Exception as e:
        logger.error(f'Error in analyse_workout_duration function: {e}')
        raise

def analyse_avg_temperature(workout):
    try:
        session_id = workout.session_id
        entries = WorkoutEntry.objects.filter(session_id=session_id)

        # Analysis:
        logger.debug('Calculating average temperature')
        avg_temp = sum(entry.temperature for entry in entries)/entries.count()
        workout.avg_temperature = avg_temp
        print(f"Average temp for session {session_id}: average temp: {avg_temp}")

        # in the last task in the queue inject the below 2 lines, that mark the 'processed' value of WorkoutType to True, meaning that the entile analysis was done
        # if you add more functions below this function, just cut them and paste in that last function
        workout.processed = True
        workout.save()

        return avg_temp
    except Exception as e:
        logger.error(f'Error in analyse_avg_temperature function: {e}')
        raise