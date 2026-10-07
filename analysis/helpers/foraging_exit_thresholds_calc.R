foraging_exit_thresholds_calc <- function(df) { # path the the foraging_data.csv file created with load_data.R

# Get exit thresholds in foraging 
# browser()
#libraries
library(tidyverse) # tidy functions (including readr)


# Read data
df <- df %>%
  mutate(row_number = row_number())

# preprocess the data for this task
df_exit_thresholds <- df %>%
  select(trial_type, response, reward_received, galaxy_type, row_number) %>%
  filter(trial_type == 'alien_welcome' | trial_type == 'harvest' | trial_type == 'decision') # | trial_type == 'land' | trial_type == 'dig'
df_exit_thresholds <- df_exit_thresholds[df_exit_thresholds$response != 'a', ] # remove decisions that were dig
#df_task <- df_exit_thresholds

# Add a new column for the average reward, initialize with NA
df_exit_thresholds$exit_threshold <- NA

# Calculate exit thresholds - if it can't be calculated because the participant only dug one time, then there's nothing calculated.
# based on 2015 and 2017 articles (avg. of the last 2 harvests received before leaving).

# Iterate through the dataframe
for (i in 3:nrow(df_exit_thresholds)) {
  if (df_exit_thresholds$trial_type[i] == "decision") {
    # Check if the two previous rows are 'harvest'
    if (df_exit_thresholds$trial_type[i-1] == "harvest" && df_exit_thresholds$trial_type[i-2] == "harvest") {
      # Calculate the average of reward_received for these two rows
      df_exit_thresholds$exit_threshold[i] <- mean(c(df_exit_thresholds$reward_received[i-1], df_exit_thresholds$reward_received[i-2]))
    } else if (df_exit_thresholds$trial_type[i-1] == "harvest" && df_exit_thresholds$trial_type[i-2] == "alien_welcome") {
      df_exit_thresholds$exit_threshold[i] <- df_exit_thresholds$reward_received[i-1]
    }
  }
}



df$exit_threshold <- NA

for (i in 1:nrow(df)) {
  for (j in 1:nrow(df_exit_thresholds)) {
    if (df$row_number[i] == df_exit_thresholds$row_number[j]) {
      df$exit_threshold[i] <- df_exit_thresholds$exit_threshold[j]
    }
  }
}

return(df)

}
#write.csv(df_task, "df_thresholds.csv")