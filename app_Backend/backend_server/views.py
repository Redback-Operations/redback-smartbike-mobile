from django.conf import settings
from .models import MyUser, AccountDetails, HelpCentreMessage, TerminateAccountMessage, WorkoutType, WorkoutAnalysis
from .serializers import UserSerializer, AccountDetailsSerializer, HelpCentreMsgSerializer, TerminateAccMsgSerializer, \
    WorkoutEntrySerializer, WorkoutTypeSerializer, SocialMediaUserSerializer, WorkoutAnalysisSerializer
from .forms import UserCreationForm, SignUpForm, LoginForm
from django.http import JsonResponse
from django.core.exceptions import ObjectDoesNotExist
from .auth_form_serializers import LoginSerializer, SignupSerializer
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from rest_framework.exceptions import ValidationError
from django.contrib.auth import authenticate, login
from django.shortcuts import render, redirect
from django.views.decorators.csrf import csrf_exempt
from django.utils.encoding import force_bytes
from django.utils.http import urlsafe_base64_encode
from django.core.mail import send_mail
from django.contrib.auth.models import User
from rest_framework.decorators import parser_classes
from rest_framework.parsers import JSONParser
from django.db.models import Q
from datetime import datetime, timedelta 
import hashlib
from .tasks import clean_workout_data_task, analyse_workout_data_task
from rest_framework import viewsets
from rest_framework.response import Response
import logging
from celery import chain
from django.contrib.auth.tokens import default_token_generator
from django.template.loader import render_to_string
import json
from .models import MyUser
import random
from django.utils import timezone

logger = logging.getLogger(__name__)
def home(request):
    return render(request, "home.html")

def redirect_home(request):
    return render(request, "redirect_home.html")

@api_view(['GET', 'PUT', 'DELETE'])
def user_detail(request, email):
    user = AccountDetails.objects.get(email=email)

    if request.method == 'GET':
        serializer = AccountDetailsSerializer(user)
        return Response(serializer.data)
    elif request.method == 'PUT':
        serializer = AccountDetailsSerializer(user, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    elif request.method == "DELETE":
        user.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

@api_view(['GET'])
def get_user_details(request, emaill, format=None):
    try:
        user = AccountDetails.objects.get(email=emaill)
    except AccountDetails.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)

    if request.method == 'GET':
        serializer = AccountDetailsSerializer(user)
        return Response(serializer.data)

@api_view(['GET', 'POST'])
def user_list(request, format=None):
    if request.method == 'GET':
        users = AccountDetails.objects.all()
        serializer = AccountDetailsSerializer(users, many=True)
        return Response(serializer.data)
    elif request.method == 'POST':
        serializer = AccountDetailsSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
