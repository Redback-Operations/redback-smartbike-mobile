from django.conf import settings
from .models import MyUser, AccountDetails, HelpCentreMessage, TerminateAccountMessage, WorkoutType, WorkoutAnalysis, Schedule # Added Schedule
from .serializers import UserSerializer, AccountDetailsSerializer, HelpCentreMsgSerializer, TerminateAccMsgSerializer, \
    WorkoutEntrySerializer, WorkoutTypeSerializer, SocialMediaUserSerializer, WorkoutAnalysisSerializer, ScheduleSerializer # Added ScheduleSerializer
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
# from rest_framework.response import Response # Already imported
import logging
from celery import chain
from django.contrib.auth.tokens import default_token_generator
from django.template.loader import render_to_string
import json
# from .models import MyUser # Already imported
import random
from django.utils import timezone
from django.contrib.auth.hashers import check_password
from django.contrib.auth.hashers import make_password
import os


logger = logging.getLogger(__name__)

##home/
def home(request):
    return render(request, "home.html")

def redirect_home(request):
    return render(request, "redirect_home.html")

# view to get or update User Details
##update/<str:userId>/
@api_view(['GET', 'PUT', 'DELETE'])
def user_detail(request, userId):
    print('userId received:' + userId)

    #find account via MyUser id
    user = MyUser.objects.filter(id=userId).first()
    if (user == None):
         return Response("User not found!", status=status.HTTP_404_NOT_FOUND)

    account = AccountDetails.objects.filter(email=user).first()
    if (account == None):
         return Response("Account details not found!", status=status.HTTP_404_NOT_FOUND)

    if request.method == 'GET':
        serializer = AccountDetailsSerializer(account)
        return Response(serializer.data)
    elif request.method == 'PUT':
        serializer = AccountDetailsSerializer(account, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    ## dangerous - deletes account but not associated MyUser object
    elif request.method == "DELETE":
        account.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

##UNUSED
@api_view(['GET'])
def get_user_details(request, emaill, format=None):
    try:
        user = AccountDetails.objects.get(email=emaill)
    except AccountDetails.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)

    if request.method == 'GET':
        serializer = AccountDetailsSerializer(user)
        return Response(serializer.data)

# view to get list of user account details (not users)
##users/
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

#view to create new direct or social-media account
##signup/
@api_view(['POST'])
def signup(request, format=None):
    if request.method == 'POST':
        print(request.data)
        fetched_email = request.data.get("email")
        fetched_username = request.data.get("username")

        email_is_exist = MyUser.objects.filter(email__iexact=fetched_email).exists()
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

#view to login to social media account
##login-sm/
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
            Q(login_id=fetched_id) & Q(login_type=fetched_type) & Q(email__iexact=fetched_email)).first()
        user_is_registered = MyUser.objects.filter(
            Q(login_id__isnull=True) & Q(login_type__isnull=True) & Q(email__iexact=fetched_email)).exists()

        if user_is_enrolled is not None:
            account_details = AccountDetails.objects.filter(email=user_is_enrolled)
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

                user = MyUser.objects.get(email__iexact=fetched_email)
                account_details = AccountDetails.objects.filter(email=user)
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

                    # Assuming 'email' should be 'fetched_email' here based on context
                    user = MyUser.objects.get(email__iexact=fetched_email)
                    account_details = AccountDetails.objects.filter(email=user)
                    account_serializer = AccountDetailsSerializer(account_details, many=True)

                    return Response({
                        'message': 'Login successful - new user',
                        # 'id': serializer.data.id, # serializer.data is a dict, so use ['id']
                        'id': serializer.data['id'],
                        'account_details': account_serializer.data,
                    }, status=status.HTTP_200_OK)
                else:
                    return Response({"message": "Failed to create user.", "errors": serializer.errors},
                                    status=status.HTTP_400_BAD_REQUEST)
            else:
                return Response({"message": "Failed to create user.", "errors": serializer.errors},
                                status=status.HTTP_400_BAD_REQUEST)

#view to create help center message
##messages/
@api_view(['POST'])
def help_center_message_create(request, format=None):
    if request.method == 'POST':
        serializer = HelpCentreMsgSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

#view to create termination account reasons message
##save_ta_message/
@api_view(['POST'])
@parser_classes([JSONParser])
def terminate_account_message_create(request, format=None):
    if request.method == 'POST':
        serializer = TerminateAccMsgSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

