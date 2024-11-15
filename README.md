# AutoMLSelect Stata Package

AutoMLSelect automates the selection and execution of regression or classification models based on user input. It evaluates multiple models and selects the best-performing one based on appropriate performance metrics.

## Installation

1. Download the `AutoMLSelect` package files.
2. Place the `automlselect.ado` file in your Stata `ado` directory.
3. Place the `automlselect.hlp` file in your Stata `help` directory.
4. Ensure that the `examples` directory contains the sample datasets provided.

## Usage

### Regression Example

```stata
use "data/sample_regression_data.dta", clear
automlselect using "data/sample_regression_data.dta", ///
   NumCols("Size Bedrooms Age") ///
   CatCols("Location") ///
   Target("Price") ///
   Task("regression") ///
   OutputPred("results/predictions_reg.dta") ///
   OutputCoeff("results/coefficients_reg.csv") ///
   OutputMetrics("results/metrics_reg.csv")
```

### Classification Example

```stata
use "data/sample_classification_data.dta", clear
automlselect using "data/sample_classification_data.dta", ///
   NumCols("Age Income") ///
   CatCols("Gender Region") ///
   Target("Purchase") ///
   Task("classification") ///
   OutputPred("results/predictions_clas.dta") ///
   OutputCoeff("results/coefficients_clas.csv") ///
   OutputMetrics("results/metrics_clas.csv")
```

## Parameters

- **Filepath (`using`)**: Path to the `.dta` dataset file.
- **Numerical Columns (`NumCols`)**: Space-separated list of numerical predictor columns.
- **Categorical Columns (`CatCols`)**: Space-separated list of categorical predictor columns.
- **Target Column (`Target`)**: The dependent variable to predict.
- **Task Type (`Task`)**: Either `"regression"` or `"classification"`.
- **Output Paths (`OutputPred`, `OutputCoeff`, `OutputMetrics`)**: Paths to save predictions, coefficients, and metrics respectively.

## Output

- **Predictions**: Saved at the specified `OutputPred` path.
- **Model Coefficients**: Saved at the specified `OutputCoeff` path.
- **Evaluation Metrics**: Saved at the specified `OutputMetrics` path.

## Interpretation

- **Regression**: Review R² to understand variance explained by the model.
- **Classification**: Review accuracy to understand the proportion of correct predictions.

## Troubleshooting

- Ensure all specified files and directories exist and are accessible.
- Verify that column names are correctly specified and exist in the dataset.
- Ensure there are no missing values in the specified columns.
- For classification tasks, ensure the target variable is binary.

## Contribution

Contributions are welcome! Please fork the repository and submit a pull request with your enhancements.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For any questions or support, please contact [your.email@example.com].


