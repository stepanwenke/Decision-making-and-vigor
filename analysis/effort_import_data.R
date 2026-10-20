#libraries
library(tidyverse) # tidy functions (including readr)
library(psych)
library(jsonlite) # to parse the JSON objects
library(rvest) # to extract plain text from the HTML code
library(ggsignif)
library(ez)
library(rempsyc)
library(broom)
library(lme4)
library(lmerTest)

# set wd to analysis folder
script_dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
if (getwd() != script_dir) {
  setwd(script_dir)
} else {
  message("The script_dir is the same as the current working directory.")
}


# Session 1 or 2
day <- 1

# Set the working directory to the data folder
setwd(paste0("../data/session", day))

# Set the output folder
output_folder <- "output/"

# Folder for saving images and stuff
folder_path_pilot_anal <- paste0("../../output/session", day, "/")

# Check if the folder exists, and create it if it doesn't
if (!dir.exists(folder_path_pilot_anal)) {
  dir.create(folder_path_pilot_anal)
}

# Check if the folder effort/ exists, and create it if it doesn't
if (!dir.exists(paste0(folder_path_pilot_anal, "effort/"))) {
  dir.create(paste0(folder_path_pilot_anal, "effort/"))
}


## Trial parameters ##
effort_levels_num <- 5 # number of effort levels
reward_levels_num <- 5 # number of reward levels
trials_num <- 75 # number of trials per effort
omit_iteration <- 0 # number of initial iterations to omit from the analyses
effort_iteration_num <- (trials_num / (effort_levels_num * reward_levels_num) - omit_iteration) # number of iterations per effort level
offers_per_level <- effort_levels_num * effort_iteration_num # nr of offers for each reward/effort level
reward_offers_per_level <- reward_levels_num * effort_iteration_num # nr of offers for each reward/effort level


# Get list of subfolders (assuming they are all named 's' followed by numbers)
subfolders <- list.dirs(path = output_folder, full.names = TRUE, recursive = FALSE)

# Initialize a list to store data frames
data_frames <- list()

# Loop through each subfolder and read the CSV file
for (i in seq_along(subfolders)) {
  subfolder <- subfolders[i]
  file_path <- file.path(subfolder, "effort_data.csv")
  
  # Check if the file exists before reading
  if (file.exists(file_path)) {
    data_frames[[subfolder]] <- read_csv(file_path)
  }
}




##############################################################################

# filter out only relevant columns
relevant_columns <- c(
  "trial_index", "subjID", "rt", "stimulus", "response", "task",
  "trial_number", "total_time", "total_duration", "total_credits",
  "mental_credits", "physical_credits", "button_order", "effort_level",
  "effort_credits", "effort_type", "training", "choice_latency",
  "chosen_task","n_presses", "successful", "time_elapsed", "task_type"
)



# Parse the HTML code in stimulus 
extract_text_from_html <- function(html_code) {
  # Check if the value is NA or if it's already plain text
  if (is.na(html_code) || grepl("^[a-zA-Z]", html_code)) {
    return(html_code)
  }
  
  # Parse the HTML code
  html <- read_html(html_code)
  
  # Extract text using html_text
  text <- gsub("\\s{2,}", " ", html_text(html, trim = TRUE))
  
  
  return(text)
}

calculate_effort_levels <- function(df) {
  #browser()
    # Subset the data frame with relevant columns
  df_filtered <- subset(df, select = relevant_columns)
  
  ## Physical effort counts
  ## check if its day <- 999
  if (day == 999) {
    physical_effort_df <- df_filtered %>%
      filter(training == FALSE & task_type == "effort")  
  } else {
    
    if (omit_iteration > 0) {
      physical_effort_df <-df_filtered %>%
        filter(task == "physical effort outcome" | task == "physical rest") %>%
        group_by(effort_level, effort_credits) %>%
        arrange(time_elapsed) %>%  # or trial_index if more appropriate
        slice(-omit_iteration) %>%
        ungroup() %>%
        filter(task == "physical effort outcome")
    } else {
      physical_effort_df <- df_filtered %>%
        filter(task == "physical effort outcome")
    }

    #browser()
  }
  
  # physical_effort_df <- df_filtered %>%
  #   filter(task == "physical effort outcome") #& chosen_task == 'effort'
  # 
  physical_output <- physical_effort_df  %>%
    count(effort_level, effort_credits) %>%
    # complete(effort_level = seq(1, 5), fill = list(n = 0)) %>%
    rename(effort = effort_level, n = n, reward = effort_credits) %>%
    mutate(prop = n/(effort_iteration_num)) # accepted offers (n) dividied by total offers (4)
  
  # Return the calculated outputs
  return(list(
    df_filtered = df_filtered,
    #effort_catch = effort_catch,
    #df_physical = df_physical,
    physical_output = physical_output
  ))
}



process_data_frame <- function(df) {
  
  result <- calculate_effort_levels(df)
  # Do something with the result if needed
  return(result)
}

processed_data <- lapply(data_frames, process_data_frame)


# check if excluded_participants vector is empty skip it, otherwise exclude_ids will be assigned excluded_participants
if (exists("excluded_participants") && length(excluded_participants) > 0) {
  exclude_ids <- excluded_participants
  exclusion_prefix <- "excluded_"
} else {
  exclude_ids <- c()
  exclusion_prefix <- ""
}

exclude_ids <- paste0("output/", exclude_ids)

# Filter out participants by excluding them from the list
processed_data <- processed_data[!(names(processed_data) %in% exclude_ids)]
data_frames <- data_frames[!(names(data_frames) %in% exclude_ids)]

##################################################################
# loop over each participant and fill in the correct proportions of offers accepted

reward_effort_proportions <- list() # initialize list
for (i in 1:length(processed_data)) {
  #browser()
  # extract physical_output from the processed data
  df <- processed_data[[i]]$physical_output
  sID <- processed_data[[i]]$df_filtered$subjID[1]
  
  # create all possible combinations of effort and reward
  all_combinations <- expand.grid(effort = 1:effort_levels_num, reward = seq(2,10,by=2))
  
  
  # Merge with existing data frame, filling in missing combinations
  full_data <- full_join(all_combinations, df, by = c("effort", "reward")) %>%
    mutate(
      n = coalesce(n, 0),   # Set n to 4 where it is NA
      prop = coalesce(prop, 0) # Set prop to 0 where it is NA
    )
  
  # store this participant in a list
  reward_effort_proportions[[i]] <- full_data
  names(reward_effort_proportions)[i] <- sID # name sublist with subjID
}

#################################################################
# average across participants

# Combine all data frames into one
combined_df <- do.call(rbind, lapply(1:length(reward_effort_proportions), function(i) {
  cbind(reward_effort_proportions[[i]], participant = names(reward_effort_proportions)[i])
}))

# Calculate the mean of 'n' and 'prop' for each combination of 'effort' and 'reward'
averaged_prop_df <- combined_df %>%
  group_by(effort, reward) %>%
  summarise(
    n = mean(n),
    prop = mean(prop)
  ) %>%
  ungroup()  # remove the grouping

write.csv(averaged_prop_df, paste0(folder_path_pilot_anal, "effort/", exclusion_prefix,"prop_all.csv"), row.names = FALSE)

# Calculate the mean proportion accepted for effort levels 4 and 5
effort_4_5_avg <- combined_df %>%
  filter(effort %in% c(4,5)) %>%
  group_by(participant) %>%
  summarise(
    n = sum(n),
    prop = mean(prop)
  )# %>%
  #arrange(desc(prop))

print(effort_4_5_avg)
which(effort_4_5_avg$prop > 0.90) # check which participants are above 95% acceptance rate

# Save to csv
write.csv(effort_4_5_avg, paste0(folder_path_pilot_anal, "effort/", exclusion_prefix,"prop_4_5_avg.csv"), row.names = FALSE)

# Calculate the mean proportion accepted for effort lvl 5
effort_5_avg <- combined_df %>%
  filter(effort %in% c(5)) %>%
  group_by(participant) %>%
  summarise(
    n = sum(n),
    prop = mean(prop)
  ) %>%
  arrange(desc(prop))

print(effort_5_avg)

