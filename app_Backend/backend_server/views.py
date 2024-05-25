# Import necessary modules and classes

from .models import MyUser, AccountDetails, HelpCentreMessage, TerminateAccountMessage, WorkoutType, WorkoutAnalysis
from .serializers import UserSerializer, AccountDetailsSerializer, HelpCentreMsgSerializer, TerminateAccMsgSerializer, WorkoutEntrySerializer, WorkoutTypeSerializer, SocialMediaUserSerializer, WorkoutAnalysisSerializer
from .forms import UserCreationForm,SignUpForm,LoginForm
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
from datetime import datetime
import hashlib
from .tasks import clean_workout_data_task, analyse_workout_data_task
from rest_framework import viewsets
from rest_framework.response import Response
import logging
from celery import chain

logger = logging.getLogger(__name__)

def home(request):
    return render(request, "home.html")

def redirect_home(request):
    return render(request, "redirect_home.html")



# View to handle GET, PUT, and DELETE requests for a specific user
@api_view(['GET', 'PUT', 'DELETE'])
def user_detail(request, email):
    user = AccountDetails.objects.get(email=email)

    if request.method == 'GET':
        # Retrieve details of a specific user
        serializer = AccountDetailsSerializer(user)
        return Response(serializer.data)
    elif request.method == 'PUT':
        # Update details of a specific user
        data = request.data
        # Remove username from the update data
        serializer = AccountDetailsSerializer(user, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        # Return errors if the data is invalid
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    elif request.method == "DELETE":
        # Delete a specific user
        user.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


#get specific user details
@api_view(['GET'])
def get_user_details(request, emaill, format=None):
    try:
        user = AccountDetails.objects.get(email=emaill)
    except AccountDetails.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)

    if request.method == 'GET':
        # Retrieve details of a specific user
        serializer = AccountDetailsSerializer(user)
        return Response(serializer.data)






    # if request.method == 'POST':

    #     fetched_username = request.data.get("username")
    #     fetched_password = request.data.get("password")

    #     print(fetched_username)
    #     print(fetched_password)


    #     # Optionally, return a response indicating success or any other necessary data
    #     return Response({"message": "Data logged in successfully"}, status=201)

    
#  user_list to retrieve users from the acc_details model
@api_view(['GET', 'POST'])
def user_list(request, format=None):
    if request.method == 'GET':
        # Retrieve all users from the warehouse model
        users = AccountDetails.objects.all()
        # Serialize all users
        serializer = AccountDetailsSerializer(users, many=True)
        return Response(serializer.data)
    elif request.method == 'POST':
        # Create a new user in the warehouse model
        serializer = AccountDetailsSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        # Return errors if the data is invalid
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# -----------------------------------------------functions that work---------------------------------------------------------

#                                   USER SIGN UP (create)
@api_view(['POST'])
def signup(request, format=None):
    if request.method == 'POST':
        fetched_email = request.data.get("email")
        fetched_username = request.data.get("username")
        fetched_password = request.data.get("password")
        fetched_timestamp = request.data.get("user_created")

        email_is_exist = MyUser.objects.filter(email=fetched_email).exists()
        username_is_exist = MyUser.objects.filter(username=fetched_username).exists()

        if email_is_exist:
            return Response("This email already exists in our records.", status=status.HTTP_409_CONFLICT)
        elif username_is_exist:
            return Response("This username already exists in our records.", status=status.HTTP_409_CONFLICT)
        else:
            # save details to user table; then signals.py use 'create_table2_entry' to insert email and username from that to AccountDetails Table
            serializer = UserSerializer(data=request.data)
            if serializer.is_valid():
                serializer.save()
                return Response(serializer.data, status=status.HTTP_201_CREATED)
            else:
                return Response({"message": "Failed to create user.", "errors": serializer.errors}, status=status.HTTP_400_BAD_REQUEST)





