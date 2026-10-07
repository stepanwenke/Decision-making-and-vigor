library(tidyverse)

# load necessary functions
# Get the directory where the R script file is located
script_dir <- rstudioapi::getActiveDocumentContext()$path
if (getwd() != script_dir) {
  setwd(dirname(script_dir))
} else {
  message("The script_dir is the same as the current working directory.")
}

day <- 1

# Set the working directory to the data folder
setwd(paste0("../data/session", day))


# Load utility functions
source("../../analysis/helpers/load_data_all_participants.R")
source("../../analysis/helpers/parse_data.R")
source("../../analysis/helpers/rlwm_prop_corr_per_stim_iter.R")

# soft-coded variables
output_folder <- "output/"
createSubjectFiles <- TRUE # whether or not to create the single task files.
# output_folder <- "../../analysis/data/output" # relative path to where the parsed data will end up
folder_path <- getwd()
#folder_path <- paste(folder_path, '/25-1', sep = "")#temp

# columns of the data file that need to be converted into the correct data type when read into R
column_types <- list(
  parsing = col_character(),
  robot = col_double(),
  choice = col_double(),
  rune = col_character(),
  rune_set = col_character(),
  trial = col_double(),
  valence = col_character(),
  action = col_character(),
  outcome = col_character(),
  exp_order = col_character(),
  setsize = col_number(),
  stimulus_type = col_character(),
  block_num = col_double(),
  galaxy_type = col_double(),
  alien = col_number(),
  n_presses = col_number(),
  time_in_block = col_number(),
  trial_number = col_number(),
  total_time  = col_number(),
  total_credits = col_number(),
  physical_credits = col_number(),
  button_order = col_number(),
  button_order = col_number(),
  trial_number = col_number(),
  effort_level = col_number(),
  effort_credits = col_number(),
  effort_type = col_character(),
  required_presses = col_number(),
  chosen_task = col_character(),
  reward_received = col_number(),
  training = col_logical(),
  subjID = col_character()
) # to correctly load these columns

# Load the data
df_all <- load_data_all_participants(folder_path, col_types = column_types)

# Parse the data

## Function to generate the participantID sequence
# generate_sequence <- function(n) {
#   # Use sprintf to format the numbers with leading zeros, then paste 's' in front
#   paste0("s", sprintf("%03d", 1:n))
# }

# Get participant IDs
## Generate sequence up to the number of participants
num_participants <- length(df_all)
# participantID <- generate_sequence(num_participants)
participantID <- character()
for (i in 1:num_participants) {
  participantID[i] <- df_all[[i]][["subjID"]][1]
}


## Parse data (if createSubjectFiles is true -> creates sub folders for each participant, containing the data of each task. Otherwise just create df's for individual tasks)
df_per_task <- list()
for (i in 1:num_participants) {
  df_per_task[[i]] <- parse_data(df_all[[i]],
                                 participantID[i],
                                 output_folder,
                                 createSubjectFiles,
                                 day) # parse data
}

# load individual task data of all participants (participant 1 here)
# df_single_participant <- parse_data(df_all[[1]], participantID[1], output_folder, createSubjectFiles) # parse data
