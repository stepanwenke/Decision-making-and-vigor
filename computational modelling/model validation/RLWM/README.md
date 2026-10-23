## How to run it

#### Compare models to get iBIC for each
1. Open *model_comparison.m*. Specify the session (day). The three used models are specified by default, otherwise change that. RUn it. The output will be saved in */model_comp_output*.

#### Constructing confusion matrix
1. If you want to construct the confusion matrix from the generated files, run *model_validation.m*. It uses the estimated data for convenience. If you want to reproduce the analysis and estimate the parameters yourself follow further to step 2.

**Warning: Estimating parameters using WMH model takes significantly resources. Depending
on the availability of your resources, the entire analysis can take a few weeks**

- *original_model_rlwm corresponds* to the model used in the manuscript (ll_rlwm)
- *k_rho_alpha_ll_wmh* corresponds to the alternative WMH model proposed by Collins (2025) - ll_wmh

2. To reproduce the analysis from the scratch one needs to:
- Generate synthetic data using the scripts in */parameter recovery* folder. Copy the generated synthetic data to session respective folder (e.g., day1)
- Estimate the WM capacity for all synthetic subjects using *model_validation_fit_K_RLWM.m*
This takes a lot of computational power. This function has to be submitted as an array job (i.e., SLURM)
for each subject (sj). Use function *aggregate_model.m* when the job is done to merge all output files
into one.
- Estimate the parameters for the model given the synthetic data using  *model_fitting_fun_job.m* as a job in SLURM.
- Run *model_validation.m* when all files are generated to construct the confusion matrix.