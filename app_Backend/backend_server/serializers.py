import os # Standard library

from rest_framework import serializers # Third-party
from django.contrib.auth.hashers import make_password # Django is third-party

from .models import ( # Local application imports
    MyUser, AccountDetails, HelpCentreMessage, TerminateAccountMessage,
    WorkoutType, WorkoutEntry, WorkoutAnalysis, Schedule
)

# Base serializer for common user logic
class BaseUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = MyUser
        fields = ['id', 'email', 'username', 'password', 'user_created', 'login_id', 'login_type', 'otp']
        extra_kwargs = {
            'id': {'read_only': True},
            'user_created': {'read_only': True},
            'login_id': {'required': False, 'allow_null': True, 'allow_blank': True},
            'login_type': {'required': False, 'allow_null': True, 'allow_blank': True},
            'otp': {'required': False, 'write_only': True, 'allow_null': True, 'allow_blank': True},
            # 'password' write_only status handled in __init__
            # 'password' required status is handled by subclasses
        }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Default to "FALSE" if DEBUG is not set, ensuring production secure default
        debug_mode = os.getenv("DEBUG", "FALSE").upper() == "TRUE"
        if 'password' in self.fields:  # Ensure 'password' field exists
            self.fields['password'].write_only = not debug_mode

    def _hash_password_if_present(self, validated_data):
        password = validated_data.get('password')
        if password:  # Hashes if password is not None and not an empty string
            validated_data['password'] = make_password(password)
        # If password is None or not provided, it's not hashed.
        # The model/manager should handle None passwords (e.g., set_unusable_password).
        return validated_data

    def create(self, validated_data):
        validated_data = self._hash_password_if_present(validated_data)
        return super().create(validated_data)

    def update(self, instance, validated_data):
        validated_data = self._hash_password_if_present(validated_data)
        return super().update(instance, validated_data)

# Serializer for standard Users
class UserSerializer(BaseUserSerializer):
    class Meta(BaseUserSerializer.Meta): # Inherits model, fields from BaseUserSerializer.Meta
        extra_kwargs = {
            **BaseUserSerializer.Meta.extra_kwargs,  # Inherit base extra_kwargs
            'password': {'required': True, 'write_only': True} # Standard users must provide a password
        }
    # __init__ is inherited and will set write_only based on DEBUG

# Serializer for Social Media Users
class SocialMediaUserSerializer(BaseUserSerializer):
    class Meta(BaseUserSerializer.Meta): # Inherits model, fields from BaseUserSerializer.Meta
        extra_kwargs = {
            **BaseUserSerializer.Meta.extra_kwargs,
            'password': {'required': False, 'write_only': True, 'allow_null': True, 'allow_blank': True} # Password is not required for social media users
        }
    # __init__ is inherited and will set write_only based on DEBUG

class AccountDetailsSerializer(serializers.ModelSerializer):
    class Meta:
        model = AccountDetails
        fields = ['email', 'username', 'name', 'surname', 'dob', 'phone_number', 'image']
        # Assuming 'email' and 'username' might be linked to MyUser and potentially read-only here
        # or updatable through a specific user profile update endpoint.
        # Example: read_only_fields = ['email', 'username']

class HelpCentreMsgSerializer(serializers.ModelSerializer):
    class Meta:
        model = HelpCentreMessage
        fields = ['thread_number', 'email', 'subject', 'topic', 'message_body', 'timestamp_sent', 'timestamp_read', 'is_read', 'status', 'actions']
        read_only_fields = ['thread_number', 'timestamp_sent', 'timestamp_read'] # These are typically system-set

class TerminateAccMsgSerializer(serializers.ModelSerializer):
    class Meta:
        model = TerminateAccountMessage
        fields = ['reason', 'message_body', 'submitted_at', 'reviewed']
        read_only_fields = ['submitted_at', 'reviewed'] # 'reviewed' likely set by admin, 'submitted_at' by system

class WorkoutTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = WorkoutType
        fields = ['session_id', 'email', 'name', 'session_duration', 'level', 'type', 'finished', 'processed']
        read_only_fields = ['session_id'] # Assuming session_id is PK or auto-generated
        # 'processed' and 'finished' might be updated by system or user actions, depending on logic.

class WorkoutEntrySerializer(serializers.ModelSerializer):
    class Meta:
        model = WorkoutEntry
        fields = ['session_id', 'speed', 'rpm', 'distance', 'heart_rate', 'temperature', 'incline', 'timestamp']
        read_only_fields = ['timestamp'] # If timestamp is auto_now_add or similar

class WorkoutAnalysisSerializer(serializers.ModelSerializer):
    class Meta:
        model = WorkoutAnalysis
        fields = '__all__'
        # For critical models, consider listing fields explicitly for clarity and security,
        # e.g., fields = ['id', 'workout_type', 'analysis_data', 'created_at']
        # and specify read_only_fields as needed, e.g., read_only_fields = ['id', 'created_at']

class ScheduleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Schedule
        fields = '__all__' # Or list fields explicitly if preferred
        # Example: read_only_fields = ['id', 'created_at', 'updated_at'] if you have such fields