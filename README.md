# Clinical Pharmacology Analytics: Visualizing PK/PD Trends, Variability, and Target Attainment

# Introduction
In clinical development, translating complex longitudinal data into actionable insights is essential for assessing a drug's safety, efficacy, and therapeutic viability. This project focuses on the visual re-engineering and analysis of Pharmacokinetic (PK) and Pharmacodynamic (PD) Longitudinal Profiles to effectively communicate population trends, data variability, and target attainment over time.

Using advanced data visualization techniques in R, this project provides a unified, scannable framework that bridges the gap between complex statistical outputs and non-technical stakeholder decision-making.

# Key Features of the Analysis
- Dual-Panel Integration: Synchronized longitudinal tracking of drug concentration (PK in ng/mL) and biological response (PD in IU/L) on a common $\log_{10}$ scale.
- Trend & Variability Mapping: Application of LOESS (Locally Estimated Scatterplot Smoothing) curves alongside $95\%$ confidence intervals to capture non-linear population trajectories without forcing rigid parametric assumptions.Contextual
- Benchmarking: Static horizontal target thresholds and explicit sample sizes ($n$) annotated across time intervals to provide strict context for therapeutic target attainment.By optimizing data density and clarity, this visualization serves as a powerful analytical tool for clinical pharmacologists and strategic leaders alike, ensuring that critical data trends are recognized at a glance.

# Result



# Data Specifications & Data Dictionary

This dataset follows a standardized pharmacometric (NONMEM-style) structure containing both pharmacokinetic (PK) and pharmacodynamic (PD) variables, alongside baseline patient covariates.

| Column Name | Type | Description |
| :--- | :--- | :--- |
| **ID** | Numeric | Unique subject identifier. |
| **USUBJID** | Character | Unique subject identifier (identical to the `ID` column). |
| **TIME** | Numeric | Time relative to the first drug administration. Negative values represent events or observations that occurred prior to the first dose. |
| **NOMTIME** | Numeric | Nominal (planned) protocol time. |
| **TIMEUNIT** | Character | Unit of time measurement (e.g., "Day"). |
| **AMT** | Numeric | Dosing amount administered (populated only for dosing events where `EVID = 1`), measured in mg. |
| **LIDV** | Numeric | Linear Dependent Variable. Represents the raw observation scale (observation type is determined by `CMT` / `YTYPE`), with units specified in the `EVENTU` column. |
| **YTYPE** | Integer | Type of dependent variable (see **Variable Codes Lookup** below). |
| **ADM** | Integer | Route of administration. `1` = Intravenous (IV), `0` = Non-dosing records. |
| **CMT** | Integer | Compartment number that determines the type of observation/event (see **Variable Codes Lookup** below). |
| **NAME** | Character | Description of the row event type: `"PK"`, `"PD"`, or `"Dose"`. |
| **EVENTU** | Character | Unit for the specific row's observation (e.g., `"ng/mL"` or `"mg"`). |
| **UNIT** | Character | Unit for the observation (identical to `EVENTU`). |
| **MDV** | Integer | Missing Dependent Variable flag (`0` = Not missing/observed, `1` = Missing). |
| **CENS** | Integer | Censoring flag indicating values falling below the assay limits (see **Censoring Logic** below). |
| **EVID** | Integer | Event Identification flag (`0` = Observation event, `1` = Dosing event). |
| **AGEB** | Numeric | Baseline age of the subject (years). |
| **AGE0** | Numeric | Subject age at the exact start of dosing (years). |
| **WEIGHTB**| Numeric | Baseline body weight (kg). |
| **WEIGHT0**| Numeric | Subject body weight at the exact start of dosing (kg). |
| **SEXN** | Integer | Numeric sex code: `1` = Male, `2` = Female. |
| **SEX** | Character | Categorical sex descriptor: `"Male"` or `"Female"`. |
| **TRTN** | Numeric | Numeric treatment arm dose level (mg). |
| **TRT** | Character | Categorical treatment arm descriptor (e.g., `"3 mg"`, `"6 mg"`, `"12 mg"`, `"24 mg"`, `"48 mg"`). |
| **PROFDAY** | Numeric | Planned study profile day where intensive PK or PD sampling occurred (e.g., `0`, `28`, `56`, `84`, `112`, `140`, `168`, `196`, or `NA`). |
| **VISNAME**| Character | Visit name documenting the study Cycle and Day. |
| **CYCLE** | Integer | Study cycle number. Starts at `1` and increments by 1 every 4 weeks. |
| **LLOQ** | Numeric | Lower Limit of Quantification for the assay (see **Assay Quantification Logic** below). |

---

### Variable Codes Lookup

#### Dependent Variable Classification (`YTYPE` & `CMT`)
Both `YTYPE` and `CMT` align to dictate the data type present on any given row:
* **`0` = Dosing Event:** The amount of drug administered (corresponds to rows where `EVID = 1`).
* **`1` = PK Concentration:** Active drug concentration measured in blood plasma (e.g., `mg/L` or `ng/mL`).
* **`2` = PD Response:** Biological effect, biomarker value, or continuous pharmacodynamic response score.

