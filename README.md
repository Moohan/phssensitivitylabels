# phssensitivitylabels

An R package for applying and reading Microsoft Information Protection (MIP) sensitivity labels in PHS Excel files using [openxlsx2](https://github.com/JanMarvin/openxlsx2).

This package provides a simple interface to work with sensitivity labels on Excel files, allowing you to programmatically apply and read labels that are compatible with Microsoft's sensitivity labeling system.

## Features

- **Apply sensitivity labels**: Add Microsoft Information Protection labels to Excel files
- **Read sensitivity labels**: Extract existing labels from Excel files  
- **Three supported label types**: Personal, OFFICIAL, and OFFICIAL_SENSITIVE_VMO (visual markings only)
- **Built-in XML metadata**: Pre-configured XML templates for each label type
- **Integration with openxlsx2**: Leverages the robust openxlsx2 package for Excel manipulation
- **Comprehensive testing**: Fully tested with testthat framework

## Installation

This package is not available on CRAN and must be installed from GitHub using the `remotes` package:

```r
# Install remotes if not already installed
if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes")
}

# Install phssensitivitylabels from GitHub
remotes::install_github("Moohan/phssensitivitylabels")
```

The package will automatically install the required dependency `openxlsx2`.

## Usage

```r
library(phssensitivitylabels)

# Apply a sensitivity label to an Excel file
# Returns the file path invisibly if successful
apply_sensitivity_label("myfile.xlsx", "Personal")

# Read the sensitivity label from an Excel file  
# Returns the label name or "no label" if none exists
label <- read_sensitivity_label("myfile.xlsx")
print(label)  # "Personal"
```

## Supported Labels
- `Personal`
- `OFFICIAL`
- `OFFICIAL_SENSITIVE_VMO`

## Testing

To run tests during development:
```r
# Install testthat if needed for development
install.packages("testthat")

# Run all tests
testthat::test_dir("tests/testthat")
```

Or use the standard R package testing approach:
```r
# Test the installed package
testthat::test_package("phssensitivitylabels")
```

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
