# BRFSS Diabetes Surveillance Analysis: Data Dictionary

## Overview

This project uses publicly available data from the Behavioral Risk Factor Surveillance System (BRFSS) to examine weighted diabetes prevalence trends across demographic groups from 2013–2023.

The analytic dataset was created by harmonizing variables across survey years due to changes in BRFSS variable naming conventions.

---

# Key Variables

| Variable Name | Original Name | Description | Recoding / Notes |
|---|---|---|---|
| `year` | Survey year | BRFSS survey year | Added during import loop |
| `diabetes_code` | `DIABETE3`, `DIABETE4` | Self-reported diabetes status | Harmonized across years |
| `diabetes` | Derived | Binary diabetes outcome | 1 = diagnosed diabetes, 0 = no diabetes |
| `sex_code` | `SEX`, `SEX1`, `SEXVAR` | Respondent sex | Harmonized across years |
| `sex_label` | Derived | Descriptive sex category | Men, Women |
| `age6` | `_AGE_G` | BRFSS 6-level age grouping | Used to derive broader age categories |
| `age_group` | Derived | Collapsed age category | 1 = 18–34, 2 = 35–54, 3 = 55–64, 4 = 65+ |
| `age_group_label` | Derived | Descriptive age category | "18–34", "35–54", "55–64", "65+" |
| `_STSTR` | BRFSS design variable | Sampling strata | Used in survey-weighted analyses |
| `_PSU` | BRFSS design variable | Primary sampling unit | Used in survey-weighted analyses |
| `_LLCPWT` | BRFSS survey weight | Final survey weight | Applied in weighted prevalence estimation |
| `prevalence_pct` | Derived | Weighted diabetes prevalence (%) | Estimated using PROC SURVEYFREQ |
| `lower_ci` | Derived | Lower 95% confidence interval | From weighted prevalence estimation |
| `upper_ci` | Derived | Upper 95% confidence interval | From weighted prevalence estimation |

---

# Harmonization Notes

## Diabetes Variable

BRFSS changed the diabetes variable name after 2018:

| Years | Variable Used |
|---|---|
| 2013–2018 | `DIABETE3` |
| 2019–2023 | `DIABETE4` |

These were harmonized into:

```sas
diabetes_code
```

---

## Sex Variable

BRFSS changed sex variable naming conventions across years:

| Years | Variable Used |
|---|---|
| 2013–2017 | `SEX` |
| 2018 | `SEX1` |
| 2019–2023 | `SEXVAR` |

These were harmonized into:

```sas
sex_code
```

---

# Age Group Recoding

The original BRFSS `_AGE_G` variable was collapsed into broader analytic categories:

| Original `_AGE_G` | Recoded Group | Label |
|---|---|---|
| 1–2 | 1 | 18–34 |
| 3–4 | 2 | 35–54 |
| 5 | 3 | 55–64 |
| 6 | 4 | 65+ |

---

## Regional groupings

| Region | States included |
|---|---|
| Northeast | ME, NH, VT, MA, RI, CT, NY, NJ, PA |
| Southeast | MD, DE, WV, VA, NC, SC, GA, FL, TN, KY, AL, MS, AR, LA |
| Midwest | OH, MI, IN, WI, IL, MN, IA, MO, ND, SD, NE, KS |
| Southwest | TX, OK, NM, AZ |
| West | CO, WY, MT, ID, UT, NV, CA, OR, WA, AK, HI |

---

# Survey Weighting

All prevalence estimates were generated using BRFSS complex survey design variables:

- Strata: `_STSTR`
- Cluster: `_PSU`
- Weight: `_LLCPWT`

Weighted prevalence estimates and 95% confidence intervals were calculated using:

```sas
PROC SURVEYFREQ
```

---


## Exclusions

- Respondents with missing or refused diabetes status
- Gestational diabetes (coded separately in BRFSS)
- Respondents with missing age, sex, or state variables

---

# Data Source

Behavioral Risk Factor Surveillance System (BRFSS)  
Centers for Disease Control and Prevention (CDC)

Public-use datasets:
https://www.cdc.gov/brfss/
