from mongoengine import Document, StringField, EmailField, DateTimeField
from datetime import datetime

class AppUser(Document):
    email = EmailField(required=True, unique=True)
    username = StringField(required=True)
    password = StringField(required=True)  # Store hashed passwords only!
    created_at = DateTimeField(default=datetime.utcnow)

    meta = {
        'collection': 'app_users'  # This will be the MongoDB collection name
    }
