*! version 1.0.0 15 Nov 2024
program define automlselect
    version 16.0
    syntax ///
        using file(string) ///
        , NumCols(string) CatCols(string) ///
          Target(string) Task(string) ///
          OutputPred(string) OutputCoeff(string) OutputMetrics(string)

    *-----------------------------
    * Validate Task Type
    *-----------------------------
    if "`Task'" != "regression" & "`Task'" != "classification" {
        error 198 // invalid syntax
        exit
    }

    *-----------------------------
    * Load Dataset
    *-----------------------------
    capture confirm file "`using'"
    if _rc {
        di as error "Error: File `"`using'"' does not exist."
        exit 198
    }

    use "`using'", clear

    *-----------------------------
    * Validate Columns
    *-----------------------------
    tokenize `"`NumCols'"'
    local num_vars
    while "`1'" != "" {
        if !inlist("`1'", `: varlist) {
            di as error "Error: Numerical column `1' does not exist in the dataset."
            exit 198
        }
        * Check if numeric
        confirm numeric variable `1'
        if _rc {
            di as error "Error: Variable `1' is not numeric."
            exit 198
        }
        local num_vars `num_vars' `1'
        macro shift
    }

    tokenize `"`CatCols'"'
    local cat_vars
    while "`1'" != "" {
        if !inlist("`1'", `: varlist) {
            di as error "Error: Categorical column `1' does not exist in the dataset."
            exit 198
        }
        * Check if categorical (string or labeled)
        capture confirm string variable `1'
        if _rc {
            confirm numeric variable `1'
            if _rc {
                di as error "Error: Variable `1' must be either string or labeled categorical."
                exit 198
            }
        }
        local cat_vars `cat_vars' `1'
        macro shift
    }

    * Check Target Variable
    if !inlist("`Target'", `: varlist) {
        di as error "Error: Target column `Target' does not exist in the dataset."
        exit 198
    }

    * Ensure no missing values
    quietly count if missing(`num_vars') | missing(`cat_vars') | missing(`Target')
    if r(N) > 0 {
        di as error "Error: Dataset contains missing values. Please clean the data before using this package."
        exit 198
    }

    *-----------------------------
    * Prepare Data: Encode Categorical Variables
    *-----------------------------
    foreach var of local cat_vars {
        capture encode `var', gen(`var'_encoded)
        if !_rc {
            drop `var'
            rename `var'_encoded `var'
        }
    }

    *-----------------------------
    * Define Model Formulas
    *-----------------------------
    local predictors `num_vars' `cat_vars'
    local formula = "`Target' " 
    foreach var of local predictors {
        local formula = "`formula' `var'"
    }

    *-----------------------------
    * Initialize Variables to Store Best Model
    *-----------------------------
    local best_model ""
    local best_metric = .

    *-----------------------------
    * Regression Task
    *-----------------------------
    if "`Task'" == "regression" {
        * Linear Regression
        regress `Target' `predictors'
        scalar r2_linear = e(r2)

        * Box-Cox Transformation (if applicable)
        capture boxcox `Target', model(`predictors') lambda(0(.1)2)
        if !_rc {
            * Assuming Box-Cox was successful
            regress `Target' `predictors'
            scalar r2_boxcox = e(r2)
        }
        else {
            scalar r2_boxcox = .
        }

        * Determine Best Model
        if r2_boxcox > r2_linear {
            local best_model = "Box-Cox Regression"
            local best_metric = r2_boxcox
            regress `Target' `predictors'
        }
        else {
            local best_model = "Linear Regression"
            local best_metric = r2_linear
        }

        * Save Outputs
        * Predictions
        predict double pred, xb
        save "`OutputPred'", replace

        * Coefficients
        matrix coef = e(b)'
        mata: st_matrix("coefficients", coef)

        * Metrics
        scalar R_squared = `best_metric'
        mata: st_matrix("metrics", (R_squared \ .))

    }
    *-----------------------------
    * Classification Task
    *-----------------------------
    else if "`Task'" == "classification" {
        * Ensure Target is binary
        qui tabulate `Target', missing
        if r(r) != 2 {
            di as error "Error: For classification, the target variable must be binary."
            exit 198
        }

        * Linear Regression (as classification via threshold)
        regress `Target' `predictors'
        predict double pred_lin, xb
        gen predicted_lin = pred_lin >= 0.5
        qui tabulate `Target' predicted_lin, matcell(freq_lin)
        matrix freq_lin = r(freq_lin)
        scalar accuracy_lin = (freq_lin[1,1] + freq_lin[2,2]) / sum(freq_lin)

        * Logistic Regression
        logistic `Target' `predictors'
        predict double pred_logit, pr
        gen predicted_logit = pred_logit >= 0.5
        qui tabulate `Target' predicted_logit, matcell(freq_logit)
        matrix freq_logit = r(freq_logit)
        scalar accuracy_logit = (freq_logit[1,1] + freq_logit[2,2]) / sum(freq_logit)

        * Determine Best Model
        if accuracy_logit > accuracy_lin {
            local best_model = "Logistic Regression"
            local best_metric = accuracy_logit
            * Use logistic regression coefficients
            logistic `Target' `predictors'
            predict double final_pred, pr
            gen predicted = final_pred >= 0.5
        }
        else {
            local best_model = "Linear Regression (Thresholded)"
            local best_metric = accuracy_lin
            * Use linear regression predictions
            regress `Target' `predictors'
            predict double final_pred, xb
            gen predicted = final_pred >= 0.5
        }

        * Save Outputs
        save "`OutputPred'", replace

        * Coefficients
        matrix coef = e(b)'
        mata: st_matrix("coefficients", coef)

        * Metrics
        scalar Accuracy = `best_metric'
        mata: st_matrix("metrics", (Accuracy \ .))
    }

    *-----------------------------
    * Save Model Coefficients and Metrics
    *-----------------------------
    * Save Coefficients
    mata clear
    mata: st_matrix("coefficients", coef)
    export delimited using "`OutputCoeff'", replace

    * Save Metrics
    mata: st_matrix("metrics", metrics)
    export delimited using "`OutputMetrics'", replace

    * Inform User
    di as result "Best Model: `best_model'"
    di as result "Performance Metric: `best_metric'"

end
