rlwm_rt_per_stim_iter <- function(df) {
  
  df <- as_tibble(df) # turn df into tibble
  
  # preprocessing - extract task data
  df_task <- df %>%
    filter(task == 'stimulus_presentation') %>% # extract stimulus trials
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
    rm(df_task2)
  }
  df_task <- do.call(rbind, templist)
  
  # Extract set sizes 3, 4, and 6, and add trial number
  df_ns3 <- df_task %>%
    filter(setsize == 3) %>%
    mutate(trial_number = row_number())
  
  df_ns4 <- df_task %>%
    filter(setsize == 4) %>%
    mutate(trial_number = row_number())
  
  df_ns6 <- df_task %>%
    filter(setsize == 6) %>%
    mutate(trial_number = row_number())
  
  ## Single participant learning curves - percentage correct vs trials
  
  # Compute cumulative sum of accuracy and add to df
  df_ns3 <- df_ns3 %>%
    mutate(cum_sum = cumsum(df_ns3$correct))
  
  df_ns4 <- df_ns4 %>%
    mutate(cum_sum = cumsum(df_ns4$correct))
  
  df_ns6 <- df_ns6 %>%
    mutate(cum_sum = cumsum(df_ns6$correct))
  
  # Add proportion correct (number correct out of total possible correct - at each time point)
  df_ns3 <- df_ns3 %>%
    mutate(proportion_correct = cum_sum / trial_number)
  
  df_ns4 <- df_ns4 %>%
    mutate(proportion_correct = cum_sum / trial_number)
  
  df_ns6 <- df_ns6 %>%
    mutate(proportion_correct = cum_sum / trial_number)
  
  # X axis should be iteration per stimulus aka trials per stimulus 
  
  stimulus_iteration_ns3 <- c(rep(1, 3), rep(2, 3), rep(3, 3), rep(4, 3), rep(5, 3), rep(6, 3),
                              rep(7, 3), rep(8, 3), rep(9, 3), rep(10, 3), rep(11, 3), rep(12, 3))
  stimulus_iteration_ns4 <- c(rep(1, 4), rep(2, 4), rep(3, 4), rep(4, 4), rep(5, 4), rep(6, 4),
                              rep(7, 4), rep(8, 4), rep(9, 4), rep(10, 4), rep(11, 4), rep(12, 4))
  stimulus_iteration_ns6 <- c(rep(1, 6), rep(2, 6), rep(3, 6), rep(4, 6), rep(5, 6), rep(6, 6),
                              rep(7, 6), rep(8, 6), rep(9, 6), rep(10, 6), rep(11, 6), rep(12, 6))
  
  stimulus_iteration_ns3 <- rep(stimulus_iteration_ns3, 2)
  stimulus_iteration_ns4 <- rep(stimulus_iteration_ns4, 2)
  stimulus_iteration_ns6 <- rep(stimulus_iteration_ns6, 2)
  
  df_ns3 <- df_ns3 %>%
    mutate(stimulus_iteration = stimulus_iteration_ns3)
  
  df_ns4 <- df_ns4 %>%
    mutate(stimulus_iteration = stimulus_iteration_ns4)
  
  df_ns6 <- df_ns6 %>%
    mutate(stimulus_iteration = stimulus_iteration_ns6)
  
  # Initialize results matrix
  rts <- matrix(0, 4, 12) # setsize (3,4,6) x stimulus iteration - first row will be x axis
  num_iterations <- 12
  
  # Set size 6
  for (i in 1:num_iterations) {
    ns6_iter <- df_ns6 %>%
      filter(stimulus_iteration == i) %>%
      select(rt)
    rts[4, i] <- mean(as.numeric(as.vector(unlist(ns6_iter))), na.rm = TRUE)
  }
  
  # Set size 4
  for (i in 1:num_iterations) {
    ns4_iter <- df_ns4 %>%
      filter(stimulus_iteration == i) %>%
      select(rt)
    rts[3, i] <- mean(as.numeric(as.vector(unlist(ns4_iter))), na.rm = TRUE)
  }
  
  # Set size 3
  for (i in 1:num_iterations) {
    ns3_iter <- df_ns3 %>%
      filter(stimulus_iteration == i) %>%
      select(rt)
    rts[2, i] <- mean(as.numeric(as.vector(unlist(ns3_iter))), na.rm = TRUE)
  }
  
  # X axis:
  rts[1, ] <- 1:12
  
  # Data for plotting
  df_to_plot <- data.frame(t(rts))
  
  return(df_to_plot)
}
