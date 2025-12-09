# HW7_client_test.R
# Client test code for Homework 7 API

library(httr)
library(jsonlite)

# Example test appointment
test_df <- data.frame(
  appt_time   = as.POSIXct("2025-01-10 15:00:00"),
  appt_made   = as.Date("2025-01-01"),
  age         = 40,
  provider_id = 5,
  specialty   = 1,      
  address     = 2
)

# Convert to JSON
json_input <- toJSON(test_df, auto_unbox = TRUE)

# ---------------------------------------------------------
# Test PREDICT_PROB endpoint
# ---------------------------------------------------------
resp_prob <- POST(
  "http://127.0.0.1:8000/predict_prob",
  body = list(df = json_input),
  encode = "form"
)

prob_output <- fromJSON(content(resp_prob, "text"))
cat("\nPredicted probabilities:\n")
print(prob_output)

# ---------------------------------------------------------
# Test PREDICT_CLASS endpoint
# ---------------------------------------------------------
resp_class <- POST(
  "http://127.0.0.1:8000/predict_class",
  body = list(df = json_input),
  encode = "form"
)

class_output <- fromJSON(content(resp_class, "text"))
cat("\nPredicted classes:\n")
print(class_output)