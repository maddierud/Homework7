# HW7_api_server.R
# API for Homework 7 – No-Show ML Model

library(plumber)
library(jsonlite)
library(lubridate)
library(dplyr)

# ---------------------------------------------------------------
# Load model and threshold saved in Homework 4
# ---------------------------------------------------------------
model <- readRDS("no_show_model.rds")
threshold <- as.numeric(readLines("model_threshold.txt"))

# ---------------------------------------------------------------
# Feature engineering function
# ---------------------------------------------------------------

featurize <- function(df) {
  df %>%
    mutate(
      lead_time_days = as.numeric(as.Date(appt_time) - appt_made),
      hour = hour(appt_time),
      dow = wday(appt_time, label = TRUE, week_start = 1),
      is_weekend = wday(appt_time, week_start = 1) >= 6,
      age_z = (age - 54.47305) / 16.39949,
      provider_id = factor(provider_id),
      specialty = factor(specialty),
      address = factor(address),
      lead_time_days = pmax(lead_time_days, 0)
    )
}

# ---------------------------------------------------------------
# predict_prob endpoint
# ---------------------------------------------------------------

#* Predict probability of no-show
#* @param df JSON-encoded data frame of predictor values
#* @post /predict_prob
function(df) {
  input_df <- fromJSON(df)
  
  input_df$appt_time <- as.POSIXct(input_df$appt_time)
  input_df$appt_made <- as.Date(input_df$appt_made)
  
  input_df$provider_id <- factor(input_df$provider_id, levels = model$xlevels$provider_id)
  input_df$specialty   <- factor(input_df$specialty,   levels = model$xlevels$specialty)
  input_df$address     <- factor(input_df$address,     levels = model$xlevels$address)
  
  processed <- featurize(input_df)
  
  probs <- predict(model, newdata = processed, type = "response")
  list(prob = probs)
}



# ---------------------------------------------------------------
# predict_class endpoint
# ---------------------------------------------------------------

#* Predict no-show class (0 or 1)
#* @param df JSON-encoded data frame of predictor values
#* @post /predict_class
function(df) {
  input_df <- fromJSON(df)
  
  input_df$appt_time <- as.POSIXct(input_df$appt_time)
  input_df$appt_made <- as.Date(input_df$appt_made)
  
  input_df$provider_id <- factor(input_df$provider_id, levels = model$xlevels$provider_id)
  input_df$specialty   <- factor(input_df$specialty,   levels = model$xlevels$specialty)
  input_df$address     <- factor(input_df$address,     levels = model$xlevels$address)
  
  processed <- featurize(input_df)
  
  probs <- predict(model, newdata = processed, type = "response")
  preds <- ifelse(probs >= threshold, 1, 0)
  
  list(class = preds)
}
