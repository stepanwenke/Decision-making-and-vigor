# check out non-experimental things, such as task order.

#libraries
library(tidyverse) # tidy functions (including readr)
library(jsonlite) # to parse the JSON objects

# set wd to analysis folder
script_dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
if (getwd() != script_dir) {
  setwd(script_dir)
} else {
  message("The script_dir is the same as the current working directory.")
}

# Choose session 0, 1 or 2
day <- 0

# Set the working directory to the data folder
setwd(paste0("../data/session", day))


# Set the output folder
output_folder <- "output/"

# Get list of subfolders (assuming they are all named 's' followed by numbers)
subfolders <- list.dirs(path = output_folder, full.names = TRUE, recursive = FALSE)

# Initialize a list to store data frames
data_frames <- list()

# Loop through each subfolder and read the CSV file
for (i in seq_along(subfolders)) {
  subfolder <- subfolders[i]
  file_path <- file.path(subfolder, "non-task_data.csv")
  
  # Check if the file exists before reading
  if (file.exists(file_path)) {
    data_frames[[subfolder]] <- read_csv(file_path)
  }
}

exclude_ids <- c()

# Exclusion of day 2 performance-based measures
if (day == 2) {
  exclude_ids <- c(
    "output/5eef7da8a4868b05c902ef2d",
    "output/65956ab743aa1e8fe002ba3b",
    "output/60e0dc6be0772b7dfdad9b2c",
    "output/67d0581ffe3bbe5188426aff",
    "output/67f65a16d76fa76c28091ede",
    "output/675436e14d7ef1173a74a5b8",
    "output/6774f9e03114a09130a1e78f",
    "output/67e2a5b83621fdee51b6277e",
    "output/5a77529ff49c9a0001f2fdbd",
    "output/672879d614dce67b8c3090ea",
    "output/67dc135e06eee79a0b0324ef",
    "output/67f7c74584da18f7cd5fceeb",
    "output/60d9dfd4dcc09cf57dc92cb1",
    "output/65fb34c4df61f03ce0dd6dd9",
    "output/6122f45e2e93a3ff9a7b7a5d",
    "output/65b26a99fe500245f7a7c750",
    "output/67f3619e16d4ca195fbd1bd0",
    "output/669a6bba1fd09527cf41717a",
    "output/5bf3199ebe7c7300017b710a",
    "output/5c549c6372fd9000018b5968",
    "output/5e5c993cd0394c474f7cc502",
    "output/5fabca68273dd403ab40e361",
    "output/5fed47cfcb429d79af4f8ded",
    "output/655f8bf6de805f7bd81e5811",
    "output/65651805d1afb42ba1a55476",
    "output/667971a555af1f83d3f29ae7",
    "output/66ce541cd8da920539a1c3cc",
    "output/673bf9c0212c1ae07ff6c22e",
    "output/67cd50f22f22938860f85a66"
  )
} else if (day == 1) {
  exclude_ids <- c(
    "output/6697c39cfbf1e3381e6ee45c",
    "output/65956ab743aa1e8fe002ba3b",
    "output/669a6bba1fd09527cf41717a",
    "output/65b26a99fe500245f7a7c750",
    "output/677009b08130c3028f6a8a6d",
    "output/6161cb3de3d274978d46575b",
    "output/65fc95c627592d85499ae358",
    "output/655f8bf6de805f7bd81e5811",
    "output/665c5d94303fdf202ac9ded0",
    "output/65fb34c4df61f03ce0dd6dd9",
    "output/5d66b4f503b0d900195ca627",
    "output/676d40e2915d059bf7ef62e8",
    "output/67d095bc257ecc840642912e",
    "output/66645dfa2639fc47c5bca0a6",
    "output/67826c0cd5858c9d420da7ff",
    "output/67d0581ffe3bbe5188426aff",
    "output/5eef7da8a4868b05c902ef2d",
    "output/5fff2877a99bcb65a14a223c",
    "output/67f3619e16d4ca195fbd1bd0",
    "output/67e5cf90b79d0874e1cf16b0",
    "output/571a78f06a1c6300114b8d80",
    "output/5af82cf9e066a40001136ace",
    "output/67e2a5b83621fdee51b6277e",
    "output/66ce541cd8da920539a1c3cc",
    "output/6741ce8667002c96f0362d34",
    "output/5e4066ed9eec8d2a184e4ff4",
    "output/63d9d5072e083033fc895df1",
    "output/67d9a91f56a568412eecda60",
    "output/67f6a640d2046b13fcf33328",
    "output/66083cd0a45e1ce399e6a85f",
    "output/67851f4cba98f2087f182764",
    "output/67dc135e06eee79a0b0324ef",
    "output/604fa685e33606f9a0ee8189",
    "output/609bfd97a7c95881330491d4",
    "output/6122f45e2e93a3ff9a7b7a5d",
    "output/64feeabd355b506d0512d862",
    "output/6606b31155457e4f162ecf5a",
    "output/6776b99a8215d150863a71b4"
  )
}

