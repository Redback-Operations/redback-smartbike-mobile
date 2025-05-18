
from ..models import WorkoutEntry
from ..data_analysis.exploratory_analysis import *
from ..data_analysis.modelling import *
from ..data_analysis.visualize import * # this you use to preview if the analysis works and makes sense

# Perform 'data_clean_stages.py' and save those changes to the original table there

# the stage 2 this way will have updated data ready for some next calculations
def stage_1():
    # get all WorkoutEntry objects from the database
    entries = WorkoutEntry.objects.all()
    # call a relevant function/ functions

    # at the end save the info into a new table (here you need to create a relevant model with fields you need)


# TODO: add more stages here , like

# 1. perform some analysis
# 2. the results of those analysis save in a new table (yes we need to crate a model, like 'WorkoutAnalysisResult' for that too, serializers etc)
# because once we do the clean + analysis, and save the results of analysis somewhere, we will
# delete those entries from WorkoutEntry, so get some space back. 
# once we do analysis we no longer need all data, just the results of analysis, that we will store
# and can always refer to them 
# 4. send back the data from 'WorkoutAnalysisResult' to flutter and build the visualizations there

def main():
    # run the stages one by one
    print("Executing Stage 1...")
    stage_1()
    print("Stage 1 completed.")
    


if __name__ == "__main__":
    main()