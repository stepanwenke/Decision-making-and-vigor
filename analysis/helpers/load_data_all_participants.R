# load_data_all_participants <- function(folder_path) {
#   # Requires tidyverse and for the files to be in the current working directory (not in a sub directory)
#   
#   # Ensure the tidyverse package is loaded
#   if (!requireNamespace("tidyverse", quietly = TRUE)) {
#     stop("tidyverse package is required but not installed.")
#   }
#   
#   # List all .csv files in the directory
#   csv_files <- list.files(path = folder_path, pattern = "\\.csv$", full.names = TRUE)
#   
#   # Read each .csv file into a data frame and store these data frames in a list
#   data_frames <- lapply(csv_files, function(f) {
#     read_csv(f) %>% as.data.frame()
#   })
# 
#   return(data_frames)
#   
# }


load_data_all_participants <- function(folder_path, col_types = NULL) {
  # Requires tidyverse and for the files to be in the specified folder path
  
  # Ensure the tidyverse package is loaded
  if (!requireNamespace("tidyverse", quietly = TRUE)) {
    stop("tidyverse package is required but not installed.")
  }
  
  # List all .csv files in the directory
  csv_files <- list.files(path = folder_path, pattern = "\\.csv$", full.names = TRUE)
  
  # Read each .csv file into a data frame and store these data frames in a list
  data_frames <- lapply(csv_files, function(f) {
    if (is.null(col_types)) {
      read_csv(f) %>% as.data.frame()
    } else {
      read_csv(f, col_types = cols(!!!col_types)) %>% as.data.frame()
    }
  })
  
  return(data_frames)
}