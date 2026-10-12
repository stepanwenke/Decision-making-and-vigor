#libraries
library(tidyverse) # tidy functions (including readr)
library(psych)
library(lsmeans)
library(ggsignif)
library(pixiedust)
library(rempsyc)
library(gridExtra)
library(grid)
library(nlme)
library(lme4)
library(lmerTest)
library(ez)
library(irr)
library(broom)


# Galaxies (conditions):
## Galaxy0: short-steep
## Galaxy1: long-steep
## Galaxy2: short-shallow
## Galaxy3: long-shallow


# Get the directory where the R script file is located
#script_dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
#dataPath <- paste(script_dir, "/data/output/adrian/foraging_data.csv", sep="") # path to data file

#set wd to analysis folder
script_dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
if (getwd() != script_dir) {
  setwd(script_dir)
} else {
  message("The script_dir is the same as the current working directory.")
}

source("helpers/foraging_exit_thresholds_calc.R")

# Session 1 or 2
day <- 2

# Set the working directory to the data folder
setwd(paste0("../data/session", day))

# Set the <- folder
output_folder <- "output/"

# Get list of subfolders (assuming they are all named 's' followed by numbers)
subfolders <- list.dirs(path = output_folder, full.names = TRUE, recursive = FALSE)

# Initialize a list to store data frames
data_frames <- list()

# Loop through each subfolder and read the CSV file
for (i in seq_along(subfolders)) {
  subfolder <- subfolders[i]
  file_path <- file.path(subfolder, "foraging_data.csv")
  
  # Check if the file exists before reading
  if (file.exists(file_path)) {
    data_frames[[subfolder]] <- read_csv(file_path)
  }
}

exclude_ids <- c()

exclude_ids <- paste0("output/", exclude_ids)


data_frames <- data_frames[!(names(data_frames) %in% exclude_ids)]


# Check it and create the folder if it doesn't exist
folder_path_pilot_anal <- paste0("../../output/session", day, "/")

# Check if the folder exists, and create it if it doesn't
if (!dir.exists(folder_path_pilot_anal)) {
  dir.create(folder_path_pilot_anal)
}

if (!dir.exists(paste0(folder_path_pilot_anal, "foraging/"))) {
  dir.create(paste0(folder_path_pilot_anal, "foraging/"))
}


#optimal_exits <- c(5.88088,6.55581,7.73821,8.04002)
optimal_exits <- c(4.64,6.55581,6.00,8.04002)
default_cond_order <- c('long-steep','long-shallow','short-steep','short-shallow')

# single participant
#data_frames <- data_frames[20]

# Remove STEWEN because he never travelled (test trial)
#data_frames <- data_frames[1:2]

#data_frames <- data_frames[12] # Weird presses n.1
#data_frames <- data_frames[45] # Weird presses n.2

calculate_exit_thresholds <- function(dataPath) {
  # Read data (in Tibble)
  #browser()
  #df <- read_csv(dataPath)
  df <- dataPath
  
  # Extract participant ID from the subjID column
  participant_id <- unique(df$subjID)
  
  # Extract participant ID from file path
  #participant_id <- gsub("[^[:digit:]]", "", basename(dataPath))
  
  # calculate exit thresholds
  
  df <- foraging_exit_thresholds_calc(dataPath)
  
  # Check catch trials (attention checks)
  df_catch <- df %>%
    filter(task == 'catch_trial') %>%
    select(task, subjID, rt, response, correct_response, correct)
  

  
  
  # Preprocessing - extract task data
  df_task <- df %>%
    select(trial_type,  rt, response, next_reward, planet, aliens, reward_received, decay_rate_actual, decay_rate_exp, time_in_block, 
           block_num, prt, last_trial_on_planet, time_in_block, galaxy_type, task, exit_threshold) %>%
    filter(trial_type == 'alien_welcome'  | trial_type == 'land' | trial_type == 'dig' | trial_type == 'harvest' | trial_type == 'decision')
  
  # Get condition order
  df_harvest <- df_task %>%
    filter(trial_type == 'harvest')
  conditions <- c("short-steep", "long-steep", "short-shallow", "long-shallow")
  galaxy_types <- df_harvest %>%
    pull(galaxy_type) + 1
  cond_order <- conditions[unique(galaxy_types)]
  
  # Get travel times of the corresponding conditions
  travel_times_general <- c(6, 12, 6, 12)
  travel_times <- travel_times_general[unique(galaxy_types)]
  
  # Time in each block in minutes and seconds (for plotting)
  df_task <- df_task %>%
    mutate(time_in_block_sec = time_in_block / 1000,
           time_in_block_min = (time_in_block / 1000) / 60)
  
  # Time in experiment. Add block_nr x 6.5 to time in block
  df_task <- df_task %>%
    mutate(time_foraging_min = ((block_num -1 ) * 6.5) + time_in_block_min,
           travel_time_min = travel_times[block_num] / 60)
  
  # Get the trials where participant traveled
  df_leave <- df_task %>%
    filter(response == 'l' & !is.na(exit_threshold)) %>%
    select(trial_type, block_num, exit_threshold, time_in_block_min, time_foraging_min, travel_time_min)
  
  # Plot exit thresholds over time
  flat_length <- df_leave %>%
    pull(travel_time_min)
  block_num <- df_leave %>%
    pull(block_num)
  
  # Create the line plots for each condition
  x <- df_leave %>%
    pull(time_foraging_min)
  y <- df_leave %>%
    pull(exit_threshold)
  
  # Sample data
  df_to_plot <- data.frame(
    x  = x,
    y  = y,
    fl = flat_length,
    bn = block_num,
    cond = cond_order[block_num],
    id = participant_id
  )
  
  # Add optimal_exit column to df_to_plot
  df_to_plot$optimal_exit <- optimal_exits[match(df_to_plot$cond, default_cond_order)]
  
  # Create intermediate points
  extended_data <- df_to_plot %>%
    rowwise() %>%
    do({
      data.frame(x = c(.$x, .$x + .$fl),
                 y = rep(.$y, 2),
                 fl = rep(.$fl, 2),
                 bn=rep(.$bn,2),
                 cond=rep(.$cond,2),
                 id = participant_id,
                 optimal_exit = rep(.$optimal_exit, 2))
    }) %>%
    ungroup()
  
  avg_threshold_blocks <- sapply(1:4, function(i) {
    df_leave %>%
      filter(block_num == i) %>%
      summarise(mean_threshold = mean(exit_threshold, na.rm = TRUE)) %>%
      pull(mean_threshold)
  })
  
  # Plot exit thresholds in blocks
  df_to_plot <- data.frame(Category = factor(1:4), Mean = avg_threshold_blocks)
  # ggplot(data = df_to_plot) + aes(x = Category, y = Mean) + 
  #   geom_bar(stat = "identity", fill = "black") + 
  #   labs(title = "Exit Thresholds", x = "Block", y = "Mean Exist Threshold") + 
  #   scale_y_continuous(breaks = c(0,20,40,60,80,100), limits = c(0, 100)) +
  #   scale_x_discrete(labels = cond_order) +
  #   theme_minimal()
  
  # Create a data frame for average values and corresponding x-axis limits
  average_data <- data.frame(bn = rep(1:4),
                             mean_value = avg_threshold_blocks,
                             x_start = tapply(extended_data$x, extended_data$bn, min),
                             x_end = tapply(extended_data$x, extended_data$bn, max))
  
  # Add mean_value to extended_data based on bn and cond
  extended_data <- merge(extended_data, average_data[, c("bn", "mean_value")], by = "bn")
  
  # Assuming 'all_conditions_data' is the combined data for all participants
  all_conditions_data <- extended_data
  
  return(list(extended_data = extended_data, average_data = average_data, cond_order = cond_order, participant_id = participant_id))
}

