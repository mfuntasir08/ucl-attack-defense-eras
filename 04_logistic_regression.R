## ============================================================
## 04_logistic_regression.R
## Phase 4: Pooled logistic regression - does attack or defense
##          predict championship success more strongly?
## ============================================================

## Run once if broom is not yet installed:
# install.packages("broom")

suppressMessages({
  library(dplyr)
  library(broom)
})

samp <- read.csv("ucl_analysis_sample.csv", stringsAsFactors = FALSE)
samp$era <- factor(samp$era, levels = c("Era A (1993-2001)",
                                         "Era B (2002-2010)",
                                         "Era C (2011-2020)"))

## ---- Standardize predictors so coefficients are directly comparable ----
samp_z <- samp %>%
  mutate(z_goals = as.numeric(scale(goals_pm)),
         z_conc  = as.numeric(scale(conceded_pm)))

attack_defense_model <- glm(champions ~ z_goals + z_conc, data = samp_z, family = binomial)

cat("=== Logistic regression (pooled, standardized): champions ~ attack + defense ===\n")
print(summary(attack_defense_model))

write.csv(tidy(attack_defense_model), "table4_logit_pooled.csv", row.names = FALSE)
cat("\nPhase 4 complete: table4_logit_pooled.csv saved.\n")
