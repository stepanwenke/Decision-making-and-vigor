library(tidyverse)
library(gridExtra)
library(grid)  # This package contains the textGrob function and arrow/annotation
library(emmeans)
library(ez)
library(lme4)
library(lmerTest)
library(rempsyc)
library(irr)
library(broom)

# set wd to analysis folder
script_dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
if (getwd() != script_dir) {
  setwd(script_dir)
} else {
  message("The script_dir is the same as the current working directory.")
}
source("helpers/rlwm_prop_corr_per_stim_iter.R") # assumes working directory is analysis folder
source("helpers/rlwm_rt_per_stim_iter.R") # assumes working directory is analysis folder


# Session 1 or 2
day <- 2

# Set the working directory to the data folder
setwd(paste0("../data/session", day))

# Set the output folder
output_folder <- "output/"

# Folder for saving images and stuff
folder_path_pilot_anal <- paste0("../../output/session",day, "/")

# Check if the folder exists, and create it if it doesn't
if (!dir.exists(folder_path_pilot_anal)) {
  dir.create(folder_path_pilot_anal)
}

if (!dir.exists(paste0(folder_path_pilot_anal, "rlwm/"))) {
  dir.create(paste0(folder_path_pilot_anal, "rlwm/"))
}

# Get list of subfolders (assuming they are all named 's' followed by numbers)
subfolders <- list.dirs(path = output_folder, full.names = TRUE, recursive = FALSE)

# Initialize a list to store data frames
data_frames <- list()

# Loop through each subfolder and read the CSV files
for (i in seq_along(subfolders)) {
  subfolder <- subfolders[i]
  file_path <- file.path(subfolder, "rlwm_data.csv")
  
  # Check if the file exists before reading
  if (file.exists(file_path)) {
    data_frames[[subfolder]] <- read_csv(file_path)
  }
}
exclude_ids <- c()

exclude_ids <- paste0("output/", exclude_ids)
data_frames <- data_frames[!(names(data_frames) %in% exclude_ids)]

# for one participant
#data_frames <- data_frames[22]

# initialize df to store variables that will be saved
output_data_frame <- data.frame(subjID = 1:length(data_frames))
for(i in 1:length(data_frames)) {
  output_data_frame$subjID[i] <- data_frames[[i]]$subjID[1]
}

# Extract the data for each participant from processed_data list
extract_total_time <- function(df) {
  #browser()
  subjID <- df$subjID[1]
  
  # Find the index of the row where trial type is "instruc_begin_exp"
  instruc_index <- which(df$trial_type == "survey-multi-choice")[1]
  
  # Create only_training_df with all rows from 1 to instruc_index
  only_training_df <- df[1:instruc_index, ]
  
  total_time_training <- max(only_training_df$time_elapsed) - min(only_training_df$time_elapsed)
  
  # Create only_task_df with all remaining rows
  only_task_df <- df[(instruc_index + 1):nrow(df), ]
  total_time_task <- max(only_task_df$time_elapsed) - min(only_task_df$time_elapsed)
  
  # Convert times to minutes and round to 2 decimals
  rlwm_training <- round(total_time_training / 60000, 2)
  rlwm_task <- round(total_time_task / 60000, 2)
  rlwm_total_time <- round(rlwm_training + rlwm_task, 2)
  
  return(data.frame(
    subjID = subjID,
    rlwm_training = rlwm_training,
    rlwm_task = rlwm_task,
    rlwm_total_time = rlwm_total_time
  ))
}

total_time_df <- do.call(rbind, lapply(data_frames, extract_total_time))
rownames(total_time_df) <- NULL

# Save the time elapsed data frame to <- a CSV file
write.csv(total_time_df, paste0(folder_path_pilot_anal, "/rlwm_time_elapsed.csv"), row.names = FALSE)


# calculate proportion correct per stimulus iteration
df_rlwm_plot <- list()
for (i in 1:length(data_frames)) {
  df_rlwm_plot[[i]] <- rlwm_prop_corr_per_stim_iter(data_frames[[i]])
}

# save for other plots later too
prop_corr_per_stim_data <- df_rlwm_plot

# Calculate average proportion correct across participants

## Check that all data frames have the same number of rows and columns
if(length(unique(lapply(df_rlwm_plot, nrow))) > 1 || length(unique(lapply(df_rlwm_plot, ncol))) > 1) {
  stop("All data frames must have the same dimensions.")
}

n <- length(df_rlwm_plot) # Number of participants

## Calculate the average for each corresponding cell (stimulus iteration x set size (where column 1 is stim iteration))
average_df <- Reduce("+", df_rlwm_plot) / n

# function to calculate confidence intervals over iterations
# returns a list with a sublist for each set size
calc_conf_int <- function(df_rlwm_plot) {
  # Turn the list of proportion correct for each set size and iteration into data frame
  prop_correct_df <- data.frame(average_df$stim_iter)  # initialize
  names(prop_correct_df)[1] <- "stim_iter"
  
  # Set size 2
  prop_correct_ns2_df <- prop_correct_df
  for (i in 1:n) {
    prop_correct_ns2_df[ , i+1] <- df_rlwm_plot[[i]]$ns_2
    names(prop_correct_ns2_df)[i+1] <- paste0("subj_", i)
  }

  # Set size 3
  prop_correct_ns3_df <- prop_correct_df
  for (i in 1:n) {
    prop_correct_ns3_df[ , i+1] <- df_rlwm_plot[[i]]$ns_3
    names(prop_correct_ns3_df)[i+1] <- paste0("subj_", i)
  }
  
  # Set size 4
  prop_correct_ns4_df <- prop_correct_df
  for (i in 1:n) {
    prop_correct_ns4_df[ , i+1] <- df_rlwm_plot[[i]]$ns_4
    names(prop_correct_ns4_df)[i+1] <- paste0("subj_", i)
  }
  
  # Set size 5
  prop_correct_ns5_df <- prop_correct_df
  for (i in 1:n) {
    prop_correct_ns5_df[ , i+1] <- df_rlwm_plot[[i]]$ns_5
    names(prop_correct_ns5_df)[i+1] <- paste0("subj_", i)
  }
  
  # Set size 6
  prop_correct_ns6_df <- prop_correct_df
  for (i in 1:n) {
    prop_correct_ns6_df[ , i+1] <- df_rlwm_plot[[i]]$ns_6
    names(prop_correct_ns6_df)[i+1] <- paste0("subj_", i)
  }
  
  
  summarize_data <- function(df) {
    
    # summarized data frame for set size 2 (put into list later) - function
    setsize_df <- data.frame(mean = numeric(12), std = numeric(12), sem = numeric(12),
                             lower = numeric(12), upper = numeric(12))#initialize
    for(i in 1:12) {
      row_mean <- mean(as.numeric(df[i,-1]))
      row_sd <- sd(as.numeric(df[i,-1]))
      setsize_df[i,1] <- row_mean # mean
      setsize_df[i,2] <- row_sd # SD
      setsize_df[i,3] <- row_sd / sqrt(n) # SEM
      setsize_df[i,4] <- row_mean - 1.96 * (row_sd / sqrt(n)) # lower CI bound
      setsize_df[i,5] <- row_mean + 1.96 * (row_sd / sqrt(n)) # upper CI bound
    }
    
    stim_iter <- 1:12
    setsize_df <- cbind(stim_iter, setsize_df)
    return(setsize_df)
  }
  
  # make a list to return
  errorbar_list <- list()
  errorbar_list[[1]] <- summarize_data(prop_correct_ns2_df)
  names(errorbar_list)[1] <- "set size 2"
  errorbar_list[[1]]$setsize <- "2"

  errorbar_list[[2]] <- summarize_data(prop_correct_ns3_df)
  names(errorbar_list)[2] <- "set size 3"
  errorbar_list[[2]]$setsize <- "3"
  
  errorbar_list[[3]] <- summarize_data(prop_correct_ns4_df)
  names(errorbar_list)[3] <- "set size 4"
  errorbar_list[[3]]$setsize <- "4"
  
  errorbar_list[[4]] <- summarize_data(prop_correct_ns5_df)
  names(errorbar_list)[4] <- "set size 5"
  errorbar_list[[4]]$setsize <- "5"
  
  errorbar_list[[5]] <- summarize_data(prop_correct_ns6_df)
  names(errorbar_list)[5] <- "set size 6"
  errorbar_list[[5]]$setsize <- "6"
  
  return(errorbar_list)
  
}



