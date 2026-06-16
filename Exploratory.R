############################### Exploratory ###################################

# Load libraries----
library(tidyverse)
library(ggplot2)
library(scales)

# Remote URL to the raw dataset on the Novartis repository
data_url <- "https://raw.githubusercontent.com/Novartis/xgx/master/Data/Data_Checking.csv"

# Read the CSV data directly from the web
data_checking <- read.csv(data_url, stringsAsFactors = FALSE)


# NOTES ----

  # TIME - No missing, distribution asymmetric D (>E). TIME<0 - before the first dose.
  # WEITHGB - No missing.
  # LIDV - Values. 129 missing.
  # AGEB - No missing, asymmetric (>E).

  # YTYPE == 1 - No missing. drug concentration in the blood (PK); ==2 PD. More outlier in PK.
  # ADM == 1 - IV route of administration; 0 == Dose
  # TRT - No missing.
  # CMT == 1 - PK concentration; == 2 - PD response value
  # CENS == 0 - not censored. Valid.
  # CYCLE = Week number.
  # LLOQ = NA means doesn't apply.
  # SEX - female has more outliers. Women are older then man.

# Exploring----
head(data_checking)
view(data_checking)

unique(data_checking$YTYPE)

data_checking %>% 
  filter(YTYPE == 1) %>% 
  select(TIME, LIDV) %>% 
  arrange(TIME)


# Data understanding----

  ## Missing----
table(is.na(data_checking$LIDV))
table(is.na(data_checking$YTYPE))
table(is.na(data_checking$TRT))
table(is.na(data_checking$TIME))
table(is.na(data_checking$WEIGHTB))
table(is.na(data_checking$AGEB))


  ## Percentage missing in the dataset----
colMeans(is.na(data_checking))*100
  # obs: what is the limit of missing? >50%?

  # Frequencies
table(data_checking$SEX)
table(data_checking$NAME)
table(data_checking$TRT)
table(data_checking$VISNAME)

ggplot(data_checking, aes(x = SEX, fill = SEX))+
        geom_bar()

  ## Distributions----
  # General
ggplot(data = data_checking, aes(x = LIDV)) +
  geom_histogram(aes(y = after_stat(density)), bins = 30, fill = "lightblue", color = "black") +
  geom_density(color = "red", linewidth = 1) +
  labs(title = "Distribution of Values",
       x = "LIDV",
       y = "Count") +
  theme_classic()
# The values have asymmetric distribution, to the left side, what means more values around zero.

  # AGE
ggplot(data = data_checking, aes(x = AGEB)) +
  geom_histogram(aes(y = after_stat(density)), bins = 30, fill = "lightblue", color = "black") +
  geom_density(color = "red", linewidth = 1) +
  labs(title = "Distribution of AGE",
       x = "Age",
       y = "Count") +
  theme_classic()

  # WEIGHTB
ggplot(data = data_checking, aes(x = WEIGHTB)) +
  geom_histogram(aes(y = after_stat(density)), bins = 30, fill = "lightblue", color = "black") +
  geom_density(color = "red", linewidth = 1) +
  labs(title = "Distribution of WEIGHT Base",
       x = "Weight",
       y = "Count") +
  theme_classic()
  
  # TIME
ggplot(data = data_checking, aes(x = TIME)) +
  geom_histogram(aes(y = after_stat(density)), bins = 30, fill = "green", color = "black") +
  geom_density(color = "orange", linewidth = 1) +
  labs(title = "Distribution of TIME",
       x = "TIME",
       y = "Count") +
  theme_classic()
 
 # Just type 1 (PK)
data_checking %>% 
  filter(YTYPE == 1) %>% 
  ggplot(aes(x = LIDV)) +
  geom_histogram(aes(y = after_stat(density)), bins = 30, fill = "pink", color = "black") +
  geom_density(color = "red", linewidth = 1) +
  labs(title = "Distribution of Values",
       x = "LIDV",
       y = "Count") +
  theme_classic()
# Asymetric, nearby zero - log(10)

# Just type 2
data_checking %>% 
  filter(YTYPE == 2) %>% 
  ggplot(aes(x = LIDV)) +
  geom_histogram(aes(y = after_stat(density)), bins = 30, fill = "darkgreen", color = "black") +
  geom_density(color = "red", linewidth = 1) +
  labs(title = "Distribution of Values",
       x = "LIDV",
       y = "Count") +
  theme_classic()

  



## Boxplot Value----
  # General
data_checking %>% 
  filter (YTYPE != 0, !is.na(LIDV)) %>% 
  ggplot( aes(x = LIDV)) +
  geom_boxplot()+
  labs(
    title = "Boxplot of Values",
    x = "Values") +
  theme_classic()


  # Comparing PK and PD
