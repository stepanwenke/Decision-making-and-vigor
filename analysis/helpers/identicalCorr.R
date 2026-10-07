identicalCorr <- function(x, y){
  
  tmpErr <- matrix(NA, nrow = length(x), ncol = 1)
  for (i in 1:length(x)) {
    tmpErr[i,] <- (y[i]- x[i])^2
  }

  
  MSE <- (1/length(y))*sum(tmpErr[,1])
  
  return(1-(MSE/var(y)))
  }