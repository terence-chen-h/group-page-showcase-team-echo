install.packages("fitdistrplus")
install.packages("moments")
install.packages("actuar")
install.packages("survival")
install.packages("MASS")
install.packages("readxl", repos = "https://cloud.r-project.org")
library(readxl)
library(fitdistrplus)
library(actuar)
library(moments)
library(survival)
library(MASS)



# ==============================================================================
# SHEETS READING
# ==============================================================================

cargo_freq <- read_xlsx("C:/Uni - Year 4/ACTL4001/Clean.xlsx", sheet = "Cargo freq")
cargo_sev <- read_xlsx("C:/Uni - Year 4/ACTL4001/Clean.xlsx", sheet = "Cargo sev")
bus_freq <- read_xlsx("C:/Uni - Year 4/ACTL4001/Clean.xlsx", sheet = "Bus freq")
bus_sev <- read_xlsx("C:/Uni - Year 4/ACTL4001/Clean.xlsx", sheet = "Bus sev")
equip_freq <- read_xlsx("C:/Uni - Year 4/ACTL4001/Clean.xlsx", sheet = "Equip freq")
equip_sev <- read_xlsx("C:/Uni - Year 4/ACTL4001/Clean.xlsx", sheet = "Equip sev")
worker_freq <- read_xlsx("C:/Uni - Year 4/ACTL4001/Clean.xlsx", sheet = "Worker freq")
worker_sev <- read_xlsx("C:/Uni - Year 4/ACTL4001/Clean.xlsx", sheet = "Worker sev")
interest <- read_xlsx("C:/Uni - Year 4/ACTL4001/Clean.xlsx", sheet = "Interest")
inventory <- read_xlsx("C:/Uni - Year 4/ACTL4001/Clean.xlsx", sheet = "Inventory")
personnel <- read_xlsx("C:/Uni - Year 4/ACTL4001/Clean.xlsx", sheet = "Personnel")





# ==============================================================================
# CLEANING DATA
# ==============================================================================

# Removing missing data
bus_freq <- na.omit(bus_freq)
cargo_freq <- na.omit(cargo_freq)
equip_freq <- na.omit(equip_freq)
worker_freq <- na.omit(worker_freq)

bus_sev <- na.omit(bus_sev)
cargo_sev <- na.omit(cargo_sev)
equip_sev <- na.omit(equip_sev)
worker_sev <- na.omit(worker_sev)

length(bus_sev$claim_amount)
length(bus_freq$claim_count)

# Removing hidden/corrupted characters
clean_chr_cols <- function(data) {
  data[] <- lapply(data, function(col) {
    if (is.character(col)) {
      sub("_.*", "", col)
    } else {
      col
    }
  })
  return(data)
}

bus_freq <- clean_chr_cols(bus_freq)
cargo_freq <- clean_chr_cols(cargo_freq)
equip_freq <- clean_chr_cols(equip_freq)
worker_freq <- clean_chr_cols(worker_freq)

bus_sev <- clean_chr_cols(bus_sev)
cargo_sev <- clean_chr_cols(cargo_sev)
equip_sev <- clean_chr_cols(equip_sev)
worker_sev <- clean_chr_cols(worker_sev)

# Rounding freq claim counts
bus_freq$claim_count <- round(bus_freq$claim_count)
cargo_freq$claim_count <- round(cargo_freq$claim_count)
equip_freq$claim_count <- round(equip_freq$claim_count)
worker_freq$claim_count <- round(worker_freq$claim_count)

# Absolute valuing claim amounts
bus_sev$claim_amount <- abs(bus_sev$claim_amount)
cargo_sev$claim_amount <- abs(cargo_sev$claim_amount)
equip_sev$claim_amount <- abs(equip_sev$claim_amount)
worker_sev$claim_amount <- abs(worker_sev$claim_amount)



# ==============================================================================
# SETTING UP CAPPED DATA
# ==============================================================================

# Capping Freq Counts
bus_freq_capped <- bus_freq
cargo_freq_capped <- cargo_freq
equip_freq_capped <- equip_freq
worker_freq_capped <- worker_freq

clean_freq <- function(dataset, max) {
  for (i in 1:length(dataset)) {
    if (dataset[i] > max) {
      dataset[i] = max
    }
  }
  return(dataset)
}

bus_freq_capped$claim_count <- clean_freq(bus_freq_capped$claim_count, 4)
cargo_freq_capped$claim_count <- clean_freq(cargo_freq_capped$claim_count, 5)
equip_freq_capped$claim_count <- clean_freq(equip_freq_capped$claim_count, 3)
worker_freq_capped$claim_count <- clean_freq(worker_freq_capped$claim_count, 2)