#view to login to direct user account
##login/
@api_view(['POST'])
@csrf_exempt
def login_view(request):
    if request.method == 'POST':
        email = request.data.get('email')
        password = request.data.get('password')

        try:
            user = MyUser.objects.get(email__iexact=email)
            print(check_password(password, user.password))
            if check_password(password, user.password): #compares received password to stored hashed
                request.session['email'] = user.email
                request.session['id'] = user.id

                print(user.email)
                account_details = AccountDetails.objects.filter(email=user)
                serializer = AccountDetailsSerializer(account_details, many=True)

                return Response({
                    'message': 'Login successful',
                    'id': user.id,
                    'account_details': serializer.data,
                }, status=status.HTTP_200_OK)
            else:
                # Changed to 401 for incorrect password as per localhost, 404 from git for user not found is better.
                # Keeping 404 here as the more specific message if user exists but pass is wrong is handled by 'Incorrect password'
                # Original git comment: "was 401, but we don't want to tell hackers they have the right email"
                # Let's stick to the Git version's intent for this specific response.
                return Response({'message': 'User not found'}, status=status.HTTP_404_NOT_FOUND)
        except MyUser.DoesNotExist:
            return Response({'message': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

# view to authenticate account password (only used for termination)
##user/authenticate/<str:userID>
@api_view(['POST']) #changed to post for more secure authorization
@csrf_exempt
def auth_password(request, format=None):
    if request.method == 'POST':
        userId = request.data.get('userId')
        password = request.data.get('password')

        print(f'userId: {userId}, password: {password}') #debug
        try:
            user = MyUser.objects.get(id=userId)
            if check_password(password, user.password):  #compares received password to stored hashed
                return Response(status=status.HTTP_200_OK)
            else:
                return Response(status=status.HTTP_403_FORBIDDEN)
        except MyUser.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)
    else:
        return Response(status=status.HTTP_405_METHOD_NOT_ALLOWED)

#view to delete user account
##user/delete/<str:userId>/
@api_view(['DELETE']) #replaced email with userID for more security
@csrf_exempt
def delete_user(request, userId):
    print('userId received:' + userId)

    if request.method == 'DELETE':
        try:
            user = MyUser.objects.get(id=userId)
            user.delete()
            return Response({"message": "User deleted successfully"}, status=status.HTTP_204_NO_CONTENT)
        except MyUser.DoesNotExist:
            return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)
    else:
        return Response(status=status.HTTP_405_METHOD_NOT_ALLOWED)


## UNNUSED
def get_all_details(request):
    if request.method == 'POST':
        all_details = AccountDetails.objects.all().values()
        details_list = list(all_details)
        return JsonResponse({'details': details_list})
    else:
        return JsonResponse({'error': 'Method not allowed'}, status=405)

def getDebugMode(): # Helper function from conflict resolution
    return os.getenv('DEBUG','').strip().upper() == 'TRUE'

