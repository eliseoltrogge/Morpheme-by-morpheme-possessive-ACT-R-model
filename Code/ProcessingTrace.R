# Define the file path
trace_file <- "TraceOutput.txt"

# Read lines from the file, suppressing the warning
lines <- readLines(trace_file, warn = FALSE)

# Initialize vectors to store the results
time <- c()
activation <- c()
picture <- character()

# Loop through each line to extract data
for (i in seq_along(lines)) {
  line <- lines[i]
  
  # Check for lines containing time information
  if (grepl("^\\s*[0-9]+\\.[0-9]{3}", line)) {
    # Extract the time from the line
    current_time <- as.numeric(sub("^\\s*([0-9]+\\.[0-9]{3}).*", "\\1", line))
  }
  
  # Extract activation values for the specified words
  if (grepl("activation of:", line)) {
    word <- sub("Chunk (\\w+) has an activation of:.*", "\\1", line)
    activation_value <- as.numeric(sub(".*activation of:\\s*([-0-9\\.]+).*", "\\1", line))
    
    # Check if activation_value is numeric and picture is either FLASCHE or KNOPF
    if (!is.na(activation_value) && (word == "FLASCHE" || word == "KNOPF")) {
      # Store the time, activation value, and picture object
      time <- c(time, current_time)
      activation <- c(activation, activation_value)
      picture <- c(picture, word)
    } else {
      # Handle case where activation value is NA or picture is not FLASCHE or KNOPF
      cat("Warning: Failed to extract numeric activation value or invalid picture from line:", line, "\n")
    }
  }
}

# Combine the extracted data into a data frame
data <- data.frame(time, activation, picture)

# Print the extracted data
cat("Extracted data:\n")
print(data)