data_frames <- data_frames[!(names(data_frames) %in% exclude_ids)]

# single participant
# data_frames <- data_frames[10]

# Extract the bonuses
# Get the questionnaires
get_questionnaire <- function(df, quest) {
  #browser()
  
  id <- df[1,] %>% 
    select(subjID) %>%
    pull()
  
  raw <-  df %>% filter(task == quest) %>% 
    select(response)
  
  json_df <- fromJSON(raw$response)
  
  # Flatten the list of responses
  responses <- unlist(json_df, use.names = FALSE)
  
  # Creating a data frame
  df <- data.frame(item_number = seq_along(responses), response = responses)
  
  # The last row should be the attention check -> rename it to "AC": should be "Mostly untrue"
  df[nrow(df),1] <- 'AC'
  
  return(list(id,df))
}

get_bonus <- function(df) {
  id <- df[1,] %>% 
    select(subjID) %>%
    pull()
  
  if (day > 0) {
    result <- df[1,] %>%
      mutate(bonus_effort = round(bonus_effort * (2/3),2)) # adjusting the effort bonus due to the wrongly paid bonuses
    
    # result <- df[1,]
    bonuses <- result %>%
      select(bonus_effort, bonus_foraging, bonus_rlwm, bonus_gonogo)
    
    result <- result %>%
      select(bonus_effort, bonus_foraging, bonus_rlwm, bonus_gonogo) %>%
      rowSums()
    
    #print(df$bonus_effort)
  } else if (day == 0) {
    result <- df[1,] %>%
      select(bonus_gonogo) %>%
      rowSums()
    
    bonuses <- result
  }
  return(list(id,result,bonuses))
}

get_feedback <- function(df) {
  id <- df[1,] %>% 
    select(subjID) %>%
    pull()
  
  # if (id == "309") {
  #   browser()
  # }
  
  json_string <- df %>%
    filter(task == 'final_feedback') %>%
    select(response) %>%
    pull()
  
  # 3. SAFETY CHECK: Handle empty, NA, or missing data
  if (length(json_string) == 0 || is.na(json_string[1]) || json_string[1] == "") {
    warning(paste("Subject", id, "has no final_feedback data. Returning empty dataframe."))
    # Return a dataframe with the expected columns but filled with NA
    return(list(id, data.frame(like = NA_character_, dislike = NA_character_, bugs = NA_character_)))
  }
  
  final_feedback <- data.frame(fromJSON(json_string))
  
  return(list(id,final_feedback))
}

if (day != 0) {
  ami_df <- lapply(data_frames, get_questionnaire, quest = 'AMI')
  cesd_df <-lapply(data_frames, get_questionnaire, quest = 'CESD')
  asrm_df <- lapply(data_frames, get_questionnaire, quest = 'ASRM')
  shps_df <- lapply(data_frames, get_questionnaire, quest = 'SHPS')
  bisbas_df <- lapply(data_frames, get_questionnaire, quest = 'BIS_BAS')
  pss_df <- lapply(data_frames, get_questionnaire, quest = 'PSS')
}
total_bonus <- lapply(data_frames, get_bonus)
final_feedback <- lapply(data_frames, get_feedback)

################################## Payouts     ##################################
bonuses <- sapply(total_bonus, function(x) x[[2]])
all_bonuses <-  sapply(total_bonus, function(x) c(x[[2]], x[[3]]))

# Step 1: Convert the matrix to a tibble and rename columns
all_bonuses_df <- as.data.frame(as_tibble(t(all_bonuses), rownames = "subjID")) %>%
  rename(bonus_total = V1)  # Rename the first column to "bonus_total"

