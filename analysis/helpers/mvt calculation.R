# Sample initial reward (R0) like your JS code
draw_initial_reward <- function() {
  r <- rnorm(1, mean = 10, sd = 1)
  r <- max(min(r, 15), 0)
  return(round(r, 1))
}

# Sample decay rate (lambda) like your steep galaxy
draw_lambda <- function() {
  rbeta(1, shape1 = 14.9, shape2 = 2.03)
}

# Discrete exponential MVT
optimal_digs_exponential <- function(T, d = 4.5, R0 = 10, lambda = 0.88) {
  
  if (is.null(R0)) R0 <- draw_initial_reward()
  if (is.null(lambda)) lambda <- draw_lambda()
  
  # maximum feasible digs: stop if reward < 0.01 (practically exhausted)
  max_k <- 500  # arbitrary large number; can be refined if needed
  
  # compute reward for each dig
  rewards <- R0 * lambda^(0:(max_k-1))
  
  # compute cumulative gain and average rate for k digs
  rates <- sapply(1:max_k, function(k){
    gain <- sum(rewards[1:k])
    time <- k * d + T
    gain / time
  })
  
  # find optimal number of digs
  best_k <- which.max(rates)
  best_rate <- rates[best_k]  # units per second
  
  # leaving threshold: reward at which next dig < average reward per dig
  R_thresh <- best_rate * d
  
  # reward of last accepted dig
  R_last <- rewards[best_k]
  # reward if one more dig were taken
  R_next <- rewards[best_k + 1]
  
  return(list(
    R0 = R0,
    lambda = lambda,
    best_k = best_k,
    best_rate = best_rate,
    R_thresh = R_thresh,
    R_last = R_last,
    R_next = R_next,
    rewards = rewards[1:(best_k+1)],
    rates = rates[1:max_k]
  ))
}

# Example usage
set.seed(42)

# Time 12 and 6
result_12s <- optimal_digs_exponential(T = 12, d = 4.5) # 3s digging + 1.5 reward display

result_6s <- optimal_digs_exponential(T = 6, d = 4.5)

print(result_12s$R_thresh)
print(result_6s$R_thresh)


