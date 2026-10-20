## Structure

#### Folders
- /helpers: Necessary custom functions required to run task analyses scripts
- /comp_modelling: Input files that can be loaded into computational modelling scripts in a root folder /computational modelling

#### Files
- main_analysis.Rmd: Main analysis markdown file. This file generates tables and figures used in the manuscript (except for the behavioral data and LPA analysis). The .html file is the knitted output of this markdown file.
- non-task_import_data.R: Script to analyse non-task specific questions (such as attention checks, administration time of the battery etc.) 
- Other files in the folder correspond to each task that can generate plots and statistics related to each task. 

