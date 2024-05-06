from rest_framework import serializers
from .models import MyUser,AccountDetails,HelpCentreMessage, TerminateAccountMessage, WorkoutType, WorkoutEntry


# Serializer for the Users model to convert Python objects to JSON
class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = MyUser  
        fields = ['id','email', 'username', 'password', 'user_created']   

class AccountDetailsSerializer(serializers.ModelSerializer):
    class Meta:
        model = AccountDetails
        fields = ['email','username','name', 'surname', 'dob', 'phone_number','image'] 

class HelpCentreMsgSerializer(serializers.ModelSerializer):
    class Meta:
        model = HelpCentreMessage
        fields = ['thread_number','email','subject','topic', 'message_body', 'timestamp_sent', 'timestamp_read','is_read', 'status','actions'] 

class TerminateAccMsgSerializer(serializers.ModelSerializer):
    class Meta:
        model = TerminateAccountMessage
        fields = ['reason','message_body','submitted_at','reviewed'] 

class WorkoutTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = WorkoutType
        fields = ['session_id','email','name','session_duration','level','type', ] 

class WorkoutEntrySerializer(serializers.ModelSerializer):
    class Meta:
        model = WorkoutEntry
        fields = ['session_id','speed','rpm', 'distance', 'heart_rate', 'temperature','incline', 'timestamp',] 
# or :  fields: '__all__'   if we want to choose all fields