ci_data <- calc_conf_int(df_rlwm_plot)
# Combine the list into one data frame
ci_data_long <- bind_rows(ci_data)

### UPDATE LEARNING CURVES WITH ERROR BARS ############
# plot title
if(length(data_frames) == 1) {
  plot_title <- "Learning Curves for a Single Participant"
} else {
  plot_title <- "Learning Curves Averaged Across Participants"
}


# PLOT LEARNING CURVES WITH ERRORBARS REPRESENTING 95% CONFIDENCE INTERVAL
ggplot(ci_data_long, aes(x = stim_iter, y = mean, color = factor(setsize), group = setsize)) +
  geom_line(linewidth=1) + 
  geom_errorbar(aes(ymin = lower, ymax = upper), width = 0.2) +
  geom_point(size = 3) + # Add dots at each observation
  labs(title = plot_title, x = "Stimulus iteration", y = "Proportion Correct", color = "WM Load") +
  #labs(x = "Stimulus Iteration", y = "Mean Value", color = "Set Size") +
  # ggtitle(plot_title) + 
  #scale_color_manual(values = c("2" = "blue", "3" = "red", "4" = "green", "5" = "orange", "6" = "purple")) +
  scale_x_continuous(breaks = 1:12, limits = c(0.9, 12.1)) +
  scale_y_continuous(breaks = seq(from = 0, 
                                  to = 1, 
                                  by = 0.10)) +
  scale_color_manual(values = c("2" = "blue", "3" = "green", "4" = "red", "5" = "orange", "6" = "purple")) +
  theme(
    panel.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(colour = "black")
  )


# PLOT LEARNING CURVES WITH RIBBONS (SHADED REGIONS) REPRESENTING 95% CONFIDENCE INTERVAL
plot_main_prop_cor_iteration <-  ggplot(ci_data_long, aes(x = stim_iter, y = mean, group = setsize)) +
  geom_ribbon(aes(ymin = lower, ymax = upper, fill = factor(setsize)), alpha = 0.2, color = NA) +
  geom_line(aes(color = factor(setsize)), linewidth=1) +
  labs(x = "Stimulus Iteration", y = "Proportion Correct", color = "Set Size", fill = "Set Size") +
  ggtitle("C") + # should be plot_title
  scale_color_manual(values = c("2" = "blue", "3" = "green", "4" = "red", "5" = "orange", "6" = "purple")) +
  scale_fill_manual(values = c("2" = "blue", "3" = "green", "4" = "red", "5" = "orange", "6" = "purple")) +
  scale_x_continuous(breaks = 1:12, limits = c(0.9, 12.1)) +
  scale_y_continuous(breaks = seq(from = 0, 
                                  to = 1, 
                                  by = 0.10)) +
  theme(
    panel.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(colour = "black"),
    text = element_text(size = 25),
    axis.text = element_text(size = 19),
    axis.title = element_text(size = 19)
  )

print(plot_main_prop_cor_iteration)

# save plot
ggsave(paste0(folder_path_pilot_anal, "rlwm/prop_corr_iteration.jpg"), plot_main_prop_cor_iteration, width = 10, height = 10)



############## Proportion correct per set size #####################

calc_prop_corr_rlwm <- function(df) {
  
  # Get subjID from first row
  subjID <- df$subjID[1]
  
  # preprocessing - extract task data
  df_task <- df %>%
    filter(task == 'stimulus_presentation') %>% # extract stimulus trials
    select(rt, response, correct_response, correct, stimulus_type,
           setsize, block, stim_id)
  
  # extract set size 2 and add trial number
  df_ns2 <- df_task %>%
    filter(setsize == 2) %>%
    mutate(trial_number = row_number())
  
  # extract set size 3 and add trial number
  df_ns3 <- df_task %>%
    filter(setsize == 3) %>%
    mutate(trial_number = row_number())
  
  # extract set size 4 and add trial number
  df_ns4 <- df_task %>%
    filter(setsize == 4) %>%
    mutate(trial_number = row_number())
  
  # extract set size 5 and add trial number
  df_ns5 <- df_task %>%
    filter(setsize == 5) %>%
    mutate(trial_number = row_number())
  
  # extract set size 6 and add trial number
  df_ns6 <- df_task %>%
    filter(setsize == 6) %>%
    mutate(trial_number = row_number())
  
  
  # Take the average to get proportion correct
  prop_corr_ns2 <- mean(df_ns2$correct)
  prop_corr_ns3 <- mean(df_ns3$correct)
  prop_corr_ns4 <- mean(df_ns4$correct)
  prop_corr_ns5 <- mean(df_ns5$correct)
  prop_corr_ns6 <- mean(df_ns6$correct)
  prop_corr_all_set_sizes <- mean(df_task$correct)
  
  # put the proportions in one df
  df_prop_corr <- data.frame(
    prop_corr_ns2=prop_corr_ns2, 
    prop_corr_ns3=prop_corr_ns3, 
    prop_corr_ns4=prop_corr_ns4, 
    prop_corr_ns5=prop_corr_ns5,
    prop_corr_ns6=prop_corr_ns6,
    prop_corr_all_set_sizes=prop_corr_all_set_sizes,
    subjID = subjID
  )
  
  return(df_prop_corr)
}


# Data frame with proportion correct for each participant (each row)
# turn the list into a da# PLOT
# Data frame with performance measures for each participant (each row)
# turn the list into a dataframe more suitable for plotting 
vec <- numeric(length(data_frames))
df_prop_corr <- data.frame(#placement df
  prop_corr_ns2=vec, 
  prop_corr_ns3=vec, 
  prop_corr_ns4=vec,
  prop_corr_ns5=vec,
  prop_corr_ns6=vec,
  prop_corr_all_set_sizes=vec,
  subjID=vec
)



# one participant per row (prop corr rt)
for (i in 1:length(data_frames)) {
  df_prop_corr[i, ] <- calc_prop_corr_rlwm(data_frames[[i]]) # 1 row per participant
}

# save total proportion correct
total_prop_corr_rlwm <- df_prop_corr %>%
  select(subjID,prop_corr_all_set_sizes)

# update output df
output_data_frame <- cbind(output_data_frame, total_prop_corr_rlwm)