data_checking %>% 
  filter (YTYPE != 0, !is.na(LIDV)) %>% 
  ggplot( aes(x = LIDV)) +
  geom_boxplot(fill = "purple") +
  facet_wrap(~ NAME) +
  labs(
    title = "Boxplot of Values",
    x = "Values") +
  theme_classic()
# More outliers in PK

# Comparing AGE
data_checking %>% 
  filter(!is.na(LIDV)) %>% 
  ggplot( aes(x = LIDV)) +
  geom_boxplot(fill = "purple") +
  facet_wrap(~ AGEB) +
  labs(
    title = "Boxplot of Value x Age",
    x = "Values") +
  theme_classic()

# Comparing SEX
ggplot(data_checking, aes (x = SEX, y = AGEB))+
    geom_boxplot()
  # women older then man

data_checking %>% 
  filter(!is.na(LIDV)) %>% 
  ggplot(aes(x = LIDV)) +
  geom_boxplot(fill = "pink") +
  facet_wrap(~ SEX) +
  labs(
    title = "Boxplot of Value x SEX",
    x = "Values") +
  theme_classic()

 
# Density----

  ## LIVD x WEIGHTB
  # No normality
ggplot(data_checking, aes(x= LIDV, fill = TRT))+
  geom_density()+
  facet_wrap(~TRT, ncol=1)+
  theme_classic()


# Correlation----

   ## Correlation time x values
ggplot(data = data_checking, aes(x = TIME, y = LIDV)) +
  # 1. Add the data points
  geom_point(alpha = 0.3, color = "darkblue") + 
  # 2. Add a linear regression trend line
  geom_smooth(method = "lm", color = "red", se = TRUE) + 
  labs(title = "Correlation between TIME and LIDV",
       x = "TIME",
       y = "LIDV") +
  theme_classic()
  # Positive, Possibly weak relation because of the curve inclination

  ## Correlation Weight basal x PK
data_checking %>% 
  filter(YTYPE==1) %>% 
  ggplot(aes(x = WEIGHTB, y = LIDV)) +
  # 1. Add the data points
  geom_point(alpha = 0.3, color = "darkgreen") + 
  # 2. Add a linear regression trend line
  geom_smooth(method = "lm", color = "red", se = TRUE) + 
  labs(title = "Correlation between Weight basal and PK concentration",
       x = "Weight",
       y = "PK value") +
  theme_classic()
# Negative, Possibly weak relation because of the curve inclination

## Correlation Weight basal x PD
data_checking %>% 
  filter(YTYPE==2) %>% 
  ggplot(aes(x = WEIGHTB, y = LIDV)) +
  # 1. Add the data points
  geom_point(alpha = 0.3, color = "purple") + 
  # 2. Add a linear regression trend line
  geom_smooth(method = "lm", color = "red", se = TRUE) + 
  labs(title = "Correlation between Weight basal and PD value",
       x = "Weight",
       y = "PD value") +
  theme_classic()
# Positive, Possibly weak relation because of the curve inclination


# Statistics summary ----

summarise(data_checking$LIDV)


# PRE_DOSE 

df_pred <-data_checking %>% 
  filter(TIME<0, EVID == 0) %>% 
  select(ID,YTYPE, TIME, ADM, EVID, CMT, NAME, LIDV,ADM, AGEB, SEX, SEXN, WEIGHTB, CYCLE, LLOQ)

# Raw data - Longitudinal PKPD charts (LIDV vs. TIME)
df_pred %>%
  ggplot(aes(x = TIME, y = LIDV))+
  geom_point()+
  scale_y_log10() +
  theme_classic()+
  labs(
    title = "Time versus Value",
    y = "log(10) Value (ng/mL)",
    x = "Days"
  )
  
# By sex - PKPD charts (LIDV vs. TIME)
df_pred %>%
  ggplot(aes(x = TIME, y = LIDV))+
  geom_point()+
  facet_wrap(~ SEX, nrow = 2) +
  scale_y_log10() +
  theme_classic()+
  labs(
    title = "Time versus Value by Sex",
    y = "log(10) Value (ng/mL)",
    x = "Days"
  )

# By weight - PKPD charts (LIDV vs. TIME)
median(df_pred$WEIGHTB) #66.45Kg

df_pred<-df_pred %>%
  mutate(WEIGHTB_G = if_else(WEIGHTB >= 66.45, "> = 66.45Kg", "< 66.45Kg"))

df_pred %>%
  ggplot(aes(x = TIME, y = LIDV))+
  geom_point()+
  facet_wrap(~ WEIGHTB_G, nrow = 2) +
  scale_y_log10() +
  theme_classic()+
  labs(
    title = "Time versus Value by Basal Weight",
    y = "log(10) Value (ng/mL)",
    x = "Days"
  )

# Patient Journey
  # EVID = 0 (observation), = 1 (dose is being administered at this exact time)

  # Prepare the dataset