output <- lapply(data_frames, calculate_exit_thresholds)


# Extract the data for each participant from processed_data list
extract_total_time <- function(df) {
  #browser()
  subjID <- df$subjID[1]
  
  # Find the index of the row where trial type is "instruc_begin_exp"
  instruc_index <- which(df$trial_type == "instruc_begin_exp")[1]
  
  # Create only_training_df with all rows from 1 to instruc_index
  only_training_df <- df[1:instruc_index, ]
  
  total_time_training <- max(only_training_df$time_elapsed) - min(only_training_df$time_elapsed)
  
  # Create only_task_df with all remaining rows
  only_task_df <- df[(instruc_index + 1):nrow(df), ]
  total_time_task <- max(only_task_df$time_elapsed) - min(only_task_df$time_elapsed)
  
  # Convert times to minutes and round to 2 decimals
  foraging_training <- round(total_time_training / 60000, 2)
  foraging_task <- round(total_time_task / 60000, 2)
  foraging_total_time <- round(foraging_training + foraging_task, 2)
  
  return(data.frame(
    subjID = subjID,
    foraging_training = foraging_training,
    foraging_task = foraging_task,
    foraging_total_time = foraging_total_time
  ))
}

total_time_df <- do.call(rbind, lapply(data_frames, extract_total_time))
rownames(total_time_df) <- NULL

# Save the time elapsed data frame to <- a CSV file
write.csv(total_time_df, paste0(folder_path_pilot_anal, "foraging_time_elapsed.csv"), row.names = FALSE)



# Assuming 'all_conditions_data' contains the combined data for all participants
# Extract data for all conditions
all_conditions_data <- lapply(output, function(participant_output) {
  participant_output$extended_data %>%
    group_by(id) %>%
    mutate(relative_x = x - min(x)) %>%
    ungroup()
})

# Combine the data into a single data frame
all_conditions_data <- do.call(rbind, all_conditions_data)

# Calculate relative_x for each participant and condition
all_conditions_data <- all_conditions_data %>%
  group_by(id, cond) %>%
  mutate(relative_x = x - min(x)) %>%
  ungroup()


# Compute mean optimal_exit for each condition
mean_optimal_exit <- all_conditions_data %>%
  group_by(cond) %>%
  summarize(mean_optimal_exit = mean(optimal_exit, na.rm = TRUE))

without_outlier <- all_conditions_data

# # plot the exit threshold boxplots by condition
df_avg_thresholds <- without_outlier %>% # all_conditions_data (5a94ee9bf6dfdd0001ea50f1 removed outlier)
  select(id, cond, mean_value) %>%
  distinct()


# Get the total number of missed trials
extract_timeout_and_decisions <- function(data_frames) {
  df_summary <- lapply(data_frames, function(df) {
    subj_id <- first(df$subjID)
    
    num_timeouts <- df %>%
      filter(trial_type == "time_out") %>%
      nrow()
    
    num_decisions <- df %>%
      filter(trial_type %in% c("decision", "decision_prac")) %>%
      nrow()
    
    tibble(subjID = subj_id,
           num_timeouts = num_timeouts,
           num_decisions = num_decisions)
  }) %>%
    bind_rows()
  
  return(df_summary)
}

# Example usage:
df_timeout_summary <- extract_timeout_and_decisions(data_frames)

df_timeout_summary <- df_timeout_summary %>%
  mutate(timeout_rate = num_timeouts / num_decisions)

print(df_timeout_summary)

# Save the df_timeout summary
write.csv(df_timeout_summary, paste0(folder_path_pilot_anal, "foraging/foraging_timeout_summary.csv"), row.names = FALSE)

# Extract df_catch trials
df_catch_summary <- lapply(data_frames, function(df) {
  subj_id <- first(df$subjID)
  
  num_catch_trials <- df %>%
    filter(task == "catch_trial") %>%
    nrow()
  #browser()
  num_catch_correct <- df %>%
    filter(task == "catch_trial" & correct == 1) %>%
    nrow()
  
  tibble(subjID = subj_id,
         num_catch_trials = num_catch_trials,
         num_catch_correct = num_catch_correct)
}) %>%
  bind_rows()

catch_trial_fun <- function(df) {
  #browser()
  df_catch <- df %>% 
    filter(task == 'catch_trial') %>%
    select(subjID, rt, task, response, correct)
  return(df_catch)
}

df_catch <- lapply(data_frames, catch_trial_fun)

df_catch_all <- bind_rows(df_catch, .id = "source")

write.csv(df_catch_all, paste0(folder_path_pilot_anal,'foraging_catch_trials.csv' )) 


# Save the df_catch summary
write.csv(df_catch_summary, paste0(folder_path_pilot_anal, "foraging/foraging_catch_summary.csv"), row.names = FALSE)

t_test_result <- t.test(df_avg_thresholds %>%
                         filter(cond == "long-steep") %>%
                         pull(mean_value),
                       df_avg_thresholds %>%
                         filter(cond == "short-steep") %>%
                         pull(mean_value),
                       paired = TRUE)

# Create a data frame for the t-test results
t_test_df <- data.frame(
  t = round(t_test_result$statistic, 3),
  df = t_test_result$parameter,
  p = round(t_test_result$p.value, 4),
  CI_lower = round(t_test_result$conf.int[1], 3),
  CI_upper = round(t_test_result$conf.int[2], 3),
  Mean_Difference = round(t_test_result$estimate, 3)
)

# Display the results as a nice table
#kable(t_test_df, caption = "Paired t-test Results", digits = 3)

ttest_nice <- nice_table(
  t_test_df,
  title = c("Table 1", "Paired t-test Results Foraging")
)