#### Censoring Logic (`CENS`)
Flags observations where the true value cannot be perfectly quantified because it falls outside the limits of the analytical laboratory assay equipment.
* **`0` (Not Censored):** The measurement is completely reliable; the laboratory assay successfully detected and quantified the concentration or biomarker value.
* **`1` (Left-Censored / BLLOQ):** The drug concentration fell Below the Lower Limit of Quantification (BLLOQ). The actual biological value is too low for the analytical equipment to accurately measure.

#### Assay Quantification Logic (`LLOQ`)
The absolute lowest concentration of a drug that the laboratory equipment can reliably measure with acceptable accuracy and precision. 
* For rows where **`YTYPE = 1` (PK Concentration)**, the LLOQ is explicitly set to **`10`**. If a patient's plasma concentration drops below 10, the equipment cannot read it accurately (and `CENS` is flagged as `1`).
* For dosing events or non-PK biomarker rows, this value is intentionally set to **`NA`**, as a standard lower limit threshold is not applicable to those events.


# Libraries

library(dplyr)
library(ggplot2)

# Functions
## R Functions Glossary

The following table summarizes all the functions utilized in this analysis pipeline, categorized by their respective R packages, along with a brief description of their purpose in the script.

| Package | Function | Description / Practical Purpose in This Script |
| :--- | :--- | :--- |
| **`dplyr`** | `filter()` | Subsets rows to remove missing observations (`LIDV`, `TIME`) and restricts the timeline to `TIME < 50`. |
| **`dplyr`** | `mutate()` | Creates or transforms columns (used to generate time bins, convert data types, and re-level factors). |
| **`dplyr`** | `group_by()` | Groups the data by assay type (`NAME`) and interval (`Time_Bin`) for group-specific summary calculations. |
| **`dplyr`** | `summarise()` | Compresses multiple rows into summary statistics; calculates the sample size `n()` for each group. |
| **`base`** | `cut()` | Converts the continuous numeric `TIME` vector into discrete interval categories based on specific cutoff `breaks`. |
| **`base`** | `factor()` | Converts a variable into a categorical factor to enforce a specific plotting order (e.g., `"PK"` before `"PD"`). |
| **`base`** | `as.character()` | Converts factor-based time bins into raw text characters so they can safely be transformed into numbers. |
| **`base`** | `as.numeric()` | Converts text intervals back into numeric values to map exact coordinates on the plot's X-axis. |
| **`base`** | `paste0()` | Concatenates text strings without spaces to build dynamic labels (e.g., converting `15` into `"n = 15"`). |
| **`ggplot2`** | `ggplot()` | Initializes the coordinate system and defines the default data source and aesthetic mappings (`x` and `y`). |
| **`ggplot2`** | `aes()` | Handles aesthetic mapping; links dataset columns (like `TIME`) to visual properties of the plot. |
| **`ggplot2`** | `geom_point()` | Adds a scatter plot layer to display individual, raw PK/PD data points in a subtle grey color. |
| **`ggplot2`** | `geom_vline()` | Draws vertical reference lines to mark key study milestones (Baseline Day 0 and Cutoff Day 60). |
| **`ggplot2`** | `geom_hline()` | Draws a horizontal reference line from an external dataset (`intercept_data`) to denote a target threshold. |
| **`ggplot2`** | `geom_smooth()` | Fits a non-parametric local regression curve (`method = "loess"`) with a 95% confidence interval band. |
| **`ggplot2`** | `facet_wrap()` | Splits the visualization into stacked panels based on `NAME`, allowing independent Y-axis scales. |
| **`ggplot2`** | `labeller()` | Customizes the text displayed on the facet headers using a pre-defined lookup list (`facet_labels`). |
| **`ggplot2`** | `scale_y_log10()` | Transforms the continuous Y-axis to a $\log_{10}$ scale, which is standard for analyzing exponential PK decay. |
| **`ggplot2`** | `scale_color_manual()` | Assigns explicit, custom colors and corresponding legend titles to the specified reference lines. |
| **`ggplot2`** | `geom_text()` | Injects text annotations into the plot; maps the calculated sample sizes (`n = ...`) onto the canvas. |
| **`ggplot2`** | `coord_cartesian()` | Defines the plot bounding box; setting `clip = "off"` allows text to be drawn outside the main panel margins. |
| **`ggplot2`** | `theme_classic()` | Applies a clean background theme with solid axis lines and no distracting background grid lines. |
| **`ggplot2`** | `theme()` | Fine-tunes non-data elements of the plot, such as moving the legend to the bottom and adjusting margins. |
| **`ggplot2`** | `margin()` | Defines custom padding space (top, right, bottom, left) around plot elements, measured in points. |
| **`ggplot2`** | `element_text()` | Mandates formatting for text elements; used to push the horizontal axis title further down. |
| **`ggplot2`** | `labs()` | Organizes all structural plot typography, including the `title`, `subtitle`, axis labels, and `caption`. |

## Data Source

The **Data_Checking** dataset is not for a specific real-world drug. It is a mock, model-generated simulation dataset engineered by Novartis.
Link: https://opensource.nibr.com/xgx/Datasets.html