# remove total proportion correct (not needed here)
df_prop_corr <- df_prop_corr %>%
  select(-prop_corr_all_set_sizes, -subjID) # remove subjID and total prop corr

# save proportion correct per set size for later calculation of "set size slope"
accuracy_per_ns <- df_prop_corr # each row is one participant

# update output df
output_data_frame <- cbind(output_data_frame, accuracy_per_ns)

# Convert the dataframe to long format using tidyr
df_prop_corr_long <- df_prop_corr %>%
  pivot_longer(everything(), names_to = "set_size", values_to = "Value")

# reorder factors to get them in the order I want when plotting
#df_prop_corr_long$set_size <- factor(performance_df_long$Performance_measure, levels = c("prop_correct", "go_bias", "outcome_bias", "pavlovian_bias", "feedback_sensitivity"))


# Creating the box and whisker plot with individual observations
plot_prop_cor_setsize <- ggplot(df_prop_corr_long, aes(x = set_size, y = Value)) +
  geom_boxplot(outlier.shape = NA) + # Suppress outliers
  guides(color = "none") + # Remove color legend
  geom_jitter(aes(color = set_size), width = 0.1, height = 0, alpha = 0.5, size=2) + # Adjust jitter
  labs(x = "Set Size", y = "Proportion Correct", title = "Proportion Correct") +
  scale_x_discrete(labels = c("2","3", "4","5", "6")) +
  scale_y_continuous(
    limits = c(0, 1), # Set limits from 0 to 1
    breaks = seq(0, 1, by = 0.1) # Set breaks at every 0.1 interval
  ) +
  theme(
    panel.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(colour = "black")
  )
print(plot_prop_cor_setsize)

# save plot
ggsave(paste0(folder_path_pilot_anal, "rlwm/prop_corr_setsize.jpg"), plot_prop_cor_setsize, width = 10, height = 7)

############### ANOVA #########################

subjId <- character(length(data_frames))
for(i in 1:length(data_frames)) {
  subjId[i] <- data_frames[[i]]$subjID[1]
}
anova_data <- cbind(df_prop_corr, subjId)

# Pivot the data to long format
anova_data_long <- pivot_longer(
  anova_data,
  cols = starts_with("prop_corr"), # Select columns that start with "prop_corr"
  names_to = "set_size",           # New column for set size
  names_prefix = "prop_corr_",     # Remove this prefix from the original column names
  values_to = "prop_corr"          # New column for the proportion correct values
)

# Convert set_size to a factor
anova_data_long$set_size <- as.factor(anova_data_long$set_size)
anova_data_long$subjId <- as.factor(anova_data_long$subjId)

# Run the one-way repeated measures ANOVA
anova_results <- ezANOVA(
  data = anova_data_long,
  dv = .(prop_corr),           # Dependent variable
  wid = .(subjId),             # Within-subjects ID
  within = .(set_size),        # Within-subject factor
  detailed = TRUE,             # Request detailed output
  type = 3                     # Type 3 sums of squares
)

nice_anova <- nice_table(anova_results$ANOVA,title = c("Table 4","RLWM Anova Results"))

## Perform logistic regression for the paper ##
# Extract the data for each participant from processed_data list
extract_trial_by_trial_data <- function(df) {
  #browser()
  subjID <- df$subjID[1]
  
  # Add stimulus exposure
  decision_df <- df %>%
    select(subjID, correct, setsize, block, stim_id, stimulus_type) %>%
    filter(!is.na(block) & !is.na(stim_id) & !is.na(stimulus_type) & stimulus_type!="instructions") %>%
    group_by(block, stim_id, stimulus_type) %>%
    mutate(stimulus_exposure = row_number()) %>%
    ungroup()
  

  
  return(decision_df)
}

trial_data_df <- do.call(rbind, lapply(data_frames, extract_trial_by_trial_data))
rownames(trial_data_df) <- NULL

# Do a logistic regression on Correct - setsize * stimulus_exposure
prop_corr_regression <- glmer(
  correct ~ setsize * stimulus_exposure + (1 | subjID),
  data = trial_data_df,
  family = binomial(link = "logit")
)

summary(prop_corr_regression)

# Convert to log odds by exp()

######################## RT ###########################################


rt_list <- list()
for (i in 1:length(data_frames)) {
  rt_list[[i]] <- rlwm_rt_per_stim_iter(data_frames[[i]])
}

# Check if all dataframes have the same structure
if (!all(sapply(rt_list, function(x) all(dim(x) == dim(rt_list[[1]])))))
  stop("Dataframes do not have the same structure")

# Summing up the dataframes
sum_df <- Reduce(`+`, rt_list)

# Calculating the average rt
avg_rt_df <- data.frame(lapply(sum_df, function(x) x / length(rt_list)))

# Line plots
ggplot() + 
  geom_line(data = avg_rt_df, aes(x = X1, y = X2, color = "Set size 3"), linewidth=1) +
  geom_line(data = avg_rt_df, aes(x = X1, y = X3, color = "Set size 4"), linewidth=1) +
  geom_line(data = avg_rt_df, aes(x = X1, y = X4, color = "Set size 6"), linewidth=1) +
  geom_line(data = avg_rt_df, aes(x = X1, y = X5, color = "Set size 5"), linewidth=1) +
  geom_line(data = avg_rt_df, aes(x = X1, y = X6, color = "Set size 6"), linewidth=1) +
  labs(title = "Reaction Times Averaged Across Participants", x = "Stimulus iteration", y = "Reaction Time (ms)", color = "WM Load") +
  scale_color_manual(values = c("Set size 3" = "red", "Set size 4" = "green", "Set size 6" = "black"))  +
  scale_x_continuous(breaks = 1:12, limits = c(1, 12)) +
  # scale_y_continuous(breaks = seq(from = 0, 
  #                                 to = 1, 
  #                                 by = 0.10)) +
  theme(
    panel.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(colour = "black")
  )


################## RT PER CONDITION ###################################


calc_rt_per_cond_rlwm <- function(df) {
  
  #browser()
  # preprocessing - extract task data
  df_task <- df %>%
    filter(task == 'stimulus_presentation') %>% # extract stimulus trials
    select(rt, response, correct_response, correct, stimulus_type,
           setsize, block, stim_id)
  
  # extract set size 2 and add trial number
  df_ns2 <- df_task %>%
    filter(setsize == 2) %>%
    mutate(trial_number = row_number())
  
  # extract set size 3 and add trial number
  df_ns3 <- df_task %>%
    filter(setsize == 3) %>%
    mutate(trial_number = row_number())
  
  # extract set size 4 and add trial number
  df_ns4 <- df_task %>%
    filter(setsize == 4) %>%
    mutate(trial_number = row_number())
  
  # extract set size 5 and add trial number
  df_ns5 <- df_task %>%
    filter(setsize == 5) %>%
    mutate(trial_number = row_number())

  # extract set size 6 and add trial number
  df_ns6 <- df_task %>%
    filter(setsize == 6) %>%
    mutate(trial_number = row_number())
  
  
  # Take the average to get proportion correct
  rt_ns2 <- mean(as.numeric(df_ns2$rt), na.rm = TRUE)
  rt_ns3 <- mean(as.numeric(df_ns3$rt), na.rm = TRUE)
  rt_ns4 <- mean(as.numeric(df_ns4$rt), na.rm = TRUE)
  rt_ns5 <- mean(as.numeric(df_ns5$rt), na.rm = TRUE)
  rt_ns6 <- mean(as.numeric(df_ns6$rt), na.rm = TRUE)
  
  # put the proportions in one df
  df_rt <- data.frame(
    rt_ns2=rt_ns2, 
    rt_ns3=rt_ns3, 
    rt_ns4=rt_ns4, 
    rt_ns5=rt_ns5,
    rt_ns6=rt_ns6
  )
  
  return(df_rt)
}


