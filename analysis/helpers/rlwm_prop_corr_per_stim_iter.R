rlwm_prop_corr_per_stim_iter <- function(df) {
  
df <- as_tibble(df) # turn df into tibble

# preprocessing - extract task data
df_task <- df %>%
  filter(task == 'stimulus_presentation') %>% # extract stimulus trials
  select(rt, response, correct_response, correct, stimulus_type,
         setsize, block, stim_id)# %>% # select relevant variables
  #mutate(trial_index = 1:n()) #%>% # add trial_index for stimulus trials
  #mutate(rt = as.numeric(rt)) # make response time numeric

# Create block index (counting images within each block)
num_blocks <- max(df_task$block)
templist <- list()
for (i in 1:num_blocks) {
  df_task2 <- df_task %>%
    filter(block==i) %>%
    mutate(block_index = 1:n())
  
  templist[[i]] <- df_task2
  rm(df_task2)
  
}
df_task <- do.call(rbind, templist)






# extract set size 2 and add trial number
df_ns2 <- df_task %>%
  filter(setsize == 2) %>%
  mutate(trial_number = row_number())

# extract set size 3 and add trial number
df_ns3 <- df_task %>%
  filter(setsize == 3) %>%
  mutate(trial_number = row_number())

# extract set size 4 and add trial number
df_ns4 <- df_task %>%
  filter(setsize == 4) %>%
  mutate(trial_number = row_number())

# extract set size 5 and add trial number
df_ns5 <- df_task %>%
  filter(setsize == 5) %>%
  mutate(trial_number = row_number())

# extract set size 6 and add trial number
df_ns6 <- df_task %>%
  filter(setsize == 6) %>%
  mutate(trial_number = row_number())


## Single participant learning curves - percentage correct vs trials - not used in avg. across participants

# compute cumulative sum of accuracy and add to df
df_ns2 <- df_ns2 %>%
  mutate(cum_sum = cumsum(df_ns2$correct))

df_ns3 <- df_ns3 %>%
  mutate(cum_sum = cumsum(df_ns3$correct))

df_ns4 <- df_ns4 %>%
  mutate(cum_sum = cumsum(df_ns4$correct))

df_ns5 <- df_ns5 %>%
  mutate(cum_sum = cumsum(df_ns5$correct))

df_ns6 <- df_ns6 %>%
  mutate(cum_sum = cumsum(df_ns6$correct))


# add proportion correct (number correct out of total possible correct - at each time point)
df_ns2 <- df_ns2 %>%
  mutate(proportion_correct = cum_sum / trial_number)

df_ns3 <- df_ns3 %>%
  mutate(proportion_correct = cum_sum / trial_number)

df_ns4 <- df_ns4 %>%
  mutate(proportion_correct = cum_sum / trial_number)

df_ns5 <- df_ns5 %>%
  mutate(proportion_correct = cum_sum / trial_number)

df_ns6 <- df_ns6 %>%
  mutate(proportion_correct = cum_sum / trial_number)

# x axis should be iteration per stimulus aka trials per stimulus 

stimulus_iteration_ns2 <- c(rep(1,2), rep(2,2), rep(3,2), rep(4,2), rep(5,2), rep(6,2), rep(7,2), rep(8,2), rep(9,2), rep(10,2), rep(11,2), rep(12,2))
stimulus_iteration_ns3 <- c(rep(1,3), rep(2,3), rep(3,3), rep(4,3), rep(5,3), rep(6,3), rep(7,3), rep(8,3), rep(9,3), rep(10,3), rep(11,3), rep(12,3))
stimulus_iteration_ns4 <- c(rep(1,4), rep(2,4), rep(3,4), rep(4,4), rep(5,4), rep(6,4), rep(7,4), rep(8,4), rep(9,4), rep(10,4), rep(11,4), rep(12,4))
stimulus_iteration_ns5 <- c(rep(1,5), rep(2,5), rep(3,5), rep(4,5), rep(5,5), rep(6,5), rep(7,5), rep(8,5), rep(9,5), rep(10,5), rep(11,5), rep(12,5))
stimulus_iteration_ns6 <- c(rep(1,6), rep(2,6), rep(3,6), rep(4,6), rep(5,6), rep(6,6), rep(7,6), rep(8,6), rep(9,6), rep(10,6), rep(11,6), rep(12,6))
stimulus_iteration_ns2 <- rep(stimulus_iteration_ns2, 2)
stimulus_iteration_ns3 <- rep(stimulus_iteration_ns3, 2)
stimulus_iteration_ns4 <- rep(stimulus_iteration_ns4, 2)
stimulus_iteration_ns5 <- rep(stimulus_iteration_ns5, 2)
stimulus_iteration_ns6 <- rep(stimulus_iteration_ns6, 2)


df_ns2 <- df_ns2 %>%
  mutate(stimulus_iteration = stimulus_iteration_ns2)

df_ns3 <- df_ns3 %>%
  mutate(stimulus_iteration = stimulus_iteration_ns3)

df_ns4 <- df_ns4 %>%
  mutate(stimulus_iteration = stimulus_iteration_ns4)

df_ns5 <- df_ns5 %>%
  mutate(stimulus_iteration = stimulus_iteration_ns5)

df_ns6 <- df_ns6 %>%
  mutate(stimulus_iteration = stimulus_iteration_ns6)


#for loop 1:12?

# don't care about the blocks here - later

prop_corr <- matrix(0, 6, 12) # setsize (2,3,4,5,6) x stimulus iteration - first row wil be x axis
num_iterations <- 12

# set size 6
prop_corr_ns6 = vector()
for (i in 1:num_iterations) {
  ns6_iter <- df_ns6 %>%
    filter(stimulus_iteration == i) %>%
    select(correct)
  # proportion correct
  prop_corr[6,i] <- mean(unlist(ns6_iter))
  
}

# set size 5
prop_corr_ns5 = vector()
for (i in 1:num_iterations) {
  ns5_iter <- df_ns5 %>%
    filter(stimulus_iteration == i) %>%
    select(correct)
  # proportion correct
  prop_corr[5,i] <- mean(unlist(ns5_iter))
  
}

# set size 4
prop_corr_ns4 = vector()
for (i in 1:num_iterations) {
  ns4_iter <- df_ns4 %>%
    filter(stimulus_iteration == i) %>%
    select(correct)
  # proportion correct
  prop_corr[4,i] <- mean(unlist(ns4_iter))
  
}

# set size 3
prop_corr_ns3 = vector()
for (i in 1:num_iterations) {
  ns3_iter <- df_ns3 %>%
    filter(stimulus_iteration == i) %>%
    select(correct)
  # proportion correct
  prop_corr[3,i] <- mean(unlist(ns3_iter))
  
}

# set size 2
prop_corr_ns2 = vector()
for (i in 1:num_iterations) {
  ns2_iter <- df_ns2 %>%
    filter(stimulus_iteration == i) %>%
    select(correct)
  # proportion correct
  prop_corr[2,i] <- mean(unlist(ns2_iter))
  
}



# prop_corr has the y variables (double-check correctness)
# X axis:
prop_corr[1,] <- 1:12

# data for plotting
df_to_plot <- data.frame(t(prop_corr))
names(df_to_plot) <- c("stim_iter", "ns_2", "ns_3", "ns_4", "ns_5", "ns_6")

return(df_to_plot)

}