short_steep <- df_avg_thresholds %>%
  filter(cond == "short-steep") %>%
  pull(mean_value)

long_steep <- df_avg_thresholds %>%
  filter(cond == "long-steep") %>%
  pull(mean_value)

# compare using paired t test
ttest_res <- t.test(short_steep, long_steep, paired = TRUE)



# New plot only with asterisks
plot_ind_means <- ggplot(df_avg_thresholds, aes(x = cond, y = mean_value)) +
  geom_bar(data = mean_optimal_exit, stat = "identity", aes(x = cond, y = mean_optimal_exit)) +
  geom_point(aes(color = cond), position = position_jitter(width = 0, height = 0), size = 3) +
  stat_summary(geom = "point", fun = median, shape = 5, size = 4, stroke = 3, alpha = 0.9, color = "red") +
  stat_summary(geom = "crossbar", fun = mean, width = 0.4, fatten = 2, color = "blue") +  # Mean as a crossbar
  labs(title = "B",
       x = "Travel time",
       y = "Average Threshold for Leaving a Reward Environment") +
  scale_y_continuous(breaks = seq(1, 15, 1)) +
  scale_x_discrete(labels = c("long-steep" = "long", "short-steep" = "short")) +   # <-- relabel axis
  theme(
    panel.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(colour = "black"),
    text = element_text(size = 25),
    axis.text = element_text(size = 19),
    axis.title = element_text(size = 19),
    legend.position = "none"  # Remove the legend
  ) +
  geom_signif(
    comparisons = list(c("long-steep", "short-steep")),
    annotations = "***",
    y_position = c(11, 11),  # Adjust the y position as needed 
    textsize = 6  # Increase the font size of the significance annotation
  )


print(plot_ind_means)


# Save the plot


plot_ind_means_paper <- ggplot(df_avg_thresholds, aes(x = cond, y = mean_value)) +
  # 2. Draw boxplot SECOND (so it sits on top)
  # Map fill and color to 'cond' to match point colors
  # Set alpha < 1 for transparency
  geom_boxplot(aes(fill = cond, color = cond), 
               outlier.shape = NA, 
               width = 0.6, 
               alpha = 0.3) + 
  # 1. Draw points FIRST (so they are at the bottom)
  geom_point(aes(color = cond), 
             position = position_jitter(width = 0.15, height = 0), 
             size = 3) +
  

  
  # Optional: Add your summary stats if you still want them

  labs(title = "B",
       x = "Travel time",
       y = "Average Threshold for Leaving a Reward Environment") +
  scale_y_continuous(breaks = seq(1, 15, 1)) +
  scale_x_discrete(labels = c("long-steep" = "long", "short-steep" = "short")) +
  theme(
    panel.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(colour = "black"),
    text = element_text(size = 25),
    axis.text = element_text(size = 19),
    axis.title = element_text(size = 19),
    legend.position = "none"
  ) +
  geom_signif(
    comparisons = list(c("long-steep", "short-steep")),
    annotations = "***",
    y_position = c(11, 11),
    textsize = 6
  )
print(plot_ind_means_paper)

ggsave(paste0(folder_path_pilot_anal, "foraging/foraging_exit_thresholds_plot.jpg"), plot = plot_ind_means_paper, width = 10, height = 10, units = "in", dpi = 300)




### Anova ###
# Add new columns using mutate
foraging_anova_df <- df_avg_thresholds %>%
  mutate(
    time = case_when(
      grepl("short", cond) ~ "short",
      grepl("long", cond) ~ "long"
    ),
    depl_rate = case_when(
      grepl("shallow", cond) ~ "shallow",
      grepl("steep", cond) ~ "steep"
    )
  )




foraging_anova_df <- foraging_anova_df %>%
  select(id,time, depl_rate, mean_value)

# foraging_anova_result <- ezANOVA(
#   data = foraging_anova_df,
#   dv = .(mean_value),
#   wid = .(id),
#   within = .(time, depl_rate),
#   detailed = TRUE
# )

## Anova by day ##
# Import the data from day 1
# foraging_anova_df_day1 <- read.csv("foraging_anova_df_day1.csv")
# 
# # Get the IDs of participants who completed the task on both days
# common_ids <- intersect(foraging_anova_df$id, foraging_anova_df_day1$id)
# 
# # Filter day 1 data
# foraging_anova_df_day1_filtered <- foraging_anova_df_day1 %>%
#   filter(id %in% common_ids) %>%
#   select(-X) %>%
#   mutate(day = "1")
# 
# foraging_anova_df_day2 <- foraging_anova_df %>%
#   mutate(day = "2")
# 
# # Combine both days for ANOVA
# foraging_anova_df_both_days <- bind_rows(foraging_anova_df_day1_filtered,foraging_anova_df_day2)
# # anova_combined_df_both_days$participant <- as.factor(anova_combined_df_both_days$participant)
# # anova_combined_df_both_days$day <- as.factor(anova_combined_df_both_days$day)
# # anova_combined_df_both_days$effort <- as.factor(anova_combined_df_both_days$effort)
# # anova_combined_df_both_days$reward <- as.factor(anova_combined_df_both_days$reward)
# # 
# 
# # Run the ANOVA by day
# foraging_anova_result_by_day <- ezANOVA(
#   data = foraging_anova_df_both_days,
#   dv = mean_value,
#   wid = id,
#   within = .(day, time, depl_rate),
#   detailed = TRUE
# )
# 
# 
# print(foraging_anova_result)

# Run ICC of behavioural params
# Reshape data to wide format
#df_wide <- reshape(foraging_anova_df_both_days, idvar = "id", timevar = "day", direction = "wide")

# Extract only the necessary columns (exit thresholds for day 1 and day 2)
#prop_data <- df_wide[, grep("mean_value", names(df_wide))]

# foraging_anova_df_wide <- foraging_anova_df_both_days %>%
#   pivot_wider(names_from = c(time, depl_rate), 
#               values_from = mean_value, 
#               names_sep = "_")
# 
# # Calculate the mean thresholds for each participant for day 1
# foraging_anova_day1 <- foraging_anova_df_both_days %>%
#   filter(day == 1) %>%
#   pivot_wider(names_from = c(time, depl_rate), 
#               values_from = mean_value, 
#               names_sep = "_") %>%
#   mutate(mean_threshold_day1 = rowMeans(select(., starts_with("short_steep"):starts_with("long_shallow"))))
# 
# # Calculate the mean thresholds for each participant for day 2
# foraging_anova_day2 <- foraging_anova_df_both_days %>%
#   filter(day == 2) %>%
#   pivot_wider(names_from = c(time, depl_rate), 
#               values_from = mean_value, 
#               names_sep = "_") %>%
#   mutate(mean_threshold_day2 = rowMeans(select(., starts_with("short_shallow"):starts_with("long_shallow"))))
# 
# # Combine the day 1 and day 2 data into a single dataframe
# combined_exit_thresholds <- merge(foraging_anova_day1 %>% select(id, mean_threshold_day1),
#                         foraging_anova_day2 %>% select(id, mean_threshold_day2),
#                         by = "id")
# 
# 
# 
# # Calculate ICC
# icc_result <- icc(combined_exit_thresholds[,2:3], model = "twoway", type = "agreement", unit = "average")
# 
# # Print ICC result
# print(icc_result)

