from __future__ import absolute_import, unicode_literals
import os
from celery import Celery


# Celery for asynchronous processing

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend_server.settings')
app = Celery('backend_server')
app.config_from_object('django.conf:settings', namespace='CELERY')
app.autodiscover_tasks()