# Capping Severity Amounts
bus_sev_capped <- bus_sev
cargo_sev_capped <- cargo_sev
equip_sev_capped <- equip_sev
worker_sev_capped <- worker_sev

cap_data <- function(dataset, max, min) {
  for (i in 1:length(dataset)) {
    if (dataset[i] > max) {
      dataset[i] = max
    } else if (dataset[i] < min) {
      dataset[i] = min
    }
  }
  return(dataset)
}

bus_max_claim = 1426000
bus_min_claim = 28000
cargo_max_claim = 678000
cargo_min_claim = 31000
equip_max_claim = 790000
equip_min_claim = 11000
worker_max_claim = 170000
worker_min_claim = 5000

bus_sev_capped$claim_amount <- cap_data(bus_sev_capped$claim_amount,
                                    bus_max_claim, bus_min_claim)
cargo_sev_capped$claim_amount <- cap_data(cargo_sev_capped$claim_amount,
                                      cargo_max_claim, cargo_min_claim)
equip_sev_capped$claim_amount <- cap_data(equip_sev_capped$claim_amount,
                                      equip_max_claim, equip_min_claim)
worker_sev_capped$claim_amount <- cap_data(worker_sev_capped$claim_amount,
                                       worker_max_claim, worker_min_claim)



# ==============================================================================
# STAT ANALYSIS + EDA OF FREQUENCY SHEETS
# ==============================================================================

stats <- function(dataset, type, name) {
  cat("\nSummary Stats: ", type, name, "\n")
  print(summary(dataset))
  cat("Mean: ", mean(dataset), "\n")
  cat("Variance: ", var(dataset), "\n")
  cat("Skewness: ", skewness(dataset), "\n")
  cat("Kurtosis: ", kurtosis(dataset), "\n")
}

histogram <- function(dataset, type, name, info) {
  hist(dataset, main = paste("Histogram of", type, name, "Claim", info), 
       xlab = paste("Claim", info), 
       col = "skyblue", border = "white")
}

freq_analysis <- function(claims, type) {
  for (sheet in names(claims)) {
    data <- claims[[sheet]]
    stats(data$claim_count, type, sheet)
    histogram(data$claim_count, type, sheet, "Counts")
    cat("% 0's: ", mean(data$claim_count == 0), "\n")
    cat("Crude Exposure: ", sum(data$claim_count) / sum(data$exposure), "\n")
  }
}

raw_claims <- list(Business = bus_freq,
                   Cargo = cargo_freq,
                   Equipment = equip_freq,
                   Worker = worker_freq)
capped_claims <- list(Business = bus_freq_capped,
                      Cargo = cargo_freq_capped,
                      Equipment = equip_freq_capped,
                      Worker = worker_freq_capped)
raw_freq_analysis <- freq_analysis(raw_claims, "Raw")
capped_freq_analysis <- freq_analysis(capped_claims, "Capped")



# ==============================================================================
# STAT ANALYSIS + EDA OF SEVERITY SHEETS
# ==============================================================================

intervals <- c(0.8, 0.85, 0.9, 0.95, 0.99)

conf_int <- function(data) {
  results <- data.frame(
    level = intervals,
    VaR = NA,
    ES = NA
  )
  
  print("Confidence Intervals")
  
  for (i in seq_along(intervals)) {
    VaR <- quantile(data, intervals[i], na.rm = TRUE)
    ES <- mean(data[data >= VaR],na.rm = TRUE)
    cat(intervals[i], " VaR: ", VaR, " ES: ", ES, "\n")
    results$VaR[i] <- VaR
    results$ES[i] <- ES
  }
  return(results)
}


qqmatch <- function(dataset, type, sheet, info) {
  log_data <- log(dataset)
  hist(log_data,
       main = paste("Histogram of Log", type, sheet, "Claim", info),
       xlab = paste("log(Claim", info, ")"),
       col = "lightgreen",
       border = "white")
  qqnorm(log_data, main = paste("Log Q-Q Plot:", type, sheet, "Claim", info))
  qqline(log_data, col = "red")
}

sev_dist_fit <- function(dataset, type, sheet) {
  fit_lnorm <- fitdist(dataset, "lnorm")
  fit_weibull <- fitdist(dataset, "weibull")
  fit_llogis <- fitdist(dataset, "llogis")
  
  qqcomp(list(fit_lnorm, fit_weibull, fit_llogis),
         legendtext = c("Lognormal", "Weibull", "Log-Logistic"),
         main = paste("Q-Q Comparison:", type, sheet, "Claim Amounts"))
  cdfcomp(list(fit_lnorm, fit_weibull, fit_llogis),
          legendtext = c("Lognormal", "Weibull", "Log-Logistic"),
          main = paste("CDF Comparison:", type, sheet, "Claim Amounts"))
  denscomp(list(fit_lnorm, fit_weibull, fit_llogis),
           legendtext = c("Lognormal", "Weibull", "Log-Logistic"),
           main = paste("Density Comparison:", type, sheet, "Claim Amounts"))
  print(gofstat(list(fit_lnorm, fit_weibull, fit_llogis)))
}

