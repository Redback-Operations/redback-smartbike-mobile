from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from .models import MyUser, AccountDetails,WorkoutType, WorkoutEntry

# those are not needed anymore, as PK, FK and on_delete = ..... were implemented in models doing exatly what the signals used to


# Every time a new user is created in warehouse model (where the request is sent to), 
# the email and username values are passed there too. Those will not de editable so can be sent once.
@receiver(post_save, sender=MyUser)
def pass_from_MyUser_to_AccDet(sender, instance, created, **kwargs):
    if created:
        AccountDetails.objects.create(
            email=instance,  
            username=MyUser.objects.get(username=instance.username), 
        )




# when we terminate the account, the details are deleted in the warehouse table, as well as from the acc_details table or any table
# that we want to add in the future


# maybe a signal will need to be created here too for Account DELETE, to dlete all instances of that user
# across all tables .


# in the future, use the signals for notifications, logging events or updating other records. 