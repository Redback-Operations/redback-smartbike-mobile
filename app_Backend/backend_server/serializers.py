from rest_framework import serializers #use for MySql
from rest_framework_mongoengine.serializers import DocumentSerializer
from .models import MyUser, AccountDetails, HelpCentreMessage, TerminateAccountMessage, WorkoutType, WorkoutEntry, WorkoutAnalysis
from django.contrib.auth.hashers import make_password
import os
from django.conf import settings
from rest_framework_mongoengine.fields import ReferenceField

# Serializer for the Users model to convert Python objects to JSON
class UserSerializer(DocumentSerializer):
    login_id = serializers.CharField(required=False) 
    login_type = serializers.CharField(required=False) 
    otp = serializers.CharField(required=False)
    class Meta:
        model = MyUser  
        fields = ['id','email', 'username', 'password', 'user_created', 'login_id', 'login_type','otp']
        extra_kwargs = {
            'id': {'required': False, 'read_only': False}  # allow manual ID setting
        }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        # Check debug from environment and set password field visibility
        if settings.DEBUG:
            # Allow password to be visible for debugging (not recommended in production!)
            self.fields['password'].write_only = False
        else:
            self.fields['password'].write_only = True
            

    #no plaintext passwords in DB - hash them!
    def create(self, validated_data):
        validated_data['password'] = make_password(validated_data['password'])
        return super().create(validated_data)

class SocialMediaUserSerializer(DocumentSerializer):
    password = serializers.CharField(required=False)
    otp = serializers.CharField(required=False) 
    class Meta:
        model = MyUser  
        fields = ['id', 'email', 'username', 'password', 'user_created', 'login_id', 'login_type', 'otp']
        extra_kwargs = {
            'id': {'required': False, 'read_only': False}  # allow manual ID setting
        }     
        #extra_kwargs = {'password': {'write_only': True}} #don't return passwords whith sm user object

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        # Check debug from environment and set password field visibility
        if settings.DEBUG:
            # Allow password to be visible for debugging (not recommended in production!)
            self.fields['password'].write_only = False
        else:
            self.fields['password'].write_only = True   

    #no plaintext passwords in DB - hash them!
    def create(self, validated_data):
        validated_data['password'] = make_password(validated_data['password'])
        return super().create(validated_data)

class AccountDetailsSerializer(DocumentSerializer):
    class Meta:
        model = AccountDetails
        fields = ['id', 'email', 'username', 'name', 'surname', 'dob', 'phone_number', 'image'] 

class HelpCentreMsgSerializer(DocumentSerializer):
    class Meta:
        model = HelpCentreMessage
        fields = ['id', 'email', 'subject', 'topic', 'message_body', 'timestamp_sent', 'timestamp_read','is_read', 'status','actions'] 

class TerminateAccMsgSerializer(DocumentSerializer):
    class Meta:
        model = TerminateAccountMessage
        fields = ['id', 'reason', 'message_body', 'submitted_at', 'reviewed'] 

class WorkoutTypeSerializer(DocumentSerializer):
    class Meta:
        model = WorkoutType
        fields = ['id', 'email', 'name', 'session_duration', 'level', 'type', 'finished', 'processed']        
        extra_kwargs = {
            'id': {'required': False, 'read_only': False}  # allow manual setting
        }

class WorkoutEntrySerializer(DocumentSerializer):
    class Meta:
        model = WorkoutEntry
        fields = ['id', 'session_id', 'speed', 'rpm', 'distance', 'heart_rate', 'temperature', 'incline', 'timestamp'] 
# or :  fields = '__all__'   if we want to choose all fields

class WorkoutAnalysisSerializer(DocumentSerializer):
    class Meta:
        model = WorkoutAnalysis
        fields = '__all__' 