df_journey <-data_checking %>% 
  mutate(WEIGHTB_G = if_else(WEIGHTB >= 66.45, "> = 66.45Kg", "< 66.45Kg")) %>% 
  select(ID,YTYPE, TIME, ADM, EVID, CMT, NAME, LIDV,ADM, AGEB, SEX, SEXN, WEIGHTB, WEIGHTB_G, CYCLE, LLOQ, TRT) 
  
  # Exploring
max(df_journey$TIME)
unique(df_journey$TIME)

df_journey %>% 
  filter(TIME>200) %>% 
  select(ID, LIDV) # The value is NA

df_journey %>% 
  filter(!is.na(LIDV), !is.na(TIME)) %>% 
  select(ID, TIME, LIDV) %>% 
  arrange(TIME)


df_journey %>%
  group_by(TRT, YTYPE) %>%
  summarize(Unique_ID_Count = n_distinct(ID), .groups = "drop")



# PKPD Plots----
  # Patient journey v01 - PK (OK)
df_journey %>% 
  filter(!is.na(LIDV), !is.na(TIME), YTYPE == 1) %>% 
  # Rounding time slightly can group points that were drawn a few minutes apart
  mutate(TIME_Group = factor(round(TIME, 2))) %>% 
  ggplot(aes(x = TIME, y = LIDV, group = ID)) +
  geom_vline(xintercept = 150, color = "black", linetype = "solid")+
  geom_vline(xintercept = 0, color = "red", linetype = "dashed")+
  geom_hline(yintercept = 10000, color = "grey", linetype = "dashed")+
  geom_line(aes(group = ID), color = "grey80") +
  geom_point()+
  # stat_summary(
  #   aes(group = 1),          # Ignore individual patient ID grouping
  #   fun = median,            # Calculate the median value at each unique timepoint
  #   geom = "line",           # Connect those median points with a line
  #   color = "brown",      # Give it a distinct color
  #   linewidth = 1,
  #   alpha = 0.8
  # ) +
  # facet_wrap(~ WEIGHTB_G, nrow = 2) +
  scale_y_log10(labels = trans_format("log10", math_format(10^.x))) +
  theme_classic() +
  # Rotate the x-axis text 90 degrees 
  theme(axis.text.x = element_text(size = 7)) + 
  labs(
    title = "Time versus Value",
    subtitle = "Individual patient trajectories - PK",
    y = "log(10) Value (ng/mL)",
    x = "Days"
  )

# Patient journey v02 - PK
df_journey %>% 
  filter(!is.na(LIDV), !is.na(TIME), YTYPE == 1) %>% 
  # Rounding time slightly can group points that were drawn a few minutes apart
  mutate(TIME_Group = factor(round(TIME, 2))) %>% 
  # Factorized group variable for X
  ggplot(aes(x = TIME_Group, y = LIDV, group = ID)) +
  geom_line(color = "grey90") +
  geom_point() +
  stat_summary(aes(group = 1), fun = median, geom = "line", color = "brown", linewidth = 1) +
  facet_wrap(~ WEIGHTB_G, nrow = 2, scales = "free_x") +
  scale_y_log10(labels = trans_format("log10", math_format(10^.x))) +
  theme_classic() +
  # Rotate the x-axis text 90 degrees 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, size = 7)) + 
  labs(
    title = "Sequential Time points by Basal Weight",
    y = "log(10) Value (ng/mL)",
    x = "Day"
  )

# Patient journey v01 - PD (OK)
df_journey %>% 
  filter(!is.na(LIDV), !is.na(TIME), YTYPE == 2) %>% 
  # Rounding time slightly can group points that were drawn a few minutes apart
  mutate(TIME_Group = factor(round(TIME, 2))) %>% 
  ggplot(aes(x = TIME, y = LIDV, group = ID)) +
  geom_vline(xintercept = 150, color = "black", linetype = "solid")+
  geom_vline(xintercept = 0, color = "red", linetype = "dashed")+
  geom_hline(yintercept = 10000, color = "grey", linetype = "dashed")+
  geom_line(aes(group = ID), color = "grey80") +
  geom_point()+
  # stat_summary(
  #   aes(group = 1),          # Ignore individual patient ID grouping
  #   fun = median,            # Calculate the median value at each unique timepoint
  #   geom = "line",           # Connect those median points with a line
  #   color = "brown",      # Give it a distinct color
  #   linewidth = 1,
  #   alpha = 0.8
  # ) +
  # facet_wrap(~ WEIGHTB_G, nrow = 2) +
  scale_y_log10(labels = trans_format("log10", math_format(10^.x))) +
  theme_classic() +
  # Rotate the x-axis text 90 degrees 
  theme(axis.text.x = element_text(size = 7)) + 
  labs(
    title = "Time versus Value PD",
    subtitle = "Individual patient trajectories",
    y = "log(10) Value (ng/mL)",
    x = "Days"
  )

  # Dots - LOESS curve