#foraging_anova_table <- nice_table(foraging_anova_result, title = c("Table 1","Foraging Anova Results"))
#print(foraging_anova_table, preview = "docx")

###### Exploring shortening the task while maitaining good ICC ######
# conditions <- c("short_steep", "long_steep", "short_shallow", "long_shallow")
# 
# # Generate all possible non-empty combinations of conditions
# combinations <- unlist(lapply(1:length(conditions), function(x) combn(conditions, x, simplify = FALSE)), recursive = FALSE)
# 
# # Function to calculate ICC for a given combination, with corrected day-wise mean calculation
# calculate_icc_for_combination <- function(df, combination) {
#   
#   if (length(combination) == 4) {
#     #browser()
#   }
#   
#   #browser()
#   
#   # Calculate the mean for the given combination per participant for day 1
#   day1_means <- df %>%
#     filter(day == 1) %>%
#     rowwise() %>%
#     mutate(mean_combination_day1 = mean(c_across(all_of(combination)), na.rm = TRUE)) %>%
#     ungroup() %>%
#     select(id, mean_combination_day1)
#   
#   # Calculate the mean for the given combination per participant for day 2
#   day2_means <- df %>%
#     filter(day == 2) %>%
#     rowwise() %>%
#     mutate(mean_combination_day2 = mean(c_across(all_of(combination)), na.rm = TRUE)) %>%
#     ungroup() %>%
#     select(id, mean_combination_day2)
#   
#   # Merge the day 1 and day 2 results by id
#   combined_means <- merge(day1_means, day2_means, by = "id")
#   
#   # Calculate ICC for the combination
#   tryCatch({
#     icc_result <- icc(combined_means[, 2:3], model = "twoway", type = "agreement", unit = "average")
#     return(icc_result$value) # Return cthe ICC value
#   }, error = function(e) {
#     warning("Failed to calculate ICC for combination: ", paste(combination, collapse = " + "))
#     return(NA) # Return NA if ICC calculation fails
#   })
# }
# 
# # Create a data frame to store ICC results
# icc_results <- data.frame(Combination = character(), ICC = numeric(), comment = character(), stringsAsFactors = FALSE)
# 
# # Define a named vector for specific comments
# comments <- c(
#   "short_steep + long_steep" = "fix: steep, var: time",
#   "short_steep + short_shallow" = "fix: short, var: steepness",
#   "short_steep + long_shallow" = "The smallest MVT difference",
#   "long_steep + short_shallow" = "The biggest MVT difference",
#   "long_steep + long_shallow" = "fix: long, var: steepness",
#   "short_shallow + long_shallow" = "fix: shallow, var: time",
#   "short_steep + long_steep + short_shallow + long_shallow" = "default"
#   )
# 
# # Loop through each combination, calculate the ICC, and store the result
# for (comb in combinations) {
#   comb_name <- paste(comb, collapse = " + ")
#   icc_value <- calculate_icc_for_combination(foraging_anova_df_wide, comb)
#   
#   # Check if the combination has a specific comment
#   comment <- ifelse(comb_name %in% names(comments), comments[comb_name], "")
#   
#   # Add the result to the icc_results data frame
#   icc_results <- icc_results %>%
#     add_row(Combination = comb_name, ICC = icc_value, comment = comment)
# }
# 
# # View the ICC results
# print(icc_results)
###################################################### Difference measures ####################################################