# Plot histograms of averaged_prop_df$prop using gplot
plot_prop_hist <- ggplot(averaged_prop_df, aes(x = prop)) +
  geom_histogram(binwidth = 0.025, fill = "steelblue", color = "black") +
  labs(title = "Histogram of Proportion Accepted Offers",
       x = "Proportion Accepted",
       y = "Frequency") +
  theme_minimal()
print(plot_prop_hist)



plot_prop_hist_4_5 <- ggplot(effort_4_5_avg, aes(x = prop)) +
  geom_histogram(binwidth = 0.025, fill = "steelblue", color = "black") +
  labs(title = "Histogram of Proportion Accepted Hard Offers",
       x = "Proportion Accepted",
       y = "Frequency") +
  theme_minimal()
print(plot_prop_hist_4_5)

# List of participant IDs to exclude based on >90% acceptance rate at effort level 5
# Extract participants with prop >= 0.9 and format the vector
excluded_participants <- effort_4_5_avg %>%
  filter(prop > 0.9) %>%  # Filter participants
  mutate(participant = paste0("output/", participant)) %>%  # Add "output/" prefix
  pull(participant)  # Extract as a vector

# Save the excluded participants to a file
write.csv(excluded_participants, paste0(folder_path_pilot_anal, "effort/", exclusion_prefix,"excluded_participants.csv"), row.names = FALSE)

# Calculate the mean of 'n' and 'prop' accepted for each participant
participant_avg_df <- combined_df %>%
  group_by(participant) %>%
  summarise(
    n = sum(n),
    prop = mean(prop)
  ) %>%
  arrange(desc(prop))

# Save it to a file
write.csv(participant_avg_df, paste0(folder_path_pilot_anal, "effort/", exclusion_prefix,"participant_avg.csv"), row.names = FALSE)

# Explorative correlations of prop accepting effort at higher effort with exit thresholds
high_eff <- combined_df %>%
  select(participant,effort, prop) %>%
  filter(effort == 5) %>%
  group_by(participant, effort) %>%
  summarize(mean_prop = mean(prop))

# Prop accepted by participant per effort level
effort_prop_participant_df <- combined_df %>%
  select(participant,effort, prop) %>%
  group_by(participant, effort) %>%
  summarize(mean_prop = mean(prop))

################################################################
# HEATMAPS
breaks = c(2,4,6,8,10)


plot_heatmap <-  ggplot(averaged_prop_df, aes(x = reward, y = effort, fill = prop)) +
  geom_tile(color = "white") +
  geom_text(color = "black", size = 9, aes(label = round(prop, 2))) +  # Add text labels
  scale_fill_gradient(low = "yellow", high = "red") +
  #scale_x_continuous(breaks = c(20,40,60,80,100)) +
  scale_x_continuous(breaks = breaks) +
  labs(title = "A",
       x = "Reward",
       y = "Effort Level") +
  theme(
    panel.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(colour = "black"),
    text = element_text(size = 25),
    axis.text = element_text(size = 19),
    axis.title = element_text(size = 19),
    legend.position = "none"  # Remove the legend
  )
print(plot_heatmap)

# Save the plot
ggsave(paste0(folder_path_pilot_anal, "effort/", exclusion_prefix,"heatmap.jpg"), plot_heatmap, width = 10, height = 10, dpi = 300)

# Collapse across effort & reward for each participant and barplot (with individual dots)
# using reward_effort_proportions created previously
# Calculate the average of 'prop' for each unique 'effort' and 'reward'

prop_per_effort_level <- function(df){

# proportion accepted offers across effort
average_prop_by_effort <- df %>%
  group_by(effort) %>%
  summarise(average_prop = sum(n) / reward_offers_per_level) # nr of accepted / total offers

}

prop_per_reward_level <- function(df){
  
  #browser()
  
  # proportion accepted offers across reward
  average_prop_by_reward <- df %>%
    group_by(reward) %>%
    summarise(average_prop = sum(n) / offers_per_level)
}

# proportion of accepted offers for each reward and effort level
prop_per_effort <- lapply(reward_effort_proportions, prop_per_effort_level)
prop_per_reward <- lapply(reward_effort_proportions, prop_per_reward_level)

# Combine all reward levels into one dataframe
combined_df_reward <- bind_rows(prop_per_reward, .id = "participant")

# combined_df_reward <- combined_df_reward %>%
#   filter(participant != '656756280fdfebe03fd59e28') # remove participant 1)


# Combine all effort levels into one dataframe
combined_df_effort <- bind_rows(prop_per_effort, .id = "participant")

# combined_df_effort <- combined_df_effort %>%
#   filter(participant != '656756280fdfebe03fd59e28') # remove participant 1)



############# Bar plot reward #######################
# Calculate the mean of average_prop for each reward level
average_prop_reward <- combined_df_reward %>%
  group_by(reward) %>%
  summarise(mean_average_prop = mean(average_prop))

# Calculate mean, standard deviation, and standard error of the mean (SEM) for each reward
stats_by_reward <- combined_df_reward %>%
  group_by(reward) %>%
  summarise(mean_average_prop = mean(average_prop),
            sd = sd(average_prop),
            sem = sd / sqrt(n()))

# Assuming a 95% confidence interval for the SEM
# The critical value for a 95% confidence interval is approximately 1.96 for a large sample size.
stats_by_reward <- stats_by_reward %>%
  mutate(lower = mean_average_prop - 1.96 * sem,
         upper = mean_average_prop + 1.96 * sem)