# Strip the "output/" prefix in bonus_total_individual
all_bonuses_df$subjID <- str_remove(all_bonuses_df$subjID, "output/")

all_bonuses_df <- apply(all_bonuses_df, 2, as.character)

# Save to disk
write.csv(all_bonuses_df, paste0("../../output/session",day ,"/bonus_total_individual.csv"), row.names = FALSE)


# Calculate bonus_netto
bonus_netto <- sum(bonuses)

# Calculate bonus_brutto
bonus_brutto <- bonus_netto * 1.4

# Number of participants
num_participants <- length(total_bonus)

# Compensation factor based on the day


if (day == 1 || day == 2) {
  compensation_factor <- 14
} else if (day == 0) {
  compensation_factor <- 4
}

# Calculate compensation_netto and compensation_brutto
compensation_netto <- num_participants * compensation_factor
compensation_brutto <- compensation_netto * 1.4

total_paid <- bonus_brutto + compensation_brutto

# Create the dataframe
df_payouts <- data.frame(
  bonus_netto = bonus_netto,
  bonus_brutto = bonus_brutto,
  compensation_netto = compensation_netto,
  compensation_brutto = compensation_brutto,
  total_paid = total_paid
)

# Print the dataframe
print(df_payouts)

if (day != 0) {
  ################################## Score AMI ##################################
  score_ami <- function(ami_df) {
    
    # indices of the scores for the three subscales
    ba_idx <- c(5,9,10,11,12,15) # behavioral activation (BA)
    es_idx <- c(1,6,7,13,16,18) # emotional sensitivity (ES)
    sm_idx <- c(2,3,4,8,14,17) # social motivation (SM)
    
    n_items <- 18
    n_participants <- length(ami_df)
    ami_responses <- matrix(nrow = n_participants, ncol = n_items) # initialize response matrix
    subID <- character(n_participants)
    
    for(i in 1:n_participants) {
      # The first 18 of participants responses (item 19 is attention check)
      cur_subject <- ami_df[[i]][[2]]$response[1:n_items] # get responses of this participant
      
      # Extract only the numbers of participant's responses using regexpr and regmatches
      ami_responses[i, ] <- as.numeric(regmatches(cur_subject, regexpr("\\d+", cur_subject)))
      # add subjID as rownames
      subID[i]  <- ami_df[[i]][[1]]
    }
    
    #ami_responses <- 4 - ami_responses
    
    # extract subscales
    ba_responses <- ami_responses[,ba_idx] # BA
    es_responses <- ami_responses[,es_idx] # ES
    sm_responses <- ami_responses[,sm_idx] # SM
    
    # Score by taking the average of the individual items (Ang et al., 2017)
    ba_scores <- rowMeans(ba_responses)
    es_scores <- rowMeans(es_responses)
    sm_scores <- rowMeans(sm_responses)
    
    ami_scores <- data.frame(behavioral_activation=ba_scores, 
                             emotional_sensitivity=es_scores, 
                             social_motivation = sm_scores,
                             subjID = subID)
    return(ami_scores)
  }
  
  # A greater score indicates greater apathy (from 0 to 4)
  if (day > 0) {
    ami_scores <- score_ami(ami_df)
    ami_scores <- ami_scores %>% 
      select(subjID, behavioral_activation, emotional_sensitivity, social_motivation)
    
    # combine AMI and PANAS into one df and save as csv
    combined_df <- reduce(list(ami_scores), full_join, by = "subjID")
    
    
    
    write.table(combined_df, paste0(output_folder, '/questionnaire_scores.csv'), row.names = FALSE, col.names = TRUE, sep=",")
  }
  
  ######################### ASMR #########################
  
  score_asrm <- function(asrm_df) {
    
    scores <- lapply(names(asrm_df), function(id) {
      subjID <- sub("^output/", "", id)  # remove 'output/' prefix
      df <- asrm_df[[id]][[2]]
      df <- df[df$item_number != "AC", ]
      
      # Extract the number at the beginning of each response
      numbers <- as.numeric(sub("^(\\d+)\\..*", "\\1", df$response))
      
      # Subtract 1 from each item before summing
      score <- sum(numbers - 1)
      
      return(data.frame(subjID = subjID, Score_ASRM = score))
    })
    
    do.call(rbind, scores)
  }
  
  if (day > 0) {
    asrm_scores <- score_asrm(asrm_df)
  }
  
  
  ######## CESD ##########
  
  score_cesd <- function(cesd_df) {
    
    scores <- lapply(names(cesd_df), function(id) {
      
      subjID <- sub("^output/", "", id)
      df <- cesd_df[[id]][[2]]
      df <- df[df$item_number != "AC", ]
      
      # Extract the number from the beginning of the response
      points <- as.numeric(sub("^(\\d+)\\..*", "\\1", df$response))
      
      # Convert item_number to numeric for indexing
      df$item_number <- as.numeric(df$item_number)
      
      # Reverse-score items 4, 8, 12, 16 (0 ↔ 3)
      reverse_items <- c(4, 8, 12, 16)
      reverse_idx <- df$item_number %in% reverse_items
      points[reverse_idx] <- 3 - points[reverse_idx]
      
      # Total score
      score <- sum(points)
      
      return(data.frame(subjID = subjID, Score_CESD = score))
    })
    
    do.call(rbind, scores)
  }
  
  
  ######## SHPS ##########
  
  score_shps <- function(shps_df) {
    
    scores <- lapply(names(shps_df), function(id) {
      # browser()
      subjID <- sub("^output/", "", id)
      df <- shps_df[[id]][[2]]
      df <- df[df$item_number != "AC", ]
      
      # Extract the number from the beginning of the response
      points <- as.numeric(sub("^(\\d+)\\..*", "\\1", df$response))
      
      # Convert item_number to numeric for indexing
      df$item_number <- as.numeric(df$item_number)
      
      # Reverse-score items 4, 8, 12, 16 (0 ↔ 3)
      reverse_items <- c(2, 4, 5, 7, 9)
      reverse_idx <- df$item_number %in% reverse_items
      points[reverse_idx] <- 3 - points[reverse_idx]
      
      # Total score
      score <- sum(points)
      
      return(data.frame(subjID = subjID, Score_SHPS = score))
    })
    
    do.call(rbind, scores)
  }
  
  ###### PSS ##########
  score_pss <- function(pss_df) {
    
    scores <- lapply(names(pss_df), function(id) {
      subjID <- sub("^output/", "", id)
      df <- pss_df[[id]][[2]]
      df <- df[df$item_number != "AC", ]
      
      # Extract the number from the beginning of the response
      points <- as.numeric(sub("^(\\d+)\\..*", "\\1", df$response))
      
      # Convert item_number to numeric for indexing
      df$item_number <- as.numeric(df$item_number)
      
      # Reverse-score items 4, 5, 7 and 8 (0 ↔ 4)
      reverse_items <- c(4, 5, 7, 8)
      reverse_idx <- df$item_number %in% reverse_items
      points[reverse_idx] <- 4 - points[reverse_idx]
      
      # Total score
      score <- sum(points)
      
      return(data.frame(subjID = subjID, Score_PSS = score))
    })
    
    do.call(rbind, scores)
  }
  
  ##### BIS/BAS ##########
  
  score_bisbas <- function(bisbas_df) {
    
    scores <- lapply(names(bisbas_df), function(id) {
      subjID <- sub("^output/", "", id)
      df <- bisbas_df[[id]][[2]]
      df <- df[df$item_number != "AC", ]
      
      # Extract the number from the beginning of the response
      points <- as.numeric(sub("^(\\d+)\\..*", "\\1", df$response))
      
      # Convert item_number to numeric for indexing
      df$item_number <- as.numeric(df$item_number)
      
      # Reverse-score items (all except 2 and 22)
      reverse_items <- setdiff(1:24, c(2, 22))
      reverse_idx <- df$item_number %in% reverse_items
      points[reverse_idx] <- 5 - points[reverse_idx]
      
      # indices of the scores for the four subscales
      bas_drive <- c(3,9,12,21) # BAS Drive (goal pursuit)
      bas_fun <- c(5,10,15,20) # BAS Fun Seeking (spontaneity, novelty seeking)
      bas_reward <- c(4,7,14,18,23) # BAS Reward Responsiveness (positive reaction to reward)
      bis <- c(2,8,13,16,19,22,24) # BIS (sensitivity to punishment or negative emotion)
      fillers <- c(1,6,11,17) # fillers
      
      # Sum scores per subscale
      score_BAS_Drive <- sum(points[df$item_number %in% bas_drive])
      score_BAS_Fun <- sum(points[df$item_number %in% bas_fun])
      score_BAS_Reward <- sum(points[df$item_number %in% bas_reward])
      score_BIS <- sum(points[df$item_number %in% bis])
      
      return(data.frame(
        subjID = subjID,
        BIS = score_BIS,
        BAS_Drive = score_BAS_Drive,
        BAS_Fun = score_BAS_Fun,
        BAS_Reward = score_BAS_Reward
      ))
    })
    
    do.call(rbind, scores)
  }
  
  
  ### Combine questionnaires and save it ###
  if (day > 0) {
    cesd_scores <- score_cesd(cesd_df)
    shps_scores <- score_shps(shps_df)
    pss_scores <- score_pss(pss_df)
    bisbas_scores <- score_bisbas(bisbas_df)
    combined_df <- reduce(list(ami_scores, asrm_scores, cesd_scores, shps_scores, pss_scores, bisbas_scores), full_join, by = "subjID")
    write.csv(combined_df,paste0("../../output/session",day , '/questionnaire_scores.csv'), row.names = FALSE)
    
  }

}

