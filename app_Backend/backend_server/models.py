from django.db import models
from django.utils import timezone
from mongoengine import Document, UUIDField, StringField, DateTimeField, BooleanField, DateField, IntField, DecimalField, ReferenceField, CASCADE
import uuid
from datetime import datetime, timedelta 


# When creating a user you need to provide all 3 fields, out of which:
#           - email will be a primary key and unique (PK implies uniqueness)
#           - username will need to be unique
#   TODO:   - set password max length to 20 in Flutter
#           - used in Flutter in signup.dart
class MyUser(Document):
    id = UUIDField(primary_key=True, default=uuid.uuid4, binary=False)  # Explicit ID field (was int, now UUIDv4)
    email = StringField(required=True)
    username = StringField(required=True, unique=True)
    password = StringField(required=True)
    user_created = DateTimeField(default=datetime.utcnow)
    login_type = StringField(required=False, sparse=True, default=None)
    login_id = StringField(unique=True, required=False, sparse=True, default=None) #added sparse to ensure nulls don't clash in MongoDB
    otp = StringField(default=None)
    otp_created_at = DateTimeField()

    # generate the id, starting at 1000, and add 1 to each new user
    def save(self, *args, **kwargs):
        self.email = self.email.strip().lower() ##lowercase email

        #old ID system
        '''        
        if not self.id:  # If id is not already set
            last_user = MyUser.objects.order_by('-id').first()
            if last_user:
                last_id = int(last_user.id)
            else:
                last_id = 999  # Starting from 1000
            self.id = str(last_id + 1)  # Increment the id
            '''
    
        super(MyUser, self).save(*args, **kwargs)


    def set_otp_hash(self, otp_hash):
        self.otp_hash = otp_hash

    def set_otp_created(self, otp_created):
        self.otp_created = otp_created

    def get_otp_hash(self):
        return self.otp_created

    def get_otp_created(self):
        return self.otp_created

# has a 1:1 relationship with User table: one User entry has exactly 1 AccountDetails entry, and the inverse is also 1:1
#           - all fields except for user can be empty, as when we create a user we have to edit the profile and provide those values 
#           - the user instance also serves as a PK here  
#           - used in Flutter in edit_profile.dart     
class AccountDetails(Document):
    id = UUIDField(primary_key=True, default=uuid.uuid4, binary=False)  # Explicit ID field (can be UUID, etc.)

    user = ReferenceField(MyUser, reverse_delete_rule=CASCADE, required=True)
    email = StringField(default='')
    username = StringField(default='')
    name = StringField(max_length=50, default="", blank=True)  # Add default value here
    surname = StringField(max_length=50, blank=True, default='')
    dob = DateTimeField(null=True, blank=True, default=datetime.utcnow) # was models.datefield
    phone_number = StringField(max_length=15, null=True, blank=True, default='')
    image = StringField(null=True, blank=True, upload_to='images/', default='') #was models.imageField


