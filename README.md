# Decision making and vigor
Public repository containing code to run tasks and questionnaires. Further it contains anonymized data and scripts in R to analyse them to reproduce results in our manuscript. 

## Structure

- /tasks: Contains code for the tasks and questionnaires in JavaScript
- /styles: Containes stylesheet files necessary to display tasks correctly
- /data: Contains raw data files as well as already parsed files into separate tasks in subfolder /output which is done by load_data.R in /analysis. Subfolder /comp_modelling contains input files for computational modelling.
- /computational modelling: Includes all scripts related to computational modelling, parameter recovery and model comparisons:
    - Input files to these analyses are located in *data/sessionX/comp_modelling/taskX*
    - Output files are *analysis/comp_modelling/*
- /analysis: Contains analysis scripts for each task
    *main_analysis.Rmd* is the main analysis file yielding most tables, figures and analyses used in the manuscript.

    To obtain behavioral results from each task (such as performance metrics) one has to run a script for the specific task. At the top of the script a session (0, 1 or 2) is given in the variable *day* (e.g., day <- 1)
    - /output: Parsed data files into separate tasks
    - /comp_modelling: Input files that can be loaded into computational modelling scripts in a root folder /computational modelling
    While sessionX folder contains estimated computational parameters for each task, *sessionX_comp_params.csv* contains parameters from all tasks in one file. 
- /output: Contains figures and other generated outputs by scripts in /analysis for each respective session

## How to run the battery

The battery was made to be tested online on desktops. The only pre-requisite to run the tasks is having a internet browser. The battery can be launched by opening *index.html* in the browser and then specifying which session or specific task one desires to run. Parameters are added at the end of the URL:

Session: ?day (0,1,2) e.g., ?day=1
Task: ?task (rlwm, gng, effort, foraging), e.g., ?task=effort