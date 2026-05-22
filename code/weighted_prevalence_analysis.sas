/**************************************************************************
BRFSS Diabetes Surveillance Analysis (2013-2023)
Olivia Wallen
December 2025

Description:
    Weighted analysis of diabetes prevalence trends by sex and age group
    using BRFSS complex survey data (2013–2023).

Methods:
    - Complex survey weighting
    - Stratified prevalence estimation
    - 95% confidence intervals
    - Longitudinal trend visualization

**************************************************************************/

/*==============================================================*
  Create Empty Dataset to Store Results                        
 *==============================================================*/

data all_years_weighted;
    length year 8
           sex_label $10
           age_group_label $10
           prevalence_pct 8
           lower_ci 8
           upper_ci 8;
    stop;
run;

/*==============================================================*
  Loop Through Survey Years and Estimate Weighted Prevalence   
 *==============================================================*/

%macro weighted_prevalence_analysis(start_year=2013, end_year=2023);

    %do yr = &start_year %to &end_year;

        /**********************************************************
        Estimate weighted diabetes prevalence using BRFSS
        complex survey design variables
        **********************************************************/

        proc surveyfreq data=diabetes_clean_&yr;
            strata _STSTR;
            cluster _PSU;
            weight _LLCPWT;

            tables age_group*sex_code*diabetes / row cl;

            ods output CrossTabs=prev_&yr;
        run;

        /**********************************************************
        Keep diagnosed diabetes prevalence estimates only
        **********************************************************/

        data prev_&yr;

            set prev_&yr;

            if diabetes = 1;

            /**********************************************************
            Create formatted prevalence outputs
            **********************************************************/

            prevalence_pct = round(RowPercent, 0.1);
            lower_ci       = round(RowLowerCL, 0.1);
            upper_ci       = round(RowUpperCL, 0.1);

            keep year
                 sex_label
                 age_group
                 age_group_label
                 prevalence_pct
                 lower_ci
                 upper_ci;

        run;

        /**********************************************************
        Append yearly estimates into master dataset
        **********************************************************/

        proc append
            base=all_years_weighted
            data=prev_&yr
            force;
        run;

    %end;

%mend weighted_prevalence_analysis;

/*==============================*
  Run Weighted Analysis        
 *==============================*/

%weighted_prevalence_analysis(
    start_year=2013,
    end_year=2023
);

/*==============================================================*
  Final Data Cleaning                                           
 *==============================================================*/

data all_years_weighted_clean;

    set all_years_weighted;

    if missing(sex_label) then delete;
    if missing(age_group_label) then delete;
    if missing(prevalence_pct) then delete;

run;

/*==============================================================*
  Export Final Analytic Dataset                                
 *==============================================================*/

proc export
    data=all_years_weighted_clean
    outfile="C:\Users\owalle01\Box\ADA\data\diabetes_prevalence_2013_2023.csv"
    dbms=csv
    replace;
run;

/*==============================================================*
  Visualization: Diabetes Trends by Age and Sex                
 *==============================================================*/

proc sgpanel data=all_years_weighted_clean;

    panelby age_group_label /
        columns=2
        rows=2
        novarname;

    /**********************************************************
    Confidence interval bands
    **********************************************************/

    band x=year
         lower=lower_ci
         upper=upper_ci /
         group=sex_label
         transparency=0.5;

    /**********************************************************
    Trend lines
    **********************************************************/

    series x=year
           y=prevalence_pct /
           group=sex_label
           markers
           lineattrs=(thickness=2)
           markerattrs=(symbol=circlefilled size=6);

    colaxis
        label="Survey Year"
        values=(2013 to 2023 by 2);

    rowaxis
        label="Diabetes Prevalence (%)"
        grid;

    title
        "Weighted Diabetes Prevalence by Sex and Age Group, BRFSS 2013–2023";

run;