#view to create active workout
##setworkout/
@api_view(['POST'])
def set_workout(request):
    if request.method == 'POST':
        try:
            data = request.data.copy()

            if ('email') in data:
                email_is_exist = MyUser.objects.filter(email__iexact=data['email']).exists()
                if (not email_is_exist): return Response({"message": "Failed to create workout.", "errors": "User not Found"}, status=status.HTTP_404_NOT_FOUND)
            else: return Response({"message": "Failed to create workout.", "errors": "User not Found"}, status=status.HTTP_404_NOT_FOUND)

            #block manual setting of session_ID in production mode, but allow setting for testing in debug
            if ('session_id' in data):
                if (not getDebugMode()):
                    data['session_id'] = None

            workout_type_serializer = WorkoutTypeSerializer(data=data)
            if workout_type_serializer.is_valid():
                workout_type = workout_type_serializer.save()
                return Response(workout_type_serializer.data, status=status.HTTP_201_CREATED)
            else:
                return Response({"message": "Failed to create workout.", "errors": workout_type_serializer.errors}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response({"message": "Failed to create workout.", "errors": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

#view to create workout entry for a given workout
##workoutdata/  # Resolved conflict for comment
@api_view(['POST'])
def wrk_data(request):
    if request.method == 'POST':
        try:
            if ('session_id') in request.data:
                # session_id should exist in WorkoutType not MyUser
                session_exists = WorkoutType.objects.filter(session_id=request.data['session_id']).exists()
                if (not session_exists): return Response({"message": "Failed to create workout data.", "errors": "Session ID not Found"}, status=status.HTTP_404_NOT_FOUND)
            else: return Response({"message": "Failed to create workout data.", "errors": "Session ID not Found"}, status=status.HTTP_404_NOT_FOUND)

            serializer = WorkoutEntrySerializer(data=request.data)
            if serializer.is_valid():
                serializer.save()
                return Response(serializer.data, status=status.HTTP_201_CREATED)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response({"message": "Failed to gen workout data.", "errors": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class WorkoutViewSet(viewsets.ModelViewSet):
    queryset = WorkoutType.objects.all()
    serializer_class = WorkoutTypeSerializer

    def perform_create(self, serializer):
        instance = serializer.save()
        chain(
            clean_workout_data_task.s(instance.id),
            analyse_workout_data_task.s(instance.id)
        ).apply_async()

# view to finish an active workout
##finish_workout/
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

# view to perform a workout analysis on a given workout
##workout_analysis/<int:session_id>/
@api_view(['GET'])
def get_analysis(request, session_id):
    try:
        workout_analysis = WorkoutAnalysis.objects.get(session_id=session_id)
        serializer = WorkoutAnalysisSerializer(workout_analysis)
        return Response(serializer.data)
    except WorkoutAnalysis.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)

#generates OTP based on DEBUG status
def get_otp(increment):
    otp_min = 100000
    otp_max = 999999

    if getDebugMode(): # Resolved conflict to use helper
        increment = int(increment)
        otp = str(otp_min+increment)
    else:
        otp = str(random.randint(otp_min, otp_max))

    return otp

# View to handle password reset requests
##user/password_reset/
@api_view(['POST'])
@csrf_exempt
def password_reset_request(request):
    if request.method == "POST":

        email = request.data.get("email")
        user = MyUser.objects.filter(email__iexact=email).first()

        if user:
            subject = "Password Reset Requested"
            email_template_name = "registration/password_reset_otp_email.html"
            otp = get_otp(0)
            otp_email = otp + user.email
            print(f'{email}, {user.email}, {otp}')

            try:
                hashed_otp = hashlib.md5(otp_email.encode()).hexdigest()
                user.otp = hashed_otp
                user.otp_created_at = timezone.now()
                print(hashed_otp)
                user.save()

            except Exception as e:
                logger.error(f"Error Saving the OTP")
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)

            context = {
                "user": user,
                "otp": otp,
            }
            email_content = render_to_string(email_template_name, context)
            try:
                send_mail(subject, email_content, settings.DEFAULT_FROM_EMAIL, [user.email],
                          fail_silently=False)
            except Exception as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
            return Response({"message": "Password reset e-mail has been sent."}, status=status.HTTP_200_OK)
        else:
            return Response({"error": "User not found."}, status=status.HTTP_404_NOT_FOUND)
    return Response({"error": "Invalid request method."}, status=status.HTTP_400_BAD_REQUEST)


# View to handle otp verification
##user/password_reset/otp_validate
@api_view(['POST'])
@csrf_exempt
def password_reset_otp_validation(request):
    if request.method == "POST":
        otp = request.data.get('otp')
        email = request.data.get('email','').strip().lower()

        otp_email = otp + email
        hashed_otp = hashlib.md5(otp_email.encode()).hexdigest()
        user = MyUser.objects.filter(Q(otp=hashed_otp) & Q(email=email)).first()
        print(f'{email}, {otp}')
        print(hashed_otp)


        if user:
            print(user.email)
            now = timezone.now()

            if user.otp_created_at and user.otp_created_at < now - timedelta(minutes=4):
                logger.warning(f"User with email {email} entered wrong otp")
                return Response({"error": "Expired OTP"}, status=status.HTTP_401_UNAUTHORIZED)
            else:
                try:
                    otp_val_stage = get_otp(1) # Use a different OTP for this validation stage
                    otp_email_val_stage = otp_val_stage + email
                    hashed_otp_val_stage = hashlib.md5(otp_email_val_stage.encode()).hexdigest()

                    user.otp = hashed_otp_val_stage # Store this new token
                    user.otp_created_at = None # Clear the timestamp, indicating it's a validation token
                    print(f'out: {hashed_otp_val_stage}')
                    user.save()

                    return Response({"message": "OTP validated successfully", "otp_token": hashed_otp_val_stage}, status=status.HTTP_200_OK)

                except Exception as e:
                    logger.error(f"Error Saving validated OTP: {e}") # Log the error
                    return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
        else:
            return Response({"error": "Invalid OTP"}, status=status.HTTP_401_UNAUTHORIZED)
    return Response({"error": "Invalid request method."}, status=status.HTTP_400_BAD_REQUEST)


# View to handle new password setting
##user/password_reset/new_password
@api_view(['POST'])
@csrf_exempt
def password_reset_new_password(request):
    if request.method == "POST":
        otp_token = request.data.get('otp_token')
        email = request.data.get('email','').strip().lower()
        password = request.data.get('password')
        re_password = request.data.get('re_password')
        user = MyUser.objects.filter(Q(otp=otp_token) & Q(email__iexact=email)).first()

        if user:
            # Check if the otp_created_at is None, meaning it's a validated token from the previous step
            if user.otp_created_at is not None:
                return Response({"error": "Please request/validate OTP first."}, status=status.HTTP_401_UNAUTHORIZED)
            else:
                try:
                    if password is not None and password != "" and password == re_password:
                        user.otp = None # Clear the token
                        user.password = make_password(password) #hash new password
                        user.save()
                        return Response({"message": "Password reset successful."}, status=status.HTTP_200_OK)
                    else:
                        return Response({"error": "Passwords are not matching!"}, status=status.HTTP_403_FORBIDDEN)
                except Exception as e:
                    logger.error(f"Error resetting password: {e}") # Log the error
                    return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
        else:
            return Response({"error": "Invalid OTP Token or email."}, status=status.HTTP_401_UNAUTHORIZED)
    return Response({"error": "Invalid request method."}, status=status.HTTP_400_BAD_REQUEST)

# --- Schedule Views (from conflict resolution) ---
@api_view(['POST'])
def create_schedule(request):
    serializer = ScheduleSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
def get_schedules(request, email):
    try:
        user = MyUser.objects.get(email=email)
        schedules = Schedule.objects.filter(user=user).order_by('date', 'time')
        serializer = ScheduleSerializer(schedules, many=True)
        return Response(serializer.data)
    except MyUser.DoesNotExist:
        return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)