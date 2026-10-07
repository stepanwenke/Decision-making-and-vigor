# PCA and Factor Analysis - RMarkdown chapter

# Integrate the variables from each task

library(tidyverse)
library(correlation)
library(see)
library(readr)
library(psych)
library(nFactors)
library(rempsyc)
library(irr)
library(stringr)

# set wd to analysis folder
script_dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
if (getwd() != script_dir) {
  setwd(script_dir)
} else {
  message("The script_dir is the same as the current working directory.")
}

# Settings
collection_date <- "20-05-25"
day <- 2
rt_anal <- FALSE

modelling_path <- paste0(getwd(),"/day",day)
foraging_params_path <- paste0("../../data/day",day,"_",collection_date,"/output/foraging_params.csv")
pilot_anal_path <- paste0("../../pilot analyses/",collection_date)
# participant_list <- read_csv("df_1_with_id.csv")
# participant_list <- participant_list %>%
#   select(subjID) %>%
#   mutate(subjID = str_remove(subjID, "^output/"))

############ Load computational model parameters #######################


# Load effort variables from logistic regression
#effort_path <- paste(modelling_path, "/original3iter_physical_effort_params_retest.csv", sep="")
effort_path <- paste(modelling_path, "/physical_effort_params_retest.csv", sep="")
effort_data <- read_csv(effort_path)

# Load RT
if (rt_anal == TRUE) {
  effort_rt_path <- paste0(pilot_anal_path, "/effort/effort_betas_day_",day,".csv")
  effort_rt_data <- read_csv(effort_rt_path)


#missing_participants <- setdiff(participant_list$subjID, effort_rt_data$subjID)


  effort_rt_data <- effort_rt_data %>%
    select(effort_level, effort_credits) %>%
    rename(phys_effort_rt = effort_level, phys_credits_rt = effort_credits)
}
# effort_data <- effort_data %>%
#   filter(subjID %in% missing_participants)

#effort_data_exit_plus_rt <- cbind(effort_data, effort_rt_data)

if (day > 0) {
  # Load parameters
  # rlwm
  #modelling_path <- '../../analysis/modelling_battery'
  rlwm_path <- paste(modelling_path, "/rlwm_params_retest.csv", sep="")
  # rlwm_path <- paste(modelling_path, "/rlwm_params.csv", sep="")
  rlwm_data <- read_csv(rlwm_path)
  names(rlwm_data) <- paste0("rlwm_", names(rlwm_data)) #Add a prefix to the column names
  
  if (rt_anal == TRUE) {
    # Load RT
    rlwm_rt_path <- paste0(pilot_anal_path, "/rlwm/rlwm_betas_day_",day,".csv")
    rlwm_rt_data <- read_csv(rlwm_rt_path)
    
    # Filter out the missing participants
    rlwm_rt_data <- rlwm_rt_data %>%
      filter(!subjID %in% missing_participants)
    
    # Summarize the data by averaging the correctTRUE and (Intercept) for each participant
    rlwm_rt_data_avg <- rlwm_rt_data %>%
      group_by(subjID) %>%
      summarize(
        #avg_Intercept = mean(`(Intercept)`, na.rm = TRUE),
        avg_correctTRUE = mean(correctTRUE, na.rm = TRUE)
      ) %>%
      select(avg_correctTRUE) %>%
      rename(rlwm_rt = avg_correctTRUE)
  }
  
  #rlwm_data_plus_rt <- cbind(rlwm_data, rlwm_rt_data_avg)
  
  # # View the result
  # head(rlwm_rt_data_avg)
  
  # Load foraging variables
  foraging_data_exit <- read_csv(foraging_params_path, col_names = FALSE)
  colnames(foraging_data_exit) <- c("subjID","foraging_exit_threshold")
  
  # Load RT
  if (rt_anal == TRUE) {
    foraging_rt_path <- paste0(pilot_anal_path, "/foraging/foraging_betas_day_",day,".csv")
    foraging_rt_data <- read_csv(foraging_rt_path)
    
    # Filter out the missing participants
    foraging_rt_data <- foraging_rt_data %>%
      filter(!subjID %in% missing_participants)
    
    foraging_rt_data <- foraging_rt_data %>%
      select(galaxy_type) %>%
      rename(foraging_rt = galaxy_type)
  }

  # foraging_data_exit_plus_rt <- cbind(foraging_data_exit, foraging_rt_data)
  
}

