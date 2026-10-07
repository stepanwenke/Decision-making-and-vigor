### -----------------------------------------------------------
### Parameters for your foraging task
### -----------------------------------------------------------

kappa <- 0.88        # expected decay rate (steep condition)
r0 <- 10             # initial reward
travel_times <- c(6, 12)  # two travel times to test
h <- 4.5             # harvest time in seconds (3s digging + 1.5s outcome display)
rho_init <- 5             # average reward rate
n_patches <- 100     # number of patches per simulation
block_length <- 3000


### -----------------------------------------------------------
### Simulate foraging to compute optimal rho
### -----------------------------------------------------------

visit_planet <- function(kappa, r0, travel_time, h, rho,total_reward,total_time,exit_threshold) {

  # Value of exiting the patch - avg. reward rate * opportunity cost of time
  Q_exit <- rho * h
  
  # After landing on a planet
  total_time <- total_time + h
  total_reward <- total_reward + r0
  patch_reward <- r0
  dig <- 1
  
  
  repeat { # Digging loop
    
    if (patch_reward < Q_exit) { # If reward falls below the average reward rate
      exit_threshold <- c(exit_threshold,patch_reward)
      break
    } else if (total_time >= block_length * 60) {  # If time is up
      # if more than six minutes exit the function with exit threshold corresponding to the last value to not fuck up average
      exit_threshold <- c(exit_threshold, tail(exit_threshold, 1))
      break
    }
    
    dig <- dig + 1 # Dig
    patch_reward <- r0 * (kappa^(dig - 1)) # Harvest a reward that decays by kappa ^ n_digs
    
    # Sum up the current reward and time spend digging
    total_reward <- total_reward + patch_reward
    total_time <- total_time + h
    

  }
  

  # Update the time by travelling to a new planet
  total_time <- total_time + travel_time
  
  # update average reward rate - per second
  rho <- total_reward / total_time
  
  return(list(
    total_reward = total_reward,
    total_time = total_time,
    digs = dig,
    rho = rho,
    exit_threshold = exit_threshold,
    performance_bonus_GBP = total_reward * 0.0012
  ))
}


### -----------------------------------------------------------
### Loop over travel times and compute optimal rho + harvests
### -----------------------------------------------------------

set.seed(42)
results <- list()

for (tt in travel_times) {
  
  total_time <- 0      # total time spent foraging
  total_reward <- 0    # total reward collected
  exit_thresholds <- numeric(0)  # threshold for leaving patch (to be computed)
  
  # initialize variables for this travel time
  rho <- rho_init
 
  # simulate multiple patches
  for (i in 1:n_patches) {
    # break if total_time will be more than 6 minutes
    if (total_time >= block_length * 60) {
      break
    }
    
    res <- visit_planet(kappa, r0, tt, h, rho, total_reward, total_time, exit_thresholds)
    
    total_reward <- res$total_reward
    total_time <- res$total_time
    rho <- res$rho
    exit_thresholds <- res$exit_threshold
    performance_bonus_GBP <- res$performance_bonus_GBP
    

  }
  
  # store results for this travel time
  results[[paste0("travel_", tt)]] <- list(
    rho = rho,
    exit_thresholds = exit_thresholds,
    total_reward = total_reward,
    total_time = total_time / 60,
    performance_bonus_GBP = performance_bonus_GBP,
    last_exit_threshold = exit_thresholds[length(exit_thresholds)]
  )
}

### -----------------------------------------------------------
### Inspect results
### -----------------------------------------------------------

results$travel_6
results$travel_12