# calc_foraging_sensitivity_measures <- function(df) {
#   df <- foraging_exit_thresholds_calc(df)
#   
#   # Preprocessing - extract task data
#   df_task <- df %>%
#     select(trial_type,  rt, response, next_reward, planet, aliens, reward_received, decay_rate_actual, decay_rate_exp, time_in_block, 
#            block_num, prt, last_trial_on_planet, time_in_block, galaxy_type, task, exit_threshold) %>%
#     filter(trial_type == 'alien_welcome'  | trial_type == 'land' | trial_type == 'dig' | trial_type == 'harvest' | trial_type == 'decision')
#   
#   # Get condition order
#   df_harvest <- df_task %>%
#     filter(trial_type == 'harvest')
#   conditions <- c("short-steep", "long-steep", "short-shallow", "long-shallow")
#   galaxy_types <- df_harvest %>%
#     pull(galaxy_type) + 1
#   cond_order <- conditions[unique(galaxy_types)]
#   
#   # Get all decisions (for reaction times) and group by condition
#   df_decision <- df_task %>%
#     filter(trial_type == 'decision')
#     
#   average_rt <- df_decision %>%
#     mutate(rt = as.numeric(rt)) %>%
#     filter(!is.na(rt)) %>%
#     group_by(block_num) %>%
#     summarise(average_rt = mean(rt)) %>%
#     mutate(cond = cond_order[block_num])
#   
#   # Get the trials where participant traveled
#   df_leave <- df_task %>%
#     filter(response == 'l' & !is.na(exit_threshold)) %>%
#     select(trial_type, block_num, exit_threshold)
#   
#   # average the exit thresholds for each condition (block_num)
#   average_exit_threshold <- df_leave %>%
#     group_by(block_num) %>%
#     summarise(average_threshold = mean(exit_threshold)) %>%
#     mutate(cond = cond_order[block_num])
#   
#   # Calculate the difference measures (based on Ianni et al., 2023):
#   
#   ## Behavioral sensitivity to reward environment
#   short_shallow_threshold <- average_exit_threshold %>% 
#     filter(cond == "short-shallow") %>% 
#     pull(average_threshold)
#   
#   long_steep_threshold <- average_exit_threshold %>% 
#     filter(cond == "long-steep") %>% 
#     pull(average_threshold)
#   
#   reward_environment_sensitivity <- short_shallow_threshold - long_steep_threshold
#   
#   ## Behavioral sensitivity to travel time
#   short_threshold <- average_exit_threshold %>% 
#     filter(cond == "short-shallow" | cond == "short-steep") %>% 
#     summarise(mean_average_threshold = mean(average_threshold)) %>%
#     pull(mean_average_threshold)
#   
#   long_threshold <- average_exit_threshold %>% 
#     filter(cond == "long-steep" | cond == "long-shallow") %>% 
#     summarise(mean_average_threshold = mean(average_threshold)) %>%
#     pull(mean_average_threshold)
#   
#   travel_time_sensitivity <- short_threshold - long_threshold
#   
#   ## Behavioral sensitivity to depletion rate
#   shallow_threshold <- average_exit_threshold %>% 
#     filter(cond == "short-shallow" | cond == "long-shallow") %>% 
#     summarise(mean_average_threshold = mean(average_threshold)) %>%
#     pull(mean_average_threshold)
#   
#   steep_threshold <- average_exit_threshold %>% 
#     filter(cond == "long-steep" | cond == "short-steep") %>% 
#     summarise(mean_average_threshold = mean(average_threshold)) %>%
#     pull(mean_average_threshold)
#   
#   depletion_rate_sensitivity <- shallow_threshold - steep_threshold
#   
#   # Changes in reaction times (between the most and least rewarding environments)
#   #"to assess for relative changes in response invigoration, we measured the change in reaction time between the most and least rewarding environments."
#   short_shallow_rt <- average_rt %>%
#     filter(cond == "short-shallow") %>%
#     pull(average_rt)
# 
#   long_steep_rt <- average_rt %>%
#     filter(cond == "long-steep") %>%
#     pull(average_rt)
# 
#   rt_difference <- short_shallow_rt - long_steep_rt
#   
#   # Put the measures into a list
#   sensitivity_measures <- list(reward_environment_sensitivity = reward_environment_sensitivity,
#                                travel_time_sensitivity = travel_time_sensitivity,
#                                depletion_rate_sensitivity = depletion_rate_sensitivity,
#                                average_per_condition = average_exit_threshold,
#                                rt_difference = rt_difference)
#   
#   return(sensitivity_measures)
# }
# 
# # Calculate behavioral measures of interest (based on Ianni et al., 2023) for each participant
# difference_measures <- lapply(data_frames, calc_foraging_sensitivity_measures)
# # remove the data frames that are not necessary for these calculations
# behavioral_measures <- lapply(difference_measures, function(cell) {
#   cell[names(cell) != "average_per_condition"]
# })
# 
# 
# # Convert the list to a dataframe
# behavioral_measures_df <- do.call(rbind, lapply(behavioral_measures, function(x) {
#   # Convert each list element into a dataframe row
#   as.data.frame(t(unlist(x)))
# }))
# 
# # Some cleanup, add subjIDs to the behavioral measures
# rownames(behavioral_measures_df) <- NULL
# subjID <- character()
# for (i in 1:length(data_frames)) {
#   subjID[i] <- dplyr::pull(unique(data_frames[[i]]["subjID"]))
# }
# behavioral_measures_df <- cbind(behavioral_measures_df, subjID)
# 
# # Make the subjID be the first column in the data frame
# behavioral_measures_df <- behavioral_measures_df[, c("subjID", setdiff(names(behavioral_measures_df), "subjID"))]
# 
# 
# # Convert the dataframe to long format using tidyr
# behavioral_measures_long <- pivot_longer(behavioral_measures_df, 
#                                          cols = reward_environment_sensitivity:depletion_rate_sensitivity,
#                                          names_to = "Variable",
#                                          values_to = "Value")
# 
# # Create a boxplot for whatever reason
# ggplot(behavioral_measures_long, aes(x = Variable, y = Value)) +
#   geom_boxplot(outlier.shape = NA) + # supress the outlier, or it will look like there are extra observations
#   guides(color = "none")  + # This line removes the color legend
#   geom_jitter(aes(color = Variable), width = 0.1, alpha = 0.5, size=2) + # change the width to change the jitter (or set to 0 to have no jitter)
#   labs(x = "Behavioral Measure", y = "Difference Score", title = "Behavioral Measures of Interest") +
#   scale_x_discrete(labels = c("Depletion Rate", "Reward Environment", "Travel Time")) +
#   #scale_y_continuous(breaks = seq(-15, 50, by = 5)) +
#   theme(
#     panel.background = element_blank(),
#     panel.grid.major = element_blank(),
#     panel.grid.minor = element_blank(),
#     axis.line = element_line(colour = "black")
#   )
# #write.csv(extended_data, "extended_data.csv")
# 
# # catch trials
# catch_trial_fun <- function(df) {
#   df_catch <- df %>% 
#     filter(task == 'catch_trial') %>%
#     select(subjID, rt, task, response, correct)
#   return(df_catch)
# }
# 
# df_catch <- lapply(data_frames, catch_trial_fun)
# print(df_catch) # for initial inspection of single participants
# 
# names(behavioral_measures_df)[2:length(behavioral_measures_df)] <- paste0("foraging_", names(behavioral_measures_df))[2:length(behavioral_measures_df)]

#### MN code to get moving average plots ####


#df <- data_frames[[1]]

# requires data_frames



#function
foraging_moving_avg_plot <- function(df) {
  df <- foraging_exit_thresholds_calc(df)
  
  # Check catch trials (attention checks)
  df_catch <- df %>%
    filter(task == 'catch_trial') %>%
    select(task, subjID, rt, response, correct_response, correct)
  
  # Preprocessing - extract task data
  df_task <- df %>%
    select(trial_type,  rt, response, next_reward, planet, aliens, reward_received, decay_rate_actual, decay_rate_exp, time_in_block, 
           block_num, prt, last_trial_on_planet, time_in_block, galaxy_type, task, exit_threshold) %>%
    filter(trial_type == 'alien_welcome'  | trial_type == 'land' | trial_type == 'dig' | trial_type == 'harvest' | trial_type == 'decision')
  
  # Get condition order
  df_harvest <- df_task %>%
    filter(trial_type == 'harvest')
  conditions <- c("short-steep", "long-steep", "short-shallow", "long-shallow")
  galaxy_types <- df_harvest %>%
    pull(galaxy_type) + 1
  cond_order <- conditions[unique(galaxy_types)]
  
  # Get travel times of the corresponding conditions
  travel_times_general <- c(6, 12, 6, 12)
  travel_times <- travel_times_general[unique(galaxy_types)]
  
  # Time in each block in minutes and seconds (for plotting)
  df_task <- df_task %>%
    mutate(time_in_block_sec = time_in_block / 1000,
           time_in_block_min = (time_in_block / 1000) / 60)
  
  # Time in experiment. Add block_nr x 6.5 to time in block
  df_task <- df_task %>%
    mutate(time_foraging_min = ((block_num -1 ) * 6.5) + time_in_block_min,
           travel_time_min = travel_times[block_num] / 60)
  
  # Get the trials where participant traveled
  df_leave <- df_task %>%
    filter(response == 'l' & !is.na(exit_threshold)) %>%
    select(trial_type, block_num, exit_threshold)
  
  df_leave <- df_leave %>%
    mutate(cond = case_when(
      block_num == 1 ~ cond_order[1],
      block_num == 2 ~ cond_order[2],
      block_num == 3 ~ cond_order[3],
      block_num == 4 ~ cond_order[4],
      TRUE ~ NA_character_ # This line handles any other unexpected values
    ))
  
  y_ssh <- df_leave %>% 
    filter(cond == "short-shallow") %>%
    pull(exit_threshold)
  
  return(df_leave)
}


