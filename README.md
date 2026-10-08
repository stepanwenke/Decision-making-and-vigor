# Decision making and vigor
Public repository containing full code to run the tasks and questionnaires. It also contains anonymized data and scripts in R to analyse them to reproduce results in our manuscript. 

## Task

We have adapted three existing task to our needs (detailed description of the modifications can be found in the Supplementary Materials) and developed the Effort Task de novo. Our battery thus consists of four gamified tasks tapping into mechanisms of RL and vigor, namely:
- Reinforcement Learning / Working Memory Task (Collins & Frank, 2012)
- Go/No-Go Task (Zorowitz et al., 2025)
- Foraging Task (Harhen & Bornstein, 2023)
- Effort Task, developped in our lab but inspired by Lockwood et al. (2021) and Treadway et al. (2009)

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

## Running the battery

The battery was designed to be tested online on desktops with keyboards. We used JavaScript and jsPsych (de Leeuw et al., 2023), a framework for creating behavioral experiments.  The only pre-requisite to run the tasks is having an internet browser and enabled JavaScript. The battery can be launched by opening *index.html* in the browser and then specifying which session or specific task one desires to run. Parameters are added at the end of the URL (the battery will not run if no parameter is provided):

Session: ?day (0,1,2) e.g., ?day=1

Task: ?task (rlwm, gng, effort, foraging), e.g., ?task=effort

## Saving data

The battery was hosted on Pavlovia.org (Pavlovia; Open Science Tools, Nottingham, UK) where all generated data was saved after running by each participant. However,thanks to the flexibility of the jsPsych library, it is entirely up to a researcher which platform they use or whether they host the experiment themselves (refer to https://www.jspsych.org/latest/overview/running-experiments/). If you intend to test it or run locally, you can obtain generated data at any time by typing 

```jsPsych.data.get()```

in the browser console (see https://www.jspsych.org/latest/reference/jspsych-data/)

## Contact

In case of interest or any other questions regarding our repository, do not hesitate email the author Stepan Wenke: stepan.wenke@ki.se

## References

Collins, A. G. E., & Frank, M. J. (2012). How much of reinforcement learning is working memory, not reinforcement learning? A behavioral, computational, and neurogenetic analysis. European Journal of Neuroscience, 35(7), 1024–1035. https://doi.org/10.1111/j.1460-9568.2011.07980.x.

Harhen, N. C., & Bornstein, A. M. (2023). Overharvesting in human patch foraging reflects rational structure learning and adaptive planning. Proceedings of the National Academy of Sciences of the United States of America, 120(13), e2216524120. https://doi.org/10.1073/pnas.2216524120.

de Leeuw, J.R., Gilbert, R.A., & Luchterhandt, B. (2023). jsPsych: Enabling an open-source collaborative ecosystem of behavioral experiments. Journal of Open Source Software, 8(85), 5351, https://joss.theoj.org/papers/10.21105/joss.05351.

Lockwood, P. L., Abdurahman, A., Gabay, A. S., Drew, D., Tamm, M., Husain, M., & Apps, M. A. J. (2021). Aging Increases Prosocial Motivation for Effort. Psychological Science, 32(5), 668–681. https://doi.org/10.1177/0956797620975781.

Treadway, M. T., Buckholtz, J. W., Schwartzman, A. N., Lambert, W. E., & Zald, D. H. (2009). Worth the “EEfRT”? The effort expenditure for rewards task as an objective measure of motivation and anhedonia. PLoS ONE, 4(8), 1–9. https://doi.org/10.1371/journal.pone.0006598.

Zorowitz, S., Karni, G., Paredes, N., Daw, N., & Niv, Y. (2025). Improving the Reliability of the Pavlovian Go/No-Go Task for Computational Psychiatry Research. Computational Psychiatry, 9(1), 231–252. https://doi.org/10.5334/cpsy.127.