# Data frame with performance measures for each participant (each row)
# turn the list into a dataframe more suitable for plotting 
vec <- numeric(length(data_frames))
rt_df <- data.frame(#placement df
  rt_ns2=vec, 
  rt_ns3=vec, 
  rt_ns4=vec,
  rt_ns5=vec,
  rt_ns6=vec
)

# one participant per row (mean rt)
for (i in 1:length(data_frames)) {
  rt_df[i, ] <- calc_rt_per_cond_rlwm(data_frames[[i]]) # 1 row per participant
}



# Convert the dataframe to long format using tidyr
rt_df_long <- rt_df %>%
  pivot_longer(everything(), names_to = "set_size", values_to = "Value")

# update output df
output_data_frame <- cbind(output_data_frame, rt_df)

# reorder factors to get them in the order I want when plotting
#df_prop_corr_long$set_size <- factor(performance_df_long$Performance_measure, levels = c("prop_correct", "go_bias", "outcome_bias", "pavlovian_bias", "feedback_sensitivity"))


# Creating the box and whisker plot with individual observations
ggplot(rt_df_long, aes(x = set_size, y = Value)) +
  geom_boxplot(outlier.shape = NA) + # supress the outlier, or it will look like there are extra observations
  #theme_base() + 
  guides(color = "none")  + # This line removes the color legend
  geom_jitter(aes(color = set_size), width = 0.1, height = 0,alpha = 0.5, size=2) + # change the width to change the jitter (or set to 0 to have no jitter)
  labs(x = "Set Size", y = "Reaction Time (ms)", title = "Reaction Times per Condition") +
  scale_x_discrete(labels = c("2","3", "4","5", "6")) +
  # scale_y_continuous(breaks = seq(from = 0,
  #                                 to = 1,
  #                                 by = 0.10)) +
  theme(
    panel.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(colour = "black")
  )
################################################## RT Analysis ##########################################
# Get the desired RT df for each participant containing subjID, rt, setsize
extract_reaction_times <- function(df) {
  #browser()
  # Extract the task data
  df$rt_log <- log(as.numeric(df$rt))
  
  df_reaction_times <- df %>%
    filter(task == 'stimulus_presentation') %>% # extract stimulus trials
    select(rt_log, correct, setsize)
  
  # Add the subject ID to the data frame
  subjID <- df$subjID[1]
  df_reaction_times <- cbind(subjID, df_reaction_times)
  
  return(df_reaction_times)
}

# Apply the function to each dataset in processed_data
output_rt <- lapply(data_frames, extract_reaction_times)

### Run the regression to get an individual effect of condition on RT
# Function to run regression per participant
run_regression_per_subject <- function(df) {
  # Ensure valid trials
  df <- df %>%
    filter(!is.na(rt_log) & is.finite(rt_log))
  
  # Get unique set sizes
  set_sizes <- unique(df$setsize)
  
  # Initialize an empty list to store results
  results <- list()
  
  for (ss in set_sizes) {
    df_subset <- df %>% filter(setsize == ss)
    
    # Run regression only if there are enough trials
    if (nrow(df_subset) > 1) {
      model <- lm(rt_log ~ correct, data = df_subset)
      model_result <- tidy(model) %>%
        select(term, estimate) %>%
        pivot_wider(names_from = term, values_from = estimate) %>%
        mutate(subjID = unique(df$subjID), setsize = ss)
    } else {
      # Return NA if not enough trials
      model_result <- tibble(subjID = unique(df$subjID), setsize = ss, `(Intercept)` = NA, correct = NA)
    }
    
    results[[as.character(ss)]] <- model_result
  }
  
  # Bind results for different set sizes into one data frame
  return(bind_rows(results))
}

# Apply function to each subject's dataset
beta_coefficients <- bind_rows(lapply(output_rt, run_regression_per_subject))

# Plot the beta coefficients as boxplots
beta_coefficients_long <- pivot_longer(beta_coefficients, cols = c(correctTRUE), names_to = "Variable", values_to = "Beta")
# 
# ggplot(beta_coefficients_long, aes(x = Variable, y = Beta)) +
#   geom_boxplot(outlier.shape = NA) +
#   geom_jitter(aes(color = Variable), width = 0.1, height = 0, alpha = 0.7) +
#   labs(title = "Beta Coefficients of RT across set sizes and proportion correct",
#        x = "Proportion correct",
#        y = "Beta Coefficient") +
#   theme_minimal()

# Test one-sample t test against zero for each betas
beta_coefficients_3 <- beta_coefficients %>%
  filter(setsize == 3)

beta_coefficients_4 <- beta_coefficients %>%
  filter(setsize == 4)

beta_coefficients_6 <- beta_coefficients %>%
  filter(setsize == 6)

t.test(beta_coefficients_3$correctTRUE)
t.test(beta_coefficients_4$correctTRUE)
t.test(beta_coefficients_6$correctTRUE)

ggplot(beta_coefficients_long, aes(x = Variable, y = Beta)) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(aes(color = Variable), width = 0.1, height = 0, alpha = 0.7) +
  facet_wrap(~ setsize) +  # Separate plots by set size
  labs(title = "Beta Coefficients of RT across Set Sizes and Proportion Correct",
       x = "Proportion Correct",
       y = "Beta Coefficient") +
  theme_minimal()


# Correlation of prop corr and RT
# Add subjId to the rt data frame
rt_df_with_id <- cbind(subjId,rt_df)

# Log transform the Rts
rt_df_with_id$log_rt_ns3 <- log(rt_df_with_id$rt_ns3)
rt_df_with_id$log_rt_ns4 <- log(rt_df_with_id$rt_ns4)
rt_df_with_id$log_rt_ns6 <- log(rt_df_with_id$rt_ns6)

# Add subjId to the prop corr data frame
df_prop_corr_with_id <- cbind(subjId,df_prop_corr)

# Correlate the average RT across columns with the average prop corr across columns
rt_prop_corr_correlation_ns3 <- cor.test(rt_df_with_id$log_rt_ns3, df_prop_corr$prop_corr_ns3, method = "pearson")
rt_prop_corr_correlation_ns4 <- cor.test(rt_df_with_id$log_rt_ns4, df_prop_corr$prop_corr_ns4, method = "pearson")
rt_prop_corr_correlation_ns6 <- cor.test(rt_df_with_id$log_rt_ns6, df_prop_corr$prop_corr_ns6, method = "pearson")

print(rt_prop_corr_correlation_ns3)
print(rt_prop_corr_correlation_ns4)
print(rt_prop_corr_correlation_ns6)

# Plot scatter plots for all three set sizes with fitted lines
# Set size 3
ggplot(rt_df_with_id, aes(x = log_rt_ns3, y = df_prop_corr$prop_corr_ns3)) +
  geom_point() +
  geom_smooth(method = "lm", se = TRUE) +
  labs(x = "Log RT", y = "Proportion Correct", title = "Set Size 3") +
  theme(
    panel.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(colour = "black")
  )

