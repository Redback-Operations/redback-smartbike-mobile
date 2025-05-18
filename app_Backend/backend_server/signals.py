from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import MyUser, AccountDetails,WorkoutType, WorkoutEntry
from .tasks import clean_workout_data_task
import logging

# those are not needed anymore, as PK, FK and on_delete = ..... were implemented in models doing exatly what the signals used to

logger = logging.getLogger(__name__)

# Every time a new user is created in warehouse model (where the request is sent to), 
# the email and username values are passed there too. Those will not de editable so can be sent once.
@receiver(post_save, sender=MyUser)
def pass_from_MyUser_to_AccDet(sender, instance, created, **kwargs):
    if created:
        AccountDetails.objects.create(
            email=instance,  
            username=MyUser.objects.get(username=instance.username), 
        )

# every time the workout is finished (WorkoutType 'processed' set to True, trigger the clean$ analysis)
@receiver(post_save, sender=WorkoutType)
def trigger_processing_task(sender, instance, **kwargs):
    try:
        logger.info(f"Trigger processing task called for session_id: {instance.session_id}, processed: {instance.processed}")
        if instance.processed:
            logger.info(f"Scheduling task for session_id: {instance.session_id}")
            clean_workout_data_task.delay(instance.session_id)
    except Exception as e:
        logger.error(f"Error in signal handler: {e}")



# maybe a signal will need to be created here too for Account DELETE, to delete all instances of that user
# across all tables; alternatively same logic could be done in views with additional code


# in the future, use the signals for notifications, logging events or updating other records. 