######## Time elapsed ########
# Initialize an empty data frame to store the results
time_elapsed_df <- data.frame(
  subjID = character(),
  pre_tasks = numeric(),
  AMI = numeric(),
  ASRM = numeric(),
  CESD = numeric(),
  SHPS = numeric(),
  PSS = numeric(),
  BIS_BAS = numeric(),
  final_trial = numeric(),
  final_feedback = numeric(),
  stringsAsFactors = FALSE
)

# Loop through each tibble in the list `data_frames`
for (df in data_frames) {
  # Convert rt to a double
  df$rt <- as.double(df$rt)
  
  
  # Extract subjID from each tibble (assuming it's the same for all rows in the tibble)
  subj_id <- unique(df$subjID)
  
  # Initialize a temporary data frame to store the time elapsed for each task
  temp_df <- data.frame(
    subjID = subj_id,
    pre_tasks = 0,
    AMI = 0,
    ASRM = 0,
    CESD = 0,
    SHPS = 0,
    PSS = 0,
    BIS_BAS = 0,
    final_trial = 0,
    final_feedback = 0,
    stringsAsFactors = FALSE
  )
  
  # Filter for trial_type == "instructions" and get the time_elapsed
  instructions_row <- df %>% filter(trial_type == "instructions")
  if (nrow(instructions_row) > 0) {
    temp_df$pre_tasks <- round(instructions_row$time_elapsed  / 60000, 2)
  }
  
  # Filter for each task and store the respective time_elapsed in the appropriate column
  tasks <- c("AMI", "ASRM", "CESD","SHPS","PSS","BIS_BAS", "final_trial", "final_feedback")
  for (task in tasks) {
    task_row <- df %>% filter(task == !!task)
    if (nrow(task_row) > 0) {
      temp_df[[task]] <- round(task_row$rt / 60000, 2)
    }
  }
  
  # Append the temporary data frame to time_elapsed_df
  time_elapsed_df <- rbind(time_elapsed_df, temp_df)
}

