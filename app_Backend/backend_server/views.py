from django.conf import settings
from .models import MyUser, AccountDetails, HelpCentreMessage, TerminateAccountMessage, WorkoutType, WorkoutEntry, WorkoutAnalysis
from .serializers import UserSerializer, AccountDetailsSerializer, HelpCentreMsgSerializer, TerminateAccMsgSerializer, \
    WorkoutEntrySerializer, WorkoutTypeSerializer, SocialMediaUserSerializer, WorkoutAnalysisSerializer
from rest_framework_mongoengine.serializers import DocumentSerializer
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
#from django.db.models import Q
from mongoengine.queryset import Q #mongo version
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
from django.http import JsonResponse, HttpResponse
from mongoengine import Document, StringField, DateTimeField
from django.contrib.auth.hashers import check_password, make_password
import uuid

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
    try:
        print('userId received:' + userId)

        #find account via MyUser id
        target_uuid = uuid.UUID(userId)
        print(userId)
        user = MyUser.objects(id=target_uuid).first()
        if (user == None):
            return Response("User not found!", status=status.HTTP_404_NOT_FOUND) 

        account = AccountDetails.objects.filter(user=user).first()
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
            
    except Exception as e:
        return Response({"error": "Failed to get isers", "errors": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

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
    try:
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
    except Exception as e:
        return Response({"error": "Failed to get isers", "errors": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


#view to create new direct or social-media account
##signup/
@api_view(['POST'])
def signup(request, format=None):
    if request.method == 'POST':
        print(request.data)
        fetched_email = request.data.get("email")
        fetched_username = request.data.get("username")

    try:
        email_is_exist = MyUser.objects(email__iexact=fetched_email).first() is not None
        username_is_exist = MyUser.objects(username=fetched_username).first() is not None

        if email_is_exist:
            return Response("This email already exists in our records.", status=status.HTTP_409_CONFLICT)
        elif username_is_exist:
            return Response("This username already exists in our records.", status=status.HTTP_409_CONFLICT)
        else:
            target_uuid = request.data.get('id') if settings.DEBUG else None
            serializer = UserSerializer(data=request.data)
            serializer.ID = target_uuid
            if serializer.is_valid():
                serializer.save()
                return Response(serializer.data, status=status.HTTP_201_CREATED)
            else:
                return Response({"message": "Failed to create user.", "errors": serializer.errors},  status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        return Response({"error": "Failed to login", "errors": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

#view to login to social media account
##login-sm/
@api_view(['POST'])
def social_media_login(request, format=None):
    try: 
        if request.method == 'POST':
            fetched_email = request.data.get("email")
            fetched_username = request.data.get("username")
            fetched_id = request.data.get("login_id",'').strip()
            fetched_type = request.data.get("login_type",'').strip()

            if fetched_id == '': fetched_id = None
            if fetched_type == '': fetched_type = None

            print(fetched_email, fetched_username, fetched_id, fetched_type)

            if fetched_id is None and fetched_type is None:
                return Response({"message": "Failed to Authenticate User", "errors": "login_id and type is required!"},
                                status=status.HTTP_403_FORBIDDEN)
            
            #try finding SM user first, then non-SM
            user = MyUser.objects.filter(email__iexact=fetched_email).first()
            if user: print(user.id, user.login_id, user.login_type)
            
            user_is_enrolled = MyUser.objects.filter(
                Q(login_id=fetched_id) & Q(login_type=fetched_type) 
                & Q(email__iexact=fetched_email)).first() #update to work with MongoDB
            user_is_registered = MyUser.objects.filter(
                (Q(login_id=None) | Q(login_id="")) 
                & (Q(login_type=None)| Q(login_type="")) 
                & Q(email__iexact=fetched_email)).first() #update to work with MongoDB

            print(user_is_enrolled)
            print(user_is_registered)

            if user_is_enrolled is not None:
                account_details = AccountDetails.objects.filter(user=user_is_enrolled)
                serializer = AccountDetailsSerializer(account_details, many=True)

                return Response({
                    'message': 'Login successful',
                    'id': str(user_is_enrolled.id),
                    'account_details': serializer.data,
                }, status=status.HTTP_200_OK)
            elif user_is_registered:
                return Response({"message": "User is already registered directly to the platform", "code": 1001},
                                status=status.HTTP_400_BAD_REQUEST)
            else:
                print("making new user")
                target_uuid = request.data.get('id') if settings.DEBUG else None #allow set ID in debug mode
                serializer = SocialMediaUserSerializer(data=request.data)
                serializer.ID = target_uuid

                print(serializer)
                if serializer.is_valid():
                    serializer.save()
                    
                    print("serializer saved")
                    user = MyUser.objects.get(email__iexact=fetched_email)
                    account_details = AccountDetails.objects.filter(user=user)
                    account_serializer = AccountDetailsSerializer(account_details, many=True)

                    return Response({
                        'message': 'Login successful - new user',
                        'id': str(serializer.data["id"]),
                        'account_details': account_serializer.data,
                    }, status=status.HTTP_200_OK)
                elif serializer.errors.get('username') != "my user with this username already exists.":
                    suffix = str(datetime.now())[-5:]
                    request.data.update({"username": fetched_username + suffix})
                    serializer = SocialMediaUserSerializer(data=request.data)
                    if serializer.is_valid():
                        serializer.save()

                        user = MyUser.objects.get(email__iexact=email)
                        account_details = AccountDetails.objects.filter(user=user)
                        account_serializer = AccountDetailsSerializer(account_details, many=True)

                        return Response({
                            'message': 'Login successful - new user',
                            'id': str(serializer.data.id),
                            'account_details': account_serializer.data,
                        }, status=status.HTTP_200_OK)
                    else:
                        return Response({"message": "Failed to create user.", "errors": serializer.errors},
                                        status=status.HTTP_400_BAD_REQUEST)
                else:
                    return Response({"message": "Failed to create user.", "errors": serializer.errors},
                                    status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
        return Response({"error": "Failed to signup", "errors": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


#view to create help center message
##messages/
@api_view(['POST'])
def help_center_message_create(request, format=None):
    try:
        if request.method == 'POST':

            data = request.data.copy()
            fetched_email = request.data.get("email")
            try: user = MyUser.objects.get(email__iexact=fetched_email)
            except: return Response({'error': 'Invalid Email!'}, status=status.HTTP_404_NOT_FOUND)

            try:
                entry = HelpCentreMessage(
                    user = user,
                    email=request.data.get('email'), subject=request.data.get('subject'), topic=request.data.get('topic'), message_body=request.data.get('message_body'), 
                    is_read=request.data.get('is_read'), status=request.data.get('status'), actions=request.data.get('actions')
                )
                entry.save(force_insert=True) 
                print(entry.id)
                serializer = HelpCentreMsgSerializer(entry)
                return Response(serializer.data, status=status.HTTP_201_CREATED)
            except Exception as e: return Response(str(e), status=status.HTTP_400_BAD_REQUEST)

    except Exception as e:
        return Response({"error": "Failed to send message", "errors": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

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
    try:
        if request.method == 'POST':

            email = request.data.get('email')
            password = request.data.get('password')

            if (email == None or password == None):
                return Response({'error': 'Invalid Login Fields!'}, status=status.HTTP_400_BAD_REQUEST)

            try:
                user = MyUser.objects.get(email__iexact=email)
                print(check_password(password, user.password))
                if check_password(password, user.password): #compares received password to stored hashed
                    request.session['email'] = user.email
                    print(user.id)
                    request.session['id'] = str(user.id) #JSON cannot serialize pure UUID

                    print(user.email)
                    account_details = AccountDetails.objects.filter(user=user)
                    serializer = AccountDetailsSerializer(account_details, many=True)

                    print("ready response")

                    return Response({
                        'message': 'Login successful',
                        'id': str(user.id),  #JSON cannot serialize pure UUID
                        'account_details': serializer.data,
                    }, status=status.HTTP_200_OK)
                else:
                    return Response({'error': 'Email or password details incorrect'}, status=status.HTTP_401_UNAUTHORIZED)
            except MyUser.DoesNotExist:
                return Response({'error': 'Email or password details incorrect'}, status=status.HTTP_401_UNAUTHORIZED)
            except Exception as e:
                return Response({"error": "Failed to login", "errors": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    except Exception as e:
        return Response({"error": "Failed to login", "errors": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

# view to authenticate account password (only used for termination)
##user/authenticate/<str:userID>
@api_view(['POST']) #changed to post for more secure authorization
@csrf_exempt
def auth_password(request, format=None):
    if request.method == 'POST': 
        userId = request.data.get('userId')
        password = request.data.get('password')

        target_uuid = uuid.UUID(userId)
        try:
            user = MyUser.objects.get(id=target_uuid) 
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
    try:
        print('userId received:' + userId)

        if request.method == 'DELETE':
            try:
                target_uuid = uuid.UUID(userId)
                user = MyUser.objects.get(id=target_uuid)
                user.delete()
                return Response({"message": "User deleted successfully"}, status=status.HTTP_204_NO_CONTENT)
            except MyUser.DoesNotExist:
                return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)

        else:  
            return Response(status=status.HTTP_405_METHOD_NOT_ALLOWED)
    except Exception as e:
        return Response({"error": "Failed to login", "errors": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

def get_all_details(request):
    if request.method == 'POST':
        all_details = AccountDetails.objects.all().values()
        details_list = list(all_details)
        return JsonResponse({'details': details_list})
    else:
        return JsonResponse({'error': 'Method not allowed'}, status=405)

#view to create active workout
##setworkout/
@api_view(['POST'])
def set_workout(request):
    if request.method == 'POST':
        try:
            data = request.data.copy()

            if ('email') in data:
                email_is_exist = MyUser.objects.filter(email__iexact=data['email']).first()
                if (not email_is_exist): return Response({"message": "Failed to create workout.", "errors": "User not Found"}, status=status.HTTP_404_NOT_FOUND)
            else: return Response({"message": "Failed to create workout.", "errors": "User not Found"}, status=status.HTTP_404_NOT_FOUND)

            #manually recreating entry to force that reference link - find a better way!!
            try:
                entry = WorkoutType(
                    id = request.data.get('session_id') if settings.DEBUG else None, #block manual setting of session_ID in production mode, but allow setting for testing in debug
                    user_id = email_is_exist,
                    email=request.data.get('email'), name=request.data.get('name'), session_duration=request.data.get('session_duration'), 
                    level=request.data.get('level'), type=request.data.get('type'), finished=request.data.get('finished'), processed=request.data.get('processed')
                )
                entry.save(force_insert=True) 
                print(entry.id)
                serializer = WorkoutTypeSerializer(entry)
                return Response(serializer.data, status=status.HTTP_201_CREATED)
            except Exception as e: return Response({"message": "Failed to create workout.", "errors": str(e)}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response({"message": "Failed to create workout.", "errors": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

#view to create workout entry for a given workout
##workoutdata/
@api_view(['POST'])
def wrk_data(request):
    if request.method == 'POST':

        try:
            if ('session_id') in request.data:
                workout_type = WorkoutType.objects.filter(id=request.data['session_id']).first()
                if (not workout_type): return Response({"message": "Failed to create workout data.", "errors": "Session ID not Found"}, status=status.HTTP_404_NOT_FOUND)

            else: return Response({"message": "Failed to create workout data.", "errors": "Session ID not Found"}, status=status.HTTP_404_NOT_FOUND)

            #manually recreating entry to force that reference link - find a better way!!
            entry = WorkoutEntry(
                session_id = workout_type,
                speed=request.data.get('speed'), rpm=request.data.get('rpm'), distance=request.data.get('distance'), heart_rate=request.data.get('heart_rate'),
                 temperature=request.data.get('temperature'), incline=request.data.get('incline'), timestamp=request.data.get('timestamp')
            )
            entry.save(force_insert=True) 
            print(entry)
            serializer = WorkoutEntrySerializer(entry)
            serializer.session_id = workout_type
            return Response(serializer.data, status=status.HTTP_201_CREATED)
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

    if settings.DEBUG:
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
        
        #previous required specifically JSON body
        #data = json.loads(request.body)  # Load the request data
        #email = data.get('email')  # Get the email from the request data
        email = request.data.get("email")

        user = MyUser.objects.filter(email__iexact=email).first()  # Find the user by email

        if user:  # If user exists
            subject = "Password Reset Requested"  # Subject of the email
            email_template_name = "registration/password_reset_otp_email.html"  # Template for the email body
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
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)  # Handle email sending errors

            context = {
                "user": user,
                "otp": otp,  # Genera # Protocol to be used in the email link
            }
            email_content = render_to_string(email_template_name, context)  # Render the email content
            try:
                send_mail(subject, email_content, settings.DEFAULT_FROM_EMAIL, [user.email],
                          fail_silently=False)  # Send the email
            except Exception as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)  # Handle email sending errors
            return Response({"message": "Password reset e-mail has been sent."}, status=status.HTTP_200_OK)  # Success response
        else:
            return Response({"error": "User not found."}, status=status.HTTP_404_NOT_FOUND)  # User not found response
    return Response({"error": "Invalid request method."}, status=status.HTTP_400_BAD_REQUEST)  # Invalid method response


# View to handle otp verification
##user/password_reset/otp_validate/
@api_view(['POST'])
@csrf_exempt
def password_reset_otp_validation(request):
    try:
        if request.method == "POST":
            otp = request.data.get('otp')
            email = request.data.get('email','').strip().lower()

            otp_email = otp + email
            hashed_otp = hashlib.md5(otp_email.encode()).hexdigest()
            user = MyUser.objects.filter(otp=hashed_otp, email=email).first()  # Find the otp user
            print(f'{email}, {otp}')
            print(hashed_otp)
            

            if user:  # If user exists
                print(user.email)

                # Check if the datetime object is more than 4 minutes old
                otp_time = user.otp_created_at #workaround to avoid offset-naive and offset-aware datetime 
                if otp_time is not None:
                    if timezone.is_naive(otp_time):
                        otp_time = timezone.make_aware(otp_time)

                if otp_time < timezone.now() - timedelta(minutes=4):
                    logger.warning(f"User with email {email} entered wrong otp")
                    return Response({"error": "Expired OTP"}, status=status.HTTP_401_UNAUTHORIZED)
                else:
                    try:
                        otp = get_otp(1)
                        otp_email = otp + email
                        hashed_otp = hashlib.md5(otp_email.encode()).hexdigest()

                        user.otp = hashed_otp
                        user.otp_created_at = None
                        print(f'out: {hashed_otp}')
                        user.save()

                        return Response({"message": "OTP validated successfully", "otp_token": hashed_otp}, status=status.HTTP_200_OK)

                    except Exception as e:
                        logger.error(f"Error Saving validated OTP")
                    return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)  # Handle email sending errors

            else:
                return Response({"error": "Invalid OTP"}, status=status.HTTP_401_UNAUTHORIZED)  # User not found response
        return Response({"error": "Invalid request method."}, status=status.HTTP_400_BAD_REQUEST)  # Invalid method response
    except Exception as e:
        return Response({"error": "Failed to get isers", "errors": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)   

# View to handle otp verification
##user/password_reset/new_password
@api_view(['POST'])
@csrf_exempt
def password_reset_new_password(request):
    if request.method == "POST":
        otp_token = request.data.get('otp_token')
        email = request.data.get('email','').strip().lower()
        password = request.data.get('password')
        re_password = request.data.get('re_password')
        
        print(otp_token)
        user = MyUser.objects.filter(otp=otp_token, email__iexact=email).first()  # Find the otp user
        print(user)

        if user:  # If user exists

            # Check if the datetime object is more than 10 minutes old
            if user.otp_created_at is not None:
                return Response({"error": "Please request/validate OTP"}, status=status.HTTP_401_UNAUTHORIZED)
            else:
                try:
                    if password is not None and password != "" and password == re_password:
                        user.otp = None
                        user.password = make_password(password) #hash new password
                        user.save()
                        return Response({"message": "Password reset successful."}, status=status.HTTP_200_OK)
                    else:
                        return Response({"error": "Passwords are not matching!"}, status=status.HTTP_403_FORBIDDEN)
                except Exception as e:
                    return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)  # Handle email sending errors
        else:
            return JsonResponse({"error": "Invalid OTP Token"}, status=status.HTTP_401_UNAUTHORIZED)

    return JsonResponse({"error": "Invalid request method."}, status=status.HTTP_400_BAD_REQUEST)

# MongoEngine model
class RideData(Document):
    user_id = StringField(required=True)
    timestamp = DateTimeField(default=datetime.utcnow)

def test_mongo(request):
    ride = RideData(user_id="test_user").save()
    return JsonResponse({
        "message": "MongoDB is working!",
        "user_id": ride.user_id,
        "timestamp": str(ride.timestamp)
    })

def index(request):
    return HttpResponse("<h1>🚴‍♂️ Redback SmartBike Backend Running!</h1>")

from django.http import JsonResponse
from backend_server.mongo_models import AppUser

def create_test_user(request):
    try:
        user = AppUser(
            email="test@example.com",
            username="testuser",
            password="hashed_password123"
        )
        user.save()
        return JsonResponse({"message": "User created successfully!"})
    except Exception as e:
        return JsonResponse({"error": str(e)}, status=500)

    return Response({"error": "Invalid request method."}, status=status.HTTP_400_BAD_REQUEST)  # Invalid method response
    
#depreciated should remove, use settings Debug value instead
def getDebugMode():
    return os.getenv('DEBUG','').strip().upper() == 'TRUE'
  
# --- Schedule Views ---
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