sev_analysis <- function(claims, type) {
  for (sheet in names(claims)) {
    data <- claims[[sheet]]
    stats(data$claim_amount, type, sheet)
    histogram(data$claim_amount, type, sheet, "Amounts")
    qqmatch(data$claim_amount, type, sheet, "Amounts")
    conf <- conf_int(data$claim_amount)
    sev_dist_fit(data$claim_amount, type, sheet)
  }
}

raw_claims <- list(Business = bus_sev,
                   Cargo = cargo_sev,
                   Equipment = equip_sev,
                   Worker = worker_sev)
capped_claims <- list(Business = bus_sev_capped,
                      Cargo = cargo_sev_capped,
                      Equipment = equip_sev_capped,
                      Worker = worker_sev_capped)
raw_sev_analysis <- sev_analysis(raw_claims, "Raw")
capped_sev_analysis <- sev_analysis(capped_claims, "Capped")



# ==============================================================================
# RAW CLEANED DATA - MODELLING
# ==============================================================================

bus_freq_model <- glm.nb(
  claim_count ~ station_id + solar_system + production_load +
    energy_backup_score + supply_chain_index + avg_crew_exp + maintenance_freq +
    safety_compliance + offset(log(exposure)),
  data = bus_freq,
  link = log
)
cargo_freq_model <- glm.nb(
  claim_count ~ cargo_type + cargo_value + weight + route_risk + distance +
    transit_duration + pilot_experience + vessel_age + container_type +
    solar_radiation + debris_density + offset(log(exposure)),
  data = cargo_freq,
  link = log
)
equip_freq_model <- glm.nb(
  claim_count ~ equipment_type + equipment_age + solar_system +
    maintenance_int + usage_int + offset(log(exposure)),
  data = equip_freq,
  link = log
)
worker_freq_model <- glm.nb(
  claim_count ~ solar_system + station_id + occupation + employment_type +
    experience_yrs + accident_history_flag + psych_stress_index +
    hours_per_week + supervision_level + gravity_level +
    safety_training_index + protective_gear_quality + base_salary +
    offset(log(exposure)),
  data = worker_freq,
  link = log
)

bus_sev_model <- lm(
  log(claim_amount) ~ station_id + solar_system + production_load +
    energy_backup_score + safety_compliance + exposure, data = bus_sev
)
cargo_sev_model <- survreg(
  Surv(claim_amount) ~ cargo_type +
    cargo_value + weight + route_risk + distance + transit_duration +
    pilot_experience + vessel_age + container_type + solar_radiation +
    debris_density + exposure, data = cargo_sev, dist = "loglogistic"
)
equip_sev_model <- lm(
  log(claim_amount) ~ equipment_type +
    equipment_age + solar_system + maintenance_int + usage_int +
    exposure, data = equip_sev
)
worker_sev_model <- survreg(
  Surv(claim_amount) ~ solar_system +
    station_id + occupation + employment_type + experience_yrs +
    accident_history_flag + psych_stress_index + hours_per_week +
    supervision_level + gravity_level + safety_training_index +
    protective_gear_quality + injury_type + injury_cause +
    claim_length + exposure, data = worker_sev, dist = "loglogistic"
)

# Summary
summary(bus_freq_model)
summary(cargo_freq_model)
summary(equip_freq_model)
summary(worker_freq_model)

lognorm_agg_trans <- function(freq, sev) {
  expected_N <- sum(fitted(freq))
  sigma2 <- summary(sev)$sigma^2
  mean_X <- mean(exp(predict(sev) + sigma2/2))
  expected_agg <- expected_N * mean_X
  
  return(list(
    expected_N = expected_N,
    expected_X = mean_X,
    expected_agg = expected_agg
  ))
}

loglogis_agg_trans <- function(freq, sev) {
  expected_N <- sum(fitted(freq))
  scale <- sev$scale
  eta <- predict(sev, type = "lp")
  expected_X_i <- exp(eta) * ((pi * scale) / sin(pi * scale))
  mean_X <- mean(expected_X_i, na.rm = TRUE)
  expected_agg <- expected_N * mean_X
  
  return(list(
    expected_N = expected_N,
    expected_X = mean_X,
    expected_agg = expected_agg
  ))
}

# Losses
bus_agg_loss <- lognorm_agg_trans(bus_freq_model, bus_sev_model)
cargo_agg_loss <- loglogis_agg_trans(cargo_freq_model, cargo_sev_model)
equip_agg_loss <- lognorm_agg_trans(equip_freq_model, equip_sev_model)
worker_agg_loss <- loglogis_agg_trans(worker_freq_model, worker_sev_model)

