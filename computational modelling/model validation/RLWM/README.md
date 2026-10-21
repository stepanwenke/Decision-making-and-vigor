## How to run it

**Warning: Estimating parameters using WMH model takes significantly resources. Depending
on the availability of your resources, the entire analysis can take a few weeks**

- *original_model_rlwm corresponds* to the model used in the manuscript (ll_rlwm)
- *k_rho_alpha_ll_wmh* corresponds to the alternative WMH model proposed by Collins (2025) - ll_wmh

1. Open the master script *model_validation.m*. Specify session (day) and all models
that you want to compare.
- If you want to construct the confusion matrix from the generated files, set files_generated
to *true*. Otherwise *false* to run the whole procedure.
2. To reproduce the analysis from the scratch one needs to:
- Generate synthetic data (using *generate_synthetic_data.m*)
- Estimate the WM capacity for all synthetic subjects using *model_validation_fit_K_RLWM.m*
This takes a lot of computational power. This function has to be submitted as an array job (i.e., SLURM)
for each subject (sj). Use function *aggregate_model.m* when the job is done to merge all output files
into one.
- Submit *model_fitting_fun_job.m* as a job to SLURM.
- Run *model_validation.m* when all files are generated and set *files_generated*
to true to construct the confusion matrix.