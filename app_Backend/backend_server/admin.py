from django.contrib import admin
from .models import MyUser,AccountDetails,HelpCentreMessage,TerminateAccountMessage, WorkoutType, WorkoutEntry, WorkoutAnalysis

# Registers the Users model with the Django admin interface
admin.site.register(MyUser)
admin.site.register(AccountDetails)
admin.site.register(HelpCentreMessage)
admin.site.register(TerminateAccountMessage)
admin.site.register(WorkoutType)
admin.site.register(WorkoutEntry)
admin.site.register(WorkoutAnalysis)
# @admin.register(warehouse)
# class warehouseadmin(admin.ModelAdmin):
#     pass 