output <- lapply(data_frames, foraging_moving_avg_plot)



############
plot_by_decision <- function(df_leave) {
  
  
  x<-100
  
  # SHORT-SHALLOW
  # y_ssh <- df_leave %>% 
  #   filter(cond == "short-shallow") %>%
  #   pull(exit_threshold)
  # x <- 1:length(y_ssh)
  # 
  # # Create a data frame from x and y
  # df_ssh <- data.frame(x, y_ssh)
  # 
  # 
  # # Create a line plot with dots using ggplot2
  # p1 <- ggplot(df_ssh, aes(x = x, y = y_ssh)) +
  #   geom_line(color = "blue") + # Add line
  #   geom_point(color = "red", size = 2) + # Add points
  #   labs(x = "Decision", y = "Exit Threshold", title = "Short-shallow") +
  #   theme_minimal() # A minimal theme for cleaner look
  # 
  # 
  
  
  # SHORT-STEEP
  y_sst <- df_leave %>% 
    filter(cond == "short-steep") %>%
    pull(exit_threshold)
  x <- 1:length(y_sst)
  
  # Create a data frame from x and y
  df_sst <- data.frame(x, y_sst)
  
  
  # Create a line plot with dots using ggplot2
  p2 <- ggplot(df_sst, aes(x = x, y = y_sst)) +
    geom_line(color = "blue") + # Add line
    geom_point(color = "red", size = 2) + # Add points
    labs(x = "Decision", y = "Exit Threshold", title = "Short-steep") +
    theme_minimal() # A minimal theme for cleaner look
  
  # LONG-SHALLOW
  # y_lsh <- df_leave %>% 
  #   filter(cond == "long-shallow") %>%
  #   pull(exit_threshold)
  # x <- 1:length(y_lsh)
  # 
  # # Create a data frame from x and y
  # df_lsh <- data.frame(x, y_lsh)
  # 
  # 
  # # Create a line plot with dots using ggplot2
  # p3 <- ggplot(df_lsh, aes(x = x, y = y_lsh)) +
  #   geom_line(color = "blue") + # Add line
  #   geom_point(color = "red", size = 2) + # Add points
  #   labs(x = "Decision", y = "Exit Threshold", title = "long-shallow") +
  #   theme_minimal() # A minimal theme for cleaner look
  
  
  
  # LONG-STEEP
  y_lst <- df_leave %>% 
    filter(cond == "long-steep") %>%
    pull(exit_threshold)
  x <- 1:length(y_lst)
  
  # Create a data frame from x and y
  df_lst <- data.frame(x, y_lst)
  
  
  # Create a line plot with dots using ggplot2
  p4 <- ggplot(df_lst, aes(x = x, y = y_lst)) +
    geom_line(color = "blue") + # Add line
    geom_point(color = "red", size = 2) + # Add points
    labs(x = "Decision", y = "Exit Threshold", title = "long-steep") +
    theme_minimal() # A minimal theme for cleaner look
  
  return(list(y_lst = y_lst, y_sst = y_sst))
  
}

plot_condition <- lapply(output, plot_by_decision)



# get y_lsh
# Assuming list_of_sublists is your list of sublists
# y_lsh_list <- lapply(plot_condition, function(sublist) sublist$y_lsh)
y_lst_list <- lapply(plot_condition, function(sublist) sublist$y_lst)
# y_ssh_list <- lapply(plot_condition, function(sublist) sublist$y_ssh)
y_sst_list <- lapply(plot_condition, function(sublist) sublist$y_sst)

# Create a data frame from the list
# df_lsh <- map_df(plot_condition, ~data.frame(y = .x), .id = "id") %>%
#   mutate(x = row_number(), id = as.factor(id))  # Add x-values and ensure 'id' is a factor

### LSH #####
# df_lsh <- map_df(y_lsh_list, ~data.frame(y = .x), .id = "id") %>%
#   mutate(x = row_number())
# 
# # First, create a unique index for each y within each id
# df_lsh <- df_lsh %>% 
#   group_by(id) %>%
#   mutate(idx = row_number()) %>%
#   ungroup()
# 
# # Pivot the data to wide format
# df_lsh_wide <- df_lsh %>%
#   pivot_wider(
#     id_cols = id, 
#     names_from = idx, 
#     values_from = y, 
#     names_prefix = "y_"
#   )
# 
# # Assuming df_wide is your wide format dataframe
# df_lsh_long <- df_lsh_wide %>%
#   pivot_longer(
#     cols = starts_with("y_"), 
#     names_to = "x", 
#     values_to = "y",
#     names_prefix = "y_"
#   ) %>%
#   mutate(x = as.numeric(x))
# 
# # PLOT
# p1 <- ggplot(df_lsh_long, aes(x = x, y = y, group = id, color = id)) +
#   geom_line() +  # Draw lines
#   geom_point() +  # Add points at each non-NA y-value
#   scale_x_continuous(breaks = 1:20) +  # Ensure x-axis covers the range 1 to 20
#   labs(x = "Decision", y = "Exit threshold", title = "Long-shallow") +
#   theme_minimal() +
#   theme(legend.position = "none")  # Hide the legend
# 
# 

medians <- df_avg_thresholds %>%
  group_by(cond) %>%
  summarize(
    median_value = median(mean_value),
    mean_value = mean(mean_value)            
  )

# Extract median values
median_long_steep <- medians %>% filter(cond == "long-steep") %>% pull(median_value)
median_short_steep <- medians %>% filter(cond == "short-steep") %>% pull(median_value)

# Extract mean values
mean_long_steep <- medians %>% filter(cond == "long-steep") %>% pull(mean_value)
mean_short_steep <- medians %>% filter(cond == "short-steep") %>% pull(mean_value)

### LST #####

df_lst <- map_df(y_lst_list, ~data.frame(y = .x), .id = "id") %>%
  mutate(x = row_number())

# First, create a unique index for each y within each id
df_lst <- df_lst %>% 
  group_by(id) %>%
  mutate(idx = row_number()) %>%
  ungroup()

# Pivot the data to wide format
df_lst_wide <- df_lst %>%
  pivot_wider(
    id_cols = id, 
    names_from = idx, 
    values_from = y, 
    names_prefix = "y_"
  )

