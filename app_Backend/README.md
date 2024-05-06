
1.Open terminal on your machine and type : 

        git clone https://github.com/alexbaar/app_backend.git

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

        pip install Django djangorestframework

18. then go one level up. type:

        cd ..

20. type:

        ls

23. you should see: README.md, backend_server and other

24. add a .env to store sensitive data.
    first in VS Code in terminal type:

        pip install python-dotenv
    
then at project root add a new file called ' .env ' inside specify the following values:
    
        SECRET_KEY
    
        EMAIL_BACKEND
    
        DEFAULT_FROM_EMAIL


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



    






    
    