print("Business Interruptions Aggregates:")
print(bus_agg_loss)
print("Cargo Aggregates:")
print(cargo_agg_loss)
print("Equipment Aggregates:")
print(equip_agg_loss)
print("Worker Aggregates:")
print(worker_agg_loss)




# ==============================================================================
# RAW CLEANED DATA - AGGREGATE LOSS DISTRIBUTION
# ==============================================================================

simulate_agg_lognorm <- function(freq, sev, n_sim, freq_stress, sev_stress,
                                 group_category, group, freq_data, sev_data) {
  if (group_category != "NONE" && group != "NONE") {
    freq_index <- freq_data[[group_category]] == group
    sev_index <- sev_data[[group_category]] == group
    mu_freq <- fitted(freq)[freq_index] * freq_stress
    theta <- freq$theta
    eta_sev <- predict(sev)[sev_index]
                            
  } else {
    mu_freq <- fitted(freq) * freq_stress
    theta <- freq$theta
    eta_sev <- predict(sev)
  }
  
  sigma <- summary(sev)$sigma
  agg_losses <- numeric(n_sim)
  
  for (s in seq_len(n_sim)) {
    n_i <- rnbinom(length(mu_freq), mu = mu_freq, size = theta)
    total_n <- sum(n_i)
    
    if (total_n == 0) {
      agg_losses[s] <- 0
    } else {
      sev_eta <- sample(eta_sev, total_n, replace = TRUE)
      sev_draws <- rlnorm(total_n, meanlog = sev_eta, sdlog = sigma) * sev_stress
      agg_losses[s] <- sum(sev_draws)
    }
  }
  agg_losses
}


simulate_agg_loglogis <- function(freq, sev, n_sim, freq_stress, sev_stress,
                                  group_category, group, freq_data, sev_data) {
  if (group_category != "NONE" && group != "NONE") {
    freq_index <- freq_data[[group_category]] == group
    sev_index <- sev_data[[group_category]] == group
    mu_freq <- fitted(freq)[freq_index] * freq_stress
    theta <- freq$theta
    eta_sev <- predict(sev, type = "lp")[sev_index]
    
  } else {
    mu_freq <- fitted(freq) * freq_stress
    theta <- freq$theta
    eta_sev <- predict(sev, type = "lp")
  }
  
  scale <- sev$scale
  agg_losses <- numeric(n_sim)
  
  for (s in seq_len(n_sim)) {
    n_i <- rnbinom(length(mu_freq), mu = mu_freq, size = theta)
    total_n <- sum(n_i)
    
    if (total_n == 0) {
      agg_losses[s] <- 0
    } else {
      sev_eta <- sample(eta_sev, total_n, replace = TRUE)
      u <- runif(total_n)
      sev_draws <- exp(sev_eta + scale * qlogis(u)) * sev_stress
      agg_losses[s] <- sum(sev_draws)
    }
  }
  
  agg_losses
}

summarise_agg_dist <- function(x) {
  c(
    mean   = mean(x, na.rm = TRUE),
    median = median(x, na.rm = TRUE),
    sd     = sd(x, na.rm = TRUE),
    p95    = unname(quantile(x, 0.95, na.rm = TRUE)),
    p99    = unname(quantile(x, 0.99, na.rm = TRUE)),
    max    = max(x, na.rm = TRUE)
  )
}


# ================================================================================
# RAW CLEANED DATA - SIMULATING (ALL HAZARDS)
# ================================================================================
n_sim = 5000
set.seed(123)

bus_agg_dist <- simulate_agg_lognorm(bus_freq_model, bus_sev_model, n_sim,
                                     1, 1, "NONE", "NONE",
                                     bus_freq, bus_sev)
cargo_agg_dist <- simulate_agg_loglogis(cargo_freq_model, cargo_sev_model, n_sim,
                                        1, 1, "NONE", "NONE",
                                        cargo_freq, cargo_sev)
equip_agg_dist <- simulate_agg_lognorm(equip_freq_model, equip_sev_model, n_sim,
                                       1, 1, "NONE", "NONE",
                                       equip_freq, equip_sev)
worker_agg_dist <- simulate_agg_loglogis(worker_freq_model, worker_sev_model, n_sim,
                                         1, 1, "NONE", "NONE",
                                         worker_freq, worker_sev)
histogram(bus_agg_dist, "Raw", "Business", "Amounts")
histogram(cargo_agg_dist, "Raw", "Cargo", "Amounts")
histogram(equip_agg_dist, "Raw", "Equip", "Amounts")
histogram(worker_agg_dist, "Raw", "Worker", "Amounts")

