## How to run it

1. Run *generate_data_for_modelling.m* to convert the .csv output obtained from the single task scripts
to an .m matrix.
2. Open *find_K_wm.m*, specify the model (ll_rlwm or ll_wmh). Run the script. 
3. It will generate _capacity_MODEL.mat_ file containing estimated WM capacities for each participant.
4. Open *fit_RLWM_ite.m*, specifiy the desired model in the ff variable and run the script.
5. Find the output in the */MODEL* folder of the respective model. There you will find an output from each of the 10 different starting values. File *parameters_physicalE.mat*
represents the best fit with the smallest PL. These parameters are further used in
the subsequent analyses and in the manuscript.
6. The folder also contain generated histograms for each of the parameters from the best
EM iteration.