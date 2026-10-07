################### LOAD DATA FROM ALL PARTICIPANTS #########################

library(purrr)
library(tidyverse)
library(ggthemes)
library(broom)
library(ez)
library(rempsyc)
library(irr)
library(lme4)
library(lmerTest)

# set wd to analysis folder
script_dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
if (getwd() != script_dir) {
  setwd(script_dir)
} else {
  message("The script_dir is the same as the current working directory.")
}


#output folder (from parsing)
#setwd("../retest/data")

day <- 2

# Set the working directory to the data folder
setwd(paste0("../data/session", day))

# Set the output folder
output_folder <- "output/"

# Get list of subfolders (one for each participant)
subfolders <- list.dirs(path = output_folder, full.names = TRUE, recursive = FALSE)

# Initialize a list to store data frames
data_frames <- list()

# Loop through each subfolder and read the CSV file
for (i in seq_along(subfolders)) {
  subfolder <- subfolders[i]
  file_path <- file.path(subfolder, "gonogo_data.csv")
  
  # Check if the file exists before reading
  if (file.exists(file_path)) {
    data_frames[[subfolder]] <- read_csv(file_path)
  }
}

# check if excluded_participants vector is empty skip it, otherwise exclude_ids will be assigned excluded_participants
if (exists("excluded_participants") && length(excluded_participants) > 0) {
  exclude_ids <- excluded_participants
  exclusion_prefix <- "excluded_"
} else {
  exclude_ids <- c()
  exclusion_prefix <- ""
}

# # Exclusion of day 2 performance-based measures
exclude_ids <- c()

# Exclusion of day 2 performance-based measures
if (day == 2) {
  exclude_ids <- c(
    "5eef7da8a4868b05c902ef2d",
    "65956ab743aa1e8fe002ba3b",
    "60e0dc6be0772b7dfdad9b2c",
    "67d0581ffe3bbe5188426aff",
    "67f65a16d76fa76c28091ede",
    "675436e14d7ef1173a74a5b8",
    "6774f9e03114a09130a1e78f",
    "67e2a5b83621fdee51b6277e",
    "5a77529ff49c9a0001f2fdbd",
    "672879d614dce67b8c3090ea",
    "67dc135e06eee79a0b0324ef",
    "67f7c74584da18f7cd5fceeb",
    "60d9dfd4dcc09cf57dc92cb1",
    "65fb34c4df61f03ce0dd6dd9",
    "6122f45e2e93a3ff9a7b7a5d",
    "65b26a99fe500245f7a7c750",
    "67f3619e16d4ca195fbd1bd0",
    "669a6bba1fd09527cf41717a",
    "5bf3199ebe7c7300017b710a",
    "5c549c6372fd9000018b5968",
    "5e5c993cd0394c474f7cc502",
    "5fabca68273dd403ab40e361",
    "5fed47cfcb429d79af4f8ded",
    "655f8bf6de805f7bd81e5811",
    "65651805d1afb42ba1a55476",
    "667971a555af1f83d3f29ae7",
    "66ce541cd8da920539a1c3cc",
    "673bf9c0212c1ae07ff6c22e",
    "67cd50f22f22938860f85a66"
  )
} else if (day == 1) {
  exclude_ids <- c(
    "6697c39cfbf1e3381e6ee45c",
    "65956ab743aa1e8fe002ba3b",
    "669a6bba1fd09527cf41717a",
    "65b26a99fe500245f7a7c750",
    "677009b08130c3028f6a8a6d",
    "6161cb3de3d274978d46575b",
    "65fc95c627592d85499ae358",
    "655f8bf6de805f7bd81e5811",
    "665c5d94303fdf202ac9ded0",
    "65fb34c4df61f03ce0dd6dd9",
    "5d66b4f503b0d900195ca627",
    "676d40e2915d059bf7ef62e8",
    "67d095bc257ecc840642912e",
    "66645dfa2639fc47c5bca0a6",
    "67826c0cd5858c9d420da7ff",
    "67d0581ffe3bbe5188426aff",
    "5eef7da8a4868b05c902ef2d",
    "5fff2877a99bcb65a14a223c",
    "67f3619e16d4ca195fbd1bd0",
    "67e5cf90b79d0874e1cf16b0",
    "571a78f06a1c6300114b8d80",
    "5af82cf9e066a40001136ace",
    "67e2a5b83621fdee51b6277e",
    "66ce541cd8da920539a1c3cc",
    "6741ce8667002c96f0362d34",
    "5e4066ed9eec8d2a184e4ff4",
    "63d9d5072e083033fc895df1",
    "67d9a91f56a568412eecda60",
    "67f6a640d2046b13fcf33328",
    "66083cd0a45e1ce399e6a85f",
    "67851f4cba98f2087f182764",
    "67dc135e06eee79a0b0324ef",
    "604fa685e33606f9a0ee8189",
    "609bfd97a7c95881330491d4",
    "6122f45e2e93a3ff9a7b7a5d",
    "64feeabd355b506d0512d862",
    "6606b31155457e4f162ecf5a",
    "6776b99a8215d150863a71b4"
  )
}

# all_excluded_both_days <- c(
#   "6697c39cfbf1e3381e6ee45c", "65956ab743aa1e8fe002ba3b", "669a6bba1fd09527cf41717a",
#   "65b26a99fe500245f7a7c750", "677009b08130c3028f6a8a6d", "6161cb3de3d274978d46575b",
#   "65fc95c627592d85499ae358", "655f8bf6de805f7bd81e5811", "665c5d94303fdf202ac9ded0",
#   "65fb34c4df61f03ce0dd6dd9", "5d66b4f503b0d900195ca627", "676d40e2915d059bf7ef62e8",
#   "67d095bc257ecc840642912e", "66645dfa2639fc47c5bca0a6", "67826c0cd5858c9d420da7ff",
#   "67d0581ffe3bbe5188426aff", "5eef7da8a4868b05c902ef2d", "5fff2877a99bcb65a14a223c",
#   "67f3619e16d4ca195fbd1bd0", "67e5cf90b79d0874e1cf16b0", "571a78f06a1c6300114b8d80",
#   "5af82cf9e066a40001136ace", "67e2a5b83621fdee51b6277e", "66ce541cd8da920539a1c3cc",
#   "6741ce8667002c96f0362d34", "5e4066ed9eec8d2a184e4ff4", "63d9d5072e083033fc895df1",
#   "67d9a91f56a568412eecda60", "67f6a640d2046b13fcf33328", "66083cd0a45e1ce399e6a85f",
#   "67851f4cba98f2087f182764", "67dc135e06eee79a0b0324ef", "604fa685e33606f9a0ee8189",
#   "609bfd97a7c95881330491d4", "6122f45e2e93a3ff9a7b7a5d", "64feeabd355b506d0512d862",
#   "6606b31155457e4f162ecf5a", "6776b99a8215d150863a71b4", "60e0dc6be0772b7dfdad9b2c",
#   "67f65a16d76fa76c28091ede", "675436e14d7ef1173a74a5b8", "6774f9e03114a09130a1e78f",
#   "5a77529ff49c9a0001f2fdbd", "672879d614dce67b8c3090ea", "67f7c74584da18f7cd5fceeb",
#   "60d9dfd4dcc09cf57dc92cb1", "5bf3199ebe7c7300017b710a", "5c549c6372fd9000018b5968",
#   "5e5c993cd0394c474f7cc502", "5fabca68273dd403ab40e361", "5fed47cfcb429d79af4f8ded",
#   "65651805d1afb42ba1a55476", "667971a555af1f83d3f29ae7", "673bf9c0212c1ae07ff6c22e",
#   "67cd50f22f22938860f85a66"
# )

