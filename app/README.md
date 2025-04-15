SETUP:

1. Open android studio

2. File -> New -> Project from Version Control

3. paste the URL: 

   https://github.com/Redback-Operations/redback-smartbike-mobile.git

choose where to save the project on your computer

4. Click clone

5. add a '.env' file in the root project directory
inside the file add:

   # URLs
   API_URL_BASE = http://<your_machine_network_address>:8000  , for example:
   API_URL_BASE = http://192.168.3.103:8000

6. pubspec.yaml -> click on 'pub get'

7. VS Code -> run your backend     


8. From VSCode open lib/main.dart -> Press run (play button) on top right\
   Alternatively - Android Studio -> run the project


* SAVE CHANGES: save only the fully working feature that is completed

When working on any new feature or fix, create new branch first\
`git checkout -b <name of fix or feature work>`

Try to commit as soon as you have something working like button created, API integrate, library added, etc. This will help track of changes better for reviewers.

`git add .` or `git add <filename>`\
`git commit -m="<changes you made>"`\
`git push` - you might need to push upstream first if working on new branch

or

Android Studio -> Git -> commit    commit ... commit
Android Studio -> Git -> push      commit ... commit


* SUBSEQUENT USE: it is a good habit to pull any changes to the repo made by other users, before starting to work on a new feature on new branch:

Android Studio -> Git -> Pull...

If you have done some work and meantime, someone added a feature, that you have not pulled yet, make sure to save your work in a COPY file for your records for safety.
Sometimes when pulling changes, there might be merge problems that you can either try to resolve, or best if you COPY your entire project first, then try to rebase onto remote changes.
This way in the original project that you have open you will discard your work and get the current repo state, but because you copied the project you would be able to
manually re-apply your work (copy-paste) into the original project.

If in doubt, contact your project leader . 

### IDE Environment and SDK version info (this is when the app successfully worked last time)
IDE: Android Studio Iguana | 2023.2.1, Xcode Version 15.4 (15F31d)\
Flutter version: 3.22.3 Stable\
Dart: 3.4.4\
DevTools: 3.34.3

Happy coding!