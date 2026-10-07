parse_data <- function(dataFrame, participantID, output_folder, createSubjectFiles = TRUE, day) {
# For now the function requires participant ID. Hopefully it can extract it automatically later.
  
#requires Tidyverse
  
createFolder <- createSubjectFiles
# vector or scalar
#dataPath <- "data/decision-battery_JSPSYCH-V1_SESSION_2023-11-16_15h48.23.774.csv"
#dataPath <- "data/decision-battery_JSPSYCH-V1_SESSION_2023-11-20_16h48.05.582.csv"
#dataPath <- "data/decision-battery_JSPSYCH-V1_SESSION_2023-11-22_14h04.44.3.csv"  


#Tibble (default, for tidyverse)
df <- dataFrame
#add row number
df <- df %>%
  mutate(row_number = row_number())


# Pars separate tasks and save into separate csv files

## Go/No-GO
  gng_start_index <- df %>%
    filter(parsing == "start_gonogo") %>%
    pull(row_number)
  
  gng_end_index <- df %>%
    filter(parsing == "end_gonogo") %>%
    pull(row_number)
  
  gng_df <- df %>%
    slice(gng_start_index:gng_end_index)

if (day != 0) {
  
  ## RLWM
  
  rlwm_start_index <- df %>%
    filter(parsing == "start_rlwm") %>%
    pull(row_number)
  
  rlwm_end_index <- df %>%
    filter(parsing == "end_rlwm") %>%
    pull(row_number)
  
  rlwm_df <- df %>%
    slice(rlwm_start_index:rlwm_end_index)
  
  ## Foraging
  
  foraging_start_index <- df %>%
    filter(parsing == "start_foraging") %>%
    pull(row_number)
  
  foraging_end_index <- df %>%
    filter(parsing == "end_foraging") %>%
    pull(row_number)
  
  foraging_df <- df %>%
    slice(foraging_start_index:foraging_end_index)



## Effort

effort_start_index <- df %>%
  filter(parsing == "start_effort") %>%
  pull(row_number)

effort_end_index <- df %>%
  filter(parsing == "end_effort") %>%
  pull(row_number)

effort_df <- df %>%
  slice(effort_start_index:effort_end_index)

}

## General instructions - contains experiment order

genIn_start_index <- df %>%
  filter(parsing == "start_genIn") %>%
  pull(row_number)

genIn_end_index <- df %>%
  filter(parsing == "end_genIn") %>%
  pull(row_number)

genIn_df <- df %>%
  slice(genIn_start_index:genIn_end_index)

## break trial and final trial

final_trial <- df %>%
  filter(task == "final_trial")

if (day != 0) {
  break_trial <- df %>%
    filter(task == "bathroom_break")

  ami_trial <- df %>%
    filter(task == "AMI")
  
  # panas_trial <- df %>%
  #   filter(task == "PANAS")
  
  asrm_trial <- df %>%
    filter(task == "ASRM")
  
  cesd_trial <- df %>%
    filter(task == "CESD")
  
  
  shps_trial <- df %>%
    filter(task == "SHPS")
  
  bis_bas_trial <- df %>%
    filter(task == "BIS_BAS")
  
  pss_trial <- df %>%
    filter(task == "PSS")
}

feedback_trial <- df %>%
  filter(task == 'final_feedback')

## Combine non-task trials 
if (day == 0) {
  non_exp_df <- rbind(genIn_df, final_trial, feedback_trial)
} else {
  non_exp_df <- rbind(genIn_df, ami_trial, asrm_trial, cesd_trial, shps_trial, bis_bas_trial, pss_trial, break_trial, final_trial, feedback_trial)
}


  
if(createFolder == TRUE) {

  # Create output folder if it doesn't exist
  # output_folder <- "data/output"
  if (!dir.exists(output_folder)) {
    # If the folder doesn't exist, create it
    dir.create(output_folder)
    cat("Folder created:", output_folder, "\n")
  } else {
    cat("Folder already exists:", output_folder, "\n")
  }
  
  # Create participant folder
  participant_folder <- paste(output_folder, "/", participantID, sep="")
  if (!dir.exists(participant_folder)) {
    # If the folder doesn't exist, create it
    dir.create(participant_folder)
    cat("Folder created:", participant_folder, "\n")
  } else {
    cat("Folder already exists:", participant_folder, "\n")
  }
  
  gonogo_output_dir <- paste(participant_folder, "/gonogo_data.csv", sep="")
  non_task_output_dir <- paste(participant_folder, "/non-task_data.csv", sep="")
  
  if (day != 0) {
    rlwm_output_dir <- paste(participant_folder, "/rlwm_data.csv", sep="")
    effort_output_dir <- paste(participant_folder, "/effort_data.csv", sep="")
    foraging_output_dir <- paste(participant_folder, "/foraging_data.csv", sep="")
  }
  
  # Output to csv files (break and final trial too? Add somewhere?)
  write.csv(gng_df, file = gonogo_output_dir, row.names = FALSE)
  write.csv(non_exp_df, file = non_task_output_dir, row.names = FALSE)
  
  if (day != 0) {
    write.csv(effort_df, file = effort_output_dir, row.names = FALSE)
    write.csv(rlwm_df, file = rlwm_output_dir, row.names = FALSE)
    write.csv(foraging_df, file = foraging_output_dir, row.names = FALSE)
  }

}

# Store data frames in a list
if (day == 1 || day == 2) {
  list_of_data_frames <- list(gng_df, rlwm_df, foraging_df, effort_df, genIn_df)
} else if (day == 0) {
  list_of_data_frames <- list(gng_df, genIn_df)
} else {
  list_of_data_frames <- list(gng_df, effort_df, genIn_df)
}

return(list_of_data_frames)

}