exclude_ids <- paste0("output/", exclude_ids)


# Check if the include_only vector is empty
if (exists("include_only") && length(include_only) > 0) {
  # Filter the data frames to include only the specified IDs
  data_frames <- data_frames[names(data_frames) %in% include_only]
} else {
  # Filter the data frames to exclude the specified IDs
  data_frames <- data_frames[!(names(data_frames) %in% exclude_ids)]
}



####################### TIME ELAPSED ##############################
# Initialize the output data frame
df_time_elapsed <- data.frame(
  subjID = character(),
  instructions = numeric(),
  task = numeric(),
  end_of_task = numeric(),
  total_time = numeric(),
  stringsAsFactors = FALSE
)

# Process each data frame in the list
for (df in data_frames) {
  
  # Extract participant ID
  subjID <- unique(df$subjID)
  
  # Find timestamps
  timestamp_start <- min(df$time_elapsed, na.rm = TRUE)
  timestamp_instructions <- tail(df$time_elapsed[df$trial_type == "pgng-comprehension"], 1)
  timestamp_task <- tail(df$time_elapsed[df$trial_type == "pgng-trial"], 1)
  timestamp_end_of_task <- max(df$time_elapsed, na.rm = TRUE)
  
  # Calculate durations
  instructions <- (timestamp_instructions - timestamp_start) / 60000
  task <- (timestamp_task - timestamp_instructions) / 60000
  end_of_task <- (timestamp_end_of_task - timestamp_task) / 60000
  
  # Calculate total time
  total_time <- instructions + task + end_of_task
  
  # Round values to two decimals
  instructions <- round(instructions, 2)
  task <- round(task, 2)
  end_of_task <- round(end_of_task, 2)
  total_time <- round(total_time, 2)
  
  # Add results to the output data frame
  df_time_elapsed <- rbind(df_time_elapsed, data.frame(
    subjID = subjID,
    gng_instructions = instructions,
    gng_task = task,
    gng_end_of_task = end_of_task,
    gng_total_time = total_time,
    stringsAsFactors = FALSE
  ))
}

# Display the result
print(df_time_elapsed)

# Save the data frame in a csv file
# Check it and create the folder if it doesn't exist
folder_path_pilot_anal <- paste0("../../output/session", day, "/")

# Check if the folder exists, and create it if it doesn't
if (!dir.exists(folder_path_pilot_anal)) {
  dir.create(folder_path_pilot_anal)
}

if (!dir.exists(paste0(folder_path_pilot_anal, "gng/"))) {
  dir.create(paste0(folder_path_pilot_anal, "gng/"))
}

# Save the time elapsed data frame to <- a CSV file
write.csv(df_time_elapsed, paste0(folder_path_pilot_anal, "/",exclusion_prefix, "gng_time_elapsed.csv"), row.names = FALSE)

####################### MODELLING INPUT PARAMETERS ##############################

# fetch data for modelling GNG
gonogo_get_data_for_modelling <- function (df){
  
  # preprocessing - extract task data  
  df_task <- df %>%
    filter(block==1 | block==2) %>%
    select(rt, block, trial, stimulus, robot, valence,
           action, sham, correct, choice, accuracy, outcome)
  
  ## create exposure variable; the number of presentations (so far) of a given stimulus.
  df_task <- df_task %>%
    group_by(block, stimulus) %>%
    mutate(exposure = row_number())
  
  ## Replace NA in the 'choice' column with 0
  df_task <- df_task %>%
    mutate(choice = replace_na(choice, 0))
  
  # reduce size of df
  df_task_reduced <- df_task %>%
    select(block, stimulus, choice, outcome, robot) %>%
    mutate(stimulus = as.numeric(stimulus))
  
  # block 1: stimuli are currently 0 to 11, make them 1 to 12
  df_task_block1 <- df_task_reduced %>%
    filter(block == 1) %>%
    mutate(stimulus = stimulus + 1)
  
  # block 2: stimuli are currently 0 to 11 as well, make them 13 to 14
  df_task_block2 <- df_task_reduced %>%
    filter(block == 2) %>%
    mutate(stimulus = stimulus + 13)
  
  # add the blocks together again
  df_task_reduced <- bind_rows(df_task_block1, df_task_block2)
  
  # Transform the column-values in outcome. Should be 0 for "bad" outcome and 1 for "good" outcome
  df_task_reduced <- df_task_reduced %>%
    mutate(outcome = case_when(
      outcome == -1  ~ 1,
      outcome == -10 ~ 0,
      outcome == 1   ~ 0,
      outcome == 10  ~ 1,
      TRUE ~ as.numeric(NA) # This line is optional; it handles unexpected values
    ))
  
  # Transform the column-values in choice. Make it 1 for go and 0 for nogo
  df_task_reduced <- df_task_reduced %>%
    mutate(choice = case_when(
      choice == 0  ~ 1,
      choice == -1 ~ 0,
      TRUE ~ as.numeric(NA) # This line is optional; it handles unexpected values
    ))
  
  # Action vector
  A <- df_task_reduced %>%
    pull(choice)
  
  # Stimulus (state) vector
  S <- df_task_reduced %>%
    pull(stimulus)
  
  # Reward vector
  R <- df_task_reduced %>%
    pull(outcome)
  
  # Condition vector
  C <- df_task_reduced %>%
    pull(robot)
  
  inputs <- list(actions=A, stimuli=S, rewards=R, conditions=C)
  return(inputs)
}

output <- lapply(data_frames, gonogo_get_data_for_modelling)

# Extract vectors from the list and convert to a matrix (participant x trial)
stimulus_matrix <- do.call(rbind, lapply(output, function(x) x$stimuli)) # 24 different robots
action_matrix <- do.call(rbind, lapply(output, function(x) x$action)) # 1 for go, 0 for no-go
reward_matrix <- do.call(rbind, lapply(output, function(x) x$reward)) # 1 for win, 0 loss 
condition_matrix <- do.call(rbind, lapply(output, function(x) x$condition)) # 1: go-win, 2: nogo-win, 3: go-lose, 4: nogo-lose

# Participant (50) x trial (240) matrices.
# 
# A: 1=go, 0=nogo
# R: 1=”good” outcome (+10 or -1), 0 = “bad” outcome (+1 or -10)
# S: values representing the 24 different robots (12 per block)
# C: 1=go-win, 2=nogo-win, 3=go-lose, 4=nogo-lose

# Set row names to NULL to remove them
rownames(stimulus_matrix) <- NULL
rownames(action_matrix) <- NULL
rownames(reward_matrix) <- NULL
rownames(condition_matrix) <- NULL

comp_output_folder <- "comp_modelling/gng/"

# Check if the folder exists, and create it if it doesn't
if (!dir.exists(comp_output_folder)) {
  dir.create(comp_output_folder,recursive = TRUE)
}

# Save the data frames as CSV files in the output folder
s_path <- paste(comp_output_folder,"/",exclusion_prefix, "gonogo_stimulus_matrix.csv", sep="")
a_path <- paste(comp_output_folder,"/",exclusion_prefix, "gonogo_action_matrix.csv", sep="")
r_path <- paste(comp_output_folder,"/",exclusion_prefix, "gonogo_reward_matrix.csv", sep="")
c_path <- paste(comp_output_folder,"/",exclusion_prefix, "gonogo_condition_matrix.csv", sep="")

write.table(stimulus_matrix, s_path , row.names = FALSE, col.names = FALSE, sep=",")
write.table(action_matrix, a_path , row.names = FALSE, col.names = FALSE, sep=",")
write.table(reward_matrix, r_path , row.names = FALSE, col.names = FALSE, sep=",")
write.table(condition_matrix, c_path , row.names = FALSE, col.names = FALSE, sep=",")



