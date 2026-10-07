rlwm_prop_corr_per_stim_iter <- function(df) {
  
  df <- as_tibble(df) # turn df into tibble
  
  # Preprocessing - extract task data
  df_task <- df %>%
    filter(task == 'stimulus_presentation') %>% # Extract stimulus trials
    select(rt, response, correct_response, correct, stimulus_type,
           setsize, block, stim_id)
  
  # Create block index (counting images within each block)
  num_blocks <- max(df_task$block)
  templist <- list()
  for (i in 1:num_blocks) {
    df_task2 <- df_task %>%
      filter(block == i) %>%
      mutate(block_index = 1:n())
    
    templist[[i]] <- df_task2
  }
  df_task <- do.call(rbind, templist)
  
  # Extract data for each relevant set size and add trial numbers
  df_ns3 <- df_task %>%
    filter(setsize == 3) %>%
    mutate(trial_number = row_number())
  
  df_ns4 <- df_task %>%
    filter(setsize == 4) %>%
    mutate(trial_number = row_number())
  
  df_ns6 <- df_task %>%
    filter(setsize == 6) %>%
    mutate(trial_number = row_number())
  
  # Compute cumulative sum of accuracy and add proportion correct
  df_ns3 <- df_ns3 %>%
    mutate(cum_sum = cumsum(correct),
           proportion_correct = cum_sum / trial_number)
  
  df_ns4 <- df_ns4 %>%
    mutate(cum_sum = cumsum(correct),
           proportion_correct = cum_sum / trial_number)
  
  df_ns6 <- df_ns6 %>%
    mutate(cum_sum = cumsum(correct),
           proportion_correct = cum_sum / trial_number)
  
  # Define stimulus iteration
  stimulus_iteration_ns3 <- rep(c(rep(1, 3), rep(2, 3), rep(3, 3), rep(4, 3),
                                  rep(5, 3), rep(6, 3), rep(7, 3), rep(8, 3),
                                  rep(9, 3), rep(10, 3), rep(11, 3), rep(12, 3)), 2)
  stimulus_iteration_ns4 <- rep(c(rep(1, 4), rep(2, 4), rep(3, 4), rep(4, 4),
                                  rep(5, 4), rep(6, 4), rep(7, 4), rep(8, 4),
                                  rep(9, 4), rep(10, 4), rep(11, 4), rep(12, 4)), 2)
  stimulus_iteration_ns6 <- rep(c(rep(1, 6), rep(2, 6), rep(3, 6), rep(4, 6),
                                  rep(5, 6), rep(6, 6), rep(7, 6), rep(8, 6),
                                  rep(9, 6), rep(10, 6), rep(11, 6), rep(12, 6)), 2)
  
  df_ns3 <- df_ns3 %>%
    mutate(stimulus_iteration = stimulus_iteration_ns3)
  
  df_ns4 <- df_ns4 %>%
    mutate(stimulus_iteration = stimulus_iteration_ns4)
  
  df_ns6 <- df_ns6 %>%
    mutate(stimulus_iteration = stimulus_iteration_ns6)
  
  # Prepare prop_corr matrix
  prop_corr <- matrix(0, 4, 12) # set sizes (3, 4, 6) x stimulus iteration
  num_iterations <- 12
  
  # Fill prop_corr for set size 3
  for (i in 1:num_iterations) {
    ns3_iter <- df_ns3 %>%
      filter(stimulus_iteration == i) %>%
      select(correct)
    prop_corr[2, i] <- mean(unlist(ns3_iter))
  }
  
  # Fill prop_corr for set size 4
  for (i in 1:num_iterations) {
    ns4_iter <- df_ns4 %>%
      filter(stimulus_iteration == i) %>%
      select(correct)
    prop_corr[3, i] <- mean(unlist(ns4_iter))
  }
  
  # Fill prop_corr for set size 6
  for (i in 1:num_iterations) {
    ns6_iter <- df_ns6 %>%
      filter(stimulus_iteration == i) %>%
      select(correct)
    prop_corr[4, i] <- mean(unlist(ns6_iter))
  }
  
  # X-axis values
  prop_corr[1, ] <- 1:12
  
  # Create data frame for plotting
  df_to_plot <- data.frame(t(prop_corr))
  names(df_to_plot) <- c("stim_iter", "ns_3", "ns_4", "ns_6")
  
  return(df_to_plot)
}