# Print the resulting time_elapsed_df
print(time_elapsed_df)

# Replace all NAs by 0, in all rows or columns
time_elapsed_df[is.na(time_elapsed_df)] <- 0

# Load the effort and gng time elapsed


gng_time <- read_csv(paste0("../../output/session",day ,"/gng_time_elapsed.csv"))

if (day > 0) {
  effort_time <- read_csv(paste0("../../output/session",day ,"/effort_time_elapsed.csv"))
  rlwm_time <- read_csv(paste0("../../output/session",day ,"/rlwm_time_elapsed.csv"))
  foraging_time <- read_csv(paste0("../../output/session",day ,"/foraging_time_elapsed.csv"))
}

# Merge the time elapsed data frames


time_elapsed_df <- merge(time_elapsed_df, gng_time, by = "subjID", all.x = TRUE)

if (day > 0) {
  time_elapsed_df <- merge(time_elapsed_df, effort_time, by = "subjID", all.x = TRUE)
  time_elapsed_df <- merge(time_elapsed_df, rlwm_time, by = "subjID", all.x = TRUE)
  time_elapsed_df <- merge(time_elapsed_df, foraging_time, by = "subjID", all.x = TRUE)
}

if (day == 0) {
  time_elapsed_total_df <- time_elapsed_df %>% select(subjID, pre_tasks, gng_total_time, final_trial, final_feedback)
  time_elapsed_df <- time_elapsed_df %>% select(subjID, pre_tasks, gng_instructions,gng_task,gng_end_of_task, final_trial, final_feedback)
} else if (day >= 1) {
  time_elapsed_total_df <- time_elapsed_df %>% select(subjID, pre_tasks, effort_total_time, gng_total_time, rlwm_total_time,foraging_total_time, AMI, ASRM, CESD, SHPS, PSS, BIS_BAS, final_trial, final_feedback)
  time_elapsed_df <- time_elapsed_df %>% select(subjID, pre_tasks, effort_initial_instructions,effort_titration, effort_titration_verification,effort_training_remaining,effort_task,gng_instructions,gng_task,gng_end_of_task,rlwm_training,rlwm_task,foraging_training,foraging_task, AMI, ASRM, CESD,SHPS, PSS, BIS_BAS, final_trial, final_feedback)
}
# Plot boxplots of time elapsed for each task using ggplot2
time_elapsed_df_long <- time_elapsed_df %>%
  pivot_longer(cols = -subjID, names_to = "task", values_to = "time_elapsed")