############################################################################


# single participant
#data_frames <- data_frames[3]

############## Probability of responding GO! ################################

# Function to calculate the proportion of GO responses for each trial (robot exposure)
calc_propGo_gng <- function(df) {
  
  # The different "robots" (conditions) robot 1 are all go-win robots, etc.
  gowinIndex <- 1
  nogowinIndex <- 2
  goloseIndex <- 3
  nogoloseIndex <- 4
  
  #browser()
  
  # preprocessing - extract task data  
  df_task <- df %>%
    filter(block==1 | block==2) %>%
    select(rt, block, trial, stimulus, robot, valence,
           action, sham, correct, choice, accuracy, outcome)
  
  
  # Preprocessing for the plot
  ## create exposure variable; the number of presentations (so far) of a given stimulus.
  df_task <- df_task %>%
    group_by(block, stimulus) %>%
    mutate(exposure = row_number())
  
  ## Replace NA in the 'choice' column with 0
  df_task <- df_task %>%
    mutate(choice = replace_na(choice, 0))
  
  ## separate conditions
  df_nogowin <- df_task %>%
    filter(robot == nogowinIndex)
  
  df_nogolose <- df_task %>%
    filter(robot == nogoloseIndex)
  
  df_gowin <- df_task %>%
    filter(robot == gowinIndex)
  
  df_golose <- df_task %>%
    filter(robot == goloseIndex)
  
  
  ## Calculate the proportion of 0's in the 'choice' column (GO) for each 'exposure' value
  proportions_nogowin <- df_nogowin %>%
    group_by(exposure) %>%
    summarize(
      total_responses = n(),
      go_responses = sum(choice == 0),
      proportion_go = go_responses / total_responses,
      robot = nogowinIndex
    )
  
  proportions_nogolose <- df_nogolose %>%
    group_by(exposure) %>%
    summarize(
      total_responses = n(),
      go_responses = sum(choice == 0),
      proportion_go = go_responses / total_responses,
      robot = nogoloseIndex
    )
  
  proportions_gowin <- df_gowin %>%
    group_by(exposure) %>%
    summarize(
      total_responses = n(),
      go_responses = sum(choice == 0),
      proportion_go = go_responses / total_responses,
      robot = gowinIndex
    )
  
  proportions_golose <- df_golose %>%
    group_by(exposure) %>%
    summarize(
      total_responses = n(),
      go_responses = sum(choice == 0),
      proportion_go = go_responses / total_responses,
      robot = goloseIndex
    )
  
  subjID <- df$subjID[1] 
  
  # Output to return (a list with the conditions in separate cells atm)
  proportions_go <- rbind(proportions_nogowin, proportions_nogolose, proportions_gowin, proportions_golose)
  proportions_go <- cbind(subjID, proportions_go)
  return(proportions_go)
}

# Calculate the proportion of GO responses in each condition (for each type of robot)
proportions_go <- list()
for(i in 1:length(data_frames)) {
  proportions_go[[i]] <- calc_propGo_gng(data_frames[[i]])
}






## Exclusion criteria
# Calculate the proportion of GO responses for each participant
# prop_go_participant <- lapply(proportions_go, function(df) {
#   # Calculate the average proportion_go for each data frame
#   avg_proportion_go <- mean(df$proportion_go)
#   id <- unique(df$subjID)  # Obtain unique subjID
#   # Return a data frame with avg_proportion_go
#   data.frame(id = id,avg_proportion_go = avg_proportion_go)
# })
# 
# df_prop_go_participant <- do.call(rbind, prop_go_participant)
# df_prop_go_participant <- df_prop_go_participant %>%
#   arrange(desc(avg_proportion_go))

prop_go_participant <- lapply(data_frames, function(df) {
  # Get the choices
  choices <- df$choice
  
  # Replace NA with 0
  choices[is.na(choices)] <- 0
  
  # Total number of choice
  total <- length(choices)
  
  # Number of Go responses
  go <- sum(choices == 0, na.rm = TRUE)
  no_go <- sum(choices == -1, na.rm = TRUE)
  
  # Get the overall proportion
  prop <- go / total
  prop_nogo <- no_go / total
  
  id <- unique(df$subjID)  # Obtain unique subjID
  # Return a data frame with avg_proportion_go
  data.frame(id = id,prop = prop,prop_nogo = prop_nogo)
})

df_prop_go_participant <- do.call(rbind, prop_go_participant)

df_prop_go_excl <- df_prop_go_participant %>%
  arrange(desc(prop)) %>%
  filter(prop > 0.90) %>%
  select(id, prop)

rownames(df_prop_go_excl) <- seq_len(nrow(df_prop_go_excl))

# Exclude participants with a proportion of GO responses greater than 0.9 or NoGo responses greater than 0.9
# prop_go_excluded_participants <- df_prop_go_participant %>%
#   filter(prop >= 0.9 | prop_nogo >= 0.9) %>%  # Filter participants
#   mutate(participant = paste0("output/", id)) %>%  # Add "output/" prefix
#   pull(participant)  # Extract as a vector
# 
# # Append new participants to the existing vector, avoiding duplicates
# excluded_participants <- prop_go_excluded_participants

# df_prop_go_participant <- df_prop_go_participant %>%
#   filter(prop > 0.90)

ggplot(df_prop_go_participant, aes(x = "", y = prop)) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(width = 0.03, size = 2, alpha = 0.5) +  # Add jittered dots
  labs(x = NULL, y = "Average Proportion of GO Responses") +
  ggtitle("Boxplot with the Average Proportion of GO Responses") +
  theme_minimal()

#########
# ggplot(df_prop_go_participant, aes(x = "", y = avg_proportion_go)) +
#   geom_boxplot(outlier.shape = NA) +
#   geom_jitter(width = 0.03, size = 2, alpha = 0.5) +  # Add jittered dots
#   labs(x = NULL, y = "Average Proportion of GO Responses") +
#   ggtitle("Boxplot with the Average Proportion of GO Responses") +
#   theme_minimal()

# Function to calculate average for a given column across all tibbles
average_column <- function(column_name) {
  map(proportions_go, `[[`, column_name) %>%
    reduce(`+`) / length(proportions_go)
}

# Calculate averages for each column
average_proportion_go <- average_column("proportion_go")
average_exposure <- average_column("exposure")
average_robot <- average_column("robot")


proportions_go_averages <- proportions_go[[1]] #use the first tibble as a template
proportions_go_averages$proportion_go <- average_proportion_go
proportions_go_averages$exposure <- average_exposure
proportions_go_averages$robot <- average_robot
# remove the incorrect/irrelevant columns
proportions_go_averages <- proportions_go_averages %>%
  select(-total_responses, -go_responses) # maybe add them up later instead?


# separate conditions - proportions correct avg across participants
proportions_go_averages_gowin <- proportions_go_averages %>%
  filter(robot == 1)

# separate conditions - proportions correct avg across participants
proportions_go_averages_nogowin <- proportions_go_averages %>%
  filter(robot == 2)

# separate conditions - proportions correct avg across participants
proportions_go_averages_golose <- proportions_go_averages %>%
  filter(robot == 3)

# separate conditions - proportions correct avg across participants
proportions_go_averages_nogolose <- proportions_go_averages %>%
  filter(robot == 4)




# PLOT - learning curves

