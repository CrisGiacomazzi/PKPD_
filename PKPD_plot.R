######################################## PLOT ##################################
# Remote URL to the raw dataset on the Novartis repository
data_url <- "https://raw.githubusercontent.com/Novartis/xgx/master/Data/Data_Checking.csv"

# Reading the CSV data directly from the web
data_checking <- read.csv(data_url, stringsAsFactors = FALSE)

# Load libraries
library(dplyr)
library(ggplot2)

# Prepare dataset
df_journey <-data_checking %>% 
  mutate(WEIGHTB_G = if_else(WEIGHTB >= 66.45, "> = 66.45Kg", "< 66.45Kg")) %>% 
  select(ID,YTYPE, TIME, ADM, EVID, CMT, NAME, LIDV, AGEB, SEX, SEXN, WEIGHTB, WEIGHTB_G, CYCLE, LLOQ, TRT) 

# Definitions
intercept_data <- data.frame(
  NAME = factor(c("PD", "PK"), levels = c("PK", "PD")), #as a factor to plot PK -->PD
  y_threshold = c(100, 0.5)
)
# Labels
facet_labels <- c(
  "PK" = "Pharmacokinetics (ng/mL)",
  "PD" = "Pharmacodynamics (IU/L)"
)
# Count sample size
# Grouping times into intervals of 10 days (resolve overlap)
sample_table_data <- df_journey %>%
  filter(!is.na(LIDV), !is.na(TIME), TIME < 65) %>%
  mutate(
    # Bin times into clean intervals: 0, 10, 20, 30, 40, 50
    Time_Bin = cut(TIME, 
                   breaks = c(-Inf, 5, 15, 25, 35, 45, Inf), 
                   labels = c(0, 10, 20, 30, 40, 50))
  ) %>%
  group_by(NAME, Time_Bin) %>%
  summarise(n = n(), .groups = 'drop') %>%
  mutate(
    # Convert back to numeric (for plotting positioning)
    TIME_pos = as.numeric(as.character(Time_Bin)),
    label = paste0("n = ", n)
  ) %>%
  # Filter to make sure map factor names exactly
  mutate(NAME = factor(NAME, levels = c("PK", "PD")))

# Plot
df_journey %>% 
  filter(!is.na(LIDV), !is.na(TIME), TIME < 65) %>% 
  mutate(NAME = factor(NAME, levels = c("PK", "PD"))) %>% 
  ggplot(aes(x = TIME, y = LIDV)) +
  geom_point(size = 1, color = "grey") +
  geom_vline(aes(xintercept = 0, color = "Study Baseline (Day 0)"), linetype = "dashed") +
  geom_vline(aes(xintercept = 60, color = "Analysis Cutoff (Day 60)"), linetype = "solid") +
  geom_hline(data = intercept_data, aes(yintercept = y_threshold, color = "Target Threshold"), 
             linetype = "dashed") +
  geom_smooth(method = "loess", span = 0.75, se = TRUE, color = "firebrick", fill = "lightblue") +
  facet_wrap(~ NAME, nrow = 2, scales = "free_y", labeller = labeller(NAME = facet_labels)) +
  scale_y_log10() +
  scale_color_manual(
    name = "Reference Lines",
    breaks = c("Study Baseline (Day 0)", "Analysis Cutoff (Day 60)", "Target Threshold"),
    values = c("Study Baseline (Day 0)" = "blue", "Analysis Cutoff (Day 60)" = "tomato", "Target Threshold" = "grey30")
  ) +
  # Turning off clipping allows us to push y values below the plot axis line
  geom_text(data = sample_table_data, aes(x = TIME_pos, y = 1.5, label = label), 
            size = 3.5, color = "grey20", inherit.aes = FALSE) +
  
  coord_cartesian(clip = "off") + #Allows drawing outside the box
  theme_classic() +
  theme(
    legend.position = "bottom",
    # Add extra padding at the bottom of each panel to fit the text
    plot.margin = margin(t = 10, r = 10, b = 25, l = 10),
    axis.title.x = element_text(margin = margin(t = 20)) # push 'Days' label down
  ) +
  labs(
    title = "Pharmacokinetic and Pharmacodynamic Longitudinal Profiles",
    subtitle = "Population Trend with 95% Confidence Intervals vs. Target Thresholds",
    y = "log(10) Value",
    x = "Days",
    caption = "LOESS curve"
  )