def signup(request, format=None):
    if request.method == 'POST':
        fetched_email = request.data.get("email")
        fetched_username = request.data.get("username")

        email_is_exist = MyUser.objects.filter(email=fetched_email).exists()
        username_is_exist = MyUser.objects.filter(username=fetched_username).exists()

        if email_is_exist:
            return Response("This email already exists in our records.", status=status.HTTP_409_CONFLICT)
        elif username_is_exist:
            return Response("This username already exists in our records.", status=status.HTTP_409_CONFLICT)
        else:
            serializer = UserSerializer(data=request.data)
            if serializer.is_valid():
                serializer.save()
                return Response(serializer.data, status=status.HTTP_201_CREATED)
            else:
                return Response({"message": "Failed to create user.", "errors": serializer.errors},  status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
def social_media_login(request, format=None):
    if request.method == 'POST':
        fetched_email = request.data.get("email")
        fetched_username = request.data.get("username")
        fetched_id = request.data.get("login_id")
        fetched_type = request.data.get("login_type")

        if fetched_id is None and fetched_type is None:
            return Response({"message": "Failed to Authenticate User", "errors": "login_id and type is required!"},
                            status=status.HTTP_403_FORBIDDEN)
        
        user_is_enrolled = MyUser.objects.filter(
            Q(login_id=fetched_id) & Q(login_type=fetched_type) & Q(email=fetched_email)).first()
        user_is_registered = MyUser.objects.filter(
            Q(login_id__isnull=True) & Q(login_type__isnull=True) & Q(email=fetched_email)).exists()

        if user_is_enrolled is not None:
            account_details = AccountDetails.objects.filter(email=fetched_email)
            serializer = AccountDetailsSerializer(account_details, many=True)

            return Response({
                'message': 'Login successful',
                'id': user_is_enrolled.id,
                'account_details': serializer.data,
            }, status=status.HTTP_200_OK)
        elif user_is_registered:
            return Response({"message": "User is already registered directly to the platform", "code": 1001},
                            status=status.HTTP_400_BAD_REQUEST)
        else:
            serializer = SocialMediaUserSerializer(data=request.data)
            if serializer.is_valid():
                serializer.save()

                account_details = AccountDetails.objects.filter(email=fetched_email)
                account_serializer = AccountDetailsSerializer(account_details, many=True)

                return Response({
                    'message': 'Login successful - new user',
                    'id': serializer.data["id"],
                    'account_details': account_serializer.data,
                }, status=status.HTTP_200_OK)
            elif serializer.errors.get('username') != "my user with this username already exists.":
                suffix = str(datetime.now())[-5:]
                request.data.update({"username": fetched_username + suffix})
                serializer = SocialMediaUserSerializer(data=request.data)
                if serializer.is_valid():
                    serializer.save()

                    account_details = AccountDetails.objects.filter(email=fetched_email)
                    account_serializer = AccountDetailsSerializer(account_details, many=True)

                    return Response({
                        'message': 'Login successful - new user',
                        'id': serializer.data.id,
                        'account_details': account_serializer.data,
                    }, status=status.HTTP_200_OK)
                else:
                    return Response({"message": "Failed to create user.", "errors": serializer.errors},
                                    status=status.HTTP_400_BAD_REQUEST)
            else:
                return Response({"message": "Failed to create user.", "errors": serializer.errors},
                                status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
def help_center_message_create(request, format=None):
    if request.method == 'POST':
        serializer = HelpCentreMsgSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
@parser_classes([JSONParser])
def terminate_account_message_create(request, format=None):
    if request.method == 'POST':
        serializer = TerminateAccMsgSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
@csrf_exempt
def login_view(request):
    if request.method == 'POST':
        email = request.data.get('email')
        password = request.data.get('password')

        try:
            user = MyUser.objects.get(email=email)
            if user.password == password:
                request.session['email'] = user.email
                request.session['id'] = user.id  

                account_details = AccountDetails.objects.filter(email=user.email)
                serializer = AccountDetailsSerializer(account_details, many=True)

                return Response({
                    'message': 'Login successful',
                    'id': user.id,
                    'account_details': serializer.data,
                }, status=status.HTTP_200_OK)
            else:
                return Response({'message': 'Incorrect password'}, status=status.HTTP_401_UNAUTHORIZED)
        except MyUser.DoesNotExist:
            return Response({'message': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

@api_view(['GET'])
@csrf_exempt
def auth_password(request, email, format=None):
    if request.method == 'GET':
        user_password = request.GET.get('password')
        print('pass:' + user_password)
        try:
            user = MyUser.objects.get(pk=email) 
            if user.password == user_password:
                return Response(status=status.HTTP_200_OK)
            else:
                return Response(status=status.HTTP_403_FORBIDDEN)
        except MyUser.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)
    else:
        return Response(status=status.HTTP_405_METHOD_NOT_ALLOWED)

@api_view(['DELETE'])
@csrf_exempt
def delete_user(request, email):
    print('email received:' + email)
    if request.method == 'DELETE':
        try:
            user = MyUser.objects.get(pk=email)
            user.delete()
            return JsonResponse({"message": "User deleted successfully"}, status=status.HTTP_204_NO_CONTENT)
        except MyUser.DoesNotExist:
            return JsonResponse({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)

def get_all_details(request):
    if request.method == 'POST':
        all_details = AccountDetails.objects.all().values()
        details_list = list(all_details)
        return JsonResponse({'details': details_list})
    else:
        return JsonResponse({'error': 'Method not allowed'}, status=405)

@api_view(['POST'])
def set_workout(request):
    if request.method == 'POST':
        workout_type_serializer = WorkoutTypeSerializer(data=request.data)
        if workout_type_serializer.is_valid():
            workout_type = workout_type_serializer.save()
            return Response(workout_type_serializer.data, status=status.HTTP_201_CREATED)
        else:
            return Response(workout_type_serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
def wrk_data(request):
    if request.method == 'POST':
        serializer = WorkoutEntrySerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class WorkoutViewSet(viewsets.ModelViewSet):
    queryset = WorkoutType.objects.all()
    serializer_class = WorkoutTypeSerializer

    def perform_create(self, serializer):
        instance = serializer.save()
        chain(
            clean_workout_data_task.s(instance.id),
            analyse_workout_data_task.s(instance.id)
        ).apply_async()

@api_view(['PATCH'])
@csrf_exempt  
def wrk_finished(request):
    try:
        session_id = request.data.get('session_id')
        finished = request.data.get('finished')

        if session_id is None or finished is None:
            logger.error('session_id and finished fields are required')
            return Response({'error': 'session_id and finished fields are required'},
                            status=status.HTTP_422_UNPROCESSABLE_ENTITY)

        workout = WorkoutType.objects.filter(session_id=session_id).first()
        if workout is None:
            logger.error(f'WorkoutType not found for session_id: {session_id}')
            return Response({'error': 'WorkoutType not found'}, status=status.HTTP_404_NOT_FOUND)

        workout.finished = finished
        workout.save()
        logger.info(f'WorkoutType updated for session_id: {session_id}, finished: {finished}')

        if finished:
            chain(
                clean_workout_data_task.s(workout.session_id),
                analyse_workout_data_task.s(workout.session_id)
            ).apply_async()
            logger.info(f'Triggered Celery tasks for session_id: {session_id}')

        return Response({'status': 'success', 'finished': workout.finished}, status=status.HTTP_200_OK)

    except Exception as e:
        logger.error(f'An error occurred while processing the request: {e}')
        print(f"An error occurred: {e}")
        return Response({'error': 'An error occurred while processing the request'},
                        status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['GET'])
def get_analysis(request, session_id):
    try:
        workout_analysis = WorkoutAnalysis.objects.get(session_id=session_id)
        serializer = WorkoutAnalysisSerializer(workout_analysis)
        return Response(serializer.data)
    except WorkoutAnalysis.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)

# View to handle password reset requests
@api_view(['POST'])
@csrf_exempt
def password_reset_request(request):
    if request.method == "POST":
        data = json.loads(request.body)  # Load the request data
        email = data.get('email')  # Get the email from the request data
        user = MyUser.objects.filter(email=email).first()  # Find the user by email

        if user:  # If user exists
            subject = "Password Reset Requested"  # Subject of the email
            email_template_name = "registration/password_reset_otp_email.html"  # Template for the email body
            otp = str(random.randint(100000, 999999))
            otp_email = otp + email

            try:
                hashed_otp = hashlib.md5(otp_email.encode()).hexdigest()
                user.otp = hashed_otp
                user.otp_created_at = timezone.now()
                user.save()

            except Exception as e:
                logger.error(f"Error Saving the OTP")
                return JsonResponse({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)  # Handle email sending errors

            context = {
                "user": user,
                "otp": otp,  # Genera # Protocol to be used in the email link
            }
            email_content = render_to_string(email_template_name, context)  # Render the email content
            try:
                send_mail(subject, email_content, settings.DEFAULT_FROM_EMAIL, [user.email],
                          fail_silently=False)  # Send the email
            except Exception as e:
                return JsonResponse({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)  # Handle email sending errors
            return JsonResponse({"message": "Password reset e-mail has been sent."}, status=status.HTTP_200_OK)  # Success response
        else:
            return JsonResponse({"error": "User not found."}, status=status.HTTP_404_NOT_FOUND)  # User not found response
    return JsonResponse({"error": "Invalid request method."}, status=status.HTTP_400_BAD_REQUEST)  # Invalid method response


# View to handle otp verification
@api_view(['POST'])
@csrf_exempt
def password_reset_otp_validation(request):
    if request.method == "POST":
        otp = request.data.get('otp')
        email = request.data.get('email')
        otp_email = otp + email
        hashed_otp = hashlib.md5(otp_email.encode()).hexdigest()
        user = MyUser.objects.filter(Q(otp=hashed_otp) & Q(email=email)).first()  # Find the otp user

        if user:  # If user exists
            now = timezone.now()

            # Check if the datetime object is more than 4 minutes old
            if user.otp_created_at and user.otp_created_at < now - timedelta(minutes=4):
                logger.warning(f"User with email {email} entered wrong otp")
                return JsonResponse({"error": "Expired OTP"}, status=status.HTTP_401_UNAUTHORIZED)
            else:
                try:
                    otp = str(random.randint(100000, 999999))
                    otp_email = otp + email
                    hashed_otp = hashlib.md5(otp_email.encode()).hexdigest()

                    user.otp = hashed_otp
                    user.otp_created_at = None
                    user.save()

                    return JsonResponse({"message": "OTP validated successfully", "otp_token": hashed_otp}, status=status.HTTP_200_OK)

                except Exception as e:
                    logger.error(f"Error Saving validated OTP")
                return JsonResponse({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)  # Handle email sending errors

        else:
            return JsonResponse({"error": "Invalid OTP"}, status=status.HTTP_401_UNAUTHORIZED)  # User not found response
    return JsonResponse({"error": "Invalid request method."}, status=status.HTTP_400_BAD_REQUEST)  # Invalid method response


# View to handle otp verification
@api_view(['POST'])
@csrf_exempt
def password_reset_new_password(request):
    if request.method == "POST":
        otp_token = request.data.get('otp_token')
        email = request.data.get('email')
        password = request.data.get('password')
        re_password = request.data.get('re_password')
        user = MyUser.objects.filter(Q(otp=otp_token) & Q(email=email)).first()  # Find the otp user

        if user:  # If user exists

            # Check if the datetime object is more than 10 minutes old
            if user.otp_created_at is not None:
                return JsonResponse({"error": "Please request/validate OTP"}, status=status.HTTP_401_UNAUTHORIZED)
            else:
                try:
                    if password is not None and password != "" and password == re_password:
                        user.otp = None
                        user.password = password
                        user.save()
                        return JsonResponse({"message": "Password reset successful."}, status=status.HTTP_200_OK)
                    else:
                        return JsonResponse({"error": "Passwords are not matching!"}, status=status.HTTP_403_FORBIDDEN)
                except Exception as e:
                    return JsonResponse({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)  # Handle email sending errors

        else:
            return JsonResponse({"error": "Invalid OTP Token"}, status=status.HTTP_401_UNAUTHORIZED)  # User not found response
    return JsonResponse({"error": "Invalid request method."}, status=status.HTTP_400_BAD_REQUEST)  # Invalid method response
