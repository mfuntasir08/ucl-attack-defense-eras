## ============================================================
## 02_descriptive_statistics.R
## Phase 2: Descriptive statistics - Winners vs Non-winners, per era
## ============================================================
suppressMessages({
  library(dplyr)
  library(tidyr)
})

samp <- read.csv("ucl_analysis_sample.csv", stringsAsFactors = FALSE)
samp$era <- factor(samp$era, levels = c("Era A (1993-2001)",
                                         "Era B (2002-2010)",
                                         "Era C (2011-2020)"))

desc <- samp %>%
  group_by(era, champions) %>%
  summarise(
    n             = n(),
    mean_goals_pm = mean(goals_pm),
    sd_goals_pm   = sd(goals_pm),
    mean_conc_pm  = mean(conceded_pm),
    sd_conc_pm    = sd(conceded_pm),
    mean_sr       = mean(success_rate),
    .groups = "drop"
  ) %>%
  mutate(group = ifelse(champions == 1, "Winner", "Non-winner")) %>%
  select(era, group, n, mean_goals_pm, sd_goals_pm, mean_conc_pm, sd_conc_pm, mean_sr)

cat("=== Descriptive statistics: Winners vs Non-winners, per era ===\n")
print(as.data.frame(desc), digits = 3)

write.csv(desc, "table1_descriptives.csv", row.names = FALSE)
cat("\nPhase 2 complete: table1_descriptives.csv saved.\n")
