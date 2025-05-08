from django.shortcuts import render

from backend_server.customadmin import models

from backend_server.customadmin.serializers import UserSerializer
from backend_server.models import AccountDetails, MyUser
from backend_server.serializers import UserSerializer as MyUserSerializer
from .models import AdminChatMessage
from rest_framework.response import Response
from rest_framework import status

# Create your views here.
from rest_framework.decorators import (
    api_view,
    permission_classes,
    authentication_classes,
)
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated, AllowAny
from django.contrib.auth.models import User
from rest_framework.authtoken.models import Token
# from customadmin.models import AdminUser  # Import your custom admin user model
from backend_server.customadmin.models import AdminUser
from django.views.decorators.csrf import csrf_exempt
from rest_framework.authentication import TokenAuthentication
from rest_framework.permissions import IsAdminUser
from django.db.models import Q

@api_view(["POST"])
@authentication_classes([TokenAuthentication])
@permission_classes([AllowAny])
@csrf_exempt
def admin_login(request):
    """
    Admin login with username and password. User must be a superuser or staff member.
    """
    if request.method == "POST":
        username = request.data.get("username")
        password = request.data.get("password")

        # Authenticate using the username (since you want to login with username)
        try:
            # Try to get the user based on username
            user = User.objects.get(username=username)
        except User.DoesNotExist:
            return Response(
                {"message": "User not found"}, status=status.HTTP_404_NOT_FOUND
            )

        # Check if the password matches
        if user.check_password(
            password
        ):  # Use check_password to verify the password securely
            # Check if the user is a superuser or staff member
            if user.is_superuser or user.is_staff:
                # Log the user in by setting session variables
                request.session["username"] = user.username
                request.session["id"] = user.id
                token, created = Token.objects.get_or_create(user=user)
                # Fetch account details (if any)
                account_details = User.objects.filter(username=user.username)
                serializer = UserSerializer(account_details, many=True)

                return Response(
                    {
                        "message": "Login successful",
                        "id": user.id,
                        "username": user.username,
                        "account_details": serializer.data,
                        "token": token.key,
                    },
                    status=status.HTTP_200_OK,
                )
            else:
                return Response(
                    {"message": "User is not a superuser or staff member"},
                    status=status.HTTP_403_FORBIDDEN,
                )
        else:
            return Response(
                {"message": "Incorrect password"}, status=status.HTTP_401_UNAUTHORIZED
            )


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def admin_user(request):
    """
    A simple API to test if the admin user is authenticated using a token.
    """
    user = request.user
    return Response(
        {
            "message": "Authorization successful",
            "user_id": user.id,
            "username": user.username,
            "email": user.email,
        }
    )


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def get_all_active_users(request):
    """
    Retrieve all active users.
    """
    active_users = MyUser.objects.filter(is_active=True)
    print("active users are", active_users)
    serializer = MyUserSerializer(active_users, many=True)
    return Response({"data": serializer.data}, status=status.HTTP_200_OK)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def get_all_inactive_users(request):
    """
    Retrieve all inactive users.
    """
    inactive_users = MyUser.objects.filter(is_active=False)
    serializer = MyUserSerializer(inactive_users, many=True)
    return Response({"data": serializer.data}, status=status.HTTP_200_OK)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def get_all_users(request):
    """
    Retrieve all users.
    """
    users = MyUser.objects.all()
    serializer = MyUserSerializer(users, many=True)
    return Response({"data": serializer.data}, status=status.HTTP_200_OK)


@api_view(["PATCH"])
@permission_classes([IsAuthenticated])
def update_user_status(request, user_id):
    """
    Update the 'is_active' status of a user.
    This is a PATCH request, so you can modify only the 'is_active' field.
    """
    try:
        # Fetch the user by ID
        user = MyUser.objects.get(id=user_id)
    except MyUser.DoesNotExist:
        return Response({"message": "User not found"}, status=status.HTTP_404_NOT_FOUND)

    # Check if 'is_active' is provided in the request data
    is_active = request.data.get("is_active", None)

    if is_active is None:
        return Response(
            {"message": "'is_active' field is required"},
            status=status.HTTP_400_BAD_REQUEST,
        )

    # Update the user's status
    user.is_active = is_active
    user.save()

    # Return a response indicating the user was updated successfully
    return Response(
        {
            "data": {
                "message": "User status updated successfully",
                "user_id": user.id,
                "username": user.username,
                "is_active": user.is_active,
            }
        },
        status=status.HTTP_200_OK,
    )


@api_view(['GET'])
@permission_classes([IsAdminUser])
def get_user_messages(request, user_id):
    try:
        receiver = MyUser.objects.get(id=user_id)
    except MyUser.DoesNotExist:
        return Response({"detail": "User not found."}, status=status.HTTP_404_NOT_FOUND)

    messages = AdminChatMessage.objects.filter(
        (Q(sender=request.user) & Q(receiver=receiver)) |
        (Q(receiver=receiver) & Q(sender=request.user))
    ).order_by('timestamp')

    message_list = [
        {
            'id': str(message.id),
            'sender_id': str(message.sender.id),
            'receiver_id': str(message.receiver.id),
            'message': message.message,
            'timestamp': message.timestamp,
            'is_from_admin': message.is_from_admin,
        }
        for message in messages
    ]
    return Response({"data": message_list}, status=status.HTTP_200_OK)

@api_view(['POST'])
@permission_classes([IsAdminUser])
def send_message(request):
    receiver_id = request.data.get('receiver_id')
    message_text = request.data.get('message')

    if not receiver_id or not message_text:
        return Response({
            'success': False,
            'error': 'Receiver ID and message are required.'
        }, status=status.HTTP_400_BAD_REQUEST)

    try:
        receiver = MyUser.objects.get(id=receiver_id)
    except MyUser.DoesNotExist:
        return Response({
            'success': False,
            'error': 'Receiver not found.'
        }, status=status.HTTP_404_NOT_FOUND)

    user = request.user  # Already available from request (no need to fetch again)

    if not (user.is_superuser or user.is_staff):
        return Response({
            'success': False,
            'error': 'User is not authorized to send messages.'
        }, status=status.HTTP_403_FORBIDDEN)

    # Create message
    message = AdminChatMessage.objects.create(
        sender=user,
        receiver=receiver,
        message=message_text,
        is_from_admin=True
    )

    return Response({
        'success': True,
        'data': {
            'id': str(message.id),
            'sender_id': str(message.sender.id),
            'receiver_id': str(message.receiver.id),
            'message': message.message,
            'timestamp': message.timestamp,
            'is_from_admin': message.is_from_admin
        }
    }, status=status.HTTP_201_CREATED)
