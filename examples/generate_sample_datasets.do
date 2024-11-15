* generate_sample_datasets.do
* ============================
* Generates sample datasets for AutoMLSelect Package
* Author: [Your Name]
* Date: 2024-04-27
* Version: 2.3

clear all
set more off

*-----------------------------------------------------------
* Generate Sample Regression Dataset
*-----------------------------------------------------------
display "Generating sample_regression_data.dta..."

* Set seed for reproducibility
set seed 12345

* Define number of observations
local n = 100

* Create variables
clear
set obs `n'

* Numerical predictors
generate double Size = round(runiform() * 3000 + 500, 1)       // Size in square feet
generate byte Bedrooms = ceil(runiform() * 5)                // Number of bedrooms
generate double Age = round(runiform() * 30, 1)              // Age of the house in years

* Categorical predictor
generate str10 Location = ""
replace Location = "North" in 1/25
replace Location = "South" in 26/50
replace Location = "East" in 51/75
replace Location = "West" in 76/100

* One-Hot Encoding for Location
tabulate Location, generate(Location_dummy)
rename Location_dummy1 Location_north
rename Location_dummy2 Location_south
rename Location_dummy3 Location_east
rename Location_dummy4 Location_west

* Target variable
generate double Price = 50000 + 150 * Size + 10000 * Bedrooms - 200 * Age + ///
    5000 * Location_north - 3000 * Location_south + 4000 * Location_east + 2000 * Location_west + ///
    round(rnormal(0, 10000), 1)

* Save the regression dataset
save "data/sample_regression_data.dta", replace
display "sample_regression_data.dta generated successfully."

*-----------------------------------------------------------
* Generate Sample Classification Dataset
*-----------------------------------------------------------
display "Generating sample_classification_data.dta..."

* Clear the dataset
clear

* Define number of observations
set obs `n'

* Numerical predictors
generate double Age = round(runiform() * 60 + 18, 1)            // Age of the customer
generate double Income = round(runiform() * 90000 + 10000, 1) // Annual income

* Categorical predictors
generate str6 Gender = ""
replace Gender = "Male" in 1/50
replace Gender = "Female" in 51/100

generate str10 Region = ""
replace Region = "North" in 1/25
replace Region = "South" in 26/50
replace Region = "East" in 51/75
replace Region = "West" in 76/100

* One-Hot Encoding for Gender and Region
tabulate Gender, generate(Gender_dummy)
rename Gender_dummy1 Gender_male
rename Gender_dummy2 Gender_female

tabulate Region, generate(Region_dummy)
rename Region_dummy1 Region_north
rename Region_dummy2 Region_south
rename Region_dummy3 Region_east
rename Region_dummy4 Region_west

* Target variable
generate byte Purchase = 0
replace Purchase = 1 in 1/30
replace Purchase = 0 in 31/100

* Save the classification dataset
save "data/sample_classification_data.dta", replace
display "sample_classification_data.dta generated successfully."

*-----------------------------------------------------------
* Completion Message
*-----------------------------------------------------------
display "All sample datasets have been generated successfully."
