/**************************************************************************
BRFSS Diabetes Surveillance Analysis (2013-2023)
Olivia Wallen
November 2025

Description:
    Reusable SAS macro to import, clean, and harmonize BRFSS datasets
    across survey years (2013�2023).

    This script:
    - Standardizes variable names across changing BRFSS formats
    - Recodes demographic variables
    - Creates analytic diabetes outcome
    - Produces a cleaned longitudinal dataset for analysis

Data Source:
    Behavioral Risk Factor Surveillance System (BRFSS)

**************************************************************************/

/*==============================*
    Define Local Data Directory  
 *==============================*/

%let path = C:\Users\owalle01\Box\ADA\data;

/*==============================================================*
 	Macro: import_clean_brfss                                    
  	                                                      
    Loop through BRFSS survey years and create harmonized       
    analytic datasets with consistent variable naming.          
 *==============================================================*/

%macro import_clean_brfss(start_year=2013, end_year=2023);

    %do yr = &start_year %to &end_year;

        /**********************************************************
        Import annual BRFSS dataset
        **********************************************************/

        data diabetes_clean_&yr;
            set "&path.\LLCP&yr..sas7bdat";

            /**********************************************************
            Harmonize diabetes variable names across years
            **********************************************************/

            if &yr < 2019 then diabetes_code = DIABETE3;
            else diabetes_code = DIABETE4;

            /**********************************************************
            Harmonize sex variable names across years
            **********************************************************/

            if &yr <= 2017 then sex_code = SEX;
            else if &yr = 2018 then sex_code = SEX1;
            else sex_code = SEXVAR;

            /**********************************************************
            Harmonize age group variable
            	_AGE_G is consistent across study years
            **********************************************************/

            age6 = _AGE_G;

            /**********************************************************
           	Recode age into broader analytic categories
            **********************************************************/

            if age6 in (1,2) then age_group = 1;       /* 18�34 */
            else if age6 in (3,4) then age_group = 2;  /* 35�54 */
            else if age6 = 5 then age_group = 3;       /* 55�64 */
            else if age6 = 6 then age_group = 4;       /* 65+ */

            /**********************************************************
            Create descriptive age labels
            **********************************************************/

            length age_group_label $10;

            if age_group = 1 then age_group_label = "18�34";
            else if age_group = 2 then age_group_label = "35�54";
            else if age_group = 3 then age_group_label = "55�64";
            else if age_group = 4 then age_group_label = "65+";

            /**********************************************************
            Keep valid survey responses only
            **********************************************************/

            if sex_code not in (1,2) then delete;
            if diabetes_code not in (1,2,3,4) then delete;
            if missing(age_group) then delete;

            /**********************************************************
            Create binary diabetes outcome
            1 = diagnosed diabetes
            0 = no diabetes
            **********************************************************/

            if diabetes_code = 1 then diabetes = 1;
            else diabetes = 0;

            /**********************************************************
            Create descriptive sex labels
            **********************************************************/

            length sex_label $10;

            if sex_code = 1 then sex_label = "Men";
            else if sex_code = 2 then sex_label = "Women";

            /**********************************************************
            Add survey year variable
            **********************************************************/

            year = &yr;

        run;

    %end;

%mend import_clean_brfss;


/*==============================*
  Execute Cleaning Macro       
 *==============================*/

%import_clean_brfss(start_year=2013, end_year=2023);