max(df_journey$TIME)
df_journey %>% 
  filter(YTYPE == 2) %>% 
  select(TIME) %>% 
  arrange(TIME)

  # General (Ok)

# Treshholds
sample_sizes <- df_journey %>% 
  filter(!is.na(LIDV), !is.na(TIME), TIME < 50) %>% 
  mutate(NAME = factor(NAME, levels = c("PK", "PD"))) %>% 
  group_by(NAME, TIME) %>% 
  summarise(n = n(), .groups = 'drop') %>% 
  mutate(label = paste0("n=", n))

intercept_data <- data.frame(
  NAME = factor(c("PD", "PK"), levels = c("PK", "PD")), #as a factor to plot PK -->PD
  y_threshold = c(75, 160)
)
# Labels
facet_labels <- c(
  "PK" = "PK (ng/mL)",
  "PD" = "PD (IU/L)"
)
#
df_journey %>% 
  filter(!is.na(LIDV), !is.na(TIME), TIME<50) %>% 
  mutate(NAME = factor(NAME, levels = c("PK", "PD"))) %>%
  ggplot(aes(x = TIME, y = LIDV))+
  geom_point(size = 1, color = "grey")+
  #Include the sample size per day
  geom_text(data = sample_sizes, aes(x = TIME, y = 3, label = label), 
            size = 4, color = "grey60", angle = 90, vjust = 0.5) +
  # Legend
  geom_vline(aes(xintercept = 0, color = "Study Baseline (Day 0)"), linetype = "dashed") +
  geom_vline(aes(xintercept = 60, color = "Analysis Cutoff (Day 60)"), linetype = "solid") +
  # Horizontal thresholds
  geom_hline(data = intercept_data, aes(yintercept = y_threshold), 
             color = "grey30", linetype = "dashed") +
  geom_smooth(method = "loess", span = 0.75, se = TRUE, color = "firebrick", fill = "lightblue") +
  # Dividing plots
  facet_wrap(~ NAME, nrow = 2, scales = "free_y", 
             labeller = labeller(NAME = facet_labels)) +
  scale_y_log10() +
  scale_color_manual(
    name = "Reference Lines", 
    breaks = c("Study Baseline (Day 0)", "Analysis Cutoff (Day 60)", "Target Threshold"),
    values = c(
      "Study Baseline (Day 0)" = "turquoise4", # Matched the cyan/turquoise color in your image
      "Analysis Cutoff (Day 60)" = "darkblue",     # Matched the coral/red color in your image
      "Target Threshold" = "grey30"
    )
  ) +
  theme_classic()+
  theme(
    legend.position = "bottom", 
    legend.background = element_rect(color = "grey90", size = 0.5) 
  ) +
  labs(
    title = "Pharmacokinetic and Pharmacodynamic Longitudinal Profiles",
    subtitle = "Population Trend with 95% Confidence Intervals vs. Target Thresholds",
    y = "log(10)",
    x = "Days",
    caption = "The red line represent the LOESS-smoothed population median"
  )








  # PK (OK)
df_journey %>% 
  filter(!is.na(LIDV), !is.na(TIME), YTYPE == 1, LLOQ == 10) %>% 
  ggplot(aes(x = TIME, y = LIDV))+
  geom_point(size = 1, color = "grey")+
  geom_vline(xintercept = 150, color = "black", linetype = "solid")+
  geom_smooth(method = "loess", span = 0.75, se = TRUE, color = "firebrick", fill = "lightblue") +
  scale_y_log10() +
  theme_classic()+
  labs(
    title = "Time versus Value by Basal Weight - PK",
    subtitle = "LOESS curve",
    y = "log(10) Value (ng/mL)",
    x = "Days"
  )

# PD
df_journey %>% 
  filter(!is.na(LIDV), !is.na(TIME), YTYPE == 2, LLOQ == 10) %>% 
  ggplot(aes(x = TIME, y = LIDV))+
  geom_point(size = 1, color = "grey")+
  geom_vline(xintercept = 150, color = "black", linetype = "solid")+
  geom_smooth(method = "loess", span = 0.75, se = TRUE, color = "darkblue", fill = "lightblue") +
  scale_y_log10() +
  theme_classic()+
  labs(
    title = "Time versus Value by Basal Weight - PD",
    subtitle = "LOESS curve",
    y = "log(10) Value (ng/mL)",
    x = "Days"
  )

# TEST
library(dplyr)
library(ggplot2)

# Count sample size
# Grouping times into intervals of 10 days (resolve overlap)
sample_table_data <- df_journey %>%
  filter(!is.na(LIDV), !is.na(TIME), TIME < 50) %>%
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
  filter(!is.na(LIDV), !is.na(TIME), TIME < 50) %>% 
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



