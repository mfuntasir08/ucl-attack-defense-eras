## ============================================================
## 05_visualizations.R
## Phase 5: ggplot2 dark-themed visualizations
## ============================================================
suppressMessages({
  library(dplyr)
  library(tidyr)
  library(ggplot2)
  library(scales)
})

full <- read.csv("ucl_cleaned_full.csv", stringsAsFactors = FALSE)
samp <- read.csv("ucl_analysis_sample.csv", stringsAsFactors = FALSE)
desc <- read.csv("table1_descriptives.csv", stringsAsFactors = FALSE)
gap  <- read.csv("table3_attack_defense_gap.csv", stringsAsFactors = FALSE)

era_levels <- c("Era A (1993-2001)", "Era B (2002-2010)", "Era C (2011-2020)")
full$era <- factor(full$era, levels = era_levels)
samp$era <- factor(samp$era, levels = era_levels)
desc$era <- factor(desc$era, levels = era_levels)
gap$era  <- factor(gap$era,  levels = era_levels)

## ---- Dark theme ----
bg      <- "#14151f"
panel   <- "#1c1e2b"
grid_c  <- "#2c2f42"
text_c  <- "#e8e9f0"
subtext <- "#9a9db3"
attack_c  <- "#ff8a5c"   # warm orange - attack
defense_c <- "#5cc8ff"   # cool blue  - defense
gold_c    <- "#e8b923"   # champion gold accent

theme_ucl_dark <- function(base_size = 13) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.background  = element_rect(fill = bg, color = NA),
      panel.background = element_rect(fill = panel, color = NA),
      panel.grid.major = element_line(color = grid_c, linewidth = 0.3),
      panel.grid.minor = element_blank(),
      text = element_text(color = text_c),
      axis.text = element_text(color = subtext),
      axis.title = element_text(color = text_c, face = "bold"),
      plot.title = element_text(color = text_c, face = "bold", size = base_size * 1.25, margin = margin(b = 6)),
      plot.subtitle = element_text(color = subtext, size = base_size * 0.9, margin = margin(b = 12)),
      plot.caption = element_text(color = subtext, size = base_size * 0.7, hjust = 0),
      legend.background = element_rect(fill = bg, color = NA),
      legend.key = element_rect(fill = panel, color = NA),
      legend.text = element_text(color = text_c),
      legend.title = element_text(color = text_c, face = "bold"),
      strip.background = element_rect(fill = grid_c, color = NA),
      strip.text = element_text(color = text_c, face = "bold"),
      plot.margin = margin(16, 16, 16, 16)
    )
}

save_dark <- function(plot, filename, w = 8, h = 5.2) {
  ggsave(filename, plot, width = w, height = h, dpi = 200, bg = bg)
}

if (!dir.exists("figs")) dir.create("figs")

## ============================================================
## Figure 1: Goals scored/match - winners vs non-winners, by era
## ============================================================
d1 <- desc %>% mutate(group = factor(group, levels = c("Non-winner", "Winner")))

fig1 <- ggplot(d1, aes(x = group, y = mean_goals_pm, fill = group)) +
  geom_col(width = 0.6) +
  geom_errorbar(aes(ymin = mean_goals_pm - sd_goals_pm, ymax = mean_goals_pm + sd_goals_pm),
                width = 0.15, color = subtext) +
  geom_text(aes(label = sprintf("%.2f", mean_goals_pm)), vjust = -1.6, color = text_c, size = 3.6) +
  facet_wrap(~era) +
  scale_fill_manual(values = c("Non-winner" = grid_c, "Winner" = attack_c)) +
  labs(title = "Goals Scored per Match: Winners vs. Non-Winners",
       subtitle = "Stratified sample (winners = full census; non-winners = n=30/era)",
       x = NULL, y = "Goals scored / match", fill = NULL) +
  theme_ucl_dark() +
  theme(legend.position = "top")

save_dark(fig1, "figs/fig1_goals_scored.png")

## ============================================================
## Figure 2: Goals conceded/match - winners vs non-winners, by era
## ============================================================
fig2 <- ggplot(d1, aes(x = group, y = mean_conc_pm, fill = group)) +
  geom_col(width = 0.6) +
  geom_errorbar(aes(ymin = mean_conc_pm - sd_conc_pm, ymax = mean_conc_pm + sd_conc_pm),
                width = 0.15, color = subtext) +
  geom_text(aes(label = sprintf("%.2f", mean_conc_pm)), vjust = -1.6, color = text_c, size = 3.6) +
  facet_wrap(~era) +
  scale_fill_manual(values = c("Non-winner" = grid_c, "Winner" = defense_c)) +
  labs(title = "Goals Conceded per Match: Winners vs. Non-Winners",
       subtitle = "Stratified sample (winners = full census; non-winners = n=30/era)",
       x = NULL, y = "Goals conceded / match", fill = NULL) +
  theme_ucl_dark() +
  theme(legend.position = "top")

save_dark(fig2, "figs/fig2_goals_conceded.png")

## ============================================================
## Figure 3: Attack gap vs Defense gap trend across eras  [KEY FIGURE]
## ============================================================
gap_long <- gap %>%
  select(era, attack_gap, defense_gap) %>%
  pivot_longer(cols = c(attack_gap, defense_gap), names_to = "gap_type", values_to = "gap_value") %>%
  mutate(gap_type = recode(gap_type, attack_gap = "Attack gap", defense_gap = "Defense gap"))

fig3 <- ggplot(gap_long, aes(x = era, y = gap_value, color = gap_type, group = gap_type)) +
  geom_line(linewidth = 1.3) +
  geom_point(size = 3.5) +
  geom_text(aes(label = sprintf("%.2f", gap_value)),
            position = position_nudge(y = ifelse(gap_long$gap_type == "Attack gap", 0.13, -0.13)),
            size = 3.6, show.legend = FALSE, fontface = "bold") +
  scale_color_manual(values = c("Attack gap" = attack_c, "Defense gap" = defense_c)) +
  labs(title = "Attack Gap vs. Defense Gap: Which Separates Winners More?",
       subtitle = "Winner minus non-winner gap in goals scored (attack) and goals prevented (defense)",
       x = NULL, y = "Gap (goals / match)", color = NULL) +
  ylim(0, max(gap_long$gap_value) * 1.3) +
  theme_ucl_dark() +
  theme(legend.position = "top", axis.text.x = element_text(size = 11))

save_dark(fig3, "figs/fig3_attack_defense_gap_trend.png", w = 9, h = 5.5)

cat("Phase 5 complete: 3 figures saved to figs/\n")
list.files("figs")
