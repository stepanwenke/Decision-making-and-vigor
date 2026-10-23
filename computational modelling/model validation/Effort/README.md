## How to run it

#### Compare models to get iBIC for each
1. Open *model_comparison.m*. Specify the session (day). The three used models are specified by default, otherwise change that. RUn it. The output will be saved in */model_comp_output*.

#### Constructing confusion matrix
1. Open the master script *model_validation.m*. Specify session (day) and all models
that you want to compare.
- If you want to construct the confusion matrix from the generated files, set files_generated
to *true*. Otherwise *false* to run the whole procedure.
2. Run the script. Output will be stored in the respective */day* folder, where
also confusion_matrix.jpg will be generated.