# Create a bar plot
plot_reward_bars <- ggplot(average_prop_reward, aes(x = factor(reward), y = mean_average_prop)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  geom_errorbar(data = stats_by_reward, aes(x = factor(reward), ymin = lower, ymax = upper), 
                width = 0.2, color = "black") +
  geom_jitter(data = combined_df_reward, aes(x = factor(reward), y = average_prop, group = participant), 
              color = "darkred", width = 0.1, height = 0) +
  geom_line(data = combined_df_reward, aes(x = factor(reward), y = average_prop, group = participant),
  color = "red", alpha = 0.5) +
  labs(x = "Reward", y = "Proportion accepted", title = "Prop Accepted Offers per Reward Level") +
  scale_x_discrete(name = "Reward Level") + # Ensuring reward is treated as a discrete factor
  theme(
    panel.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(colour = "black")
  )
print(plot_reward_bars)  

# Save the plot
ggsave(paste0(folder_path_pilot_anal, "effort/", exclusion_prefix,"reward_bars.jpg"), plot_reward_bars, width = 10, height = 6, dpi = 300)

############# Time elapsed #######################
# Initialize the output data frame
df_time_elapsed <- data.frame(
  subjID = character(),
  effort_initial_instructions = numeric(),
  effort_titration = numeric(),
  effort_titration_verification = numeric(),
  effort_training_remaining = numeric(),
  effort_task = numeric(),
  effort_end_of_task = numeric(),
  effort_total_time = numeric(),
  stringsAsFactors = FALSE
)

# Process each data frame in the list
for (df in data_frames) {
  
  # Extract participant ID
  subjID <- unique(df$subjID)
  
  if (subjID == "5d7e761f3c9c5e0016bd6255") {
    #browser()
  }
  
  # Find timestamps
  timestamp_start <- min(df$time_elapsed, na.rm = TRUE)
  timestamp_initial_instructions <- df$time_elapsed[df$task == "3..2..1"][1]
  timestamp_titration <- tail(df$time_elapsed[df$task == "physical titration outcome"], 1)
  timestamp_titration_verification <- df$time_elapsed[df$task == "offer"][1]
  timestamp_training_remaining <- tail(df$time_elapsed[df$task == "physical quiz"], 1)
  timestamp_task <- tail(df$time_elapsed[df$task == "post_catch_feedback_screen"], 1)
  timestamp_end_of_task <- df$time_elapsed[df$task == "debrief_phys"][1]
  
  # Calculate durations
  initial_instructions <- (timestamp_initial_instructions - timestamp_start) / 60000
  titration <- (timestamp_titration - timestamp_initial_instructions) / 60000
  titration_verification <- (timestamp_titration_verification - timestamp_titration) / 60000
  training_remaining <- (timestamp_training_remaining - timestamp_titration_verification) / 60000
  task <- (timestamp_task - timestamp_training_remaining) / 60000
  end_of_task <- (timestamp_end_of_task - timestamp_task) / 60000
  
  # Calculate total time
  total_time <- initial_instructions + titration + titration_verification + training_remaining + task + end_of_task
  
  # Round values to two decimals
  initial_instructions <- round(initial_instructions, 2)
  titration <- round(titration, 2)
  titration_verification <- round(titration_verification, 2)
  training_remaining <- round(training_remaining, 2)
  task <- round(task, 2)
  end_of_task <- round(end_of_task, 2)
  total_time <- round(total_time, 2)
  
  # Add results to the output data frame
  df_time_elapsed <- rbind(df_time_elapsed, data.frame(
    subjID = subjID,
    effort_initial_instructions = initial_instructions,
    effort_titration = titration,
    effort_titration_verification = titration_verification,
    effort_training_remaining = training_remaining,
    effort_task = task,
    effort_end_of_task = end_of_task,
    effort_total_time = total_time,
    stringsAsFactors = FALSE
  ))
}

# Display the result
print(df_time_elapsed)

# Save the data frame in a csv file
write.csv(df_time_elapsed, paste0(folder_path_pilot_anal, "/", exclusion_prefix,"effort_time_elapsed.csv"), row.names = FALSE)


############# Bar plot effort #######################
# Calculate the mean of average_prop for each effort level
average_prop_effort <- combined_df_effort %>%
  group_by(effort) %>%
  summarise(mean_average_prop = mean(average_prop))

# Calculate mean, standard deviation, and standard error of the mean (SEM) for each reward
stats_by_effort <- combined_df_effort %>%
  group_by(effort) %>%
  summarise(mean_average_prop = mean(average_prop),
            sd = sd(average_prop),
            sem = sd / sqrt(n()))

# Assuming a 95% confidence interval for the SEM
# The critical value for a 95% confidence interval is approximately 1.96 for a large sample size.
stats_by_effort <- stats_by_effort %>%
  mutate(lower = mean_average_prop - 1.96 * sem,
         upper = mean_average_prop + 1.96 * sem)

# Create a bar plot
plot_effort_bars <- ggplot(average_prop_effort, aes(x = factor(effort), y = mean_average_prop)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  geom_errorbar(data = stats_by_effort, aes(x = factor(effort), ymin = lower, ymax = upper), 
                width = 0.2, color = "black") +
  geom_jitter(data = combined_df_effort, aes(x = factor(effort), y = average_prop), 
              color = "darkred", width = 0.1, height = 0) +
  geom_line(data = combined_df_effort, aes(x = factor(effort), y = average_prop, group = participant),
            color = "red", alpha = 0.5) +
  labs(x = "Effort Level", y = "Proportion accepted", title = "Prop Accepted Offers per Effort Level") +
  scale_x_discrete(name = "Effort Level") + # Ensuring reward is treated as a discrete factor
  theme(
    panel.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(colour = "black")
  )
print(plot_effort_bars)

# Save the plot
ggsave(paste0(folder_path_pilot_anal, "effort/", exclusion_prefix,"effort_bars.jpg"), plot_effort_bars, width = 10, height = 6, dpi = 300)

##################################### 

# Function to merge and sum counts for physical and mental effort
calculate_total_effort <- function(processed_data) {
  #browser()
  # Initialize empty lists for physical and mental effort
  total_physical_list <- list()
  # total_mental_list <- list()
  
  # Loop through processed data frames
  for (df_name in names(processed_data)) {
    df <- processed_data[[df_name]]
    
    # Merge and sum up the "prop" values for physical output
    total_physical_list[[df_name]] <- df$physical_output
    
  }
  #browser()
  # Combine the data frames
  total_physical <- do.call(rbind, total_physical_list)
  
  # average the proportions for physical and mental effort
  total_physical <- aggregate(n ~ effort + reward, data = total_physical, sum)
  
  total_physical_avg <- total_physical %>%
    mutate(prop = n/(length(processed_data)*effort_iteration_num))
  
  # Return the results
  return(list(total_physical_avg = total_physical_avg))
}


# Assuming you have processed_data as a list of data frames
result <- calculate_total_effort(processed_data)

# Access the results
total_physical <- result$total_physical
#total_mental <- result$total_mental

count_successful <- function(df, effort_type_para) {
  #browser()
  
  filtered <- df$df_filtered
  
  subset <- filtered %>% filter(effort_type == effort_type_para & chosen_task == 'effort' & training == FALSE) %>% 
    select(successful, effort_level) %>%
    filter(!is.na(successful))
  
  success <-  subset %>%
    group_by(effort_level, successful) %>%
    summarise(count = n())
  
  result_counts <- table(factor(subset$successful, levels = c(FALSE, TRUE)))
  proportions <- prop.table(result_counts)
  
  return(list(result_counts, proportions, success))
}

success_table_physical <- lapply(processed_data, count_successful, effort_type_para = 'physical')
#success_table_mental <- lapply(processed_data, count_successful, effort_type_para = 'mental')

########## Look at individidual success rates participants ##########

# Create an empty data frame to store the results
individual_success_df <- data.frame(subjID = character(), 
                             effort_level = numeric(), 
                             successful = logical(), 
                             count = numeric(), 
                             stringsAsFactors = FALSE)

# Iterate over the list and extract the required data
for (subjID in names(success_table_physical)) {
  tibble_data <- success_table_physical[[subjID]][[3]] # Extract the tibble
  
  # Add a column for subjID
  tibble_data <- tibble_data %>% 
    mutate(subjID = subjID)
  
  # Append to the final data frame
  individual_success_df <- bind_rows(individual_success_df, tibble_data)
}

# Reorder columns for clarity
individual_success_df <- individual_success_df %>%
  select(subjID, effort_level, successful, count)

# View the resulting data frame
print(individual_success_df)

# Calculate proportions for each effort_level and participant
# proportions_df <- individual_success_df %>%
#   group_by(subjID, effort_level, successful) %>%
#   summarise(count = sum(count), .groups = "drop") %>%
#   group_by(subjID, effort_level) %>%
#   mutate(proportion = count / sum(count))

# Ensure all combinations of subjID, effort_level, and successful exist
proportions_df <- individual_success_df %>%
  complete(
    subjID,
    effort_level = unique(individual_success_df$effort_level), # Ensure valid effort levels
    successful = c(TRUE, FALSE), # Include TRUE and FALSE
    fill = list(count = 0) # Fill missing counts with 0
  ) %>%
  group_by(subjID, effort_level, successful) %>%
  summarise(count = sum(count), .groups = "drop") %>%
  group_by(subjID, effort_level) %>%
  mutate(proportion = count / sum(count)) %>%
  ungroup()

# Get the df of average success rate in the task for each participant
success_participant_df <- proportions_df %>%
  group_by(subjID) %>%
  filter(successful == TRUE) %>%
  summarise(mean_proportion_success = mean(proportion, na.rm = TRUE))

# Filter for successful == TRUE
proportions_true <- proportions_df %>%
  filter(successful == TRUE)
# 
# # Plot only TRUE proportions
# ggplot(proportions_true, aes(x = effort_level, y = proportion, color = subjID, group = subjID)) +
#   geom_line(size = 1) +
#   geom_point(size = 3) +
#   labs(
#     title = "Proportion of Successes by Effort Level (task)",
#     x = "Effort Level",
#     y = "Proportion of Sucesses (out of 10 trials)",
#     color = "Participant"
#   ) +
#   theme_minimal() +
#   theme(
#     legend.position = "bottom",
#     panel.grid.major = element_line(color = "grey80"),
#     panel.grid.minor = element_blank()
#   )

# Calculate summary statistics for the overall proportions
summary_stats_task <- proportions_true %>%
  group_by(effort_level) %>%
  summarise(
    mean_proportion = mean(proportion, na.rm = TRUE),
    se_proportion = sd(proportion, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  )

# Plot with individual lines/points and overall bars/error bars
plot_successes_task <-  ggplot(proportions_true, aes(x = effort_level, y = proportion, color = subjID, group = subjID)) +
  # Line and points for individual participants
  geom_line(size = 1) +
  geom_point(size = 3) +
  
  # Bars with error bars for overall means
  geom_bar(
    data = summary_stats_task,
    aes(x = effort_level, y = mean_proportion),
    stat = "identity",
    alpha = 0.4,
    fill = "grey50",
    inherit.aes = FALSE # Prevent inheritance of global aes
  ) +
  geom_errorbar(
    data = summary_stats_task,
    aes(
      x = effort_level,
      ymin = mean_proportion - se_proportion,
      ymax = mean_proportion + se_proportion
    ),
    width = 0.2,
    color = "black",
    inherit.aes = FALSE # Prevent inheritance of global aes
  ) +
  
  # Labels and theme
  labs(
    title = "Proportion of Successes by Effort Level (Task)",
    x = "Effort Level",
    y = "Proportion of Successes (out of 10 trials)",
    color = "Participant"
  ) +
  theme_minimal() +
  theme(
    legend.position = "none",
    panel.grid.major = element_line(color = "grey80"),
    panel.grid.minor = element_blank()
  )
print(plot_successes_task)

# Save the plot
ggsave(paste0(folder_path_pilot_anal, "effort/", exclusion_prefix,"successes_task.jpg"), plot_successes_task, width = 10, height = 6, dpi = 300)


################# Proportion successful for training #################
# New Analysis for Specific Filters
count_successful_filtered <- function(df, effort_type_para) {
  # Apply additional filters for specific conditions
  #browser()
  filtered <- df$df_filtered
  
  # To analyse older datasets, uncomment this block:
  
  # subset <- filtered %>% 
  #   filter(
  #     effort_type == effort_type_para, 
  #     training == TRUE, 
  #     task == "post titration testing", 
  #     effort_credits == 4
  #   ) %>% 
  #   select(successful, effort_level) %>%
  #   filter(!is.na(successful))
  
    subset <- filtered %>% 
      filter(
        effort_type == effort_type_para, 
        training == TRUE, 
        task == "running training outcome"
      ) %>% 
      select(successful, effort_level) %>%
      filter(!is.na(successful))
  
  # Count successes grouped by effort level and successful status
  success <- subset %>%
    group_by(effort_level, successful) %>%
    summarise(count = n(), .groups = "drop")
  
  result_counts <- table(factor(subset$successful, levels = c(FALSE, TRUE)))
  proportions <- prop.table(result_counts)
  
  return(list(result_counts, proportions, success))
}

success_table_physical_filtered <- lapply(processed_data, count_successful_filtered, effort_type_para = 'physical')

# Process Results for Plotting: New Analysis
individual_success_df_filtered <- data.frame(
  subjID = character(), 
  effort_level = numeric(), 
  successful = logical(), 
  count = numeric(), 
  stringsAsFactors = FALSE
)

for (subjID in names(success_table_physical_filtered)) {
  tibble_data <- success_table_physical_filtered[[subjID]][[3]]
  tibble_data <- tibble_data %>% mutate(subjID = subjID)
  individual_success_df_filtered <- bind_rows(individual_success_df_filtered, tibble_data)
}

proportions_df_filtered <- individual_success_df_filtered %>%
  group_by(subjID, effort_level, successful) %>%
  summarise(count = sum(count), .groups = "drop") %>%
  group_by(subjID, effort_level) %>%
  mutate(proportion = count / sum(count))

proportions_true_filtered <- proportions_df_filtered %>%
  filter(successful == TRUE)

# Plot: New Analysis
# ggplot(proportions_true_filtered, aes(x = effort_level, y = proportion, color = subjID, group = subjID)) +
#   geom_line(size = 1) +
#   geom_point(size = 3) +
#   labs(
#     title = "Proportion of Successful Responses by Effort Level (Filtered Analysis)",
#     x = "Effort Level",
#     y = "Proportion of True",
#     color = "Participant"
#   ) +
#   theme_minimal() +
#   theme(
#     legend.position = "bottom",
#     panel.grid.major = element_line(color = "grey80"),
#     panel.grid.minor = element_blank()
#   )


# Plot both successes and failures with participants' IDs
# Boxplot and Jitter Plot for Both TRUE and FALSE without Labels
# Filter for only FALSE values
# individual_success_false_filtered <- individual_success_df_filtered %>%
#   filter(successful == FALSE)

# Bar plot for counts of unsuccessful responses (FALSE) for each participant and effort level
# ggplot(individual_success_false_filtered, aes(x = factor(effort_level), fill = factor(subjID))) +
#   # Add bars for FALSE counts
#   geom_bar(aes(y = count), stat = "identity", position = position_dodge(width = 0.75)) +
#   labs(
#     title = "Counts of Unsuccessful Responses (FALSE) by Effort Level and Participant",
#     x = "Effort Level",
#     y = "Count of Unsuccessful Responses",
#     fill = "Participant"
#   ) +
#   scale_fill_manual(values = scales::hue_pal()(length(unique(individual_success_false_filtered$subjID)))) +
#   theme_minimal() +
#   theme(
#     legend.position = "right", # Move the legend to the side
#     panel.grid.major = element_line(color = "grey80"),
#     panel.grid.minor = element_blank()
#   )

# Filter for only FALSE values
# individual_success_false_filtered <- individual_success_df %>%
#   filter(successful == FALSE)
# 
# # Bar plot for counts of unsuccessful responses (FALSE) for each participant and effort level
# ggplot(individual_success_false_filtered, aes(x = factor(effort_level), fill = factor(subjID))) +
#   # Add bars for FALSE counts
#   geom_bar(aes(y = count), stat = "identity", position = position_dodge(width = 0.75)) +
#   labs(
#     title = "Counts of Unsuccessful Responses (FALSE) by Effort Level and Participant",
#     x = "Effort Level",
#     y = "Count of Unsuccessful Responses",
#     fill = "Participant"
#   ) +
#   scale_fill_manual(values = scales::hue_pal()(length(unique(individual_success_false_filtered$subjID)))) +
#   theme_minimal() +
#   theme(
#     legend.position = "right", # Move the legend to the side
#     panel.grid.major = element_line(color = "grey80"),
#     panel.grid.minor = element_blank()
#   )



# Create a complete grid of combinations for all participants
proportions_df_filtered_complete <- proportions_df_filtered %>%
  ungroup() %>% # Remove grouping
  complete(
    subjID,
    effort_level = unique(proportions_df_filtered$effort_level),
    successful = c(TRUE, FALSE),
    fill = list(count = 0, proportion = 0)
  ) %>%
  group_by(subjID, effort_level) %>%
  mutate(proportion = count / sum(count)) %>%
  ungroup()


# Filter for TRUE (successes)
proportions_true_filtered_complete <- proportions_df_filtered_complete %>%
  filter(successful == TRUE)

# Plot: Include all participants with zero-filled combinations
# ggplot(proportions_true_filtered_complete, aes(x = effort_level, y = proportion, color = subjID, group = subjID)) +
#   geom_line(size = 1) +
#   geom_point(size = 3) +
#   labs(
#     title = "Proportion of Successes  by Effort Level (Training)",
#     x = "Effort Level",
#     y = "Proportion of Sucesses (out of 2 trials)",
#     color = "Participant"
#   ) +
#   theme_minimal() +
#   theme(
#     legend.position = "bottom",
#     panel.grid.major = element_line(color = "grey80"),
#     panel.grid.minor = element_blank()
#   )

# Calculate mean and standard error of the proportion for each effort level
summary_stats <- proportions_true_filtered_complete %>%
  group_by(effort_level) %>%
  summarize(
    mean_proportion = mean(proportion, na.rm = TRUE),
    se_proportion = sd(proportion, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  )

plot_successes_training <-  ggplot(proportions_true_filtered_complete, aes(x = effort_level, y = proportion, color = subjID, group = subjID)) +
  # Line and points for individual participants
  geom_line(size = 1) +
  geom_point(size = 3) +
  
  # Bars with error bars for overall means
  geom_bar(
    data = summary_stats,
    aes(x = effort_level, y = mean_proportion), # Override global aes
    stat = "identity",
    alpha = 0.4,
    fill = "grey50",
    inherit.aes = FALSE # Prevent inheritance of global aes
  ) +
  geom_errorbar(
    data = summary_stats,
    aes(
      x = effort_level,
      ymin = mean_proportion - se_proportion,
      ymax = mean_proportion + se_proportion
    ), # Override global aes
    width = 0.2,
    color = "black",
    inherit.aes = FALSE # Prevent inheritance of global aes
  ) +
  
  # Labels and theme
  labs(
    title = "Proportion of Successes by Effort Level (Training)",
    x = "Effort Level",
    y = "Proportion of Successes (out of 2 trials)",
    color = "Participant"
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    panel.grid.major = element_line(color = "grey80"),
    panel.grid.minor = element_blank()
  )

if (day == 0 || day == 999) {
  
  print(plot_successes_training)
  
  # Save the plot
  ggsave(paste0(folder_path_pilot_anal, "effort/", exclusion_prefix,"successes_training.jpg"), plot_successes_training, width = 10, height = 6, dpi = 300)
}

# Function to extract and average the second element of each list in a data frame
extract_and_average <- function(df_list) {
  #browser()
  # Use lapply to iterate over each data frame in the list
  result_df <- do.call(rbind, lapply(df_list, function(df) {
    # Extract the second element (assuming it is a named numeric vector)
    props <- df[[2]]
    return(props)
  }))
  result_means <- colMeans(result_df)
  
  return(list(result_df, result_means))
}

#results_mental <- extract_and_average(success_table_mental)[[1]]
results_physical <- extract_and_average(success_table_physical)[[1]]


# Successes and failures

#results_mental_df <- as.data.frame(results_mental)
results_physical_df <- as.data.frame(results_physical)

# Create a function to generate boxplots
generate_boxplot <- function(data, task_type) {
  ggplot(data, aes(x = factor(task_type), y = value, fill = variable)) +
    geom_boxplot() +
    labs(title = paste("Task Success -", task_type), x = "Task", y = "Proportion") +
    scale_fill_manual(values = c("FALSE" = "red", "TRUE" = "green")) +  # Customize fill colors if needed
    scale_y_continuous(breaks = seq(from = 0, 
                                    to = 1, 
                                    by = 0.10))
}

# Reshape the data for ggplot
reshaped_physical <- tidyr::gather(results_physical_df, key = "variable", value = "value")

# Generate boxplots for mental and physical tasks
boxplot_physical <- generate_boxplot(reshaped_physical, "Physical")

# Display the plots
print(boxplot_physical)

#################

################# Extract required n presses #################
# This was useful before I started to output it directly in the column required_presses
# Function to process data frames from each participant
# Suitable only for 4 effort levels
# get_required_presses <- function(df) {
#   
#   
#   titration_perc<-c(0.70, 0.80, 0.90, 1.00)
#   
#   
#   # Filter the data frame
#   df_titration <- df %>%
#     filter(task == 'physical effort outcome' & successful == TRUE) %>%
#     select(subjID, n_presses, effort_level)
#   
#   # Get the maximum pressess from the titraton
#   if (nrow(df_titration) == 0) { 
#     #browser()
#     ind_max <- 22
#   } else {
#     ind_max <- max(df_titration$n_presses) 
#   }
#   
#   # Populate the required n presses array for each effort level
#   required_presses <- c()
#   for (i in 1:length(titration_perc)) {
#     required_presses <- c(required_presses, round(ind_max * titration_perc[i]))
#   }
#   
#   
#   # Get the post-titration trials and the number of presses per each effort level
#   df_post_titr <- df %>%
#     filter(task == 'running training outcome' & successful == TRUE) %>%
#     select(subjID, n_presses, effort_level)
#   
#   # Handle the case where df_post_titr is empty
#   if (nrow(df_post_titr) == 0) {
#     df_post_titr <- tibble(
#       subjID = df$subjID[1],
#       n_presses = NA,  # Placeholder for missing values
#       effort_level = NA # Placeholder for missing values
#     )
#     
#     required_presses <- required_presses * 1.1
#   } else {
#     # If there is at least one row with effort level 6 all values in required presses will be 1.3 times higher
#     # If there is at least one row with effort level 5 all values in required presses will be 1.2 times higher
#     # Otherwise all values will be multiplied by 1.1
#     if (any(df_post_titr$effort_level == 6)) {
#       required_presses <- required_presses * 1.3
#     } else if (any(df_post_titr$effort_level == 5)) {
#       required_presses <- required_presses * 1.2
#     } else {
#       required_presses <- required_presses * 1.1
#     }
#   }
#   
#   
#   
#   # Create a result data frame for each participant
#   result <- df_post_titr %>%
#     distinct(subjID) %>%
#     rowwise() %>%
#     mutate(
#       effort_press_map = list(
#         tibble(
#           effort_level = seq_along(titration_perc),
#           required_presses = round(required_presses)
#         )
#       )
#     )
#   
#   return(result)
#   
# }

# Initialize a list to store results
# all_results <- list()
# 
# # Loop through each data frame in the list of lists
# for (i in seq_along(data_frames)) {
#   # Extract the current data frame
#   current_df <- data_frames[[i]]
#   
#   # Apply the get_required_presses function
#   participant_results <- get_required_presses(current_df)
#   
#   # Store the results in the all_results list with a meaningful name
#   all_results[[paste0("participant_", i)]] <- participant_results
# }
# 
# # Combine all results into a single data frame if needed
# presses_combined_results <- do.call(rbind, all_results)
# 
# # Output the combined results
# print(presses_combined_results)

# Initialize a list to store results
all_results <- list()

# Loop through each data frame in the list of lists
for (i in seq_along(data_frames)) {
  #browser()
  # Extract the current data frame
  current_df <- data_frames[[i]]
  
  # Filter where TRAINING == FALSE
  filtered_df <- current_df %>%
    filter(chosen_task == 'effort')
  
  # Extract the first occurrence of required_presses for each effort_level (1 to 5)
  effort_press_map <- filtered_df %>%
    filter(effort_level %in% 1:5) %>%
    group_by(effort_level) %>%
    slice(1) %>%
    select(effort_level, required_presses)
  
  # Create a participant_results tibble
  participant_results <- tibble(
    subjID = unique(current_df$subjID),
    effort_press_map = list(effort_press_map)
  )
  
  # Store the results in the all_results list with a meaningful name
  all_results[[paste0("participant_", i)]] <- participant_results
}

# Combine all results into a single data frame if needed
presses_combined_results <- bind_rows(all_results)

# Output the combined results
print(presses_combined_results)


### Now add it to the data frame with proportion accepted efforts and rewards
# (i.e., combined_df_reward and combined_df_effort)

# Expand presses_combined_results into a single data frame without duplicate subjID
# Step 1: Expand presses_combined_results into a single data frame
presses_expanded <- presses_combined_results %>%
  unnest(effort_press_map, names_sep = "_")

# Step 2: Rename the columns for clarity
presses_expanded <- presses_expanded %>%
  rename(
    effort_level = effort_press_map_effort_level,
    required_presses = effort_press_map_required_presses
  )

# Join with the second data frame to add the n_presses column
presses_expanded$subjID <- as.character(presses_expanded$subjID)

combined_df_effort_presses <- combined_df_effort %>%
  left_join(presses_expanded, by = c("participant" = "subjID", "effort" = "effort_level"))

# Plot
average_prop_effort_presses <- combined_df_effort_presses %>%
  group_by(required_presses) %>%
  summarise(mean_average_prop = mean(average_prop))

plot_required_presses <- ggplot(average_prop_effort_presses, aes(x = factor(required_presses), y = mean_average_prop)) +
  # geom_bar(stat = "identity", fill = "steelblue") +
  geom_jitter(data = combined_df_effort_presses, 
              aes(x = factor(required_presses), y = average_prop, color = participant), 
              width = 0.1, height = 0) +
  geom_line(data = combined_df_effort_presses, 
            aes(x = factor(required_presses), y = average_prop, group = participant, color = participant), 
            alpha = 0.5) +
  labs(x = "Required Presses", y = "Proportion Accepted", title = "Proportion Accepted Offers per Required Presses") +
  scale_x_discrete(name = "Required Presses") +
  theme(
    panel.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(colour = "black"),
    legend.position = "none"  # This hides the legend
    
  )
print(plot_required_presses)

# Save the plot
ggsave(paste0(folder_path_pilot_anal, "effort/", exclusion_prefix,"effort_presses.jpg"), plot_required_presses, width = 10, height = 6, dpi = 300)

### Calculating differences between within-subject differences in number of presses between effort levels

# Step 1: Calculate average difference in required presses for each participant
required_presses_df <- combined_df_effort_presses %>%
  group_by(participant) %>%
  arrange(effort) %>% # Ensure effort levels are ordered
  mutate(diff_presses = required_presses - lag(required_presses)) %>% # Calculate difference
  summarise(
    avg_difference = round(mean(diff_presses, na.rm = TRUE), 0), # Average difference (rounded)
    .groups = "drop"
  )

# View the resulting data frame
print(required_presses_df)

# Step 2: Plot histogram of average differences
ggplot(required_presses_df, aes(x = avg_difference)) +
  geom_histogram(binwidth = 1, fill = "blue", color = "white", alpha = 0.7) +
  labs(
    title = "Histogram of Average Differences in Required Presses",
    x = "Average Difference in Required Presses",
    y = "Count of Participants"
  ) +
  theme_minimal()

#########################################

get_titration_presses <- function(df) {
  #browser()
  df_proc <- df$df_filtered %>%
    filter(task == 'physical titration outcome') %>%
    select(subjID, n_presses)
  
  df_proc <- df_proc[-5, , drop = FALSE]

  
  return(df_proc)
}

titration_presses <- lapply(processed_data, get_titration_presses)

titration_all <- bind_rows(titration_presses, .id = "subjID")
titration_all <- titration_all %>%
  filter(!is.na(n_presses)) %>%
  group_by(subjID) %>%
  mutate(occurrence = row_number())
#################

# Investigate the relationship between the titration and acceptance rate 
# First extract the max n_presses during the titration
df_titration_max <- titration_all %>%
  # Extract the participant ID from subjID
  mutate(participant = basename(subjID)) %>%
  # Group by participant
  group_by(participant) %>%
  # Calculate the max value of n_presses for each participant
  summarise(max_presses = max(n_presses)) %>%
  # Ungroup to make sure the resulting data frame isn't grouped
  ungroup()

# Merge with the df of average acceptance rate participant_avg_df
titration_acceptance_df <- merge(df_titration_max, participant_avg_df, by = "participant")

# Create the scatter plot
ggplot(titration_acceptance_df, aes(x = max_presses, y = prop)) +
  geom_point() +  # Adds the points
  geom_smooth(method = "lm", se = FALSE, color = "blue") +  # Adds a linear trend line (optional)
  labs(title = "Scatter Plot of Max Presses vs. Prop",
       x = "Max Presses",
       y = "Proportion") +
  theme_minimal()  # Uses a minimal theme for the plot


# plot the n_presses during titration
titration_all %>%
  filter(!is.na(n_presses)) %>%
  group_by(occurrence) %>%
  ggplot(aes(x = as.factor(occurrence), y = n_presses, group = as.factor(occurrence), color = occurrence)) +
  geom_boxplot() +
  #geom_point(position = position_dodge(width = 0), size = 2) +
  geom_jitter(width = 0.3, height = 0, alpha = 0.5, size=2) +
  #geom_line(aes(group = subjID), position = position_dodge(width = 0)) +
  labs(title = "Box Plot of n_presses by Occurrence",
       x = "Occurrence",
       y = "n_presses") +
  theme_minimal() +
  scale_x_discrete(breaks = seq(1, max(titration_all$occurrence), by = 1))

# Look at the association between the training choices and the max presses
if (day == 0 || day == 999) {
  # Assuming processed_data is your list of participant data frames
  df_training_choices <- data.frame()  # Initialize an empty data frame
  
  for (i in seq_along(processed_data)) {
    
    # Extract the relevant data frame for participant i
    df_filtered <- processed_data[[i]]$df_filtered
    
    # Filter the data for the specific task and where training is TRUE
    #df_subset <- df_filtered[df_filtered$task == "phys effort training outcome" & df_filtered$training == TRUE, ]
    df_subset <- df_filtered %>%
      filter(training == TRUE & task == "phys effort training outcome")
     
    # Get the last four rows of the filtered data
    if(nrow(df_subset) > 4) {
      df_subset <- tail(df_subset, 4)
    }
    
    # Replace NA values in n_presses with 0
    df_subset$n_presses[is.na(df_subset$n_presses)] <- 0
    #browser()
    # Sum the n_presses column
    total_presses <- sum(df_subset$n_presses)
    
    # Get the subjID for the current participant
    subjID <- df_subset$subjID[1]
    
    # Get the number of times effort was chosen during the training
    effort_chosen_tibble <- df_subset %>% count(chosen_task == "effort")
    effort_chosen <- effort_chosen_tibble$n
    
    # Add the results to the final data frame
    df_training_choices <- rbind(df_training_choices, data.frame(subjID = subjID, total_presses = total_presses, effort_chosen = effort_chosen))
  }
  
  # Merge it with the titration_acceptance df
  df_training_choices <- df_training_choices %>%
    mutate(participant = subjID) %>%
    select(-subjID)
  
  titration_acceptance_df <- merge(titration_acceptance_df, df_training_choices, by = "participant")


  # Correlation between presses (total_presses) during the training (4 trials) and acceptance rate throughout the task (prop)
  ggplot(titration_acceptance_df, aes(x = total_presses, y = prop)) +
    geom_point() +  # Adds the points
    geom_smooth(method = "lm", se = FALSE, color = "blue") +  # Adds a linear trend line (optional)
    labs(title = "Scatter Plot of Total Presses during training vs. Prop accepted",
         x = "Total Presses during training",
         y = "Proportion Accepted") +
    theme_minimal()  # Uses a minimal theme for the plot
  
  cor.test(titration_acceptance_df$prop, titration_acceptance_df$total_presses)
  
  # Correlation between acceptance of effort offers during the training (4 trials) and acceptance rate throughout the task (prop)
  ggplot(titration_acceptance_df, aes(x = effort_chosen, y = prop)) +
    geom_point() +  # Adds the points
    geom_smooth(method = "lm", se = FALSE, color = "blue") +  # Adds a linear trend line (optional)
    labs(title = "Scatter Plot of Total Presses during training vs. Prop accepted",
         x = "Effort Offers Accepted During Training",
         y = "Proportion Accepted") +
    theme_minimal()  # Uses a minimal theme for the plot
  
  cor.test(titration_acceptance_df$prop, titration_acceptance_df$effort_chosen, method = "spearman")
}
################# Required n presses vs reward ################

# First plot the required n presses for each participant


# Second plot the required n presses and reward

################# Timeout warnings ################

extract_timeout_warnings <- function(data_frames) {
  
  df_timeout_warnings <- lapply(data_frames, function(df) {
    #browser()
    df %>%
      filter(task == "timeout warning") %>%
      summarise(subjID = first(subjID), num_timeout_warnings = n())
  }) %>%
    bind_rows()  # Combine into a single data frame
  
  return(df_timeout_warnings)
}

df_timeout_warnings <- extract_timeout_warnings(data_frames)

# Function to extract total decisions
extract_total_decisions <- function(data_frames) {
  df_total_decisions <- lapply(data_frames, function(df) {
    
    #browser()
    df %>%
      filter(task == "offer") %>%
      summarise(subjID = first(subjID), total_decisions = n())
  }) %>%
    bind_rows()
  
  return(df_total_decisions)
}

# Example of how to use it
df_total_decisions <- extract_total_decisions(data_frames)

# Join with timeout warnings and compute percent missed
df_percent_missed <- df_timeout_warnings %>%
  inner_join(df_total_decisions, by = "subjID") %>%
  mutate(percent_missed = num_timeout_warnings / total_decisions)

# Export the percent missed df to .csv file
write.csv(df_percent_missed, paste0(folder_path_pilot_anal, "effort/", exclusion_prefix,"timeout_warnings.csv"), row.names = FALSE)

# plot it

# df_timeout_warnings$short_id <- str_sub(df_timeout_warnings$subjID, -3)  # Extract last 3 chars
# highlight_ids <- c("3fd", "bdb", "750")  # IDs to highlight
# 
# ggplot(df_timeout_warnings, aes(x = "", y = num_timeout_warnings)) +
#   geom_boxplot(outlier.shape = NA) +  # Boxplot without outliers
#   geom_jitter(aes(color = short_id), width = 0.1, size = 3, alpha = 0.7) +  # Color dots by ID
#   geom_text(aes(label = short_id, color = short_id), 
#             position = position_jitter(width = 0.1), 
#             size = 3, vjust = -0.5) +  # Label dots
#   scale_color_manual(values = setNames(
#     c("red", "blue", "green", rep("grey", length(unique(df_timeout_warnings$short_id)) - 3)), 
#     c(highlight_ids, setdiff(unique(df_timeout_warnings$short_id), highlight_ids))
#   )) +  
#   labs(title = "Distribution of Timeout Warnings", 
#        y = "Number of Timeout Warnings", 
#        x = "") +
#   theme_minimal() +
#   theme(legend.position = "none")  # Remove legend

################# RT analysis ###############################
# Extract the reaction times for each participant

extract_reaction_times <- function(data_frames) {
  
  #browser()  # Debugging breakpoint (remove later if not needed)
  
  df <- data_frames$df_filtered  # Ensure you're working with the correct data
  
  df_reaction_times <- df %>%
    filter((task == "offer" | task == "physical effort outcome" | task == "physical rest" | task == "timeout warning") & (is.na(training) | training == FALSE)) %>%  # Keep FALSE or missing (NA)
    # select(any_of(c("subjID", "rt", "effort_level", "effort_credits")))  # Select only available variables
    select("subjID","task", "rt", "effort_level", "effort_credits")  # Select only available variables
  
  # Function to adjust RTs based on timeout warnings
  adjust_rt <- function(df) {
    last_valid_rt <- NA
    timeout_count <- 0
    df$rt <- as.numeric(df$rt)  # Convert RT to numeric
    
    for (i in seq_len(nrow(df))) {
      if (df$task[i] == "offer") {
        if (!is.na(df$rt[i])) {  # Found a valid RT
          if (timeout_count > 0) {
            df$rt[i] <- df$rt[i] + (timeout_count * 2000)  # Adjust RT
            timeout_count <- 0  # Reset counter
          }
          last_valid_rt <- df$rt[i]  # Update last valid RT
        }
      } else if (df$task[i] == "timeout warning") {
        timeout_count <- timeout_count + 1  # Count timeouts
      }
    }
    
    return(df)
  }
  
  # Apply RT adjustment
  df_reaction_times <- adjust_rt(df_reaction_times)
  
  
  fill_effort_values <- function(df) {
    df <- df %>%
      #arrange(subjID, row_number()) %>%  # Ensure proper ordering
       fill(effort_level, effort_credits, .direction = "up") #%>%  # Copy down values
      # mutate(effort_level = ifelse(task == "offer", effort_level, NA),
      #        effort_credits = ifelse(task == "offer", effort_credits, NA))
    
    return(df)
  }
  
  # Apply function
  df_reaction_times <- fill_effort_values(df_reaction_times)
  
  # Log transformation of reaction times
  df_reaction_times$rt_log <- log(df_reaction_times$rt)
  
  # Add chosen_task column
  df_reaction_times <- df_reaction_times %>%
    mutate(chosen_task = case_when(
      task == "offer" & lead(task) == "physical rest" ~ "rest",
      task == "offer" & lead(task) == "physical effort outcome" ~ "effort",
      TRUE ~ NA_character_
    ))
  
  # Remove rows where RT is NA
  df_reaction_times <- df_reaction_times %>%
    filter(!is.na(rt))
  
  return(df_reaction_times)
}

# Apply the function to each dataset in processed_data
output_rt <- lapply(processed_data, extract_reaction_times)

### Run the regression to get an individual effect of RT on effort and reward
# Function to run regression per participant
run_regression_per_subject <- function(df) {
  
  
  
  # Filter for trials where chosen task is "effort"
  df_effort <- df %>% filter(chosen_task == "effort")
  
  # df_effort <- df %>%
  #   mutate(effort_level = ifelse(chosen_task == "rest", 0, effort_level),
  #          effort_credits = ifelse(chosen_task == "rest", 1, effort_credits))

  # Run the regression only if there are enough valid trials
  if (nrow(df_effort) > 1) {
    model <- lm(rt_log ~ effort_level + effort_credits, data = df_effort)
    # browser()
    result <- tidy(model) %>%
      select(term, estimate) %>%
      pivot_wider(names_from = term, values_from = estimate) %>%
      mutate(subjID = unique(df_effort$subjID))
  } else {
    # Return NA if not enough trials for regression
    result <- tibble(subjID = unique(df_effort$subjID), `(Intercept)` = NA, effort_level = NA, effort_credits = NA)
  }
  
  return(result)
}

# Apply function to each participant's dataset
beta_coefficients <- bind_rows(lapply(output_rt, run_regression_per_subject))

# View the extracted beta coefficients
print(beta_coefficients)

# Plot the beta coefficients as boxplots
beta_coefficients_long <- pivot_longer(beta_coefficients, cols = c(effort_level, effort_credits), names_to = "Variable", values_to = "Beta")

ggplot(beta_coefficients_long, aes(x = Variable, y = Beta)) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(aes(color = Variable), width = 0.1, height = 0, alpha = 0.7) +
  labs(title = "Beta Coefficients of RT on Effort and Reward",
       x = "Variable",
       y = "Beta Coefficient") +
  theme_minimal()

# Compare the differences in beta coefficients between effort and reward
t.test(beta_coefficients$effort_level, beta_coefficients$effort_credits, paired = TRUE)

# Print means of beta coefficients
print(mean(beta_coefficients$effort_level, na.rm = TRUE))
print(mean(beta_coefficients$effort_credits, na.rm = TRUE))

# Convert the list of data frames to a single data frame
output_rt_df <- bind_rows(output_rt, .id = "source")

# Compute the average rt_log for each participant
rt_avg_df <- output_rt_df %>%
  group_by(subjID) %>%
  summarise(rt_log = mean(rt_log, na.rm = TRUE))

# Rename 'participant' to 'subjID' in participant_avg_df
participant_avg_df <- participant_avg_df %>%
  rename(subjID = participant)

# Correlate the RT with the acceptance rate
rt_avg_df$subjID <- as.character(rt_avg_df$subjID)

rt_prop_df <- participant_avg_df %>%
  left_join(rt_avg_df, by = "subjID")

# Plot the correlation and calculate the correlation
ggplot(rt_prop_df, aes(x = rt_log, y = prop)) +
  geom_point() +
  geom_smooth(method = "lm", se = TRUE, color = "blue") +
  labs(title = "Scatter Plot of RT vs. Prop",
       x = "RT (log-transformed)",
       y = "Prop accepted") +
  theme_minimal()

# Calculate the correlation
cor.test(rt_prop_df$rt_log, rt_prop_df$prop)

# Test the RTs against zero
t.test(beta_coefficients$effort_credits)
t.test(beta_coefficients$effort_level)

# Save beta coefficients to a CSV file
beta_coefficients <- beta_coefficients %>%
  select(subjID, effort_level, effort_credits)  # Select only relevant columns

write.csv(beta_coefficients, file = paste0(folder_path_pilot_anal, "effort/", exclusion_prefix,"effort_betas_day_",day,".csv"), row.names = FALSE)

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

# Get the debrief questionnaire results for each participant
output_debrief <- lapply(data_frames, debriefing_current_task, 'phys')

# Convert each sublist to a dataframe with only the second value
output_debrief_df <- lapply(output_debrief, function(x) {
  as.data.frame(lapply(x, function(y) y[2]))
})

# Combine all dataframes into one
output_debrief_df <- do.call(rbind, output_debrief_df)

# Save the debriefing df
write.csv(output_debrief_df, paste0("../../output/session",day,"/effort/debrief.csv"),row.names = FALSE)

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
  labs(x = "Ratings", y = "Score", title = "Physical Debrief Ratings") +
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

###### Feedback ######
extract_debrief_data <- function(processed_data) {
  debrief_list <- list()
  
  for (participant_id in names(processed_data)) {
    # Navigate to df_filtered
    if ("df_filtered" %in% names(processed_data[[participant_id]])) {
      df_filtered <- processed_data[[participant_id]]$df_filtered
      
      # Filter for debrief data based on the 'task' column
      debrief_data <- df_filtered %>%
        filter(task %in% c("debrief_phys_1"))
      
      if (nrow(debrief_data) > 0) {
        # Add participant ID for traceability
        debrief_data <- debrief_data %>%
          mutate(participant_id = participant_id)
        
        # Append to the list
        debrief_list[[participant_id]] <- debrief_data
      } else {
        message(glue::glue("No debrief data found for participant: {participant_id}"))
      }
    } else {
      message(glue::glue("No df_filtered found for participant: {participant_id}"))
    }
  }
  
  if (length(debrief_list) > 0) {
    combined_debrief <- bind_rows(debrief_list, .id = "participant_key")
  } else {
    message("No debrief data found in the entire dataset.")
    combined_debrief <- tibble()
  }
  
  return(combined_debrief)
}

raw_feedback_df <- extract_debrief_data(processed_data)

# Assuming your data frame is named `feedback_df`
feedback_df <- raw_feedback_df %>%
  select(subjID, response) %>%               # Keep only subjID and response
  mutate(
    # Parse the JSON content in the response column
    parsed_response = map(response, ~ fromJSON(.) %>% as.list()),
    # Extract the required fields from the parsed response
    strategy = map_chr(parsed_response, ~ .[["strategy"]]),
    threshold_effort = map_chr(parsed_response, ~ .[["threshold_effort"]]),
    threshold_reward = map_chr(parsed_response, ~ .[["threshold_reward"]])
  ) %>%
  select(subjID, strategy, threshold_effort, threshold_reward)  # Keep only required columns

# View the processed data frame
print(feedback_df)

###### Get a trial-by-trial data frame for each participant ######
trial_df <- function(df, effort_type) {
 
  #browser()
  filtered_df <- df$df_filtered
  this_subj <- filtered_df$subjID[[1]]
  this_subj <- as.character(this_subj)
  print(paste("Processing subject:", this_subj))
  
  if (effort_type == 'physical') {
    task_effort <- 'physical effort outcome'
    task_rest <-  'physical rest'
  } else if (effort_type == 'mental') {
    task_effort <- 'mental effort outcome'
    task_rest <- 'mental rest'
  }
  
  out <- filtered_df %>% 
    filter(task == task_effort | task == task_rest) %>%
    select(trial_number, effort_level, effort_credits, effort_type, training, chosen_task, n_presses, successful)
  
  if (effort_type == 'physical') {
    best_titration <- titration_all %>%
      filter(str_detect(subjID, this_subj) & n_presses == max(n_presses)) %>%
      slice_head(n = 1) %>%
      mutate(max_presses = n_presses)
    max_titr_num <- best_titration[1,4]
    
    out <- cbind(out, max_titr_num)
  }
  
  
  return(out)
}

trial_data_physical <- lapply(processed_data, trial_df, 'physical')

####### ANOVA #######

# Run ANOVA
anova_result <- ezANOVA(
  data = combined_df,
  dv = .(prop),
  wid = .(participant),
  within = .(effort, reward),
  #between = .(effort, reward),
  detailed = TRUE
)

effort_anova_result <- nice_table(anova_result$ANOVA, title = c("Table 2","Effort Anova Results"))

### Do a logistic regression for the paper ###
# Combine the lists into a df
trial_data_physical_df <- bind_rows(
  lapply(seq_along(trial_data_physical), function(i) {
    df <- trial_data_physical[[i]]
    df$subjID <- i  # Add subject ID as the index in the list
    return(df)
  })
)

trial_data_physical_df$chosen_task <- as.factor(trial_data_physical_df$chosen_task)
trial_data_physical_df$chosen_task <- relevel(trial_data_physical_df$chosen_task, "rest")

# prop_effort_regression <- glm(
#   chosen_task  ~ effort_level * effort_credits + (1 | subjID),
#   data = trial_data_physical_df,
#   family = binomial(link = "logit")
# )

prop_effort_regression <- glmer(chosen_task  ~ effort_level * effort_credits + (1 | subjID), 
                               data = trial_data_physical_df, 
                               family = binomial(link = "logit"))

summary(prop_effort_regression)

####### catch trials
catch_trial_fun <- function(df) {
  df_catch <- df %>% 
    filter(task == 'catch_trial') %>%
    select(subjID, rt, task, response, correct)
  return(df_catch)
}

df_catch <- lapply(data_frames, catch_trial_fun)
#print(df_catch) # for initial inspection of single participants

df_catch_all <- bind_rows(df_catch, .id = "source")

write.csv(df_catch_all, paste0(folder_path_pilot_anal,'effort_catch_trials.csv' )) 


################ GET DATA FOR MODELLING ###########################
# df <- data_frames[[1]]
get_comp_matrix <- function(df) {
  
  #trial, effort, reward, chosen_task, n_presses, successful, max_presses
  #browser()
  # preprocessing - extract task data
  df_task <- df 
  
  df_task <- df_task %>%
    mutate(chosen_effort = case_when(
      chosen_task == 'effort' ~ 1,
      chosen_task == 'rest' ~ 0,
      TRUE ~ NA_real_  # This line handles any unexpected values by assigning NA
    ))
  
  df_task <- df_task %>%
    mutate(successful = case_when(
      successful == TRUE ~ 1,
      successful == FALSE ~ 0,
      TRUE ~ NA_real_  # This line handles any unexpected values by assigning NA
    ))
  
  chosen_effort <- df_task %>%
    pull(chosen_effort)
  
  successful <- df_task %>%
    pull(successful)
  
  # extract the actions
  trial <- df_task %>%
    pull(trial_number)
  
  # extract set sizes
  effort <- df_task %>%
    pull(effort_level)
  
  # extract correct responses and change to 1/0 (reward)
  reward <- df_task %>%
    pull(effort_credits)
  

  # extract stimulus
  presses <- df_task %>%
    pull(n_presses)
  
  # block_index
  MVC <- df_task %>%
    pull(max_presses)
    
  return(list(chosen_effort=chosen_effort, successful=successful,trial=trial,effort=effort,reward=reward,presses=presses,MVC=MVC))
}

#output_mental <- lapply(trial_data_mental, get_comp_matrix)
slice_rows <- 0

if (omit_iteration > 0) {
  slice_rows <- effort_levels_num * reward_levels_num * omit_iteration
  
  # Remove the first rows of each participant's data
  trial_data_physical <- lapply(trial_data_physical, function(x) x[-(1:slice_rows), ])
}



output_physical <- lapply(trial_data_physical, get_comp_matrix)

comp_output_folder <- "comp_modelling/effort/"

# Check if the folder exists, and create it if it doesn't
if (!dir.exists(comp_output_folder)) {
  dir.create(comp_output_folder,recursive = TRUE)
}

physical_chosen_effort_matrix <- do.call(rbind, lapply(output_physical, function(x) x$chosen_effort)) 
physical_success_matrix <- do.call(rbind, lapply(output_physical, function(x) x$successful)) 
physical_trial_matrix <- do.call(rbind, lapply(output_physical, function(x) x$trial)) 
physical_effort_matrix <- do.call(rbind, lapply(output_physical, function(x) x$effort)) 
physical_reward_matrix <- do.call(rbind, lapply(output_physical, function(x) x$reward))  
physical_presses_matrix <- do.call(rbind, lapply(output_physical, function(x) x$presses)) 
physical_MVC_matrix <- do.call(rbind, lapply(output_physical, function(x) x$MVC))  


write.table(physical_chosen_effort_matrix, paste0(comp_output_folder,exclusion_prefix, 'physical_chosen_effort_matrix.csv'), row.names = FALSE, col.names = FALSE, sep=",")
write.table(physical_success_matrix,paste0(comp_output_folder,exclusion_prefix, 'physical_success_matrix.csv'), row.names = FALSE, col.names = FALSE, sep=",")
write.table(physical_trial_matrix,paste0(comp_output_folder,exclusion_prefix, 'physical_trial_matrix.csv'), row.names = FALSE, col.names = FALSE, sep=",")
write.table(physical_effort_matrix,paste0(comp_output_folder,exclusion_prefix, 'physical_effort_matrix.csv'), row.names = FALSE, col.names = FALSE, sep=",")
write.table(physical_reward_matrix,paste0(comp_output_folder,exclusion_prefix, 'physical_reward_matrix.csv'), row.names = FALSE, col.names = FALSE, sep=",")
write.table(physical_presses_matrix, paste0(comp_output_folder,exclusion_prefix,'physical_presses_matrix.csv'), row.names = FALSE, col.names = FALSE, sep=",")
write.table(physical_MVC_matrix,paste0(comp_output_folder,exclusion_prefix, 'physical_MVC_matrix.csv'), row.names = FALSE, col.names = FALSE, sep=",")