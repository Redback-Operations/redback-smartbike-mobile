from backend_server.customadmin import views
from django.urls import path, include

urlpatterns = [
    path("login", views.admin_login, name="admin-login"),
    path("user", views.admin_user, name="admin-user"),
    path("active-users", views.get_all_active_users, name="get_all_active_users"),
    path(
        "inactive-users",
        views.get_all_inactive_users,
        name="get_all_inactive_users",
    ),
    path("all-users", views.get_all_users, name="get_all_users"),
    path(
        "update_user_status/<int:user_id>",
        views.update_user_status,
        name="update_user_status",
    ),
    path(
        "messages/<str:user_id>",
        views.get_user_messages,
        name="get_user_messages",
    ),
    path("send-message", views.send_message, name="send_message"),
]
