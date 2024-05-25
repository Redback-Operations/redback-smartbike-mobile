
1.Open terminal on your machine and type : 

        git clone https://github.com/Redback-Operations/redback-smartbike-mobile.git

2. then:

        cd app_backend

5. then :

        code .

7.  OR instead of steps 1-3 open VS Code (with no project open) , click on the 3rd icon on the vertical panel on the left (source control) and click on 'clone repository'. Then you will need to paste the repo's URL and thats it.

8. the project opens in VS Code

9. you need to generate .venv file, so follow the below steps:

10. in VS Code terminal type:

        cd backend_server

12. then:

        ls

14. you should see a list of : __init__.py, __pycache__, admin.py and other files. That means you are in the right level

    then type: (if you work with python, not python3, then type: python ......)

        python3 -m venv .venv
              
    then:

        .venv\Scripts\activate     (on Windows)
    
   
        source .venv/bin/activate  (on mac)
 

16. then type:
    
        	pip install django
    
        	pip install Django djangorestframework
    
        	pip install python-dotenv
    
for data analysis:

		pip install numpy
    
		pip install matplotlib

		pip install scimitar-learn

for celery async manager: 

		pip install redis

		pip install celery

		pip install Django-celery-results
additional:

		python -m pip install Pillow


18. then go one level up. type:

        cd ..

20. type:

        ls

23. you should see: README.md, backend_server and other

24. add a .env file at project level to store sensitive data:

        
then at project root add a new file called ' .env ' inside specify the following values:
    
        SECRET_KEY
    
        EMAIL_BACKEND
    
        DEFAULT_FROM_EMAIL

like this: 

	# SECURITY WARNING: keep the secret key used in production secret!
	SECRET_KEY = "django-insecure-p+o(#sfioy$e*&gh_uw7dhoi8swlc0@xc3uu^$qikr80w)*z9d"

	# email functionality
	EMAIL_BACKEND = "django.core.mail.backends.console.EmailBackend"

	# settings.py
	# email address used when sending emails from Django app (like when resetting password or else)
	DEFAULT_FROM_EMAIL = "put_your_email.com"



26. type :                           (if you work with python, not python3, then type: python manage.py makemigrations)

        python3 manage.py makemigrations

28. then:                            (if you work with python, not python3, then type: python manage.py makemigrations)

        python3 manage.py migrate

30. to run the backend:              (if you work with python, not python3, then type: python manage.py runserver 0.0.0.0:8000)

        python3 manage.py runserver 0.0.0.0:8000

32. !!!! Possible errors:
    
1) backend_server.acc_details.image: (fields.E210) Cannot use ImageField because Pillow is not installed.
        HINT: Get Pillow at https://pypi.org/project/Pillow/ or run command "python -m pip install Pillow".
SOLUTION : run in VS Code terminal:  (check your python version)

        python -m pip install Pillow
      
or    

        python3 -m pip install Pillow          


2) ModuleNotFoundError: No module named 'dotenv'

SOLUTION : in terminal type : 

        pip list
        
In the list find dotenv dependency. 
if found, delete it and re-install:

        pip uninstall python-dotenv
then:

        pip install python-dotenv

if not found run : 

        pip install python-dotenv
        
save project. Close VS Code and reopen. The error should be gone now. 



    






    
    
