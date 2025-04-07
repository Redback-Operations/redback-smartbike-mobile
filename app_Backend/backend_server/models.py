from django.db import models
from django.utils import timezone


# When creating a user you need to provide all 3 fields, out of which:
#           - email will be a primary key and unique (PK implies uniqueness)
#           - username will need to be unique
#   TODO:   - set password max length to 20 in Flutter
#           - used in Flutter in signup.dart
class MyUser(models.Model):
    id = models.CharField(max_length=50, unique=True, default='')
    email = models.CharField(max_length=50, primary_key=True )
    username = models.CharField(max_length=20, unique=True)
    password = models.CharField(max_length=20)
    user_created = models.DateTimeField(null=True, max_length=50)
    login_type = models.CharField(null=True, max_length=20)
    login_id = models.CharField(null=True, max_length=50, unique=True)
    otp = models.CharField(max_length=6, blank=True, null=True)  # OTP field
    otp_created_at = models.DateTimeField(blank=True, null=True)  # Optional: to track OTP creation time

    # generate the id, starting at 1000, and add 1 to each new user
    def save(self, *args, **kwargs):
        self.email = self.email.strip().lower() ##lowercase email

        if not self.id:  # If id is not already set
            last_user = MyUser.objects.order_by('-id').first()
            if last_user:
                last_id = int(last_user.id)
            else:
                last_id = 999  # Starting from 1000
            self.id = str(last_id + 1)  # Increment the id
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
class AccountDetails(models.Model):
    email = models.OneToOneField(MyUser, on_delete=models.CASCADE, related_name='email_accountdetails',
                                 primary_key=True, to_field='email')
    username = models.OneToOneField(MyUser, on_delete=models.CASCADE, related_name='username_accountdetails',
                                    unique=True, to_field='username')
    name = models.CharField(max_length=50, default="", blank=True)  # Add default value here
    surname = models.CharField(max_length=50, blank=True)
    dob = models.DateField(null=True, blank=True)
    phone_number = models.CharField(max_length=15, null=True, blank=True)
    image = models.ImageField(null=True, blank=True, upload_to='images/')


# help centre (HC) messages
# One user can have multiple HC messages, multiple messages can be sent to one user
#           - email here is a foreign key (FK) from User table's PK email; when the email instance (meaning a user) 
#             is deleted from User table, delete the respective entries from this table too
#           - thread_number (generated in frontend and passed to backend) needs to be unique
#           - subject, topic, message_body cannot be empty
#           - topic, status, actions have pre defined options
#           - used in Flutter in contact.dart
class HelpCentreMessage(models.Model):
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

    thread_number = models.UUIDField(max_length=100, unique=True,
                                     default='')  # UUID format, generate in flutter and pass
    email = models.ForeignKey(MyUser, on_delete=models.CASCADE)
    subject = models.CharField(max_length=50)
    topic = models.CharField(max_length=30, choices=TOPIC_CHOICES)
    message_body = models.CharField(max_length=1000)
    timestamp_sent = models.DateTimeField()  # provided from flutter
    timestamp_read = models.DateTimeField(null=True, blank=True)  # this will be empty first, updated from admin panel
    is_read = models.BooleanField(default=False)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default=OPEN)
    actions = models.CharField(max_length=20, choices=ACTIONS_CHOICES, default=AWAITING_REVIEW)

# TODO: in frontend impose max char constraint for subject , message_body

# Here, upon deleting the account we fill in the reason fields in the frontend. We save those messages for admin review.
#           - we do not keep any user details
#           - reason, message_body cannot be null
#           - there are 4 pre defined reason options   
class TerminateAccountMessage(models.Model):
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

    reason = models.CharField(max_length=50, choices=REASON_CHOICES)
    message_body = models.CharField(max_length=1000)
    submitted_at = models.DateTimeField(null=True, blank=True)
    reviewed = models.BooleanField(default=False)


# here we have a workout type when setting the details in set_workout_page in Flutter. An instance of this will be
# needed for the actual WorkoutEntry table below
#           - timestamp is created here automatically
#           - the names of the choices NEED to match the values you send from Flutter
#           - based on the session_id relationship here (PK) and with WorkoutEntry table where it is an FK, you can perform joins like LEFT OUTER JOIN to get one table with all data to work on
class WorkoutType(models.Model):
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

    session_id = models.CharField(max_length=100, primary_key=True)
    email = models.ForeignKey(MyUser, on_delete=models.CASCADE, default='',
                              to_field='email')  # when user deleted, delete records too
    name = models.CharField(max_length=20, choices=NAME_CHOICES)
    session_duration = models.IntegerField(choices=DURATION_CHOICES)
    level = models.CharField(max_length=20, choices=LEVEL_CHOICES)
    type = models.CharField(max_length=20, choices=TYPE_CHOICES)
    created_at = models.DateTimeField(default=timezone.now)
    finished = models.BooleanField(default=False)
    processed = models.BooleanField(
        default=False)  # this feature is used to automate data processing; by default is False, when changed to TRue it will trigger data clean & proc

    # this is for admin interface
    def __str__(self):
        return self.name
# this is where we will store data points (every second, every 5 seconds we'll see?)
# Each WorkoutType can have multiple WorkoutEntries
# Each WorkoutEntry can be associated with only 1 WorkoutType and 1 User
#           - again once we delete the used from User table, those records will be deleted as well
#           - UUID will be generated once for a sessionm in Flutter
#           - the attributes (speed, rpm etc) can be null as different workouts will collect different measures
class WorkoutEntry(models.Model):
    session_id = models.ForeignKey(WorkoutType, on_delete=models.CASCADE, related_name='session_id_workouttype',
                                   to_field='session_id')
    speed = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    rpm = models.IntegerField(null=True, blank=True)
    distance = models.DecimalField(max_digits=6, decimal_places=2, null=True, blank=True)
    heart_rate = models.IntegerField(null=True, blank=True)
    temperature = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    incline = models.IntegerField(null=True, blank=True)
    timestamp = models.DateTimeField(null=True,
                                     blank=True)  # because sometimes there might be errors when collecting data

    # this is for admin interface
    def __str__(self):
        return f"Workout for {self.user.username} - {self.workout_type.name}"


class WorkoutAnalysis(models.Model):
    session_id = models.ForeignKey(WorkoutType, on_delete=models.CASCADE, related_name='session_id_workoutanalysis',
                                   to_field='session_id')
    avg_speed = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    max_speed = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    total_distance = models.DecimalField(max_digits=6, decimal_places=2, null=True, blank=True)
    avg_heart_rate = models.IntegerField(null=True, blank=True)
    workout_duration = models.IntegerField(null=True, blank=True)
    avg_temperature = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)