ggplot() + 
  geom_line(data = proportions_go_averages_nogowin, aes(x = exposure, y = proportion_go, color = "NGW"), size=1) +
  geom_line(data = proportions_go_averages_nogolose, aes(x = exposure, y = proportion_go, color = "NGAL"), size=1) +
  geom_line(data = proportions_go_averages_gowin, aes(x = exposure, y = proportion_go, color = "GW"), size=1) +
  geom_line(data = proportions_go_averages_golose, aes(x = exposure, y = proportion_go, color = "GAL"), size=1) +
  geom_hline(yintercept = 0.50, linetype = "solid", color = "grey", size = 0.5) + 
  scale_color_manual(values = c("NGW" = "black", "NGAL" = "red", "GW" = "green", "GAL" = "blue"))  +
  labs(title = "Learning curves averaged across participants", x = "Trial", y = "p(GO)", color = "Condition") +
  scale_x_continuous(breaks = 1:12, limits = c(1, 12)) +
  scale_y_continuous(breaks = seq(from = 0, 
                                  to = 1, 
                                  by = 0.10), limits = c(0,1)) +
  theme(
    panel.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(colour = "black")
  )

#theme(panel.grid.major = element_blank(),
#       panel.grid.minor = element_blank())


#scale_y_continuous(breaks = seq(from = floor(min(prop_corr_df_long$Value)*10) / 10, 
#to = ceiling(max(prop_corr_df_long$Value)*10) /10, 
#by = 0.10)) +


############################# ERROR BARS FOR THE LEARNING CURVES #############

# The different "robots" (conditions) robot 1 are all go-win robots, etc.
gowinIndex <- 1
nogowinIndex <- 2
goloseIndex <- 3
nogoloseIndex <- 4

# Break the big list into one list for each condition
gw <- list()
ngw <- list()
gal <- list()
ngal <- list()
for(i in 1:length(proportions_go)) {
  # go to win
  gw[[i]] <- proportions_go[[i]] %>%
    filter(robot == gowinIndex) %>%
    select(-total_responses, -go_responses)
  
  # no-go to win
  ngw[[i]] <- proportions_go[[i]] %>%
    filter(robot == nogowinIndex) %>%
    select(-total_responses, -go_responses)
  
  # go to avoid lose
  gal[[i]] <- proportions_go[[i]] %>%
    filter(robot == goloseIndex) %>%
    select(-total_responses, -go_responses)
  
  # no-go to avoid lose
  ngal[[i]] <- proportions_go[[i]] %>%
    filter(robot == nogoloseIndex) %>%
    select(-total_responses, -go_responses)
}

# loop over each participant to create a wide data frame
the_df <- data.frame(ngw[[1]]$exposure)
names(the_df) <- "exposure"

# # For go to win
# gw_df <- the_df
# for(i in 1:length(data_frames)) {
#   gw_df[,i+1] <- gw[[i]]$proportion_go
#   names(gw_df)[i+1] <- paste0("subj_", i)
# }
# 
# # For no-go to win
# ngw_df <- the_df
# for(i in 1:length(data_frames)) {
#   ngw_df[,i+1] <- ngw[[i]]$proportion_go
#   names(ngw_df)[i+1] <- paste0("subj_", i)
# }
# 
# # For go to avoid lose
# gal_df <- the_df
# for(i in 1:length(data_frames)) {
#   gal_df[,i+1] <- gal[[i]]$proportion_go
#   names(gal_df)[i+1] <- paste0("subj_", i)
# }
# 
# # For go to avoid lose
# ngal_df <- the_df
# for(i in 1:length(data_frames)) {
#   ngal_df[,i+1] <- ngal[[i]]$proportion_go
#   names(ngal_df)[i+1] <- paste0("subj_", i)
# }

# For go to win
gw_df <- the_df
for(i in 1:length(data_frames)) {
  new_col <- if (nrow(gw[[i]]) < nrow(the_df)) {
    c(gw[[i]]$proportion_go, rep(NA, nrow(the_df) - nrow(gw[[i]])))
  } else {
    gw[[i]]$proportion_go[1:nrow(the_df)]
  }
  gw_df[, i + 1] <- new_col
  names(gw_df)[i + 1] <- paste0("subj_", i)
}

# For no-go to win
ngw_df <- the_df
for(i in 1:length(data_frames)) {
  new_col <- if (nrow(ngw[[i]]) < nrow(the_df)) {
    c(ngw[[i]]$proportion_go, rep(NA, nrow(the_df) - nrow(ngw[[i]])))
  } else {
    ngw[[i]]$proportion_go[1:nrow(the_df)]
  }
  ngw_df[, i + 1] <- new_col
  names(ngw_df)[i + 1] <- paste0("subj_", i)
}

# For go to avoid lose
gal_df <- the_df
for(i in 1:length(data_frames)) {
  new_col <- if (nrow(gal[[i]]) < nrow(the_df)) {
    c(gal[[i]]$proportion_go, rep(NA, nrow(the_df) - nrow(gal[[i]])))
  } else {
    gal[[i]]$proportion_go[1:nrow(the_df)]
  }
  gal_df[, i + 1] <- new_col
  names(gal_df)[i + 1] <- paste0("subj_", i)
}

# For no-go to avoid lose
ngal_df <- the_df
for(i in 1:length(data_frames)) {
  new_col <- if (nrow(ngal[[i]]) < nrow(the_df)) {
    c(ngal[[i]]$proportion_go, rep(NA, nrow(the_df) - nrow(ngal[[i]])))
  } else {
    ngal[[i]]$proportion_go[1:nrow(the_df)]
  }
  ngal_df[, i + 1] <- new_col
  names(ngal_df)[i + 1] <- paste0("subj_", i)
}


# calculate summary stats for error bars
gw_df_mean <- gw_df %>%
  rowwise() %>%
  transmute(exposure = exposure,
            row_mean = mean(c_across(-exposure), na.rm = TRUE),
            row_sd = sd(c_across(-exposure), na.rm = TRUE),
            row_sem = row_sd / sqrt(length(c_across(-exposure))),
            lower = row_mean - 1.96 * row_sem,
            upper = row_mean + 1.96 * row_sem,
            Condition = "GW") %>%
  ungroup()

ngw_df_mean <- ngw_df %>%
  rowwise() %>%
  transmute(exposure = exposure,
            row_mean = mean(c_across(-exposure), na.rm = TRUE),
            row_sd = sd(c_across(-exposure), na.rm = TRUE),
            row_sem = row_sd / sqrt(length(c_across(-exposure))),
            lower = row_mean - 1.96 * row_sem,
            upper = row_mean + 1.96 * row_sem,
            Condition = "NGW") %>%
  ungroup()

gal_df_mean <- gal_df %>%
  rowwise() %>%
  transmute(exposure = exposure,
            row_mean = mean(c_across(-exposure), na.rm = TRUE),
            row_sd = sd(c_across(-exposure), na.rm = TRUE),
            row_sem = row_sd / sqrt(length(c_across(-exposure))),
            lower = row_mean - 1.96 * row_sem,
            upper = row_mean + 1.96 * row_sem,
            Condition = "GAL") %>%
  ungroup()

ngal_df_mean <- ngal_df %>%
  rowwise() %>%
  transmute(exposure = exposure,
            row_mean = mean(c_across(-exposure), na.rm = TRUE),
            row_sd = sd(c_across(-exposure), na.rm = TRUE),
            row_sem = row_sd / sqrt(length(c_across(-exposure))),
            lower = row_mean - 1.96 * row_sem,
            upper = row_mean + 1.96 * row_sem,
            Condition = "NGAL") %>%
  ungroup()

# Combine the 4 tasks into one data frame 
combined_df_mean <- bind_rows(gw_df_mean, ngw_df_mean, gal_df_mean, ngal_df_mean)