bus_base_summary <- summarise_agg_dist(bus_agg_dist)
cargo_base_summary <- summarise_agg_dist(cargo_agg_dist)
equip_base_summary <- summarise_agg_dist(equip_agg_dist)
worker_base_summary <- summarise_agg_dist(worker_agg_dist)

print("Business Simulated Summary")
print(bus_base_summary)
print("Cargo Simulated Summary")
print(cargo_base_summary)
print("Equip Simulated Summary")
print(equip_base_summary)
print("Worker Simulated Summary")
print(worker_base_summary)

bus_conf <- conf_int(bus_agg_dist)
cargo_conf <- conf_int(cargo_agg_dist)
equip_conf <- conf_int(equip_agg_dist)
worker_conf <- conf_int(worker_agg_dist)

# ================================================================================
# RAW CLEANED DATA - PRICING (ALL HAZARDS)
# ================================================================================

profit_margin <- 1.05

# Pure premium with no loadings
bus_pure_premium <- mean(bus_agg_dist) / sum(bus_freq$exposure)
cargo_pure_premium <-  mean(cargo_agg_dist) / sum(cargo_freq$exposure)
equip_pure_premium <-  mean(equip_agg_dist) / sum(equip_freq$exposure)
worker_pure_premium <-  mean(worker_agg_dist) / sum(worker_freq$exposure)

cat("Business Premium Rate: ", bus_pure_premium)
cat("Cargo Premium Rate: ", cargo_pure_premium)
cat("Equip Premium Rate: ", equip_pure_premium)
cat("Worker Premium Rate: ", worker_pure_premium)

# Add on risk loading
risk_interval <- 0.95
bus_risk_loading <- (bus_conf$VaR[bus_conf$level == risk_interval] -
                       mean(bus_agg_dist)) / mean(bus_agg_dist)
cargo_risk_loading <- (cargo_conf$VaR[cargo_conf$level == risk_interval] -
                         mean(cargo_agg_dist)) / mean(cargo_agg_dist)
equip_risk_loading <- (equip_conf$VaR[equip_conf$level == risk_interval] -
                         mean(equip_agg_dist)) / mean(equip_agg_dist)
worker_risk_loading <- (worker_conf$VaR[worker_conf$level == risk_interval] -
                          mean(worker_agg_dist)) / mean(worker_agg_dist)

cat("Business Risk Rate: ", bus_risk_loading)
cat("Cargo Risk Rate: ", cargo_risk_loading)
cat("Equip Risk Rate: ", equip_risk_loading)
cat("Worker Risk Rate: ", worker_risk_loading)

# Premium inclusive of risk loading + profit margin
bus_premium <- bus_pure_premium * (1 + bus_risk_loading) * profit_margin
cargo_premium <- cargo_pure_premium * (1 + cargo_risk_loading) * profit_margin
equip_premium <- equip_pure_premium * (1 + equip_risk_loading) * profit_margin
worker_premium <- worker_pure_premium * (1 + worker_risk_loading) * profit_margin

cat("Final Business annual premium: ", bus_premium, "\n")
cat("Final Cargo annual premium: ", cargo_premium, "\n")
cat("Final Equip annual premium: ", equip_premium, "\n")
cat("Final Worker annual premium: ", worker_premium, "\n")
sum_premiums <- bus_premium + cargo_premium + equip_premium + worker_premium

agg_dist <- bus_agg_dist + cargo_agg_dist + equip_agg_dist + worker_agg_dist
agg_conf <- conf_int(agg_dist)
agg_exposure <- sum(bus_freq$exposure) +
  sum(cargo_freq$exposure) +
  sum(equip_freq$exposure) +
  sum(worker_freq$exposure)
agg_premium_rate <- mean(agg_dist) / agg_exposure
agg_risk_loading <- (agg_conf$VaR[agg_conf$level == risk_interval] -
                             mean(agg_dist)) / mean(agg_dist)
agg_premium <- agg_premium_rate * (1 + agg_risk_loading) * profit_margin
cat("Sum of individual premiums: ", sum_premiums, "\n")
cat("Aggregate premiums: ", agg_premium, "\n")

# ================================================================================
# RAW CLEANED DATA - SIMULATING (BY SOLAR SYSTEM)
# ================================================================================

price <- function(agg_dist, freq, name, star, risk_interval) {
  cat("\n", name, "\n")
  print(summary(agg_dist))
  premium_rate <- mean(agg_dist) / sum(freq$exposure[freq$solar_system == star])
  cat(name, "Premium Rate: ", premium_rate, "\n")
  conf <- conf_int(agg_dist)
  risk_loading <- (conf$VaR[conf$level == risk_interval] - mean(agg_dist)) / mean(agg_dist)
  cat(name, "Risk Loading Rate: ", risk_loading, "\n")
  premium <- premium_rate * (1+risk_loading) * profit_margin
  cat("Final", name, "annual premium: ", premium, "\n")
  return(premium)
}