# help centre (HC) messages
# One user can have multiple HC messages, multiple messages can be sent to one user
#           - email here is a foreign key (FK) from User table's PK email; when the email instance (meaning a user) 
#             is deleted from User table, delete the respective entries from this table too
#           - thread_number (generated in frontend and passed to backend) needs to be unique
#           - subject, topic, message_body cannot be empty
#           - topic, status, actions have pre defined options
#           - used in Flutter in contact.dart
class HelpCentreMessage(Document):
    GENERAL_INQUIRY = 'General Inquiry'
    TECHNICAL_SUPPORT = 'Technical Support'
    BILLING_ISSUE = 'Billing Issue'
    OTHER = 'Other'
    TOPIC_CHOICES = [
        (GENERAL_INQUIRY, 'General Inquiry'),
        (TECHNICAL_SUPPORT, 'Technical Support'),
        (BILLING_ISSUE, 'Billing Issue'),
        (OTHER, 'Other'),
    ]

    OPEN = 'Open'
    RESOLVED = 'Resolved'
    STATUS_CHOICES = [
        (OPEN, 'Open'),
        (RESOLVED, 'Resolved'),
    ]

    AWAITING_REVIEW = 'Awaiting Review'
    RESPONDED = 'Responded'
    ESCALATED = 'Escalated'
    ACTIONS_CHOICES = [
        (AWAITING_REVIEW, 'Awaiting Review'),
        (RESPONDED, 'Responded'),
        (ESCALATED, 'Escalated'),
    ]

    id = UUIDField(primary_key=True, default=uuid.uuid4, binary=False)  # Explicit ID field (can be UUID, etc.)
    user = ReferenceField(MyUser, reverse_delete_rule=CASCADE, required=True)
    email = StringField()
    subject = StringField(max_length=50, default='')
    topic = StringField(max_length=30, choices=TOPIC_CHOICES, default=GENERAL_INQUIRY)
    message_body = StringField(max_length=1000, default='')
    timestamp_sent = DateTimeField(default=datetime.utcnow)  # provided from flutter
    timestamp_read = DateTimeField(null=True, blank=True)  # this will be empty first, updated from admin panel
    is_read = BooleanField(default=False)
    status = StringField(max_length=20, choices=STATUS_CHOICES, default=OPEN)
    actions = StringField(max_length=20, choices=ACTIONS_CHOICES, default=AWAITING_REVIEW)

# TODO: in frontend impose max char constraint for subject , message_body

# Here, upon deleting the account we fill in the reason fields in the frontend. We save those messages for admin review.
#           - we do not keep any user details
#           - reason, message_body cannot be null
#           - there are 4 pre defined reason options   
class TerminateAccountMessage(Document):
    POOR_SERVICE = 'Poor Service'
    FOUND_A_BETTER_SERVICE = 'Found A Better Service'
    PRIVACY_CONCERNS = 'Privacy Concerns'
    OTHER = 'Other'
    REASON_CHOICES = [
        (POOR_SERVICE, 'Poor Service'),
        (FOUND_A_BETTER_SERVICE, 'Found A Better Service'),
        (PRIVACY_CONCERNS, 'Privacy Concerns'),
        (OTHER, 'Other'),
    ]

    id = UUIDField(primary_key=True, default=uuid.uuid4, binary=False)  # Explicit ID field (can be UUID, etc.)
    reason = StringField(max_length=50, choices=REASON_CHOICES, default='')
    message_body = StringField(max_length=1000, default='')
    submitted_at = DateTimeField(null=True, blank=True, default=datetime.utcnow)
    reviewed = BooleanField(default=False)


# here we have a workout type when setting the details in set_workout_page in Flutter. An instance of this will be
# needed for the actual WorkoutEntry table below
#           - timestamp is created here automatically
#           - the names of the choices NEED to match the values you send from Flutter
#           - based on the session_id relationship here (PK) and with WorkoutEntry table where it is an FK, you can perform joins like LEFT OUTER JOIN to get one table with all data to work on
class WorkoutType(Document):
    VR_GAME = 'VR Game'
    CYCLING = 'Cycling'
    RUNNING = 'Running'
    YOGA = 'Yoga'
    PILATES = 'Pilates'
    AEROBIC = 'Aerobic'
    HIGH_INTENSITY = 'High Intensity'

    NAME_CHOICES = [
        (VR_GAME, 'VR Game'),
        (CYCLING, 'Cycling'),
        (RUNNING, 'Running'),
        (YOGA, 'Yoga'),
        (PILATES, 'Pilates'),
        (AEROBIC, 'Aerobic'),
        (HIGH_INTENSITY, 'High Intensity'),
    ]

    DURATION_CHOICES = [
        (15, '15 minutes'),
        (30, '30 minutes'),
        (45, '45 minutes'),
        (60, '60 minutes'),
    ]

    BEGINNER = 'Beginner'
    INTERMEDIATE = 'Intermediate'
    ADVANCED = 'Advanced'

    LEVEL_CHOICES = [
        (BEGINNER, 'Beginner'),
        (INTERMEDIATE, 'Intermediate'),
        (ADVANCED, 'Advanced'),
    ]

    INTERVAL = 'Interval'
    CONTINUOUS = 'Continuous'

    TYPE_CHOICES = [
        (INTERVAL, 'Interval'),
        (CONTINUOUS, 'Continuous'),
    ]

    id = UUIDField(primary_key=True, default=uuid.uuid4, unique=True, binary=False)
    user_id = ReferenceField(MyUser, reverse_delete_rule=CASCADE, required=True)
    email = StringField(default='')
    name = StringField(max_length=20, choices=NAME_CHOICES, default=VR_GAME)
    session_duration = IntField(choices=DURATION_CHOICES, default=15)
    level = StringField(max_length=20, choices=LEVEL_CHOICES, default=BEGINNER)
    type = StringField(max_length=20, choices=TYPE_CHOICES, default=INTERVAL)
    created_at = DateTimeField(default=timezone.now)
    finished = BooleanField(default=False)
    processed = BooleanField(
        default=False)  # this feature is used to automate data processing; by default is False, when changed to TRue it will trigger data clean & proc

    # this is for admin interface
    #def __str__(self):
    #    return self.name
