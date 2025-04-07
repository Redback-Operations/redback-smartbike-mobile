"""
URL configuration for backend_server project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path
from backend_server import views
from rest_framework.urlpatterns import format_suffix_patterns
from django.conf import settings
from django.conf.urls.static import static
from django.urls import path
from django.contrib.auth import views as auth_views

urlpatterns = [
                  # Other URL patterns
                  path('admin/', admin.site.urls),  # URL for the Django admin interface
                  path('users/', views.user_list),  # URL for handling user list operations (GET and POST)
                  path('update/<str:userId>/', views.user_detail),
                  # URL for handling individual user operations (GET, PUT, DELETE)
                  path('signup/', views.signup, name='signup'),
                  path('home/', views.home, name='home'),
                  path('password_reset/', auth_views.PasswordResetView.as_view(
                      template_name='registration/password_reset_form.html',
                      email_template_name='registration/password_reset_email.html',
                      subject_template_name='registration/password_reset_subject.txt',
                      success_url='/password_reset/done/'
                  ), name='password_reset'),
                  path('password_reset/done/', auth_views.PasswordResetDoneView.as_view(
                      template_name='registration/password_reset_done.html'
                  ), name='password_reset_done'),
                  path('reset/<uidb64>/<token>/', auth_views.PasswordResetConfirmView.as_view(
                      template_name='registration/password_reset_confirm.html',
                      success_url='/reset/done/'
                  ), name='password_reset_confirm'),
                  path('reset/done/', auth_views.PasswordResetCompleteView.as_view(
                      template_name='registration/password_reset_complete.html'
                  ), name='password_reset_complete'),
                  # path('redirected_home.html/', views.login, name='home'),

                  # from T1 2024:
                  path('messages/', views.help_center_message_create, name='hc_message_create'),
                  # save help centre messages
                  path('save_ta_message/', views.terminate_account_message_create, name='ta_message_create'),
                  # saver terminate acc message
                  path('login/', views.login_view, name='login'),
                  path('user/authenticate/', views.auth_password, name='auth_password'),
                  path('user/delete/<str:userId>/', views.delete_user, name='delete_user'),
                  path('setworkout/', views.set_workout, name='setworkout'),
                  path('workoutdata/', views.wrk_data, name='workoutdata'),
                  path('login-sm/', views.social_media_login, name='login-sm'),
                  path('finish_workout/', views.wrk_finished, name='finish_workout'),
                  path('workout_analysis/<int:session_id>/', views.get_analysis, name='workout_analysis_detail'),

                  # Password reset paths
                  path('user/password_reset/', views.password_reset_request, name='password_reset_request'),
                  path('user/password_reset/otp_validate', views.password_reset_otp_validation, name='password_reset_otp_validation'),
                  path('user/password_reset/new_password', views.password_reset_new_password, name='password_reset_new_password')
                  # path('password_reset/done/', auth_views.PasswordResetDoneView.as_view(), name='password_reset_done'),
                  # path('reset/<uidb64>/<token>/', auth_views.PasswordResetConfirmView.as_view(), name='password_reset_confirm'),
                  # path('reset/done/', auth_views.PasswordResetCompleteView.as_view(), name='password_reset_complete'),

                  # TODO: for admin account in flutter: also get all messages with the same thread_number (all messages for that open case)
                  # TODO: for admin account in fluttre: be able to close the case, if resolved
              ] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

# Getting Json format through browzer
urlpatterns = format_suffix_patterns(urlpatterns)