#                                   USER SOCIAL MEDIA SIGN UP AND LOGIN
@api_view(['POST'])
def social_media_login(request, format=None):
    if request.method == 'POST':
        fetched_email = request.data.get("email")
        fetched_username =  ("username")
        fetched_image = request.data.get("image")
        fetched_timestamp = request.data.get("user_created")
        fetched_id = request.data.get("login_id")
        fetched_type = request.data.get("login_type")

        user_is_enrolled = MyUser.objects.filter(Q(login_id=fetched_id) & Q(login_type=fetched_type) & Q(email=fetched_email)).first()
        user_is_registered = MyUser.objects.filter(Q(login_id__isnull=True) & Q(login_type__isnull=True) & Q(email=fetched_email)).exists()

        if user_is_enrolled != None:
            account_details = AccountDetails.objects.filter(email=fetched_email)
            serializer = AccountDetailsSerializer(account_details, many=True)

            return Response({
                'message': 'Login successful',
                'id':user_is_enrolled.id,
                'account_details': serializer.data,
            }, status=status.HTTP_200_OK)
           
        elif user_is_registered:
           return Response({"message": "User is already registered directly to the platform", "code": 1001}, status=status.HTTP_400_BAD_REQUEST)
        else:
            serializer = SocialMediaUserSerializer(data=request.data)
            if serializer.is_valid():
                serializer.save()
                
                account_details = AccountDetails.objects.filter(email=fetched_email)
                account_serializer = AccountDetailsSerializer(account_details, many=True)

                return Response({
                    'message': 'Login successful - new user',
                    'id':serializer.data["id"],
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
                        'id':serializer.data.id,
                        'account_details': account_serializer.data,
                    }, status=status.HTTP_200_OK)
                else:
                    return Response({"message": "Failed to create user.", "errors": serializer.errors}, status=status.HTTP_400_BAD_REQUEST)
            else:
                return Response({"message": "Failed to create user.", "errors": serializer.errors}, status=status.HTTP_400_BAD_REQUEST)






#                                   SAVE HELP MESSAGES (create)

@api_view(['POST'])
def help_center_message_create(request, format=None):
    if request.method == 'POST':
        # Create a new message
        serializer = HelpCentreMsgSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        # Return errors if the data is invalid
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    

#                                   SAVE TERMINATE MESSAGES (create)

@api_view(['POST'])
@parser_classes([JSONParser])
def terminate_account_message_create(request, format=None):
    if request.method == 'POST':
        serializer = TerminateAccMsgSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


#                                   LOGIN: AUTHENTICATE USER (check if they exist)

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

                # get account details for the user from AccountDetails table, not MyUser
                account_details = AccountDetails.objects.filter(email=user.email)
                serializer = AccountDetailsSerializer(account_details, many=True)

                return Response({
                    'message': 'Login successful',
                    'id':user.id,
                    'account_details': serializer.data,
                }, status=status.HTTP_200_OK)
            else:
                return Response({'message': 'Incorrect password'}, status=status.HTTP_401_UNAUTHORIZED)
        except MyUser.DoesNotExist:
            return Response({'message': 'User not found'}, status=status.HTTP_404_NOT_FOUND)


#                                   DELETE USER : authenticate password
    
# check password against the records, of a user that wants to delete their account; returns TRUE/FALSE
@api_view(['GET'])
@csrf_exempt
def auth_password(request, email,format=None):
    if request.method == 'GET':
        # Extract password from the request data
        user_password = request.GET.get('password')
        print('pass:' + user_password)
        try:
            user = MyUser.objects.get(pk=email) # email is the PK of MyUser
            
            if (user.password == user_password):
                # if the password matches, return 200 response
                return Response(status=status.HTTP_200_OK)
            else:
                # Return 403 Forbidden if the password does not match
                return Response(status=status.HTTP_403_FORBIDDEN)
        except MyUser.DoesNotExist:
            # Return 404 Not Found if the user does not exist
            return Response(status=status.HTTP_404_NOT_FOUND)
    else:
        # This else part is technically unnecessary since @api_view restricts to DELETE only
        return Response(status=status.HTTP_405_METHOD_NOT_ALLOWED)
    

