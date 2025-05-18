from django.contrib import admin
from django.contrib.admin import AdminSite

from backend_server.models import AccountDetails, HelpCentreMessage, MyUser, TerminateAccountMessage, WorkoutAnalysis, WorkoutEntry, WorkoutType

class CustomAdminSite(AdminSite):
    site_header = "My Custom Admin"
    site_title = "Admin Area"
    index_title = "Welcome to My Custom Admin"
    login_template = 'customadmin/login.html'

custom_admin_site = CustomAdminSite(name='customadmin')

# Register your models here