########### PLOT WITH ERROR BARS ##############

# Errorbars
combined_df_mean %>%
  ggplot(aes(x = exposure, y = row_mean, group = Condition, color = as.factor(Condition))) +
  geom_line(linewidth=1) + # Add lines
  geom_hline(yintercept = 0.50, linetype = "solid", color = "grey", size = 0.5) + # y intercept at .5
  geom_errorbar(aes(ymin = lower, ymax = upper), width = 0.2) + # Add error bars
  geom_point(size = 3) + # Add dots at each observation
  scale_color_manual(values = c("NGW" = "black", "GW" = "green"))  +
  labs(title = "Learning curves averaged across participants", x = "Trial", y = "p(GO)", color = "Condition") +
  scale_x_continuous(breaks = 1:12, limits = c(0.9, 12.1)) +
  scale_y_continuous(breaks = seq(from = 0, 
                                  to = 1, 
                                  by = 0.10), limits = c(0,1)) +
  theme(
    panel.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(colour = "black")
  )

# Ribbon (shaded area) 95% CI
plot_proportion_go <- combined_df_mean %>%
  ggplot(aes(x = exposure, y = row_mean, group = Condition, color = as.factor(Condition))) +
  geom_line(linewidth=1) + # Add lines
  geom_hline(yintercept = 0.50, linetype = "solid", color = "grey", size = 0.5) + # y intercept at .5
  geom_ribbon(aes(ymin = pmax(lower, 0), ymax = pmin(upper,1), fill = Condition), alpha = 0.2, color = NA) + # ribbon
  geom_point(size = 3) + # Add dots at each observation
  scale_color_manual(values = c("NGW" = "black", "GW" = "green"))  +
  scale_fill_manual(values = c("NGW" = "black", "GW" = "green")) +
  labs(title = "D", x = "Trial", y = "p(GO)", color = "Condition") +
  scale_x_continuous(breaks = 1:12, limits = c(0.9, 12.1)) +
  scale_y_continuous(breaks = seq(from = 0, 
                                  to = 1, 
                                  by = 0.10), limits = c(0,1)) +
  theme(
    panel.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(colour = "black"),
    text = element_text(size = 25),
    axis.text = element_text(size = 19),
    axis.title = element_text(size = 19)
  )
print(plot_proportion_go)

# Save the plot
ggsave(paste0(folder_path_pilot_anal, "/gng/", exclusion_prefix,"proportion_go.jpg"), plot_proportion_go, width = 10, height = 10, dpi = 300)

# Save the plot


############################# Proportion correct ##########################

calc_propCorr_gng <- function(df) {
  #returns the proportions correct responses for each task condition (for a single participant)
  
  # preprocessing - extract task data  
  df_task <- df %>%
    filter(block==1 | block==2) %>%
    select(rt, block, trial, stimulus, robot, valence,
           action, sham, correct, choice, accuracy, outcome)
  
  # Overall proportion correct across all conditions
  overall <- mean(df_task$accuracy)
  
  # go to win condition
  gowin_cond <- df_task %>%
    filter(valence == 'win' & action == 'go')
  
  # overall prop correct
  prop_correct_gowin <- mean(gowin_cond$accuracy)
  
  # nogo to win condition
  nogowin_cond <- df_task %>%
    filter(valence == 'win' & action == 'no-go')
  
  # overall prop correct
  prop_correct_nogowin <- mean(nogowin_cond$accuracy)
  
  # go to avoid loss condition
  golose_cond <- df_task %>%
    filter(valence == 'lose' & action == 'go')
  
  # overall prop correct
  prop_correct_golose <- mean(golose_cond$accuracy)
  
  # no-go to avoid loss condition
  nogolose_cond <- df_task %>%
    filter(valence == 'lose' & action == 'no-go')
  
  # overall prop correct
  prop_correct_nogolose <- mean(nogolose_cond$accuracy)
  
  # Add id
  id <- df$subjID[1]
  
  # put them all in one df
  df_prop_corr <- data.frame(
    id = id,
    Overall = overall,
    GW=prop_correct_gowin, 
    NGW=prop_correct_nogowin, 
    GAL=prop_correct_golose, 
    NGAL=prop_correct_nogolose
    )
  
  return(df_prop_corr)
}

# calculate proportion correct in each condition for all participants
prop_corr <- list()
for (i in 1:length(data_frames)) {
  prop_corr[[i]] <- calc_propCorr_gng(data_frames[[i]])
}

# turn the list into a dataframe more suitable for plotting 
vec <- numeric(length(data_frames))
prop_corr_df <- data.frame(id = vec,Overall = vec,GW=vec, NGW=vec, GAL=vec,NGAL=vec)#placement df
for (i in 1:length(data_frames)) {
  prop_corr_df[i, ] <- prop_corr[[i]] # 1 row per participant
}

prop_corr_excl_df <- prop_corr_df %>%
  arrange(Overall) %>%
  select(id, Overall) %>%
  filter(Overall < 0.55)

# prop_corr_excluded_participants <- prop_corr_df %>%
#   filter(GW <= 0.55) %>%  # Filter participants
#   mutate(participant = paste0("output/", id)) %>%  # Add "output/" prefix
#   pull(participant)  # Extract as a vector

excluded_participants <- unique(c(df_prop_go_excl$id, prop_corr_excl_df$id))

included_participants <- setdiff(prop_corr_df$id, excluded_participants)



# Save the excluded participants to a CSV file
write.csv(excluded_participants, paste0(folder_path_pilot_anal, "gng/excluded_participants.csv"), row.names = FALSE)

# Load the prop_corr_df from day 1
#prop_corr_df_day1 <-  read.csv("../../analysis/modelling_battery/pilot_retest/gng_prop_corr_df_day1.csv",row.names = 1)

# Save for later - behavioral measures
behavioral_measures_1 <- prop_corr_df


# Convert the dataframe to long format using tidyr
prop_corr_df_long <- prop_corr_df[-1] %>%
  pivot_longer(everything(), names_to = "Condition", values_to = "Value")

# Create the violin plot
# ggplot(prop_corr_df_long, aes(x = Condition, y = Value, fill = Condition)) +
#   geom_violin() +
#   labs(x = "Condition", y = "Proportion correct") +
#   theme_minimal()

# Create the strip plot (dot plot)
# ggplot(prop_corr_df_long, aes(x = Condition, y = Value, color = Condition)) +
#   geom_jitter(width = 0.2, height = 0, size = 3) +
#   labs(x = "Condition", y = "Proportion correct") +
#   theme_minimal()

# Creating the box and whisker plot with individual observations
plot_prop_cor <-  ggplot(prop_corr_df_long, aes(x = Condition, y = Value)) +
  geom_boxplot(outlier.shape = NA) + # supress the outlier, or it will look like there are extra observations
  #theme_base() + 
  guides(color = "none")  + # This line removes the color legend
  geom_jitter(aes(color = Condition), width = 0.1, height = 0, alpha = 0.5, size=2) + # change the width to change the jitter (or set to 0 to have no jitter)
  labs(x = "Condition", y = "Proportion correct", title = "Proportion Correct Responses") +
  scale_y_continuous(breaks = seq(from = 0, 
                                  to = 1, 
                                  by = 0.10), limits = c(0,1)) +
  theme(
    panel.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(colour = "black")
  )

print(plot_prop_cor)

# Save the plot
ggsave(paste0(folder_path_pilot_anal, "/gng/", exclusion_prefix,"prop_corr.jpg"), plot_prop_cor, width = 10, height = 6, dpi = 300)

