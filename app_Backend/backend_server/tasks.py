from celery import shared_task
from .utils import clean_workout_data, analyse_avg_speed, analyse_max_speed, analyse_total_distance, analyse_avg_heart_rate, analyse_avg_temperature, analyse_workout_duration
from .models import WorkoutType, WorkoutEntry, WorkoutAnalysis
import logging

logger = logging.getLogger(__name__)

@shared_task
def clean_workout_data_task(session_id):
    try:
        # 1.Retrieve the WorkoutType object
        workout = WorkoutType.objects.get(session_id=session_id)
        logger.info(f"Trigger processing task called for session_id: {session_id}, processed: {workout.processed}")

        # 2.if the workout was already processed (their 'processed' info in WorkoutType table is True), then print 'allready processed' and skip rescheduling
        if workout.processed:
            logger.info(f"Session {session_id} already processed. Skipping reschedule.")
            return 'Success - Already Processed'
        
        # 3. If workout was not yet processed (their 'processed' info in WorkoutType table is False) then filter WorkoutEntry records by session_id (get all data points for that session)
        workout_entries = WorkoutEntry.objects.filter(session_id=session_id)
        
        # 4. Convert queryset to a list of data points or dictionary or whatever is needed; here we count
        # data_points = list(workout_entries.values())
        data_points = workout_entries.count()

        # 5. Log and print the retrieved data (logged to the 'debug.log' file in the project level; the most recent entries are at the bottom)
        # logger.info(f"Retrieved {(data_points)} data points for session_id: {session_id}")
        # print(f"Retrieved {(data_points)} data points for session_id: {session_id}")

        # 6. if data points exist, then pass them to the 'process_workout_data' function from utils.py; 
        # TODO: to add more cleaning or processing stages see the utils functions
        if data_points > 0:
            # clean data
            clean_workout_data(workout)
            pass

        logger.info(f"Processed workout data for session_id: {session_id}")

        return session_id
    except WorkoutType.DoesNotExist:
        error_message = f"WorkoutType with session_id {session_id} does not exist."
        logger.error(error_message)
        print(error_message)
        return error_message
    except Exception as e:
        error_message = f"An error occurred in the task: {e}"
        logger.error(error_message)
        print(error_message)
        return str(e)
    

@shared_task
def analyse_workout_data_task(session_id, *args):
    try:
        # 1. Retrieve the WorkoutType object
        workout = WorkoutType.objects.get(session_id=session_id)
        logger.info(f"Triggered analysis task for session_id: {session_id}, processed: {workout.processed}")

        # 3. Retrieve workout entries for the session
        workout_entries = WorkoutEntry.objects.filter(session_id=session_id)

        # 4. Perform analysis if data points exist
        if workout_entries.exists():
            av = analyse_avg_speed(workout)
            mx = analyse_max_speed(workout)
            td = analyse_total_distance(workout)
            av_hr = analyse_avg_heart_rate(workout)
            av_temp = analyse_avg_temperature (workout)
            wrk_dur = analyse_workout_duration(workout)
            analysis = WorkoutAnalysis.objects.create(
                session_id=workout,
                avg_speed = av,
                max_speed = mx,
                total_distance = td,
                avg_heart_rate = av_hr,
                avg_temperature = av_temp,
                workout_duration = wrk_dur
            )
            logger.info(f"Saved analysis results for session_id: {session_id}, average speed: {av}, max speed: {mx}, total distance: {td}")

        # Mark as processed (their 'processed' info in WorkoutType table is now changed to True)
        # add below 3 lines to the last task in the queue only!!
        workout.processed = True
        workout.save()
        logger.info(f"Celery performed tasks successfully!")

        return session_id
    except WorkoutType.DoesNotExist:
        error_message = f"WorkoutType with session_id {session_id} does not exist."
        logger.error(error_message)
        return error_message
    except Exception as e:
        error_message = f"An error occurred in the task: {e}"
        logger.error(error_message)
        return str(e)