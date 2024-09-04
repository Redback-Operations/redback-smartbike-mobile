from django.apps import AppConfig

class BackendServerConfig(AppConfig):
    name = 'backend_server'

    def ready(self):
        # Import and register signals here
        import backend_server.signals