sim_solar_system <- function(star, b_freq, b_sev, c_freq, c_sev,
                                  e_freq, e_sev, w_freq, w_sev) {
  # Hazards
  cat("\nStar: ", star, "\n")
  bus_agg_dist <- simulate_agg_lognorm(bus_freq_model, bus_sev_model, n_sim,
                                       b_freq, b_sev, "solar_system", star,
                                       bus_freq, bus_sev)
  bus_premium <- price(bus_agg_dist, bus_freq, "Business Interruptions", star, risk_interval)
  cargo_agg_dist <- simulate_agg_loglogis(cargo_freq_model, cargo_sev_model, n_sim,
                                          c_freq, c_sev, "solar_system", star,
                                          cargo_freq, cargo_sev)
  cargo_premium <- price(cargo_agg_dist, cargo_freq, "Cargo", star, risk_interval)
  equip_agg_dist <- simulate_agg_lognorm(equip_freq_model, equip_sev_model, n_sim,
                                         e_freq, e_sev, "solar_system", star,
                                         equip_freq, equip_sev)
  equip_premium <- price(equip_agg_dist, equip_freq, "Equipment", star, risk_interval)
  worker_agg_dist <- simulate_agg_loglogis(worker_freq_model, worker_sev_model,
                                           n_sim, w_freq, w_sev, "solar_system",
                                           star, worker_freq, worker_sev)
  worker_premium <- price(worker_agg_dist, worker_freq, "Worker", star, risk_interval)
  
  # Star Aggregate
  summary_agg_dist <- bus_agg_dist + cargo_agg_dist + equip_agg_dist + worker_agg_dist
  cat("\nStar Aggregate Summary:\n")
  print(summary(summary_agg_dist))
  star_conf <- conf_int(summary_agg_dist)
  total_exposure <- sum(bus_freq$exposure[bus_freq$solar_system == star]) +
    sum(cargo_freq$exposure[cargo_freq$solar_system == star]) +
    sum(equip_freq$exposure[equip_freq$solar_system == star]) +
    sum(worker_freq$exposure[worker_freq$solar_system == star])
  star_premium_rate <- mean(summary_agg_dist) / total_exposure
  star_risk_loading <- (star_conf$VaR[star_conf$level == 0.99] -
                          mean(summary_agg_dist)) / mean(summary_agg_dist)
  star_premium <- star_premium_rate * (1 + star_risk_loading) * profit_margin
  cat("Star Premium:", star_premium, "\n")
  cat("Profit: ", star_premium - star_premium_rate)
  
  # Sum of individual premiums
  if (is.nan(bus_premium)) {
    bus_premium <- 0
  }
  if (is.nan(cargo_premium)) {
    cargo_premium <- 0
  }
  if (is.nan(equip_premium)) {
    equip_premium <- 0
  }
  if (is.nan(worker_premium)) {
    worker_premium <- 0
  }
  solar_system_premium <- bus_premium + cargo_premium + equip_premium + worker_premium
  cat("\n", star, "Sum of Individual Premium:", solar_system_premium, "\n")
  
  return(list(
    agg_dist = summary_agg_dist,
    star_premium = star_premium,
    sum_individual_premium = solar_system_premium,
    conf = star_conf,
    total_exposure = total_exposure
  ))
}

f = 1
s = 1

# Epsilon
epsilon_agg <- sim_solar_system("Epsilon", f, s, f, s, f, s, f, s)

# Helionis Cluster
helionis <- sim_solar_system("Helionis Cluster", f, s, f, s, f, s, f, s)

# Zeta
zeta <- sim_solar_system("Zeta", f, s, f, s, f, s, f, s)


# ================================================================================
# RAW CLEANED DATA - STRESS TESTING (star, b_freq, b_sev, c_freq, c_sev, e_freq, e_sev, w_freq, w_sev)
# ================================================================================

## Moderate Shock (+20% freq, +25% sev)
f = 1.2
s = 1.25

moderate_epsilon <- sim_solar_system("Epsilon", f, s, f, s, f, s, f, s)
moderate_helionis <- sim_solar_system("Helionis Cluster", f, s, f, s, f, s, f, s)
moderate_zeta <- sim_solar_system("Zeta", f, s, f, s, f, s, f, s)

## Significant Effect Case Scenario (+40% freq, +50% sev)
f = 1.4
s = 1.5

significant_epsilon <- sim_solar_system("Epsilon", f, s, f, s, f, s, f, s)
significant_helionis <- sim_solar_system("Helionis Cluster", f, s, f, s, f, s, f, s)
significant_zeta <- sim_solar_system("Zeta", f, s, f, s, f, s, f, s)