# gonogo
#gng_path <- paste(modelling_path, "/gng_params_retest_retest.csv", sep="")
 gng_path <- paste(modelling_path, "/gng_params_retest_reduced.csv", sep="")
gng_data <- read_csv(gng_path)
names(gng_data) <- paste0("gng_", names(gng_data)) #Add a prefix to the column names

if (rt_anal == TRUE) {
  # Load RT
  gng_rt_path <- paste0(pilot_anal_path, "/gng/gng_betas_day_",day,".csv")
  gng_rt_data <- read_csv(gng_rt_path)
  
  # Filter out the missing participants
  gng_rt_data <- gng_rt_data %>%
    filter(!subjID %in% missing_participants)
  
  gng_rt_data <- gng_rt_data %>%
    select(accuracy) %>%
    rename(gng_rt = accuracy)
}


names(effort_data) <- paste0("phys_", names(effort_data)) #Add a prefix to the column names

# # with foraging exit thresholds instead of difference scores

if (rt_anal == TRUE) {

  
  computational_params_exit <- cbind(foraging_data_exit, rlwm_data, gng_data, effort_data)
  
  computational_params_exit <- computational_params_exit %>%
    mutate(subjID = str_remove(subjID, "^output/"))
  
  # exlude missing participants
  computational_params_exit <- computational_params_exit %>%
    filter(!subjID %in% missing_participants)
  
  nrow(computational_params_exit)
  
  computational_params_exit <- cbind(computational_params_exit, effort_rt_data, rlwm_rt_data_avg, foraging_rt_data, gng_rt_data)
  
  
} else if (day > 0) {
  computational_params_exit <- cbind(foraging_data_exit, rlwm_data, gng_data, effort_data)
} else {
  computational_params_exit <- cbind(gng_data)
}

#computational_params_exit <- cbind(foraging_data_exit, rlwm_data, gng_data, effort_data)
# computational_params_exit <- computational_params_exit[,-c(2,3,4,5)]


#################### PCA #########################


# remove subjId and reward sensitivity (basically collinear with the other foraging variables)
#df_2 <- computational_params_reduced[, 3:ncol(computational_params_reduced)] # reduced dataset
df_2 <- computational_params_exit[, 2:ncol(computational_params_exit)]
df_2_with_id <- computational_params_exit[, 1:ncol(computational_params_exit)]


if (rt_anal == TRUE) {
  df_2_reduced <- computational_params_exit %>%
    select(rlwm_alpha, gng_beta, gng_eps, phys_k, foraging_exit_threshold, phys_credits_rt) %>%
    drop_na()
  
  df_2 <- df_2_reduced
} else if (day > 0) {
  df_2_reduced <- computational_params_exit %>%
    select(rlwm_alpha, gng_beta, gng_eps, phys_k, foraging_exit_threshold)
} else {
  df_2 <- computational_params_exit %>%
    select(gng_alpha, gng_beta, gng_eps,phys_beta, phys_k)
}

## temp trying out ##
# df_2_testing <- computational_params_exit[, 2:ncol(computational_params_exit)]
# df_2_testing_1 <- df_2_testing %>%
#   select(rlwm_alpha, gng_beta, gng_alpha,gng_eps, phys_k, foraging_exit_threshold) %>%
#   drop_na()
# 
# df_2_testing_2 <- df_2_testing %>%
#   select(rlwm_alpha, gng_beta, gng_alpha, phys_k, foraging_exit_threshold) %>%
#   drop_na()
# 
# df_2_testing_3 <- df_2_testing %>%
#   select(rlwm_alpha, gng_beta, rlwm_rho, phys_k, foraging_exit_threshold) %>%
#   drop_na()

# run PCA
df_2 <- df_2_reduced
#df_2 <- df_2_testing
pca_res <- prcomp(df_2, scale. = TRUE)
#pca_res <- prcomp(df_2_2fact, scale. = TRUE)
#variables standardized to have mean 0 and SD 1, ensuring that variables with larger scales do not disproportionately influence the results
# prcomp used singular value decomposition (SVD).
# The function automatically centers the variables

# summary
summary_pca <- summary(pca_res)
# output: 
# SD of each component, proportion of variance explained by each component, and the proportion of variance explained

# New function
# if (day > 0) {
#   nComponents <- nCng(pca_res$sdev^2) # squared st dev are the eigenvalues
#   nFactors <- nComponents$nFactors
# }


# loadings
pca_res$rotation
# Loadings represent the correlation between the original variables and the principal components. 
# They help in interpreting the components by identifying which variables contribute most to each component.

