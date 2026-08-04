## ============================================================
## 01_data_prep_and_sampling.R
## Phase 1: Data cleaning, feature engineering, stratified sampling
## ============================================================
suppressMessages({
  library(dplyr)
  library(tidyr)
})

set.seed(2026)

df <- read.csv("E:/DSA Paper/ucl_stats.csv", stringsAsFactors = FALSE)

## ---- Feature engineering ----
df <- df %>%
  mutate(gd_calc = goals_scored - goals_conceded)

df <- df %>%
  mutate(era = case_when(
    year >= 1993 & year <= 2001 ~ "Era A (1993-2001)",
    year >= 2002 & year <= 2010 ~ "Era B (2002-2010)",
    year >= 2011 & year <= 2020 ~ "Era C (2011-2020)"
  )) %>%
  mutate(era = factor(era, levels = c("Era A (1993-2001)",
                                       "Era B (2002-2010)",
                                       "Era C (2011-2020)")))

df <- df %>%
  mutate(
    goals_pm     = goals_scored / match_played,
    conceded_pm  = goals_conceded / match_played,
    margin_pm    = gd_calc / match_played,
    success_rate = (wins + 0.5 * draws) / match_played
  )

## ---- Stratified sample: winners (full census) + 30 non-winners per era ----
winners <- df %>% filter(champions == 1)

nonwinners_sample <- df %>%
  filter(champions == 0) %>%
  group_by(era) %>%
  slice_sample(n = 30) %>%
  ungroup()

analysis_sample <- bind_rows(winners, nonwinners_sample) %>%
  arrange(era, desc(champions), year)

## ---- Save outputs ----
write.csv(df, "ucl_cleaned_full.csv", row.names = FALSE)
write.csv(analysis_sample, "ucl_analysis_sample.csv", row.names = FALSE)

cat("Phase 1 complete: ucl_cleaned_full.csv (n=", nrow(df),
    ") and ucl_analysis_sample.csv (n=", nrow(analysis_sample), ") saved.\n", sep = "")
