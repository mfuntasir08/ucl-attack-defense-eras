## ============================================================
## 03_ttests_and_gap_analysis.R
## Phase 3: Welch t-tests (Winner vs Non-winner, per era) +
##          Attack gap vs Defense gap comparison
## ============================================================
suppressMessages({
  library(dplyr)
  library(tidyr)
})

samp <- read.csv("ucl_analysis_sample.csv", stringsAsFactors = FALSE)
samp$era <- factor(samp$era, levels = c("Era A (1993-2001)",
                                         "Era B (2002-2010)",
                                         "Era C (2011-2020)"))
desc <- read.csv("table1_descriptives.csv", stringsAsFactors = FALSE)

## ---- Welch two-sample t-tests: Winner vs Non-winner, per era ----
eras <- levels(samp$era)
ttest_results <- data.frame()

for (e in eras) {
  sub <- samp %>% filter(era == e)

  t_goals <- t.test(goals_pm ~ champions, data = sub)
  t_conc  <- t.test(conceded_pm ~ champions, data = sub)

  ttest_results <- rbind(ttest_results,
    data.frame(era = e, metric = "Goals scored / match",
               mean_winner    = mean(sub$goals_pm[sub$champions == 1]),
               mean_nonwinner = mean(sub$goals_pm[sub$champions == 0]),
               diff    = t_goals$estimate[2] - t_goals$estimate[1],
               t_stat  = unname(t_goals$statistic),
               df      = unname(t_goals$parameter),
               p_value = t_goals$p.value),
    data.frame(era = e, metric = "Goals conceded / match",
               mean_winner    = mean(sub$conceded_pm[sub$champions == 1]),
               mean_nonwinner = mean(sub$conceded_pm[sub$champions == 0]),
               diff    = t_conc$estimate[2] - t_conc$estimate[1],
               t_stat  = unname(t_conc$statistic),
               df      = unname(t_conc$parameter),
               p_value = t_conc$p.value)
  )
}
rownames(ttest_results) <- NULL
ttest_results$sig <- ifelse(ttest_results$p_value < 0.001, "***",
                      ifelse(ttest_results$p_value < 0.01, "**",
                      ifelse(ttest_results$p_value < 0.05, "*", "ns")))

cat("=== Welch two-sample t-tests: Winner vs Non-winner, per era ===\n")
print(ttest_results, digits = 3)
write.csv(ttest_results, "table2_ttests.csv", row.names = FALSE)

## ---- Attack gap vs Defense gap, per era ----
gap <- desc %>%
  select(era, group, mean_goals_pm, mean_conc_pm) %>%
  pivot_wider(names_from = group, values_from = c(mean_goals_pm, mean_conc_pm)) %>%
  mutate(
    attack_gap  = `mean_goals_pm_Winner` - `mean_goals_pm_Non-winner`,
    defense_gap = `mean_conc_pm_Non-winner` - `mean_conc_pm_Winner`,
    larger_gap  = ifelse(attack_gap > defense_gap, "Attack", "Defense")
  )

cat("\n=== Attack gap vs Defense gap, per era ===\n")
print(as.data.frame(gap %>% select(era, attack_gap, defense_gap, larger_gap)), digits = 3)
write.csv(gap, "table3_attack_defense_gap.csv", row.names = FALSE)

cat("\nPhase 3 complete: table2_ttests.csv and table3_attack_defense_gap.csv saved.\n")