# Assuming df_wide is your wide format dataframe
df_lst_long <- df_lst_wide %>%
  pivot_longer(
    cols = starts_with("y_"), 
    names_to = "x", 
    values_to = "y",
    names_prefix = "y_"
  ) %>%
  mutate(x = as.numeric(x))

# PLOT
p2 <- ggplot(df_lst_long, aes(x = x, y = y, group = id, color = id)) +
  geom_line() +  # Draw lines
  geom_point() +  # Add points at each non-NA y-value
  scale_x_continuous(breaks = 1:20) +  # Ensure x-axis covers the range 1 to 20
  scale_y_continuous(limits = c(0, 13)) +
  geom_hline(yintercept = median_long_steep, linetype = "dashed", color = "red", size = 1) +  # Add median line
  geom_hline(yintercept = mean_long_steep, linetype = "solid", color = "red", size = 1) +  # Add median line
  labs(x = "Decision", y = "Exit threshold", title = "Long-steep") +
  theme_minimal() +
  theme(legend.position = "none")  # Hide the legend




### SSH #####
# df_ssh <- map_df(y_ssh_list, ~data.frame(y = .x), .id = "id") %>%
#   mutate(x = row_number())
# 
# # First, create a unique index for each y within each id
# df_ssh <- df_ssh %>% 
#   group_by(id) %>%
#   mutate(idx = row_number()) %>%
#   ungroup()
# 
# # Pivot the data to wide format
# df_ssh_wide <- df_ssh %>%
#   pivot_wider(
#     id_cols = id, 
#     names_from = idx, 
#     values_from = y, 
#     names_prefix = "y_"
#   )
# 
# # Assuming df_wide is your wide format dataframe
# df_ssh_long <- df_ssh_wide %>%
#   pivot_longer(
#     cols = starts_with("y_"), 
#     names_to = "x", 
#     values_to = "y",
#     names_prefix = "y_"
#   ) %>%
#   mutate(x = as.numeric(x))
# 
# # PLOT
# p3 <- ggplot(df_ssh_long, aes(x = x, y = y, group = id, color = id)) +
#   geom_line() +  # Draw lines
#   geom_point() +  # Add points at each non-NA y-value
#   scale_x_continuous(breaks = 1:20) +  # Ensure x-axis covers the range 1 to 20
#   labs(x = "Decision", y = "Exit threshold", title = "short-shallow") +
#   theme_minimal() +
#   theme(legend.position = "none")  # Hide the legend




### SST #####
df_sst <- map_df(y_sst_list, ~data.frame(y = .x), .id = "id") %>%
  mutate(x = row_number())

# First, create a unique index for each y within each id
df_sst <- df_sst %>% 
  group_by(id) %>%
  mutate(idx = row_number()) %>%
  ungroup()

# Pivot the data to wide format
df_sst_wide <- df_sst %>%
  pivot_wider(
    id_cols = id, 
    names_from = idx, 
    values_from = y, 
    names_prefix = "y_"
  )

# Assuming df_wide is your wide format dataframe
df_sst_long <- df_sst_wide %>%
  pivot_longer(
    cols = starts_with("y_"), 
    names_to = "x", 
    values_to = "y",
    names_prefix = "y_"
  ) %>%
  mutate(x = as.numeric(x))

# PLOT
p4 <- ggplot(df_sst_long, aes(x = x, y = y, group = id, color = id)) +
  geom_line() +  # Draw lines
  geom_point() +  # Add points at each non-NA y-value
  scale_x_continuous(breaks = 1:20) +  # Ensure x-axis covers the range 1 to 20
  scale_y_continuous(limits = c(0, 13)) +
  geom_hline(yintercept = median_short_steep, linetype = "dashed", color = "red", size = 1) +  # Add median line
  geom_hline(yintercept = mean_short_steep, linetype = "solid", color = "red", size = 1) +  # Add median line
  labs(x = "Decision", y = "Exit threshold", title = "short-steep") +
  theme_minimal() +
  theme(legend.position = "none")  # Hide the legend




# Combine into one plot
plot_exit_by_trials <- grid.arrange(p2, p4, ncol = 2, nrow = 1,top = textGrob("Exit Threshold by trials", gp = gpar(fontface = "bold", fontsize = 20)))

# Save the plot
ggsave(paste0(folder_path_pilot_anal, "/foraging/","exit_by_trials.jpg"), plot_exit_by_trials, width = 10, height = 6, dpi = 300)


  
# Exporting the behavioural DataFrame to a CSV file
#write.csv(behavioral_measures_df, file = paste0(output_folder, "/foraging_variables.csv"), row.names = FALSE)
 
############## Get average exit thresholds for each part - modelling ########## 


data_frames <- lapply(data_frames, foraging_exit_thresholds_calc)

avg_exit_thresholds <- function(df) {
  #df <- foraging_exit_thresholds_calc(df)

  # Preprocessing - extract task data
  df_task <- df %>%
    select(trial_type,  rt, response, next_reward, planet, aliens, reward_received, decay_rate_actual, decay_rate_exp, time_in_block,
           block_num, prt, last_trial_on_planet, time_in_block, galaxy_type, task, exit_threshold) %>%
    filter(trial_type == 'alien_welcome'  | trial_type == 'land' | trial_type == 'dig' | trial_type == 'harvest' | trial_type == 'decision')

  # Get the trials where participant traveled
  df_leave <- df_task %>%
    filter(response == 'l' & !is.na(exit_threshold)) %>%
    select(trial_type, block_num, exit_threshold)

  thresholds <- df_leave %>%
    pull(exit_threshold)
  avg_threshold <- mean(thresholds)

  return(avg_threshold)

}

# compute average thresholds for each participants (across all conditions)
avg_threshold <- lapply(data_frames, avg_exit_thresholds)

# Flatten the list into a numeric vector
avg_threshold <- unlist(avg_threshold)

# Convert the numeric vector into a dataframe
df_avg_threshold <- data.frame(value = avg_threshold)

# Convert row names into a character vector
df_avg_threshold <- rownames_to_column(df_avg_threshold, var = "subjID")
# Remove the path name from each string in the subjID column
df_avg_threshold$subjID <- gsub("../piloting/data/output/", "", df_avg_threshold$subjID)

df_avg_threshold_sd <- df_avg_threshold %>%
  mutate(
    group_mean = mean(value, na.rm = TRUE),
    group_sd   = sd(value, na.rm = TRUE),
    z_score    = abs((value - group_mean) / group_sd)
  )


# Save the data frame as CSV files in the output folder
csv_path <- paste(output_folder,"foraging_params.csv", sep="")
write.table(df_avg_threshold, csv_path , row.names = FALSE, col.names = FALSE, sep=",")

################# RT analysis ###############################
# Extract the reaction times for each participant

