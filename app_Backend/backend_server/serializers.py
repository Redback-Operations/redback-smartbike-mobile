from rest_framework import serializers
from .models import MyUser, AccountDetails, HelpCentreMessage, TerminateAccountMessage, WorkoutType, WorkoutEntry, WorkoutAnalysis
from django.contrib.auth.hashers import make_password
import os

# Serializer for the Users model to convert Python objects to JSON
class UserSerializer(serializers.ModelSerializer):
    login_id = serializers.CharField(required=False) 
    login_type = serializers.CharField(required=False) 
    otp = serializers.CharField(required=False)
    class Meta:
        model = MyUser  
        fields = ['id','email', 'username', 'password', 'user_created', 'login_id', 'login_type','otp']
        #extra_kwargs = {'password': {'write_only': True}} #don't return passwords whith user object

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        # Check debug from environment and set password field visibility
        debug_mode = os.getenv("DEBUG", "").upper() == "TRUE"
        if debug_mode:
            # Allow password to be visible for debugging (not recommended in production!)
            self.fields['password'].write_only = False
        else:
            self.fields['password'].write_only = True
            

    #no plaintext passwords in DB - hash them!
    def create(self, validated_data):
        validated_data['password'] = make_password(validated_data['password'])
        return super().create(validated_data)

class SocialMediaUserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(required=False)
    otp = serializers.CharField(required=False) 
    class Meta:
        model = MyUser  
        fields = ['id', 'email', 'username', 'password', 'user_created', 'login_id', 'login_type', 'otp']        
        #extra_kwargs = {'password': {'write_only': True}} #don't return passwords whith sm user object

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        # Check debug from environment and set password field visibility
        debug_mode = os.getenv("DEBUG", "").upper() == "TRUE"
        if debug_mode:
            # Allow password to be visible for debugging (not recommended in production!)
            self.fields['password'].write_only = False
        else:
            self.fields['password'].write_only = True   

    #no plaintext passwords in DB - hash them!
    def create(self, validated_data):
        validated_data['password'] = make_password(validated_data['password'])
        return super().create(validated_data)

class AccountDetailsSerializer(serializers.ModelSerializer):
    class Meta:
        model = AccountDetails
        fields = ['email', 'username', 'name', 'surname', 'dob', 'phone_number', 'image'] 

class HelpCentreMsgSerializer(serializers.ModelSerializer):
    class Meta:
        model = HelpCentreMessage
        fields = ['thread_number', 'email', 'subject', 'topic', 'message_body', 'timestamp_sent', 'timestamp_read','is_read', 'status','actions'] 

class TerminateAccMsgSerializer(serializers.ModelSerializer):
    class Meta:
        model = TerminateAccountMessage
        fields = ['reason', 'message_body', 'submitted_at', 'reviewed'] 

class WorkoutTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = WorkoutType
        fields = ['session_id', 'email', 'name', 'session_duration', 'level', 'type', 'finished', 'processed']

class WorkoutEntrySerializer(serializers.ModelSerializer):
    class Meta:
        model = WorkoutEntry
        fields = ['session_id', 'speed', 'rpm', 'distance', 'heart_rate', 'temperature', 'incline', 'timestamp',] 
# or :  fields = '__all__'   if we want to choose all fields

class WorkoutAnalysisSerializer(serializers.ModelSerializer):
    class Meta:
        model = WorkoutAnalysis
        fields = '__all__' 