# Set size 4
ggplot(rt_df_with_id, aes(x = log_rt_ns4, y = df_prop_corr$prop_corr_ns4)) +
  geom_point() +
  geom_smooth(method = "lm", se = TRUE) +
  labs(x = "Log RT", y = "Proportion Correct", title = "Set Size 4") +
  theme(
    panel.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(colour = "black")
  )

# Set size 6
ggplot(rt_df_with_id, aes(x = log_rt_ns6, y = df_prop_corr$prop_corr_ns6)) +
  geom_point() +
  geom_smooth(method = "lm", se = TRUE) +
  labs(x = "Log RT", y = "Proportion Correct", title = "Set Size 6") +
  theme(
    panel.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(colour = "black")
  )

write.csv(beta_coefficients, paste0(folder_path_pilot_anal,"/rlwm/rlwm_betas_day_",day,".csv"),row.names = FALSE)


################################################## Prop correct early and late (at asymptote) ##########################################


calc_prop_corr_early_vs_late <- function (df) {
  # calculate proportion correct (accuracy) for each stimulus iteration
  prop_corr_1part <- rlwm_prop_corr_per_stim_iter(df)
  
  # Exclude the first column (index variable)
  data_without_index <- prop_corr_1part[-1]
  
  # Calculate the average of the first 5 rows (early)
  avg_first_5 <- colMeans(data_without_index[1:5, ])
  
  # Calculate the average of the last 5 rows (late)
  avg_last_5 <- colMeans(data_without_index[(nrow(data_without_index)-4):nrow(data_without_index), ])
  
  # Create a new data frame with these averages
  averages_df <- data.frame(avg_first_5 = avg_first_5, avg_last_5 = avg_last_5)
  
  # add index variable (representing set sizes - the x variable)
  averages_df <- averages_df %>% mutate(set_size = c(2,3,4,5,6))
  
  return(averages_df)
}

# call the function on each participant
prop_corr_early_late_list <- list()
for (i in 1:length(data_frames)) {
  prop_corr_early_late_list[[i]] <- calc_prop_corr_early_vs_late(data_frames[[i]])
}

# Save data in output df (multiple steps)
# Extract a sublist for this participant
# Create column names for the new data frame
col_names <- c(#"prop_corr_early_ns_2", "prop_corr_late_ns_2", 
               "prop_corr_early_ns_3", "prop_corr_late_ns_3",
               "prop_corr_early_ns_4", "prop_corr_late_ns_4",
               #"prop_corr_early_ns_5", "prop_corr_late_ns_5",
               "prop_corr_early_ns_6", "prop_corr_late_ns_6")
# Initialize an empty vector to store the combined averages
combined_averages <- numeric(length = 6)  # 3 set sizes * 2 metrics (early, late)
# initialize data frame with 1 row per participant
early_late_data_frame <- data.frame(matrix(nrow = length(prop_corr_early_late_list), ncol = length(col_names)))
names(early_late_data_frame) <- col_names # assign column names

# Loop over each list to reshape the data into wide format
for (i in 1:length(prop_corr_early_late_list)) {
  sublist_example <- prop_corr_early_late_list[[i]]  # Replace with your actual data list name
  
  # Loop through the set sizes
  for(k in 1:nrow(sublist_example)) {
    combined_averages[(k-1)*2+1] <- sublist_example$avg_first_5[k]
    combined_averages[k*2] <- sublist_example$avg_last_5[k]
  }
  
  
  
  # Create the new data frame
  average_early_late_df <- setNames(data.frame(t(combined_averages)), col_names)
  early_late_data_frame[i,] <- average_early_late_df
}

# Update output df
output_data_frame <- cbind(output_data_frame, early_late_data_frame)





## Calculate the average for each corresponding cell (set size x early and late)
average_early_late_df <- Reduce("+", prop_corr_early_late_list) / length(prop_corr_early_late_list)

#convert to long format for plotting
df_early_late_long <- average_early_late_df %>%
  pivot_longer(everything(), names_to = "set_size", values_to = "Value")

# Plot early and late accuracy line plot (first and last 5 iterations)
ggplot() + 
  geom_line(data = average_early_late_df, aes(x = set_size, y = avg_first_5, color = "Early"), linewidth=1) +
  geom_line(data = average_early_late_df, aes(x = set_size, y = avg_last_5, color = "Late"), linewidth=1) +
  labs(title = "Accuracy Early and Late", x = "Set Size", y = "Accuracy", color = "Early or Late") +
  scale_color_manual(values = c("Early" = "blue", "Late" = "red"))  +
  scale_x_continuous(breaks = c(3,4,6), limits = c(2, 6)) +
  scale_y_continuous(breaks = seq(from = 0, 
                                  to = 1, 
                                  by = 0.10), limits = c(0,1)) +
  theme(
    panel.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(colour = "black")
  )


############################### Using this? #################
# From the data for each participant, create a new data frame
# reshape_propcorr_early_late <- function(df_early_late) {
#   df_first <- df_early_late %>%
#     select(avg_first_5, set_size) %>%
#     pivot_wider(names_from = set_size, values_from = avg_first_5, names_prefix = "avg_first_5_ns_")
#   
#   # Reshape avg_last_5
#   df_last <- df_early_late %>%
#     select(avg_last_5, set_size) %>%
#     pivot_wider(names_from = set_size, values_from = avg_last_5, names_prefix = "avg_last_5_ns_")
#   
#   # Combine the reshaped data frames
#   df_combined <- bind_cols(df_first, df_last)
#   return(df_combined)
# }
# 
# 
# # From the data for each participant, create a new data frame. One participant pe row
# df_early_late_wide <- data.frame(matrix(ncol = 10, nrow = length(prop_corr_early_late_list)))
# for (i in 1:length(prop_corr_early_late_list)) {
#   df_early_late_wide[i,] <- reshape_propcorr_early_late(prop_corr_early_late_list[[i]])
# } # 1 row per participant
# # change column names
# colnames(df_early_late_wide) <- colnames(reshape_propcorr_early_late(prop_corr_early_late_list[[1]]))
# 

################### plot early and late performance for each set size######

# Combine all data frames into one with participant information
combined_df <- do.call(rbind, lapply(seq_along(prop_corr_early_late_list), function(i) {
  cbind(participant = paste("Participant", i), prop_corr_early_late_list[[i]])
}))

# Reshape the data while keeping set_size
long_df <- combined_df %>%
  pivot_longer(cols = c(avg_first_5, avg_last_5), names_to = "time_period", values_to = "value")

long_df_ns2 <- long_df %>%
  filter(set_size == 2) %>%
  mutate(time_period = factor(time_period, levels = c("avg_first_5", "avg_last_5"), labels = c("Early", "Late")))

# Create boxplot - set size 2
p1 <- ggplot(long_df_ns2, aes(x = time_period, y = value)) +
  geom_boxplot(outlier.shape = NA) + 
  guides(color = "none")  +
  geom_jitter(aes(color = time_period), width = 0.1, height = 0, alpha = 0.5, size=2) +
  labs(x = "Set Size 2", y = "Proportion correct") +
  scale_y_continuous(breaks = seq(from = 0, 
                                  to = 1, 
                                  by = 0.10), limits = c(0,1)) +
  theme(
    panel.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(colour = "black")
  )