# this is where we will store data points (every second, every 5 seconds we'll see?)
# Each WorkoutType can have multiple WorkoutEntries
# Each WorkoutEntry can be associated with only 1 WorkoutType and 1 User
#           - again once we delete the used from User table, those records will be deleted as well
#           - UUID will be generated once for a sessionm in Flutter
#           - the attributes (speed, rpm etc) can be null as different workouts will collect different measures
class WorkoutEntry(Document):
    id = UUIDField(primary_key=True, default=uuid.uuid4, binary=False)  # Explicit ID field (can be UUID, etc.)
    session_id = ReferenceField(WorkoutType, reverse_delete_rule=CASCADE, required=True)
    speed = DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    rpm = IntField(null=True, blank=True)
    distance = DecimalField(max_digits=6, decimal_places=2, null=True, blank=True)
    heart_rate = IntField(null=True, blank=True)
    temperature = DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    incline = IntField(null=True, blank=True)
    timestamp = DateTimeField(null=True,
                                     blank=True)  # because sometimes there might be errors when collecting data

    # this is for admin interface
    #def __str__(self):
    #    return f"Workout for {self.user.username} - {self.workout_type.name}"


class WorkoutAnalysis(Document):
    id = UUIDField(primary_key=True, default=uuid.uuid4, binary=False)  # Explicit ID field (can be UUID, etc.)
    session_id = ReferenceField(WorkoutType, reverse_delete_rule=CASCADE)
    avg_speed = DecimalField(max_digits=5, decimal_places=2, null=True, blank=True, default=0)
    max_speed = DecimalField(max_digits=5, decimal_places=2, null=True, blank=True, default=0)
    total_distance = DecimalField(max_digits=6, decimal_places=2, null=True, blank=True, default=0)
    avg_heart_rate = IntField(null=True, blank=True, default=0)
    workout_duration = IntField(null=True, blank=True, default=0)
    avg_temperature = DecimalField(max_digits=5, decimal_places=2, null=True, blank=True, default=0)


class Schedule(Document):
    id = UUIDField(primary_key=True, default=uuid.uuid4, binary=False)  # Explicit ID field (can be UUID, etc.)
    user = ReferenceField(MyUser, reverse_delete_rule=CASCADE)
    title = StringField(max_length=100, default='Workout')
    description = StringField(blank=True, null=True)
    date = DateTimeField() #was models.datefield
    time = StringField() #was models.timeField
    reminder_minutes = IntField(default=0)  # e.g. 60 for 1 hour before
    recurrence = StringField(max_length=20, choices=[
        ('None', 'None'),
        ('Daily', 'Daily'),
        ('Weekly', 'Weekly'),
        ('Monthly', 'Monthly'),
    ], default='None')
    created_at = DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username} - {self.title} on {self.date} at {self.time}" #updated code
