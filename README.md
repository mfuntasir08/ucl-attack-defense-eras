[README.md](https://github.com/user-attachments/files/30703468/README.md)
# UCL Attack vs. Defense — Does "Defense Wins Championships" Hold Up?

A statistical analysis of UEFA Champions League team performance (1993–2020),
testing whether attacking or defensive output better predicts championship
success — and whether that relationship has shifted across tactical eras.

## Research question

Does attacking performance (goals scored/match) or defensive performance
(goals conceded/match) more strongly separate Champions League winners from
non-winners — and has the balance between the two shifted across eras?

## Eras studied

- **Era A** — 1993–2001
- **Era B** — 2002–2010
- **Era C** — 2011–2020

## Pipeline

Run the scripts in order; each phase reads the outputs of the previous one.

| Script | Phase | Purpose |
|---|---|---|
| `01_data_prep_and_sampling.R` | 1 | Clean raw data, engineer features (goals/match, conceded/match, success rate), stratified sample (all champions + 30 non-winners/era) |
| `02_descriptive_statistics.R` | 2 | Summary stats — mean goals scored/conceded per match, Winner vs Non-winner, per era |
| `03_ttests_and_gap_analysis.R` | 3 | Welch two-sample t-tests per era; Attack gap vs Defense gap comparison |
| `04_logistic_regression.R` | 4 | Pooled standardized logistic regression — champions ~ attack + defense |
| `05_visualizations.R` | 5 | Dark-themed ggplot2 figures (goals scored, goals conceded, attack/defense gap trend) |

## Outputs

**Tables**
- `table1_descriptives.csv` — descriptive stats, Winner vs Non-winner, per era
- `table2_ttests.csv` — Welch t-test results per era (goals scored & conceded)
- `table3_attack_defense_gap.csv` — attack gap vs defense gap, per era
- `table4_logit_pooled.csv` — pooled logistic regression coefficients

**Figures** (`figs/`)
- `fig1_goals_scored.png` — goals scored/match, Winner vs Non-winner, by era
- `fig2_goals_conceded.png` — goals conceded/match, Winner vs Non-winner, by era
- `fig3_attack_defense_gap_trend.png` — attack gap vs defense gap trend across eras (key figure)

## Key finding

The attack gap and defense gap are nearly tied in Era A (1993–2001) and Era B
(2002–2010, where defense edges ahead), but the attack gap more than doubles
between Era B and Era C (0.52 → 1.18 goals/match), while the defense gap stays
roughly flat throughout. A pooled logistic regression across all three eras
finds defense as a marginally stronger overall predictor of championship
success — but this aggregate figure is driven by the earlier, defense-leaning
eras and masks the sharp attack-driven shift visible in the most recent era.

**In short:** "defense wins championships" holds up as a historical pattern,
but attacking performance has become the more decisive factor in the modern
game (2011–2020).

## Data

Source: UEFA Champions League team season stats, 1993–2020 (`ucl_stats.csv`).
Sample: full census of champions (n=28) plus a random sample of 30 non-winners
per era.

## Requirements

```r
install.packages(c("dplyr", "tidyr", "broom", "ggplot2", "scales"))
```

## Author

Muntasir Islam — East West University, Dhaka