long_df_ns3 <- long_df %>%
  filter(set_size == 3) %>%
  mutate(time_period = factor(time_period, levels = c("avg_first_5", "avg_last_5"), labels = c("Early", "Late")))

# Create boxplot - set size 2
p2 <- ggplot(long_df_ns3, aes(x = time_period, y = value)) +
  geom_boxplot(outlier.shape = NA) + 
  guides(color = "none")  +
  geom_jitter(aes(color = time_period), width = 0.1, height = 0, alpha = 0.5, size=2) +
  labs(x = "Set Size 3", y = "Proportion correct") +
  scale_y_continuous(breaks = seq(from = 0, 
                                  to = 1, 
                                  by = 0.10), limits = c(0,1)) +
  theme(
    panel.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(colour = "black"),
    axis.line.y = element_blank(),   # Remove y-axis line
    axis.title.y = element_blank(),  # Removes the y-axis title
    axis.text.y = element_blank(),   # Removes the y-axis text/labels
    axis.ticks.y = element_blank()   # Removes the y-axis ticks
  )

long_df_ns4 <- long_df %>%
  filter(set_size == 4) %>%
  mutate(time_period = factor(time_period, levels = c("avg_first_5", "avg_last_5"), labels = c("Early", "Late")))

# Create boxplot - set size 2
p3 <- ggplot(long_df_ns4, aes(x = time_period, y = value)) +
  geom_boxplot(outlier.shape = NA) + 
  guides(color = "none")  +
  geom_jitter(aes(color = time_period), width = 0.1, height = 0, alpha = 0.5, size=2) +
  labs(x = "Set Size 4", y = "Proportion correct") +
  scale_y_continuous(breaks = seq(from = 0, 
                                  to = 1, 
                                  by = 0.10), limits = c(0,1)) +
  theme(
    panel.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(colour = "black"),
    axis.line.y = element_blank(),   # Remove y-axis line
    axis.title.y = element_blank(),  # Removes the y-axis title
    axis.text.y = element_blank(),   # Removes the y-axis text/labels
    axis.ticks.y = element_blank()   # Removes the y-axis ticks
  )

long_df_ns5 <- long_df %>%
  filter(set_size == 5) %>%
  mutate(time_period = factor(time_period, levels = c("avg_first_5", "avg_last_5"), labels = c("Early", "Late")))

# Create boxplot - set size 2
p4 <- ggplot(long_df_ns5, aes(x = time_period, y = value)) +
  geom_boxplot(outlier.shape = NA) + 
  guides(color = "none")  +
  geom_jitter(aes(color = time_period), width = 0.1, height = 0, alpha = 0.5, size=2) +
  labs(x = "Set Size 5", y = "Proportion correct") +
  scale_y_continuous(breaks = seq(from = 0, 
                                  to = 1, 
                                  by = 0.10), limits = c(0,1)) +
  theme(
    panel.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(colour = "black"),
    axis.line.y = element_blank(),   # Remove y-axis line
    axis.title.y = element_blank(),  # Removes the y-axis title
    axis.text.y = element_blank(),   # Removes the y-axis text/labels
    axis.ticks.y = element_blank()   # Removes the y-axis ticks
  )

long_df_ns6 <- long_df %>%
  filter(set_size == 6) %>%
  mutate(time_period = factor(time_period, levels = c("avg_first_5", "avg_last_5"), labels = c("Early", "Late")))

# Create boxplot - set size 2
p5 <- ggplot(long_df_ns6, aes(x = time_period, y = value)) +
  geom_boxplot(outlier.shape = NA) + 
  guides(color = "none")  +
  geom_jitter(aes(color = time_period), width = 0.1, height = 0, alpha = 0.5, size=2) +
  labs(x = "Set Size 6", y = "Proportion correct") +
  scale_y_continuous(breaks = seq(from = 0, 
                                  to = 1, 
                                  by = 0.10), limits = c(0,1)) +
  theme(
    panel.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(colour = "black"),
    axis.line.y = element_blank(),   # Remove y-axis line
    axis.title.y = element_blank(),  # Removes the y-axis title
    axis.text.y = element_blank(),   # Removes the y-axis text/labels
    axis.ticks.y = element_blank()   # Removes the y-axis ticks
  )


# Combine into one plot
plot_perf_early_late <-  grid.arrange(p2, p3,p5, ncol = 3, nrow = 1,
             top = textGrob("Performance During Early and Late Trials", gp = gpar(fontface = "bold", fontsize = 20)))
print(plot_perf_early_late)

# Save the plot
ggsave(paste0(folder_path_pilot_anal, "/rlwm/","perf_early_late.jpg"), plot_perf_early_late, width = 10, height = 6, dpi = 300)

############################################################################

# one participant per row (prop corr)
for (i in 1:length(data_frames)) {
  df_prop_corr[i, ] <- calc_prop_corr_rlwm(data_frames[[i]]) # 1 row per participant
}

################# Debriefing ################################

debriefing_current_task <- function(df, current_task) {
  # current_task <- 'rlwm'
  debrief_task <- paste('debrief_', current_task, sep = "")
  
  debrief <- df %>%
    filter(task == debrief_task) %>%
    pull(response)
  
  parse_debriefing <- function(debrief) {
    
    # Function requires jsonlite
    if (!requireNamespace("jsonlite", quietly = TRUE)) {
      install.packages("jsonlite")
    }
    library(jsonlite)
    
    # Convert JSON string to a list
    debrief_parsed <- fromJSON(debrief)
    
    # Convert the number to a rating
    for (i in 1:length(debrief_parsed)) {
      if(debrief_parsed[[i]] == 'Very easy' | debrief_parsed[[i]] == 'Very fun' | debrief_parsed[[i]] == 'Very clear') {
        debrief_parsed[[i]][2] <- 5
      } else if ((debrief_parsed[[i]] == 'Somewhat easy' | debrief_parsed[[i]] == 'Somewhat fun' | debrief_parsed[[i]] == 'Somewhat clear')) {
        debrief_parsed[[i]][2] <- 4
      } else if ((debrief_parsed[[i]] == 'Neither easy nor hard' | debrief_parsed[[i]] == 'Neither fun nor boring' | debrief_parsed[[i]] == 'Neither clear nor confusing')) {
        debrief_parsed[[i]][2] <- 3
      } else if ((debrief_parsed[[i]] == 'Somewhat hard' | debrief_parsed[[i]] == 'Somewhat boring' | debrief_parsed[[i]] == 'Somewhat confusing')) {
        debrief_parsed[[i]][2] <- 2
      } else if ((debrief_parsed[[i]] == 'Very hard' | debrief_parsed[[i]] == 'Very boring' | debrief_parsed[[i]] == 'Very confusing')) {
        debrief_parsed[[i]][2] <- 1
      }
    }
    
    return(debrief_parsed)
  }
  
  output <- parse_debriefing(debrief)
  
}

# Get the rlwm debrief questionnaire results for each participant
output_debrief <- lapply(data_frames, debriefing_current_task, 'rlwm')

# Convert each sublist to a dataframe with only the second value
output_debrief_df <- lapply(output_debrief, function(x) {
  as.data.frame(lapply(x, function(y) y[2]))
})

# Combine all dataframes into one
output_debrief_df <- do.call(rbind, output_debrief_df)

# Save the debriefing df
write.csv(output_debrief_df, paste0("../../output/session",day,"/rlwm/debrief.csv"),row.names = FALSE)