## Worst Case Scenario (+80% freq, +100% sev)
f = 1.8
s = 2

worst_epsilon <- sim_solar_system("Epsilon", f, s, f, s, f, s, f, s)
worst_helionis <- sim_solar_system("Helionis Cluster", f, s, f, s, f, s, f, s)
worst_zeta <- sim_solar_system("Zeta", f, s, f, s, f, s, f, s)



# ================================================================================
# CAPPED DATA  - MODELLING
# ================================================================================

bus_capped_freq_model <- glm.nb(
  claim_count ~ station_id + solar_system + production_load +
    energy_backup_score + supply_chain_index + avg_crew_exp + maintenance_freq +
    safety_compliance + offset(log(exposure)),
  data = bus_freq_capped,
  link = log
)
cargo_capped_freq_model <- glm.nb(
  claim_count ~ cargo_type + cargo_value + weight + route_risk + distance +
    transit_duration + pilot_experience + vessel_age + container_type +
    solar_radiation + debris_density + offset(log(exposure)),
  data = cargo_freq_capped,
  link = log
)
equip_capped_freq_model <- glm.nb(
  claim_count ~ equipment_type + equipment_age + solar_system +
    maintenance_int + usage_int + offset(log(exposure)),
  data = equip_freq_capped,
  link = log
)
worker_capped_freq_model <- glm.nb(
  claim_count ~ solar_system + station_id + occupation + employment_type +
    experience_yrs + accident_history_flag + psych_stress_index +
    hours_per_week + supervision_level + gravity_level +
    safety_training_index + protective_gear_quality + base_salary +
    offset(log(exposure)),
  data = worker_freq_capped,
  link = log
)

bus_capped_sev_model <- lm(
  log(claim_amount) ~ station_id + solar_system + production_load +
    energy_backup_score + safety_compliance + exposure, data = bus_sev_capped
)
cargo_capped_sev_model <- survreg(
  Surv(claim_amount) ~ cargo_type +
    cargo_value + weight + route_risk + distance + transit_duration +
    pilot_experience + vessel_age + container_type + solar_radiation +
    debris_density + exposure, data = cargo_sev_capped, dist = "loglogistic"
)
equip_capped_sev_model <- lm(
  log(claim_amount) ~ equipment_type +
    equipment_age + solar_system + maintenance_int + usage_int +
    exposure, data = equip_sev_capped
)
worker_capped_sev_model <- survreg(
  Surv(claim_amount) ~ solar_system +
    station_id + occupation + employment_type + experience_yrs +
    accident_history_flag + psych_stress_index + hours_per_week +
    supervision_level + gravity_level + safety_training_index +
    protective_gear_quality + injury_type + injury_cause +
    claim_length + exposure, data = worker_sev_capped, dist = "loglogistic"
)

print("Business Interruptions Capped")
summary(bus_capped_freq_model)
print("Cargo Interruptions Capped")
summary(cargo_capped_freq_model)
print("Equipment Interruptions Capped")
summary(equip_capped_freq_model)
print("Worker Interruptions Capped")
summary(worker_capped_freq_model)

# Losses
bus_capped_loss <- lognorm_agg_trans(bus_capped_freq_model, bus_capped_sev_model)
cargo_capped_loss <- loglogis_agg_trans(cargo_capped_freq_model, cargo_capped_sev_model)
equip_capped_loss <- lognorm_agg_trans(equip_capped_freq_model, equip_capped_sev_model)
worker_capped_loss <- loglogis_agg_trans(worker_capped_freq_model, worker_capped_sev_model)

print("Business Interruptions Capped Aggregates:")
print(bus_capped_loss)
print("Cargo Capped Aggregates:")
print(cargo_capped_loss)
print("Equipment Interruptions Capped Aggregates:")
print(equip_capped_loss)
print("Worker Interruptions Capped Aggregates:")
print(worker_capped_loss)



# ================================================================================
# CAPPED DATA  - SIMULATING
# ================================================================================

n_sim = 5000
set.seed(123)

bus_capped_dist <- simulate_agg_lognorm(bus_capped_freq_model, bus_capped_sev_model, n_sim,
                                     1, 1, "NONE", "NONE",
                                     bus_freq_capped, bus_sev_capped)
cargo_capped_dist <- simulate_agg_loglogis(cargo_capped_freq_model, cargo_capped_sev_model, n_sim,
                                        1, 1, "NONE", "NONE",
                                        cargo_freq_capped, cargo_sev_capped)
equip_capped_dist <- simulate_agg_lognorm(equip_capped_freq_model, equip_capped_sev_model, n_sim,
                                       1, 1, "NONE", "NONE",
                                       equip_freq_capped, equip_sev_capped)