if (day == 0) {
  time_elapsed_df_long$task <- factor(time_elapsed_df_long$task, levels = c("pre_tasks", "gng_instructions", "gng_task", "gng_end_of_task", "final_trial"))
} else if (day >= 1) {
  time_elapsed_df_long$task <- factor(time_elapsed_df_long$task, levels = c("pre_tasks", "effort_initial_instructions", "effort_titration", "effort_titration_verification", "effort_training_remaining", "effort_task", "gng_instructions", "gng_task", "gng_end_of_task", "rlwm_training", "rlwm_task", "foraging_training", "foraging_task", "AMI", "ASRM", "CESD","SHPS","PSS","BIS_BAS", "final_feedback", "final_trial"))
}

p <- ggplot(time_elapsed_df_long, aes(x = task, y = time_elapsed)) +
  geom_boxplot() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Time elapsed for each task", x = "Task", y = "Time elapsed (minutes)")

# Make y axis more detailed, show every 1 minute
p <- p + scale_y_continuous(breaks = seq(0, max(time_elapsed_df_long$time_elapsed, na.rm=TRUE), by = 15))



# Plot the same boxplots for the total time elapsed
time_elapsed_total_df_long <- time_elapsed_total_df %>%
  pivot_longer(cols = -subjID, names_to = "task", values_to = "time_elapsed")

if (day == 0) {
  time_elapsed_total_df_long$task <- factor(time_elapsed_total_df_long$task, levels = c("pre_tasks", "gng_total_time", "final_feedback", "final_trial"))
} else if (day >= 1) {
  time_elapsed_total_df_long$task <- factor(time_elapsed_total_df_long$task, levels = c("pre_tasks", "effort_total_time", "gng_total_time", "rlwm_total_time","foraging_total_time", "AMI", "ASRM", "CESD","SHPS","PSS","BIS_BAS","final_feedback", "final_trial"))
}


p_total <- ggplot(time_elapsed_total_df_long, aes(x = task, y = time_elapsed)) +
  geom_boxplot() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Total time elapsed for each task", x = "Task", y = "Time elapsed (minutes)")

# Make y axis more detailed, show every 1 minute
p_total <- p_total + scale_y_continuous(breaks = seq(0, max(time_elapsed_total_df_long$time_elapsed, na.rm=TRUE), by = 15))

# Sum up the times and boxplot the total time elapsed for each participant
time_elapsed_total_participant <- time_elapsed_total_df %>%
  mutate(total_time = rowSums(select(., -subjID))) %>%
  select(subjID, total_time)

p_total_participant <- ggplot(time_elapsed_total_participant, aes(x = "", y = total_time)) +
  
  geom_boxplot() +
  labs(title = "Total time elapsed for each participant", x = "", y = "Total time elapsed (minutes)")