extract_reaction_times <- function(df) {
  
  
  # df_task <- df %>%
  #   select(trial_type,  rt, response, next_reward, planet, aliens, reward_received, decay_rate_actual, decay_rate_exp, time_in_block, 
  #          block_num, prt, last_trial_on_planet, time_in_block, galaxy_type, task) %>%
  #   filter(trial_type == 'alien_welcome'  | trial_type == 'land' | trial_type == 'dig' | trial_type == 'harvest' | trial_type == 'decision')
  # 
  
  # Extract the reaction times for each participant
  df_reaction_times <- df %>%
    filter(trial_type == "decision" | trial_type == "harvest" | trial_type == "time_out")
  
  df_reaction_times <- df_reaction_times %>% select(subjID, rt, response, galaxy_type, trial_type)
  
  # Fill down the galaxy_type column
  df_reaction_times <- df_reaction_times %>%
    fill(galaxy_type, .direction = "down")
  
  # Add 2000 to trials with time outs
  # df_reaction_times <- df_reaction_times %>%
  #   mutate(rt = ifelse(lag(trial_type) == "time_out" & trial_type == "decision" & !is.na(rt), rt + 2000, rt))
  # 
  adjust_rt_after_timeouts <- function(df) {
    n <- nrow(df)
    df$rt <- as.numeric(df$rt)
    timeout_counter <- 0  # Counter for consecutive timeouts
    
    for (i in seq_len(n)) {
      if (df$trial_type[i] == "time_out") {
        timeout_counter <- timeout_counter + 1  # Count timeouts
      } else if (df$trial_type[i] == "decision") {
        if (!is.na(df$response[i])) {
          df$rt[i] <- df$rt[i] + (timeout_counter * 2000)  # Modify rt
          timeout_counter <- 0  # Reset counter after applying
        } 
        # If rt is NA, do nothing and continue checking the next row
      } else {
        timeout_counter <- 0  # Reset counter for other types
      }
    }
    
    return(df)
  }
  
  df_reaction_times <- adjust_rt_after_timeouts(df_reaction_times)
  
  #browser()  
  
  df_reaction_times <- df_reaction_times %>%
    filter(trial_type == "decision")
  
  
  
  # Log transformation of reaction times
  df_reaction_times <- df_reaction_times %>%
    filter(!is.na(rt) & !is.null(rt) & is.finite(rt))
  
  
  df_reaction_times$rt_log <- log(as.numeric(df_reaction_times$rt))
  
  # # Calculate the average reaction time for each participant
  # avg_rt <- df_decision %>%
  #   mutate(rt = as.numeric(rt)) %>%
  #   filter(!is.na(rt)) %>%
  #   summarise(avg_rt = mean(rt, na.rm = TRUE))
  
  return(df_reaction_times)
  
}

# Apply the function to each dataset in processed_data
output_rt <- lapply(data_frames, extract_reaction_times)

### Run the regression to get an individual effect of RT on effort and reward
# Function to run regression per participant
run_regression_per_subject <- function(df) {
  
  # browser()
  #df$galaxy_type <- as.factor(df$galaxy_type)
  
  # Log transformation of reaction times
  df <- df %>%
    filter(!is.na(rt_log) & !is.null(rt_log) & is.finite(rt_log))
  
  # Run the regression only if there are enough valid trials
  if (nrow(df) > 1) {
    model <- lm(rt_log ~ galaxy_type, data = df)
    # browser()
    result <- tidy(model) %>%
      select(term, estimate) %>%
      pivot_wider(names_from = term, values_from = estimate) %>%
      mutate(subjID = unique(df$subjID))
  } else {
    # Return NA if not enough trials for regression
    result <- tibble(subjID = unique(df$subjID), `(Intercept)` = NA, galaxy_type = NA)
  }
  
  return(result)
}

# Apply function to each participant's dataset
beta_coefficients <- bind_rows(lapply(output_rt, run_regression_per_subject))

# Plot the beta coefficients as boxplots
beta_coefficients_long <- pivot_longer(beta_coefficients, cols = c(galaxy_type), names_to = "Variable", values_to = "Beta")

ggplot(beta_coefficients_long, aes(x = Variable, y = Beta)) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(aes(color = Variable), width = 0.1, height = 0, alpha = 0.7) +
  labs(title = "Beta Coefficients of RT in Decisions",
       x = "",
       y = "Beta Coefficient") +
  theme_minimal()

# Compare the differences in beta coefficients between effort and reward
t.test(beta_coefficients$galaxy_type)

# Convert the list of data frames to a single data frame
output_rt_df <- bind_rows(output_rt, .id = "source")



# Filter out rows where rt = 0
output_rt_df <- output_rt_df %>%
  filter(rt != 0)

# Compute the average rt_log for each participant
rt_avg_df <- output_rt_df %>%
  group_by(subjID) %>%
  summarise(rt_log = mean(rt_log, na.rm = TRUE))

# Remove "output/" prefix from subjID in 
df_avg_threshold_temp <- df_avg_threshold %>%
  mutate(subjID = sub("output/", "", df_avg_threshold$subjID))

# Merge the two data frames by subjID
rt_avg_df$subjID <- as.character(rt_avg_df$subjID)
rt_exit_df <- left_join(rt_avg_df, df_avg_threshold_temp, by = "subjID")

# Remove rows where any column has non-finite values
rt_exit_df  %>%
  filter(is.finite(rt_log) & is.finite(value))

# Plot the correlation and calculate the correlation
ggplot(rt_exit_df, aes(x = rt_log, y = value)) +
  geom_point() +
  geom_smooth(method = "lm", se = TRUE, color = "blue") +
  labs(title = "Scatter Plot of RT vs. Exit",
       x = "RT (log-transformed)",
       y = "Exit threshold") +
  theme_minimal()

# Calculate the correlation xxx
cor.test(rt_exit_df$rt_log, rt_exit_df$value, method = "spearman")

beta_coefficients <- beta_coefficients %>%
  select(subjID, "(Intercept)",galaxy_type)

# Save the data frame as CSV files in the output folder
write.csv(beta_coefficients, paste0(folder_path_pilot_anal,"/foraging/foraging_betas_day_",day,".csv"),row.names = FALSE)


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
output_debrief <- lapply(data_frames, debriefing_current_task, 'foraging')

# Convert each sublist to a dataframe with only the second value
output_debrief_df <- lapply(output_debrief, function(x) {
  as.data.frame(lapply(x, function(y) y[2]))
})

# Combine all dataframes into one
output_debrief_df <- do.call(rbind, output_debrief_df)

# Save the debriefing df
write.csv(output_debrief_df, paste0("../../output/session",day,"/foraging/debrief.csv"),row.names = FALSE)