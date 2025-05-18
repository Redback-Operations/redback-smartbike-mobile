
from ..models import WorkoutEntry
from ..data_wrangling.transform_functions import *
from ..data_wrangling.clean_data import *
from ..data_wrangling.preprocessor_functions import *

# Perform 'data_clean_stages.py' and save those changes to the original table there
# it can be done at once and then, analysis1_stages.py, and others can address a particular
# angle at which we analyze those data, depending what info we want to get

def stage_1():
    # get all WorkoutEntry objects from the database
    entries = WorkoutEntry.objects.all()
    
    # fix missing values
    cleaned_entries = clean_missing_values(entries)
    
    # update the database with cleaned entries
    for entry in cleaned_entries:
        entry.save()

# TODO: add more clean stages here .....

def main():
    # run the stages one by one
    print("Executing Stage 1...")
    stage_1()
    print("Stage 1 completed.")

    # more stages here ....
    

if __name__ == "__main__":
    main()