# Add jittered points and annotate them with subjID
p_total_participant <- ggplot(time_elapsed_total_participant, aes(x = "", y = total_time)) +
  geom_boxplot() +
  geom_jitter(width = 0, height = 0.2) +  # Add jitter
  #geom_text(aes(label = subjID), position = position_jitter(width = 0.4, height = 0.2), vjust = -0.5) +  # Add labels
  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
  labs(title = "Total time elapsed for each participant", x = "", y = "Total time elapsed (minutes)")

# Make detailed y-axis, show every 1 minute
p_total_participant <- p_total_participant + scale_y_continuous(breaks = seq(0, max(time_elapsed_total_participant$total_time, na.rm=TRUE), by = 10))

# Print the plots
print(p_total)
print(p)
print(p_total_participant)

# save the plots to paste0("../../output/session",day ,"/gng_time_elapsed.csv")
ggsave(paste0("../../output/session",day ,"/total_time_elapsed.png"), p_total, width = 10, height = 6, units = "in", dpi = 300)
ggsave(paste0("../../output/session",day ,"/time_elapsed.png"), p_total_participant, width = 10, height = 6, units = "in", dpi = 300)

# Save the df of the time elapsed for each participant
write.csv(time_elapsed_total_df, paste0("../../output/session",day ,"/total_time_elapsed.csv"))
          
# Export the list of participants in this day for a quick overview
# Get list of directories
participant_dirs <- list.dirs(output_folder, recursive = FALSE)

# Remove the "output/" prefix
participant_ids <- sub("output/", "", participant_dirs)

# Remove empty entries (in case "output/" itself is listed)
participant_ids <- participant_ids[participant_ids != ""]

# Save to CSV
write.csv(participant_ids, paste0("../../output/session",day ,"/participants_list.csv"), row.names = FALSE)

### Check everyone's attention checks ###
extract_AC_item <- function(df_list, questionnaire_name) {
  do.call(rbind, lapply(df_list, function(participant_data) {
    # Some entries may be NULL or improperly structured, skip those
    if (length(participant_data) < 2 || is.null(participant_data[[2]])) return(NULL)
    
    df <- participant_data[[2]]
    subjID <- participant_data[[1]]
    
    ac_row <- df %>% 
      filter(item_number == "AC") %>%
      mutate(
        subjID = subjID,
        questionnaire = questionnaire_name
      ) %>%
      select(subjID, questionnaire, response)
    
    return(ac_row)
  }))
}

# Assuming these lists already exist:
# ami_df, cesd_df, asrm_df, shps_df, bisbas_df, pss_df
if (day != 0) {
    df_ami     <- extract_AC_item(ami_df, "AMI")
    df_cesd    <- extract_AC_item(cesd_df, "CESD")
    df_asrm    <- extract_AC_item(asrm_df, "ASRM")
    df_shps    <- extract_AC_item(shps_df, "SHPS")
    df_bisbas  <- extract_AC_item(bisbas_df, "BIS_BAS")
    df_pss     <- extract_AC_item(pss_df, "PSS")
  
  
  # Combine all into one final dataframe
  df_ac_combined <- bind_rows(
    df_ami,
    df_cesd,
    df_asrm,
    df_shps,
    df_bisbas,
    df_pss
  )
  
  # Pivot to wide format
  df_ac_wide <- df_ac_combined %>%
    pivot_wider(
      names_from = questionnaire,
      values_from = response
    )
  
  # View result
  print(df_ac_wide)
  
  df_ac_output <- df_ac_wide
  
  # Change it to TRUE/FALSE if the attention check was passed
  # mapping of column names to "trigger" values
  passed_ac_checks <- list(
    AMI   = "3. Mostly Untrue",
    CESD  = "2. Choose this option to indicate that you payed attention ",
    ASRM  = "3. Mostly Untrue",
    SHPS  = "3. Strongly Agree",
    BIS_BAS = "1. very true for me",
    PSS   = "3. Fairly Often"
  )
  
  # loop through and transform each column
  for (col in names(passed_ac_checks)) {
    df_ac_output[[col]] <- df_ac_wide[[col]] == passed_ac_checks[[col]]
  }
  
  # Export the df
  write.csv(df_ac_output, paste0("../../output/session",day ,"/quests_catch_trials.csv"), row.names = FALSE)
}