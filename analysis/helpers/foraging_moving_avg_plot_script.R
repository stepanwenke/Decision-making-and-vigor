
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
y_ssh <- df_leave %>% 
  filter(cond == "short-shallow") %>%
  pull(exit_threshold)
x <- 1:length(y_ssh)

# Create a data frame from x and y
df_ssh <- data.frame(x, y_ssh)


# Create a line plot with dots using ggplot2
p1 <- ggplot(df_ssh, aes(x = x, y = y_ssh)) +
  geom_line(color = "blue") + # Add line
  geom_point(color = "red", size = 2) + # Add points
  labs(x = "Decision", y = "Exit Threshold", title = "Short-shallow") +
  theme_minimal() # A minimal theme for cleaner look




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
y_lsh <- df_leave %>% 
  filter(cond == "long-shallow") %>%
  pull(exit_threshold)
x <- 1:length(y_lsh)

# Create a data frame from x and y
df_lsh <- data.frame(x, y_lsh)


# Create a line plot with dots using ggplot2
p3 <- ggplot(df_lsh, aes(x = x, y = y_lsh)) +
  geom_line(color = "blue") + # Add line
  geom_point(color = "red", size = 2) + # Add points
  labs(x = "Decision", y = "Exit Threshold", title = "long-shallow") +
  theme_minimal() # A minimal theme for cleaner look



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

return(list(y_lsh = y_lsh, y_lst = y_lst, y_sst = y_sst, y_ssh = y_ssh))

}

plot_condition <- lapply(output, plot_by_decision)



# get y_lsh
# Assuming list_of_sublists is your list of sublists
y_lsh_list <- lapply(plot_condition, function(sublist) sublist$y_lsh)
y_lst_list <- lapply(plot_condition, function(sublist) sublist$y_lst)
y_ssh_list <- lapply(plot_condition, function(sublist) sublist$y_ssh)
y_sst_list <- lapply(plot_condition, function(sublist) sublist$y_sst)

# Create a data frame from the list
# df_lsh <- map_df(plot_condition, ~data.frame(y = .x), .id = "id") %>%
#   mutate(x = row_number(), id = as.factor(id))  # Add x-values and ensure 'id' is a factor

### LSH #####
df_lsh <- map_df(y_lsh_list, ~data.frame(y = .x), .id = "id") %>%
  mutate(x = row_number())

# First, create a unique index for each y within each id
df_lsh <- df_lsh %>% 
  group_by(id) %>%
  mutate(idx = row_number()) %>%
  ungroup()

# Pivot the data to wide format
df_lsh_wide <- df_lsh %>%
  pivot_wider(
    id_cols = id, 
    names_from = idx, 
    values_from = y, 
    names_prefix = "y_"
  )

# Assuming df_wide is your wide format dataframe
df_lsh_long <- df_lsh_wide %>%
  pivot_longer(
    cols = starts_with("y_"), 
    names_to = "x", 
    values_to = "y",
    names_prefix = "y_"
  ) %>%
  mutate(x = as.numeric(x))

# PLOT
p1 <- ggplot(df_lsh_long, aes(x = x, y = y, group = id, color = id)) +
  geom_line() +  # Draw lines
  geom_point() +  # Add points at each non-NA y-value
  scale_x_continuous(breaks = 1:20) +  # Ensure x-axis covers the range 1 to 20
  labs(x = "Decision", y = "Exit threshold", title = "Long-shallow") +
  theme_minimal() +
  theme(legend.position = "none")  # Hide the legend




### LSH #####
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
  labs(x = "Decision", y = "Exit threshold", title = "Long-steep") +
  theme_minimal() +
  theme(legend.position = "none")  # Hide the legend




### SSH #####
df_ssh <- map_df(y_ssh_list, ~data.frame(y = .x), .id = "id") %>%
  mutate(x = row_number())

# First, create a unique index for each y within each id
df_ssh <- df_ssh %>% 
  group_by(id) %>%
  mutate(idx = row_number()) %>%
  ungroup()

# Pivot the data to wide format
df_ssh_wide <- df_ssh %>%
  pivot_wider(
    id_cols = id, 
    names_from = idx, 
    values_from = y, 
    names_prefix = "y_"
  )

# Assuming df_wide is your wide format dataframe
df_ssh_long <- df_ssh_wide %>%
  pivot_longer(
    cols = starts_with("y_"), 
    names_to = "x", 
    values_to = "y",
    names_prefix = "y_"
  ) %>%
  mutate(x = as.numeric(x))

# PLOT
p3 <- ggplot(df_ssh_long, aes(x = x, y = y, group = id, color = id)) +
  geom_line() +  # Draw lines
  geom_point() +  # Add points at each non-NA y-value
  scale_x_continuous(breaks = 1:20) +  # Ensure x-axis covers the range 1 to 20
  labs(x = "Decision", y = "Exit threshold", title = "short-shallow") +
  theme_minimal() +
  theme(legend.position = "none")  # Hide the legend




### SSH #####
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
  labs(x = "Decision", y = "Exit threshold", title = "short-steep") +
  theme_minimal() +
  theme(legend.position = "none")  # Hide the legend



# Combine into one plot
grid.arrange(p1, p2, p3, p4, ncol = 2, nrow = 2,
             top = textGrob("PLOTS", gp = gpar(fontface = "bold", fontsize = 20)))
