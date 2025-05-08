from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import AdminChatMessage

User = get_user_model()

# Serializer for the Users model to convert Python objects to JSON
class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'email', 'username']
        
        


class AdminChatMessageSerializer(serializers.ModelSerializer):
    class Meta:
        model = AdminChatMessage
        fields = '__all__'