#                                   DELETE USER : delete record

# (and other info related to that user will be deleted automatically thanks to on_delete = CASCADE from models)
@api_view(['DELETE'])
@csrf_exempt
def delete_user(request, email):
    print('email received:'+email)
    if request.method == 'DELETE':
        
        try:
            user = MyUser.objects.get(pk=email)
            # Perform password validation here if needed
            # For demonstration, assuming password validation passes
            user.delete()
            return JsonResponse({"message": "User deleted successfully"}, status=status.HTTP_204_NO_CONTENT)
        except MyUser.DoesNotExist:
            return JsonResponse({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)

    
#                                   GET ALL DETAILS FROM ACCOUNT DETAILS TABLE 
# for flutter login -> to save those details to Provider upon loggin in
def get_all_details(request):
    if request.method == 'POST':
        # Retrieve all details from the model
        all_details = AccountDetails.objects.all().values()
        # Convert QuerySet to list for JSON serialization
        details_list = list(all_details)
        return JsonResponse({'details': details_list})
    else:
        return JsonResponse({'error': 'Method not allowed'}, status=405)
    

#                                   SAVE WORKOUT SETTINGS 

# from flutter 'set_workout_page.dart'
@api_view(['POST'])
def set_workout(request):
    if request.method == 'POST':
        workout_type_serializer = WorkoutTypeSerializer(data=request.data)
        if workout_type_serializer.is_valid():
            # save to WorkoutType
            workout_type = workout_type_serializer.save()
            return Response(workout_type_serializer.data, status=status.HTTP_201_CREATED)
        else:
            return Response(workout_type_serializer.errors, status=status.HTTP_400_BAD_REQUEST)


#                                   SAVE WORKOUT DATA (every second)
 
@api_view(['POST'])
def wrk_data(request):
    if request.method == 'POST':
        serializer = WorkoutEntrySerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    



#                                   AUTOMATE DATA ANALYSIS (see also: utils, tasks)

# viewset handles WorkoutType objects and triggers the data processing tasks upon creation or update of values
class WorkoutViewSet(viewsets.ModelViewSet):
    queryset = WorkoutType.objects.all()
    serializer_class = WorkoutTypeSerializer

    def perform_create(self, serializer):
        instance = serializer.save()
        chain(
            clean_workout_data_task.s(instance.id),
            # analysis only happens after processing is complete
            analyse_workout_data_task.s(instance.id)
        ).apply_async()



#                                   UPDATE FINISHED WORKOUT in WorkoutType 'finished' to True

@api_view(['PATCH'])
@csrf_exempt  
def wrk_finished(request):
    try:
        session_id = request.data.get('session_id')
        finished = request.data.get('finished')

        if session_id is None or finished is None:
            logger.error('session_id and finished fields are required')
            return Response({'error': 'session_id and finished fields are required'}, status=status.HTTP_422_UNPROCESSABLE_ENTITY)

        workout = WorkoutType.objects.filter(session_id=session_id).first()
        if workout is None:
            logger.error(f'WorkoutType not found for session_id: {session_id}')
            return Response({'error': 'WorkoutType not found'}, status=status.HTTP_404_NOT_FOUND)

        workout.finished = finished
        workout.save()
        logger.info(f'WorkoutType updated for session_id: {session_id}, finished: {finished}')

        # Trigger Celery tasks if finished is set to True
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
        return Response({'error': 'An error occurred while processing the request'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)



#                                   FETCH DATA ANALYSIS FOR A SESSION_ID that was passed
# TODO: implement in flutter for dashboard
@api_view(['GET'])
def get_analysis(request, session_id):
    try:
        workout_analysis = WorkoutAnalysis.objects.get(session_id=session_id)
        serializer = WorkoutAnalysisSerializer(workout_analysis)
        return Response(serializer.data)
    except WorkoutAnalysis.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)