# Reshape the dataframe to long format
long_df <- pivot_longer(output_debrief_df, cols = c(difficultyRate, funRate, clarityRate), 
                        names_to = "Category", values_to = "Value")
long_df <- long_df %>%
  mutate(Value = as.numeric(Value))
long_df$Value <- as.integer(long_df$Value) # integer

# Create plot
ggplot(long_df, aes(x = Category, y = Value)) +
  geom_boxplot(outlier.shape = NA) + # Suppress outliers
  guides(color = "none") + # Remove color legend
  geom_jitter(aes(color = Category), width = 0.2, height = 0 ,alpha = 0.5, size=2) + # Adjust jitter
  labs(x = "Ratings", y = "Score", title = "Debrief Ratings") +
  scale_x_discrete(labels = c("Clarity", "Easy", "Fun")) +
  scale_y_continuous(
    limits = c(0, 6), # Set limits from 0 to 1
    breaks = 0:5 # Set breaks at every 0.1 interval
  ) +
  theme(
    panel.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(colour = "black"),
    legend.position = "none" # Remove legend
  )




############### SET SIZE SLOPE #####################33
# See Master et al., 2020:

# "To assess learning, we calculated the proportion of correct trials for each subject on each stimulus iteration. 
# Each individual stimulus was repeated 12 to 14 times within a block. Within each set size, we calculated each 
# subject ’s average percentage of correct responses at each stimulus iteration (Fig. 2a).
# We quantified the effect of set size on performance by calculating a 
# set size slope (Fig. 2b). The set size slope was a linear contrast of the form: 
# - 1.5*perf(ns5) - 0.5*perf(ns4) + 0.5*perf(ns3) + 1.5*perf(ns2), 
# where perf(ns) is the averageoverall performance of trials withina block of set size ns.

# So, perf(ns5) and perf(ns2) are weighted higher than ns 3 and 4. I have 5 conditions, not 4, so I cannot quite do 
# the same. Perf(ns6) should reasonably contribute even more negatively to the accuracy, so perhaps it should be 
# weighted by 3? But, I also want the coefficients to sum to 0. So, I will try -3 -2 +.5 + 1.5 + 3.
# Each participant should have 1 set size slope.

set_size_slopes <- numeric(nrow(accuracy_per_ns))
contrast_weights <- c(.5, 0, -.5)

# for each participant calculate its set size slope
for (i in 1:length(set_size_slopes)) {
  temp <- numeric(length(contrast_weights))
  for (j in 1:length(contrast_weights)) {
    
    temp[j] <- contrast_weights[j] * accuracy_per_ns[i, j]
  }
  set_size_slopes[i] <- sum(temp)
}


################ LEARNING CURVE SLOPES #######################################¨


calc_learning_slopes <- function(df) { # input prop_corr_per_stim_data
  # 1 set size one participant
  x_values <- 1:12
  y_values <- df %>%
    select(ns_3, ns_4, ns_6)
  
  # Calculate differences in y-values
  diff_y <- data.frame(matrix(NA, nrow = nrow(y_values)-1, ncol = ncol(y_values)))
  colnames(diff_y) <- colnames(y_values)
  for (i in 1:ncol(y_values)) {
    diff_y[i] <- diff(y_values[,i])
  }
  
  # Calculate differences in x-values (vector of 1s)
  diff_x <- diff(x_values)
  
  # Calculate slopes (approximate derivatives) - same as diff_y
  slopes <- diff_y / diff_x
  
  # Calculate avg slope early and late (delta prop corr)
  avg_slope_early <- data.frame(matrix(NA, nrow = 1, ncol = ncol(slopes)))
  colnames(avg_slope_early) <- colnames(slopes)
  avg_slope_late <- avg_slope_early
  
  # calculate avg slope early and late for this participant
  for (i in 1:ncol(slopes)) {
    avg_slope_early[i] <- mean(slopes[1:4, i])
    avg_slope_late[i] <- mean(slopes[8:11, i])
  }
  
  return(list(avg_slope_early = avg_slope_early, avg_slope_late = avg_slope_late))
}

x_values <- 1:12

# list of the slopes (avg early and late)
avg_slope_early_late <- lapply(prop_corr_per_stim_data, calc_learning_slopes) # what about many participants? lapply?


# Extract all avg_slope_early
list_avg_slope_early <- lapply(avg_slope_early_late, function(x) x$avg_slope_early)

# Extract all avg_slope_late
list_avg_slope_late <- lapply(avg_slope_early_late, function(x) x$avg_slope_late)

# Reduce the list of data frames by row-binding (1 row per participant)
avg_slope_early <- list_avg_slope_early %>% 
  bind_rows()

# then calculate the mean for each column
avg_slope_early_mean <- avg_slope_early %>%
  summarise(across(everything(), ~mean(.x, na.rm = TRUE)))

# Reduce the list of data frames by row-binding (1 row per participant)
avg_slope_late <- list_avg_slope_late %>% 
  bind_rows()

# then calculate the mean for each column
avg_slope_late_mean <- avg_slope_late %>%
  summarise(across(everything(), ~mean(.x, na.rm = TRUE)))

# save data for output df
copy_slope_late <- avg_slope_late
copy_slope_early <- avg_slope_early
colnames(copy_slope_late) <- c("slope_late_ns_3", 
                              "slope_late_ns_4", 
                              "slope_late_ns_6")
colnames(copy_slope_early) <- c("slope_early_ns_3", 
                               "slope_early_ns_4", 
                               "slope_early_ns_6")
output_data_frame <- cbind(output_data_frame,copy_slope_early ,copy_slope_late)



# PLOT the slopes across participants
# Add a grouping column to each data frame
avg_slope_early$Time <- 'Early'
avg_slope_late$Time <- 'Late'

# Combine the two data frames
combined_df <- bind_rows(avg_slope_early, avg_slope_late)

# Reshape to long format
long_df <- combined_df %>% 
  pivot_longer(cols = ns_3:ns_6, names_to = "NS", values_to = "Value")

# Plot
ggplot(long_df, aes(x = NS, y = Value, color = Time)) +
  geom_jitter(width = 0.1, height = 0, alpha = 0.5, size=2) + # Adjust jitter
  labs(x = "Set Size", y = "Change in Proportion Correct", title = "Average Slope for Early and Late Trials") +
  scale_x_discrete(labels = c("2", "3", "4", "5", "6")) +
  scale_y_continuous(
    limits = c(0, 0.5), # Set limits from 0 to 1
    breaks = seq(0, 0.5, by = 0.05) # Set breaks at every 0.1 interval
  ) +
  theme(
    panel.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(colour = "black")
  )



# Calculate average slope early and late for each set size
# Calculating the average of each column for 'Early' and 'Late' time categories
averages_slopes <- combined_df %>%
  group_by(Time) %>%
  summarise(
    #ns_2_avg = mean(ns_2, na.rm = TRUE),
    ns_3_avg = mean(ns_3, na.rm = TRUE),
    ns_4_avg = mean(ns_4, na.rm = TRUE),
    #ns_5_avg = mean(ns_5, na.rm = TRUE),
    ns_6_avg = mean(ns_6, na.rm = TRUE)
  )


######################### MOVING AVERAGE TO FIND ASYMPTOTE #####################

