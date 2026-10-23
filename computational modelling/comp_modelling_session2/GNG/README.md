## How to run it

1. Run *generate_data_for_modelling.m* to convert the .csv output obtained from the single task scripts
to an .m matrix.
2. Open *fit_GNG_ite.m*.
3. Run the script. Find the output in the */output* folder.
4. There you will find an output from each of the 10 different starting values. File *parameters_physicalE.mat*
represents the best fit with the smallest PL. These parameters are further used in
the subsequent analyses and in the manuscript.
5. The folder also contain generated histograms for each of the parameters from the best
EM iteration.