# scree plot
plot(pca_res, type = "l")

# Add a new title
title(main = "2 Factors")


########################## Factor analsysis ############################
# export df_2

if (rt_anal == FALSE) {
  write.csv(df_2, paste0("df_",day,".csv"), row.names = TRUE)
  write.csv(df_2_with_id, paste0("df_",day,"_with_id.csv"), row.names = FALSE)
} else {
  write.csv(df_2, paste0("df_",day,"_rt.csv"), row.names = TRUE)
  write.csv(df_2_with_id, paste0("df_",day,"_rt_with_id.csv"), row.names = FALSE)
}

# Apply varimax rotation - use 3 factors atm
# fa_res_rotated <- factanal(factors = nFactors, covmat = cor(df_2), rotation = "varimax")
# Varimax rotation is an orthogonal rotation method that maximizes the variance of the squared loadings of a factor on all the variables.
#It makes the interpretation of factors easier by making the structure more parsimonious, i.e., each factor has a high loading for only a
# few variables.

if (day > 0) {
# 4 factors
  # fa_res_rotated_5_full <- factanal(x = df_2, factors = 5, rotation = "varimax", scores = "regression") #covmat = cor(df_2)
  # print(fa_res_rotated_5_full)
  # 
  # fa_res_rotated_4_full <- factanal(x = df_2, factors = 4, rotation = "varimax", scores = "regression") #covmat = cor(df_2)
  # print(fa_res_rotated_4_full)
  # 
  # 3 factors
  # fa_res_rotated_3_full <- factanal(x = df_2, factors = 3, rotation = "varimax", scores = "regression") #covmat = cor(df_2)
  # print(fa_res_rotated_3_full)
  
  # 2 factors
  fa_res_rotated_2_full <- factanal(x = scale(df_2), factors = 2, rotation = "varimax", scores = "regression") #covmat = cor(df_2)
  print(fa_res_rotated_2_full)
  
  # fa_res_rotated_2_full_testing_1 <- factanal(x = scale(df_2_testing_1), factors = 2, rotation = "varimax", scores = "regression") #covmat = cor(df_2)
  # print(fa_res_rotated_2_full_testing_1)
  # 
  # fa_res_rotated_2_full_testing_2 <- factanal(x = scale(df_2_testing_2), factors = 2, rotation = "varimax", scores = "regression") #covmat = cor(df_2)
  # print(fa_res_rotated_2_full_testing_2)
  # 
  # fa_res_rotated_2_full_testing_3 <- factanal(x = scale(df_2_testing_3), factors = 2, rotation = "varimax", scores = "regression") #covmat = cor(df_2)
  # print(fa_res_rotated_2_full_testing_3)
  
  # extract loadings into a data frame
  loadings_2_new <- as.data.frame(fa_res_rotated_2_full$loadings[,])

  # Round the loadings for easier reading
  loadings_2_rounded_new <- round(loadings_2_new[,], 3)
  colnames(loadings_2_rounded_new) <- c("Vigor", "RL")
  row_names <- rownames(loadings_2_rounded_new)
  loadings_2_rounded_new <- cbind(row_names, loadings_2_rounded_new)
  colnames(loadings_2_rounded_new)[1] <- "Parameter"
  # rename parameters
  loadings_2_rounded_new$Parameter[1] <- "RLWM Alpha"
  loadings_2_rounded_new$Parameter[2] <- "GNG Beta"
  loadings_2_rounded_new$Parameter[3] <- "GNG Epsilon"
  loadings_2_rounded_new$Parameter[4] <- "Effort K"
  loadings_2_rounded_new$Parameter[5] <- "Foraging Exit Threshold"

  # table
  tabel_2factors_new <- nice_table(loadings_2_rounded_new, title = c(paste0("Table ",day),paste0("Factor Loadings for day ",day)))
  print(tabel_2factors_new, preview = "docx")
}

# reduced
# 3 factors - are too many for 5 variables
# fa_res_rotated_3 <- factanal(x = df_2_reduced, factors = nFactors, rotation = "varimax", scores = "regression") #covmat = cor(df_2)
# print(fa_res_rotated_3)

# # # 2 factors
# fa_res_rotated_2 <- factanal(x = df_2_reduced, factors = 2, rotation = "varimax", scores = "regression") #covmat = cor(df_2)
# print(fa_res_rotated_2)



