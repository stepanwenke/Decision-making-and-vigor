  library(dplyr)
  library(ggplot2)
  library(correlation)
  library(see)
  library(psych)
  library(irr)
  library(rempsyc)
  
  # set wd to analysis folder
  script_dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
  if (getwd() != script_dir) {
    setwd(script_dir)
  } else {
    message("The script_dir is the same as the current working directory.")
  }
  
  day <- 1
  
  # Set the working directory to the output folder
  setwd(paste0("../output/session", day))
  
  # Load the parameters
  params <- read.csv(paste0("df_",day,"_with_id.csv"), stringsAsFactors = FALSE) 

  all_excluded_both_days <- c(
    "6697c39cfbf1e3381e6ee45c", "65956ab743aa1e8fe002ba3b", "669a6bba1fd09527cf41717a",
    "65b26a99fe500245f7a7c750", "677009b08130c3028f6a8a6d", "6161cb3de3d274978d46575b",
    "65fc95c627592d85499ae358", "655f8bf6de805f7bd81e5811", "665c5d94303fdf202ac9ded0",
    "65fb34c4df61f03ce0dd6dd9", "5d66b4f503b0d900195ca627", "676d40e2915d059bf7ef62e8",
    "67d095bc257ecc840642912e", "66645dfa2639fc47c5bca0a6", "67826c0cd5858c9d420da7ff",
    "67d0581ffe3bbe5188426aff", "5eef7da8a4868b05c902ef2d", "5fff2877a99bcb65a14a223c",
    "67f3619e16d4ca195fbd1bd0", "67e5cf90b79d0874e1cf16b0", "571a78f06a1c6300114b8d80",
    "5af82cf9e066a40001136ace", "67e2a5b83621fdee51b6277e", "66ce541cd8da920539a1c3cc",
    "6741ce8667002c96f0362d34", "5e4066ed9eec8d2a184e4ff4", "63d9d5072e083033fc895df1",
    "67d9a91f56a568412eecda60", "67f6a640d2046b13fcf33328", "66083cd0a45e1ce399e6a85f",
    "67851f4cba98f2087f182764", "67dc135e06eee79a0b0324ef", "604fa685e33606f9a0ee8189",
    "609bfd97a7c95881330491d4", "6122f45e2e93a3ff9a7b7a5d", "64feeabd355b506d0512d862",
    "6606b31155457e4f162ecf5a", "6776b99a8215d150863a71b4", "60e0dc6be0772b7dfdad9b2c",
    "67f65a16d76fa76c28091ede", "675436e14d7ef1173a74a5b8", "6774f9e03114a09130a1e78f",
    "5a77529ff49c9a0001f2fdbd", "672879d614dce67b8c3090ea", "67f7c74584da18f7cd5fceeb",
    "60d9dfd4dcc09cf57dc92cb1", "5bf3199ebe7c7300017b710a", "5c549c6372fd9000018b5968",
    "5e5c993cd0394c474f7cc502", "5fabca68273dd403ab40e361", "5fed47cfcb429d79af4f8ded",
    "65651805d1afb42ba1a55476", "667971a555af1f83d3f29ae7", "673bf9c0212c1ae07ff6c22e",
    "67cd50f22f22938860f85a66"
  )
  
  exclude_ids <- all_excluded_both_days
  exclude_ids <- c()
  
  # Cut out the prefix output/
  params$subjID <- sub("^output/", "", params$subjID)  # remove 'output/' prefix
  
  
  # Exclude the subjects
  params <- params %>%
    filter(!subjID %in% exclude_ids) %>%
    mutate(subjID = as.character(subjID))  # Ensure subjID is character
  
  # Reduce the parameters for the desired ones
  reduced_params <- params %>%
    select(subjID, foraging_exit_threshold, rlwm_alpha, gng_beta, gng_eps, phys_k)
  
  ### temp trying out ###
  # testing_reduced_params <- params %>%
  #   select(subjID, foraging_exit_threshold, rlwm_alpha, gng_beta, gng_alpha, gng_eps, phys_k)
  #reduced_params <- testing_reduced_params
  
  # Load the questionnaires
  questionnaires <- read.csv("questionnaire_scores.csv", stringsAsFactors = FALSE)
  
  # Merge the parameters and questionnaires
  params_questionnaires_df <- merge(params, questionnaires, by = "subjID", all.x = TRUE)
  reduced_params_questionnaires_df <- merge(reduced_params, questionnaires, by = "subjID", all.x = TRUE)
  
  # Make a correlation matrix
  cor_matrix <- correlation(params_questionnaires_df, method = "spearman")
  reduced_cor_matrix <- correlation(reduced_params_questionnaires_df, method = "spearman")
  
  # Print the correlation matrix
  cor_matrix %>%
    summary(redundant = TRUE) %>%
    plot()
  
  reduced_cor_matrix %>%
    summary(redundant = TRUE) %>%
    plot
  
  reduced_param_fa_df <- reduced_params[, -1]
  
  # Do a FA of the parameters and correlate the questionnaires with the factors
  fa_params <- factanal(x =reduced_param_fa_df, factors = 2, rotation = "varimax", scores = "regression") #covmat = cor(df_2)
  fa_params_scores <- fa_params$scores
  
  # Correlate the factor scores and the questionnaires
  fa_params_scores_df <- as.data.frame(fa_params_scores)
  fa_params_scores_params_df <- cbind(reduced_params_questionnaires_df, fa_params_scores_df)
  
  # Correlate the factor scores and the questionnaires
  cor_fa_params_scores <- correlation(fa_params_scores_params_df, method = "spearman")
  
  cor_fa_params_scores %>%
    summary(redundant = TRUE) %>%
    plot()
  
  ### Assess the reliability of questionnaires ###
  # Load the other day questionnaire than the current day
  the_other_day <- 1

  if (day == 1) {
    the_other_day <- 2
  }
  
  the_other_questionnaires <- read.csv(paste0("../session", the_other_day, "/questionnaire_scores.csv"), stringsAsFactors = FALSE)
  
  # Merge dataframes by subject ID
  both_days_questionnaires <- merge(questionnaires, the_other_questionnaires, by = "subjID", suffixes = c("_day1", "_day2"))
  
  # List of questionnaire variables
  questionnaire_vars <- c(
    "behavioral_activation",
    "emotional_sensitivity",
    "social_motivation",
    "Score_ASRM",
    "Score_CESD",
    "Score_SHPS"
  )
  
  # Prepare empty list to store results
  icc_results_list <- list()
  
  # Loop through variables and compute ICC
  for (var in questionnaire_vars) {
    day1_col <- paste0(var, "_day1")
    day2_col <- paste0(var, "_day2")
    
    # Compute ICC
    icc_out <- icc(both_days_questionnaires[, c(day1_col, day2_col)], model = "twoway", type = "agreement", unit = "single")
    
    # Extract relevant values
    icc_val <- icc_out$value
    ci_low <- icc_out$lbound
    ci_high <- icc_out$ubound
    
    # Append to list
    icc_results_list[[var]] <- data.frame(
      Questionnaire = var,
      ICC = icc_val,
      CI_Lower = ci_low,
      CI_Upper = ci_high
    )
  }
  
  # Combine all results into a data frame
  icc_df <- do.call(rbind, icc_results_list)
  
  # Print final results
  print(icc_df)