##### RT Analysis #####

extract_reaction_times <- function(df) {
  #browser()
  
  # Extract and preprocess task data
  df_task <- df %>%
    filter(block == 1 | block == 2) %>%
    select(subjID,rt, block, trial, stimulus, robot, valence,
           action, sham, correct, choice, accuracy, outcome)
  
  df_reaction_times <- df_task %>%
    select(subjID,trial, block, rt, accuracy) %>%
    filter(rt > 0) %>%
    mutate(rt_log = log(as.numeric(rt)))
  
  
  return(df_reaction_times)

}

output_rt <- lapply(data_frames, extract_reaction_times)

### Run the regression to get an individual effect of RT on accuracy for each participant

# Function to run regression per participant
run_regression_per_subject <- function(df) {
  
  df$accuracy <- ifelse(df$accuracy == TRUE, 1, 0)
  
  # Run the regression only if there are enough valid trials
  if (nrow(df) > 1) {
    model <- lm(rt_log ~ accuracy, data = df)
    
    
    
    #browser()
    
    result <- tidy(model) %>%
      select(term, estimate) %>%
      pivot_wider(names_from = term, values_from = estimate) %>%
      mutate(subjID = unique(df$subjID))
  } else {
    # Return NA if not enough trials for regression
    result <- tibble(subjID = unique(df$subjID), `(Intercept)` = NA, accuracy = NA)
  }
  
  return(result)
}

# Apply function to each participant's dataset
beta_coefficients <- bind_rows(lapply(output_rt, run_regression_per_subject))

print(beta_coefficients)

# Plot the beta coefficients as boxplots
beta_coefficients_long <- pivot_longer(beta_coefficients, cols = c(accuracy), names_to = "Variable", values_to = "Beta")

ggplot(beta_coefficients_long, aes(x = Variable, y = Beta)) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(aes(color = Variable), width = 0.1, height = 0, alpha = 0.7) +
  labs(title = "Beta Coefficients of RT on Accuracy",
       x = "Variable",
       y = "Beta Coefficient") +
  theme_minimal()

# Check if the betas are significantly different from 0
t.test(beta_coefficients$accuracy)

# Convert the list of data frames to a single data frame
output_rt_df <- bind_rows(output_rt, .id = "source")

# Compute the average rt_log for each participant
rt_avg_df <- output_rt_df %>%
  group_by(subjID) %>%
  summarise(rt_log = mean(rt_log, na.rm = TRUE))

# Rename 'participant' to 'subjID' in participant_avg_df
prop_corr_df_temp <- prop_corr_df %>%
  rename(subjID = id)

# Correlate the RT with the acceptance rate
rt_prop_df <- prop_corr_df_temp %>%
  left_join(rt_avg_df, by = "subjID")

# Plot the correlation and calculate the correlation
ggplot(rt_prop_df, aes(x = rt_log, y = Overall)) +
  geom_point() +
  geom_smooth(method = "lm", se = TRUE, color = "blue") +
  labs(title = "Scatter Plot of RT vs. Prop correct",
       x = "RT (log-transformed)",
       y = "Prop correct") +
  theme_minimal()

# Calculate the correlation
cor.test(rt_prop_df$rt_log, rt_prop_df$Overall)

# Save beta coefficients to a CSV file
beta_coefficients <- beta_coefficients %>%
  select(subjID, accuracy)  # Select only relevant columns

write.csv(beta_coefficients, file = paste0(folder_path_pilot_anal, "GNG/", exclusion_prefix,"gng_betas_day_",day,".csv"), row.names = FALSE)



####################### Prop correct by exposure ############################

calc_propCorr_by_exposure <- function(df) {
  #browser()
  # Extract and preprocess task data
  df_task <- df %>%
    filter(block == 1 | block == 2) %>%
    select(rt, block, trial, stimulus, robot, valence,
           action, sham, correct, choice, accuracy, outcome)
  
  # Create the exposure variable: the number of presentations (so far) of a given stimulus
  df_task <- df_task %>%
    group_by(block, stimulus) %>%
    mutate(exposure = row_number())
  
  # Calculate the proportion correct for each exposure value
  proportions_correct <- df_task %>%
    group_by(block, stimulus, exposure, valence, action) %>%
    summarize(
      total_trials = n(),
      correct_trials = sum(accuracy, na.rm = TRUE),
      proportion_correct = correct_trials / total_trials,
      .groups = 'drop'
    ) %>%
    ungroup()
  
  # Add subject ID for tracking
  subjID <- df$subjID[1]
  proportions_correct <- proportions_correct %>%
    mutate(subjID = subjID)
  
  return(proportions_correct)
}

# Apply the function to all participants' data
prop_corr_by_exposure <- lapply(data_frames, calc_propCorr_by_exposure)

# Combine the results into a single data frame for analysis
prop_corr_by_exposure_df <- do.call(rbind, prop_corr_by_exposure)

# Summarize the data to get average proportions per exposure, condition, and stimulus
summary_prop_corr <- prop_corr_by_exposure_df %>%
  group_by(exposure, action) %>%
  summarize(
    avg_proportion_correct = mean(proportion_correct, na.rm = TRUE),
    se_proportion_correct = sd(proportion_correct, na.rm = TRUE) / sqrt(n()),
    total_stimuli = n_distinct(stimulus),
    .groups = 'drop'
  )

# summary_prop_corr <- summary_prop_corr %>%
#   filter(block == 2)

# Plot the data
plot_prop_corr_stim_exp <-  ggplot(summary_prop_corr, aes(x = exposure, y = avg_proportion_correct, color = action, group = action)) +
  geom_line(size = 1) +
  geom_hline(yintercept = 0.50, linetype = "solid", color = "grey", size = 0.5) + # y intercept at .5
  geom_ribbon(aes(ymin = avg_proportion_correct - se_proportion_correct, 
                  ymax = avg_proportion_correct + se_proportion_correct, 
                  fill = action), 
              alpha = 0.2, 
              color = NA) +
  labs(title = "D",
       x = "Stimulus Exposure",
       y = "Proportion Correct",
       color = "Action",
       fill = "Action") +
  theme(
    panel.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(colour = "black"),
    text = element_text(size = 25),
    axis.text = element_text(size = 19),
    axis.title = element_text(size = 19)
    
  ) +
  scale_y_continuous(breaks = seq(from = 0, 
                                  to = 1, 
                                  by = 0.10), limits = c(0,1)) +
  scale_x_continuous(breaks = seq(min(summary_prop_corr$exposure), max(summary_prop_corr$exposure), by = 1))

print(plot_prop_corr_stim_exp)

# Save the plot
ggsave(paste0(folder_path_pilot_anal, "/gng/", exclusion_prefix,"prop_corr_stim_exp.jpg"), plot_prop_corr_stim_exp, width = 10, height = 10, dpi = 300)

###################################### PERFORMANCE MEASURES #############################