worker_capped_dist <- simulate_agg_loglogis(worker_capped_freq_model, worker_capped_sev_model, n_sim,
                                         1, 1, "NONE", "NONE",
                                         worker_freq_capped, worker_sev_capped)

histogram(bus_capped_dist, "Capped", "Business", "Amounts")
histogram(cargo_capped_dist, "Capped", "Cargo", "Amounts")
histogram(equip_capped_dist, "Capped", "Equip", "Amounts")
histogram(worker_capped_dist, "Capped", "Worker", "Amounts")

bus_capped_summary <- summarise_agg_dist(bus_capped_dist)
cargo_capped_summary <- summarise_agg_dist(cargo_capped_dist)
equip_capped_summary <- summarise_agg_dist(equip_capped_dist)
worker_capped_summary <- summarise_agg_dist(worker_capped_dist)

cat("\nBusiness Interruptions Capped", bus_capped_summary)
cat("\nCargo Interruptions Capped", cargo_capped_summary)
cat("\nEquipment Interruptions Capped", equip_capped_summary)
cat("\nWorker Interruptions Capped", worker_capped_summary)

bus_conf <- conf_int(bus_capped_dist)
cargo_conf <- conf_int(cargo_capped_dist)
equip_conf <- conf_int(equip_capped_dist)
worker_conf <- conf_int(worker_capped_dist)



# ================================================================================
# CAPPED DATA  - PRICING
# ================================================================================

profit_margin <- 1.05

# Pure premium with no loadings
bus_pure_premium <- mean(bus_capped_dist) / sum(bus_freq_capped$exposure)
cargo_pure_premium <-  mean(cargo_capped_dist) / sum(cargo_freq_capped$exposure)
equip_pure_premium <-  mean(equip_capped_dist) / sum(equip_freq_capped$exposure)
worker_pure_premium <-  mean(worker_capped_dist) / sum(worker_freq_capped$exposure)

cat("\nBusiness Interruptions Pure Premium", bus_pure_premium)
cat("\nCargo Pure Premium", cargo_pure_premium)
cat("\nEquipment Pure Premium", equip_pure_premium)
cat("\nWorker Pure Premium", worker_pure_premium)

# Add on risk loading
risk_interval <- 0.95
bus_risk_loading <- (bus_conf$VaR[bus_conf$level == risk_interval] -
                       mean(bus_capped_dist)) / mean(bus_capped_dist)
cargo_risk_loading <- (cargo_conf$VaR[cargo_conf$level == risk_interval] -
                         mean(cargo_capped_dist)) / mean(cargo_capped_dist)
equip_risk_loading <- (equip_conf$VaR[equip_conf$level == risk_interval] -
                         mean(equip_capped_dist)) / mean(equip_capped_dist)
worker_risk_loading <- (worker_conf$VaR[worker_conf$level == risk_interval] -
                          mean(worker_capped_dist)) / mean(worker_capped_dist)

cat("\nBusiness Interruptions Final Premium", bus_risk_loading)
cat("\nCargo Final Premium", cargo_risk_loading)
cat("\nEquipment Final Premium", equip_risk_loading)
cat("\nWorker Final Premium", worker_risk_loading)

# Premium inclusive of risk loading + profit margin
bus_premium <- bus_pure_premium * (1 + bus_risk_loading) * profit_margin
cargo_premium <- cargo_pure_premium * (1 + cargo_risk_loading) * profit_margin
equip_premium <- equip_pure_premium * (1 + equip_risk_loading) * profit_margin
worker_premium <- worker_pure_premium * (1 + worker_risk_loading) * profit_margin

cat("Final Business annual premium: ", bus_premium, "\n")
cat("Final Cargo annual premium: ", cargo_premium, "\n")
cat("Final Equip annual premium: ", equip_premium, "\n")
cat("Final Worker annual premium: ", worker_premium, "\n")
sum_premiums <- bus_premium + cargo_premium + equip_premium + worker_premium

agg_dist <- bus_agg_dist + cargo_agg_dist + equip_agg_dist + worker_agg_dist
agg_conf <- conf_int(agg_dist)

agg_exposure <- sum(bus_freq_capped$exposure) +
  sum(cargo_freq_capped$exposure) +
  sum(equip_freq_capped$exposure) +
  sum(worker_freq_capped$exposure)

agg_premium_rate <- mean(agg_dist) / agg_exposure
agg_risk_loading <- (agg_conf$VaR[agg_conf$level == risk_interval] -
                       mean(agg_dist)) / mean(agg_dist)
agg_premium <- agg_premium_rate * (1 + agg_risk_loading) * profit_margin
cat("Aggregate premium: ", agg_premium, "\n")
cat("Sum of individual premiums: ", sum_premiums, "\n")

