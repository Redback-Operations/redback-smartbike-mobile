# Redback SmartBike Mobile App Backend Setup
[Frontend README](../app/README.md) 

## Prerequisites

-	Git
-	Python 3
-	Virtual Environment (venv)
-	Visual Studio Code or any preferred IDE
-	Django and other Python libraries

## Installation Steps
### 1. Fork the Repository
First, fork the repository to your own GitHub account:
Visit the repository at https://github.com/Redback-Operations/redback-smartbike-mobile.
Click on the Fork button at the top right corner of the page. This will create a copy of the repository in your GitHub account.

### 2. Clone the Forked Repository
After forking, clone the repository to your local machine by opening a terminal and running the following commands:
*git clone https://github.com/<Your_GitHub_Username>/redback-smartbike-mobile.git*  
*cd redback-smartbike-mobile*  

Replace <Your_GitHub_Username> with your actual GitHub username.
This will download the repository files to your local system and change your directory to the repository's root.

### 3. Open the Project in Visual Studio Code
You can open the project directory in VS Code by typing:
code.

Alternatively, use the source control option in VS Code to clone and open the repository directly.

### 4. Set Up Python Virtual Environment
Navigate to the backend_server directory:  
*cd backend_server*  

Create and activate the virtual environment with the following commands:

#### For Windows
*python -m venv .venv*  
*.venv\Scripts\activate*  

#### For MacOS/Linux
*python3 -m venv .venv*  
*source .venv/bin/activate*  

### 5. Install Dependencies
Install Django and other necessary Python libraries (requirements file added for convenience):  
*pip install -r requirements.txt*

OR manually install each package:

*pip install django djangorestframework*  
*pip install python-dotenv*  
*pip install numpy matplotlib scikit-learn*  
*pip install redis celery Django-celery-results*  
*pip install Pillow*  

*cd ..*   
*ls*  

### 6. Configure Environment Variables
Create a .env file at the project root and specify the following values:  

#### **SECURITY WARNING:** keep the secret key used in production secret!  
*SECRET_KEY = "your_secret_key_here"*  

#### Email functionality  
*EMAIL_BACKEND = "django.core.mail.backends.console.EmailBackend"*  
*DEFAULT_FROM_EMAIL = "your_email@example.com"*  

### 7. Database Setup
From the backend_server directory, run the following commands to set up the database:  
*python manage.py makemigrations*  
*python manage.py migrate*  

### 8. Run the Server
Start the backend server:  
*python manage.py runserver `<your-ip-address>`:8000*  

Use the SAME ip address and port as the API_URL_BASE variable on the [frontend](../app/README.md#2-configure-environment-variables).

---

## Troubleshooting Common Errors  
### Error 1: Pillow Installation Issue  
Description: You may encounter an error related to the ImageField if Pillow is not installed.  

backend_server.acc_details.image: (fields.E210) Cannot use ImageField because Pillow is not installed.
HINT: Get Pillow at https://pypi.org/project/Pillow/ or run command "python -m pip install Pillow".
Solution:

#### Check your Python version and install Pillow
python -m pip install Pillow
#### OR
python3 -m pip install Pillow   

### Error 2: Dotenv Module Not Found  
Description: If the system cannot find the dotenv module, you might see a ModuleNotFoundError.   
*ModuleNotFoundError: No module named 'dotenv'*  

#### Solution:
1. Check if python-dotenv is already installed:  
*pip list*  
2. If found, uninstall and reinstall python-dotenv:
*pip uninstall python-dotenv*  
*pip install python-dotenv*  

3. If not found, simply install the module:  
*pip install python-dotenv*

4. Restart Visual Studio Code or your IDE to ensure the environment is refreshed.