calc_performance_gng <- function(df) {
  # preprocessing - extract task data
  df_task <- df %>%
    filter(block==1 | block==2) %>%
    select(rt, block, trial, stimulus, robot, valence,
           action, sham, correct, choice, accuracy, outcome)
  
  # Preprocessing for the plot
  ## create exposure variable; the number of presentations (so far) of a given stimulus.
  df_task <- df_task %>%
    group_by(block, stimulus) %>%
    mutate(exposure = row_number())
  
  ## create exposure variable; the number of presentations (so far) of a given stimulus.
  df_task <- df_task %>%
    group_by(block, stimulus) %>%
    mutate(exposure = row_number())
  
  ##### Performance measure 1: overall proportion correct responses (mean accuracy)
  prop_correct <- mean(df_task$accuracy)
  
  ##### Performance measure 2: Go bias - 
  # the difference between (proportions correct responses during GO) and (proportions correct responses during NOGO)
  go_responses <- df_task %>%
    filter(action=='go')
  prop_corr_go <- mean(go_responses$accuracy)
  
  nogo_responses <- df_task %>%
    filter(action=='no-go')
  prop_corr_nogo <- mean(nogo_responses$accuracy)
  
  go_bias <- prop_corr_go - prop_corr_nogo
  
  ##### Performance measure 3: outcome bias (aka valence bias) - 
  # the difference between (proportion correct in rewarding conditions (positive valence)) and (proportion correct in punishing conditions (negative valence))
  rewarding_responses <- df_task %>%
    filter(valence=='win')
  
  prop_corr_win <- mean(rewarding_responses$accuracy)
  
  punishing_responses <- df_task %>%
    filter(valence=='lose')
  
  prop_corr_lose <- mean(punishing_responses$accuracy)
  
  outcome_bias <- prop_corr_win - prop_corr_lose
  
  ##### Performance measure 4: Pavlovian bias - 
  # the difference between (proportion correct in Pavlovian congruent conditions (go-win, nogo-avoid lose))
  go_congruent <- df_task %>%
    filter(action == 'go' & valence == 'win')
  
  prop_corr_go_congruent <- mean(go_congruent$accuracy)
  
  nogo_congruent <- df_task %>%
    filter(action == 'no-go' & valence == 'lose')
  
  prop_corr_nogo_congruent <- mean(nogo_congruent$accuracy)
  
  pavlovian_bias <- prop_corr_go_congruent - prop_corr_nogo_congruent
  
  ##### Performance measure 5: Feedback sensitivity - 
  # (proportion correct in trials following veridical reinforcement) vs. (proportion correct in trials following sham reinforcement)
  
  #divide into block since the stimuli are named the same for both blocks
  df_task_1 <- df_task %>%
    filter(block == '1')
  
  # reorder based on stimulus and exposure
  df_task_1 <- df_task_1 %>%
    arrange(stimulus, exposure)
  
  # Create the previous_sham column
  df_task_1 <- df_task_1 %>%
    group_by(stimulus) %>%
    mutate(previous_sham = lag(sham, default = NA))
  
  # Calculate the proportion of 1s in accuracy when previous_sham is 1
  accuracy_following_sham_block1 <- df_task_1  %>%
    filter(previous_sham == 1) %>% # filter and get trials where the previous robot was sham
    pull(accuracy)
  
  
  
  df_task_2 <- df_task %>%
    filter(block == '2')
  
  df_task_2 <- df_task_2 %>%
    arrange(stimulus, exposure)
  
  # Create the previous_sham column
  df_task_2 <- df_task_2 %>%
    group_by(stimulus) %>%
    mutate(previous_sham = lag(sham, default = NA))
  
  # Calculate the proportion of 1s in accuracy when previous_sham is 1
  accuracy_following_sham_block2 <- df_task_2  %>%
    filter(previous_sham == 1) %>% # filter and get trials where the previous robot was sham
    pull(accuracy)
  
  
  accuracy_following_sham <- c(accuracy_following_sham_block1, accuracy_following_sham_block2)
  prop_corr_sham <- mean(accuracy_following_sham)
  
  # Calculate the proportion of 1s in accuracy when previous_sham is 0
  accuracy_following_veridical_block1 <- df_task_1  %>%
    filter(previous_sham == 0) %>% # filter and get trials where the previous robot was sham
    pull(accuracy)
  
  accuracy_following_veridical_block2 <- df_task_2  %>%
    filter(previous_sham == 0) %>% # filter and get trials where the previous robot was sham
    pull(accuracy)
  
  accuracy_following_veridical <- c(accuracy_following_veridical_block1, accuracy_following_veridical_block2)
  prop_corr_veridical <- mean(accuracy_following_veridical)
  
  # Calculate the feedback sensitivity as the difference between the proportions
  feedback_sensitivity <- prop_corr_veridical - prop_corr_sham
  
  # put the performance measures in one df
  df_performance <- data.frame(
    prop_correct=prop_correct, 
    go_bias=go_bias, 
    outcome_bias=outcome_bias, 
    pavlovian_bias=pavlovian_bias,
    feedback_sensitivity=feedback_sensitivity
  )
  
  return(df_performance)
}


# Data frame with performance measures for each participant (each row)
# turn the list into a dataframe more suitable for plotting 
vec <- numeric(length(data_frames))
performance_df <- data.frame(#placement df
  prop_correct=vec, 
  go_bias=vec, 
  outcome_bias=vec,
  pavlovian_bias=vec,
  feedback_sensitivity=vec
  )

for (i in 1:length(data_frames)) {
  performance_df[i, ] <- calc_performance_gng(data_frames[[i]]) # 1 row per participant
}

# PLOT

# Convert the dataframe to long format using tidyr
performance_df_long <- performance_df %>%
  pivot_longer(everything(), names_to = "Performance_measure", values_to = "Value")

# reorder factors to get them in the order I want when plotting
performance_df_long$Performance_measure <- factor(performance_df_long$Performance_measure, levels = c("prop_correct", "go_bias", "outcome_bias", "pavlovian_bias", "feedback_sensitivity"))


# Creating the box and whisker plot with individual observations
plot_perf_measures <-  ggplot(performance_df_long, aes(x = Performance_measure, y = Value)) +
  geom_boxplot(outlier.shape = NA) + # supress the outlier, or it will look like there are extra observations
  #theme_base() + 
  guides(color = "none")  + # This line removes the color legend
  geom_jitter(aes(color = Performance_measure), width = 0.1, height = 0, alpha = 0.5, size=2) + # change the width to change the jitter (or set to 0 to have no jitter)
  labs(x = "Behavior", y = "Count", title = "Performance Measures") +
  scale_x_discrete(labels = c("Proportion correct", "Go bias", "Outcome bias", "Pavlovian bias", "Feedback sensitivity")) +
  scale_y_continuous(breaks = seq(from = floor(min(performance_df, na.rm = TRUE)*10) / 10,
                                  to = ceiling(max(performance_df, na.rm = TRUE)*10) / 10,
                                  by = 0.10),
                     labels = scales::number_format(scale = 1, accuracy = 0.1)) +
  theme(
    panel.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(colour = "black")
  )
print(plot_perf_measures)

# Save the plot
ggsave(paste0(folder_path_pilot_anal, "/gng/", exclusion_prefix,"perf_measures.jpg"), plot_perf_measures, width = 10, height = 6, dpi = 300)


# catch trials
catch_trial_fun <- function(df) {
  df_catch <- df %>% 
    filter(task == 'catch_trial') %>%
    select(subjID, rt, task, response, correct)
  return(df_catch)
}

df_catch <- lapply(data_frames, catch_trial_fun)
#print(df_catch) # for initial inspection of single participants

# Make sure all elements have the same column types
df_catch_all <- map(df_catch, ~ .x %>%
                        mutate(             # make rt numeric
                          correct = as.character(correct)     # force correct to character
                        )
)

df_catch_all <- bind_rows(df_catch_all, .id = "source")

write.csv(df_catch_all, paste0(folder_path_pilot_anal,'gng_catch_trials.csv' )) 


########################### ANOVA ############################
# 2 x 2 ANOVA
# DV: Proportion GO
# IV: valence (win/lose) and action (go/no-go)