# if (day > 0) {
#   #### Edit on 6/2/2025 - added a FA with reduced factors for the grant application ####
#   df_1 <- df_2
#   
#   df_1_new_2fact <- df_1 %>%
#     select(rlwm_alpha, gng_beta, gng_eps, foraging_exit_threshold, phys_k)
#   
#   # run PCA
#   pca_res_new <- prcomp(df_1_new_2fact, scale. = TRUE)
#   
#   # summary
#   summary_pca_new <- summary(pca_res_new)
#   
#   # Run FA on 2 factors
#   fa_res_rotated_new <- factanal(x = scale(df_1_new_2fact), factors = 2, rotation = "varimax", scores = "regression") #covmat = cor(df_1)
#   fa_res_rotated_new
#   
#   # extract loadings into a data frame
#   loadings_2_new <- as.data.frame(fa_res_rotated_new$loadings[1:ncol(df_1_new_2fact),])
#   
#   # Round the loadings for easier reading
#   loadings_2_rounded_new <- round(loadings_2_new, 2)
#   colnames(loadings_2_rounded_new) <- c("Factor 1", "Factor 2")
#   row_names <- rownames(loadings_2_rounded_new)
#   loadings_2_rounded_new <- cbind(row_names, loadings_2_rounded_new)
#   colnames(loadings_2_rounded_new)[1] <- "Parameter"
#   # rename parameters
#   loadings_2_rounded_new$Parameter[1] <- "RLWM Alpha"
#   loadings_2_rounded_new$Parameter[2] <- "GNG Beta Rew"
#   loadings_2_rounded_new$Parameter[3] <- "GNG Epsilon Rew"
#   loadings_2_rounded_new$Parameter[4] <- "Foraging Exit Threshold"
#   loadings_2_rounded_new$Parameter[5] <- "Effort K"
#   
#   # table
#   tabel_2factors_new <- nice_table(loadings_2_rounded_new, title = c(paste0("Table ",day),paste0("Factor Loadings for day ",day)))
#   print(tabel_2factors_new, preview = "docx")
# }

# Merge last and this year data frames and remove the ceiling participants
# this_year_df_1 <- df_2 %>%
#   select(-phys_g)
# last_year_df_1 <- read_csv("last year/df_1.csv")
# last_year_df_1 <- last_year_df_1 %>%
#   select(-...1, -gng_alpha_pun, -gng_beta_pun, -gng_eps_pun) %>%
#   rename(gng_beta = gng_beta_rew, gng_alpha = gng_alpha_rew, gng_eps = gng_eps_rew, foraging_exit_threshold = average_value)
# 
# # Rowbind the data frames
# df_1_last_this_year_full <- rbind(this_year_df_1, last_year_df_1)
# 
# # Reduce the data frame to only include the relevant columns
# df_1_last_this_year <- df_1_last_this_year_full %>%
#   select(rlwm_alpha, gng_beta, gng_eps, foraging_exit_threshold, phys_k)
# 
# # Ceiling participants' indices for this year
# ceiling_this_year <- c(3,  6, 10, 19, 20, 21, 26, 29, 31, 33, 38, 40, 43, 46, 47, 50, 52, 53) # Adjust indices for the merged data frame
# df_1_this_year_no_ceiling <- last_year_df_1[-ceiling_this_year, ]
# 
# ceiling_last_year <- c(1, 3,5,  6,  9, 12, 13, 21, 30, 34, 38, 42, 43, 46)
# df_1_last_year_no_ceiling <- this_year_df_1[-ceiling_last_year, ]
# 
# # Merge the years without ceilings
# df_1_last_this_year_no_ceiling <- rbind(df_1_this_year_no_ceiling, df_1_last_year_no_ceiling)
# 
# # FA with everyone
# fa_res_rotated_2_full <- factanal(x = df_1_last_this_year, factors = 2, rotation = "varimax", scores = "regression") #covmat = cor(df_2)
# print(fa_res_rotated_2_full)
# 
# df_1_last_this_year_no_ceiling_reduced <- df_1_last_this_year_no_ceiling %>%
#   select(rlwm_alpha, gng_beta, gng_eps, foraging_exit_threshold, phys_k)
# 
# # FA with no ceilings
# fa_res_rotated_2_no_ceiling <- factanal(x = df_1_last_this_year_no_ceiling_reduced, factors = 2, rotation = "varimax", scores = "regression") #covmat = cor(df_2)
# print(fa_res_rotated_2_no_ceiling)
# 