calc_asymptote_index <- function(df){ # input must be prop_corr_per_stim_data
  # For one participant and one set size initially
 
  trials <- df#$ns_2
  x_vals <- df$stim_iter
  
  trials <- trials %>% select(-stim_iter)
  

  # Moving average with a window size of 3
  # Calculate the moving average with a window size of 3
  window_size <- 3
  moving_average <- stats::filter(trials, rep(1/window_size, window_size), sides = 2)
  colnames(moving_average) <- colnames(trials)
  # centered moving average
    # Identify where stabilization occurs
  
  
  # Calculate the change in moving average
  change_in_moving_average <- matrix(0, nrow = nrow(moving_average)-1, ncol = ncol(moving_average))
  for (i in 1:ncol(change_in_moving_average)) {
    change_in_moving_average[,i] <- abs(diff(as.numeric(moving_average[,i])))
    
  }
  
  
  
  # Define the threshold for stabilization
  threshold_value <- 0.1

  
  # Initialize an index for when the criteria are met
  asymptote_index <- rep(NA, ncol(moving_average))
  
  # Loop through the moving average, checking the criteria
  for (j in 1:ncol(moving_average)) {  # Iterate over columns
    for(i in 1:(nrow(moving_average)-1)) {  # Adjust to iterate correctly based on moving_average dimensions
      # Check for NAs explicitly to avoid evaluating conditions with NA values
      if (!is.na(moving_average[i,j]) && !is.na(moving_average[i+1,j]) && !is.na(change_in_moving_average[i,j]) &&
          moving_average[i,j] > 0.85 && moving_average[i+1,j] > 0.85 && change_in_moving_average[i,j] < 0.1) {
        asymptote_index[j] <- i
        break  # Exit the inner loop once the criteria are met
      }
    }
  }
  
  
  asymptote_index <- data.frame(asymptote_index)
  #browser()
  set_size <- c(3, 4, 6)
  asymptote_index <- cbind(asymptote_index, set_size)
  
  return(list(asymptote_index = asymptote_index))
  


################################# Save output variables ######################

# Save the data frame as a CSV file in the output folder
path_names <- paste(output_folder,"/rlwm_variables.csv", sep="")
write.csv(output_data_frame,path_names , row.names = FALSE)




######################## catch trials ###############################
catch_trial_fun <- function(df) {
  df_catch <- df %>% 
    filter(task == 'catch_trial') %>%
    select(subjID, rt, task, response, correct)
  return(df_catch)
}
df_catch <- lapply(data_frames, catch_trial_fun)
print(df_catch) # for initial inspection of single participants

# Apply function and combine into a single data frame
df_catch <- lapply(data_frames, catch_trial_fun) %>%
  bind_rows()

write.csv(df_catch, paste0(folder_path_pilot_anal,'rlwm_catch_trials.csv' )) 


################ Missed trials ###########################
extract_missed_trials <- function(data_frames) {
  df_missed_trials <- lapply(data_frames, function(df) {
    current_subjID <- first(df$subjID)
    
    df %>%
      filter(task == "stimulus_presentation", !(response %in% c("q", "w", "e"))) %>%
      summarise(subjID = current_subjID, missed_trials = n()) %>%
      mutate(perc_missed_trials = missed_trials / 480)
  }) %>%
    bind_rows()
  
  
  
  return(df_missed_trials)
}

# Example usage:
df_missed_trials <- extract_missed_trials(data_frames)

write.csv(df_missed_trials, paste(folder_path_pilot_anal,"/rlwm/rlwm_missed_trials.csv", sep=""), row.names = FALSE)

################ GET DATA FOR MODELLING ###########################
# df <- data_frames[[1]]
get_comp_matrix <- function(df) {

  # preprocessing - extract task data
  df_task <- df %>%
    filter(task == 'stimulus_presentation') %>% # extract stimulus trials
    select(rt, response, correct_response, correct, stimulus_type,
           setsize, block, stim_id)
  
  # convert responses to numeric (Q=1, W=2, E=2)
  df_task <- df_task %>%
    mutate(response_numeric = case_when(
      response == 'q' ~ 1,
      response == 'w' ~ 2,
      response == 'e' ~ 3,
      TRUE ~ NA_real_  # This line handles any unexpected values by assigning NA
    ))
  
  # extract the actions
  action <- df_task %>%
    pull(response_numeric)
  

  
  # extract set sizes
  set_size <- df_task %>%
    pull(setsize)
  
  # extract correct responses and change to 1/0 (reward)
  reward <- df_task %>%
    pull(correct)
  reward <- as.numeric(reward)
  
  # create stimulus ID variables (1:set_size for each block)
  df_task <- df_task %>%
    group_by(block) %>%
    mutate(stim_id_numeric = as.integer(factor(stim_id, levels = unique(stim_id)))) %>%
    ungroup()
  
  # extract stimulus
  stimulus <- df_task %>%
    pull(stim_id_numeric)
  
  # create new column that is 1 when a new block starts, otherwise 0
  df_task <- df_task %>%
    group_by(block) %>%
    mutate(first_in_block = if_else(row_number() == 1, 1, 0)) %>%
    ungroup()
  
  # block_index
  block_index <- df_task %>%
    pull(first_in_block)

  return(list(action=action, set_size=set_size, reward=reward, stimulus=stimulus, block_index=block_index))

}

output <- lapply(data_frames, get_comp_matrix)

# Extract vectors from the list and convert to a matrix (participant x trial)
stimulus_matrix <- do.call(rbind, lapply(output, function(x) x$stimulus)) 
action_matrix <- do.call(rbind, lapply(output, function(x) x$action)) 
reward_matrix <- do.call(rbind, lapply(output, function(x) x$reward))  
setsize_matrix <- do.call(rbind, lapply(output, function(x) x$set_size)) 
block_index_matrix <- do.call(rbind, lapply(output, function(x) x$block_index)) 


comp_output_folder <- "comp_modelling/rlwm/"

# Check if the folder exists, and create it if it doesn't
if (!dir.exists(comp_output_folder)) {
  dir.create(comp_output_folder,recursive = TRUE)
}


# Save the data frames as CSV files in the output folder
s_path <- paste(comp_output_folder,"/rlwm_stimulus_matrix.csv", sep="")
a_path <- paste(comp_output_folder,"/rlwm_action_matrix.csv", sep="")
r_path <- paste(comp_output_folder,"/rlwm_reward_matrix.csv", sep="")
ss_path <-paste(comp_output_folder,"/rlwm_setsize_matrix.csv", sep="")
b_path <- paste(comp_output_folder,"/rlwm_block_index_matrix.csv", sep="")
write.table(stimulus_matrix, s_path , row.names = FALSE, col.names = FALSE, sep=",")
write.table(action_matrix, a_path , row.names = FALSE, col.names = FALSE, sep=",")
write.table(reward_matrix, r_path , row.names = FALSE, col.names = FALSE, sep=",")
write.table(setsize_matrix, ss_path , row.names = FALSE, col.names = FALSE, sep=",")
write.table(block_index_matrix, b_path , row.names = FALSE, col.names = FALSE, sep=",")





# Action_matrix: 1 for Q, 2 for W, 3 for E
# Stimulus_matrix: index of each stimulus for each block (2x each set size = 10 blocks)
# Reward_matrix: 1 for correct response, 0 for incorrect
# Block_index_matrix: 1 when it’s the first stimulus of a new block, otherwise 0
# Setsize matrix: the set size (load) of the current trial