anova_preprocessing <- function(df) {
# preprocessing - extract task data
df_task <- df %>%
  filter(block==1 | block==2) %>%
  select(rt, block, trial, stimulus, robot, valence,
         action, sham, correct, choice, accuracy, outcome)

# get variables
df_task <- df_task %>%
  mutate(go = ifelse(is.na(choice), 1, ifelse(choice == -1, 0, NA)))

# Get conditions and proportion GO
go_win <- df_task %>%
  filter(action == 'go' & valence == 'win')
go_win_prop <- mean(go_win$go)  

go_lose <- df_task %>%
  filter(action == 'go' & valence == 'lose')
go_lose_prop <- mean(go_lose$go)  

nogo_win <- df_task %>%
  filter(action == 'no-go' & valence == 'win')
nogo_win_prop <- mean(nogo_win$go)  

nogo_lose <- df_task %>%
  filter(action == 'no-go' & valence == 'lose')
nogo_lose_prop <- mean(nogo_lose$go)  


subjid <- df$subjID[1]
prop_go_anova <- data.frame(go_win_prop=go_win_prop,
                            go_lose_prop=go_lose_prop,
                            nogo_win_prop=nogo_win_prop,
                            nogo_lose_prop=nogo_lose_prop,
                            subjID=subjid)
return(prop_go_anova)
}

# initialize
# Create an empty data frame with 50 rows and 4 columns
participant_num <- length(data_frames)

anova_data <- data.frame(go_win = rep(NA,participant_num),
                         go_lose = rep(NA,participant_num),
                         nogo_win=rep(NA,participant_num),
                         nogo_lose=rep(NA,participant_num),
                         subjID=rep(NA,participant_num))
# Get data for ANOVA for each participant
for(i in 1:length(data_frames)) {
  anova_data[i,] <- anova_preprocessing(data_frames[[i]])
}

## Perform the ANOVA ##

# Reshape data into long format
anova_data_long <- pivot_longer(
  anova_data,
  cols = c(go_win, nogo_win),
  names_to = "condition",
  values_to = "prop_go"
)

# create two factors for repeated measures 2x2 anova
anova_data_long <- anova_data_long %>%
  mutate(
    action = ifelse(condition %in% c("go_win"), "go", "no-go"),
    valence = ifelse(condition %in% c("go_lose"), "lose", "win")
  )

# Run the 2x2 repeated measures ANOVA
anova_results <- ezANOVA(
  data = anova_data_long,
  dv = .(prop_go),            # Dependent variable
  wid = .(subjID),            # Subject ID as a within-subjects identifier
  within = .(action), # Within-subject factors
  type = 3,                   # Type 3 sums of squares
  detailed = TRUE             # Request detailed output
)

# Run t test comparing prop_go in go_win and nogo_win
t_test_results <- t.test(anova_data$go_win, anova_data$nogo_win, paired = TRUE)

# Print the summary of the ANOVA
print(anova_results)

# Fast plot
ggplot(anova_data_long, aes(x=action, y=prop_go, fill=valence)) +
  geom_bar(stat="summary", fun="mean", position=position_dodge(), color="black") +
  labs(x="Action", y="Mean of prop_go", title="Mean prop_go by Action and Valence") +
  theme_minimal() +
  geom_errorbar(aes(ymin=..y.., ymax=..y..), stat="summary", fun.data=mean_se, position=position_dodge(.9), width=0.25) +
  scale_fill_manual(values=c("Win"="steelblue", "Lose"="red")) +
  theme(text = element_text(size=12))

# table
gng_anova_table <- nice_table(anova_results$ANOVA,title = c("Table 3","Go/No-Go Anova Results"))
#print(gng_anova_table, preview = "docx")


## Logistic regression performance for the paper ##
# Perform a logistic regression on correct based on action (go vs no-go) and exposure (learning)
# Reorder the levels of 'action' to set 'go' as the reference level
prop_corr_by_exposure_df_go_ref <- prop_corr_by_exposure_df

prop_corr_by_exposure_df_go_ref$action <- factor(
  prop_corr_by_exposure_df_go_ref$action,
  levels = c("no-go","go")
)

prop_corr_regression <- glmer(
  (correct_trials) ~ action * exposure + (1 | subjID),
  data = prop_corr_by_exposure_df_go_ref,
  family = binomial(link = "logit")
)

summary(prop_corr_regression)

########################### Debriefing ################################

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
output_debrief <- lapply(data_frames, debriefing_current_task, 'gonogo')

# Convert each sublist to a dataframe with only the second value
output_debrief_df <- lapply(output_debrief, function(x) {
  as.data.frame(lapply(x, function(y) y[2]))
})

# Combine all dataframes into one
output_debrief_df <- do.call(rbind, output_debrief_df)

# Save the debriefing df
write.csv(output_debrief_df, paste0("../../output/session",day,"/gng/debrief.csv"),row.names = FALSE)

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



  
# # Check out the rune_set (elianto or bacs1 or bacs2)
rune_set_fun <-  function(df) {
  rune_set <- df %>%
    select(subjID, rune_set) %>%
    filter(complete.cases(.)) %>%
    slice(30)
}
rune_set_df <- lapply(data_frames, rune_set_fun)
rune_set_df <- do.call(rbind, rune_set_df)

# Filter Rune_set_df only of included_participants
rune_set_df_included <- rune_set_df %>%
  filter(subjID %in% included_participants)

# Create the JS-style lines
js_lines <- rune_set_df_included %>%
  mutate(js_format = paste0("'", subjID, "': ['", rune_set, "'],"))

# Print or write them
cat(js_lines$js_format, sep = "\n")

# Save the rune set to the pilot dir
if (day == 0) {
  write.csv(rune_set_df_included, file = paste0(folder_path_pilot_anal, "gng/", "rune_set.csv"), row.names = FALSE)
} else {
  write.csv(rune_set_df, file = paste0(folder_path_pilot_anal, "gng/", "rune_set.csv"), row.names = FALSE)
}


# Compare the performance based on the runes used
rune_prop_df <- left_join(rt_prop_df, rune_set_df, by = "subjID")
anova_result <- aov(Overall ~ rune_set, data = rune_prop_df)
summary(anova_result)

# Plot the performance with mean as a dot
ggplot(rune_prop_df, aes(x = rune_set, y = Overall)) +
  geom_boxplot() +
  stat_summary(fun = mean, geom = "point", color = "red", size = 3) +
  labs(title = "Overall Performance by Rune Set",
       x = "Rune Set", y = "Overall Score")

# rune_prop_df1 <- read.csv("../session1/rune_prop_df_day1.csv")
# 
# # Merge df1 and df2
# rune_prop_both_days <- merge(
#   rune_prop_df1,
#   rune_prop_df2,
#   by="subjID"
# )
# 
# rune_prop_both_days <- rune_prop_both_days %>%
#   select(subjID,rune_set.x, rune_set.y,Overall.x,Overall.y)

# write.csv(rune_prop_both_days, "rune_prop_both_days.csv")

rune_prop_both_days <- read.csv("../session2/rune_prop_both_days.csv")

# 1. Reshape to long format: one row per subject per session
runes_long <- rune_prop_both_days %>%
  pivot_longer(
    cols = c(rune_set.x, rune_set.y, Overall.x, Overall.y),
    names_to = c(".value", "session"),
    names_sep = "\\."
  ) %>%
  mutate(session = factor(session, levels = c("x", "y"))) %>%
  arrange(subjID, session)

head(runes_long)
# Each row: subjID, session, rune_set, Overall (accuracy proportion)

# 2. Fit the mixed model
# Overall proportion as outcome, rune_set as fixed effect,
# random intercept per subject
m1 <- lmer(Overall ~ rune_set + (1 | subjID), data = runes_long)
summary(m1)