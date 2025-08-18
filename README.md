# phssensitivitylabels

An R package for applying and reading sensitivity labels in PHS Excel files using [openxlsx2](https://github.com/JanMarvin/openxlsx2).

## Features
- Apply sensitivity labels (Personal, OFFICIAL, OFFICIAL_SENSITIVE_VMO) to Excel files
- Read sensitivity labels from Excel files
- Built-in XML for label metadata
- Fully documented and tested with `testthat`

## Installation
```r
# Install openxlsx2 if not already installed
install.packages("openxlsx2")
# Install testthat for testing
install.packages("testthat")
# Clone this repo and use devtools to install
# devtools::install_local("path/to/phssensitivitylabels")
```

## Usage
```r
library(phssensitivitylabels)

# Apply a sensitivity label
apply_sensitivity_label("myfile.xlsx", "Personal")

# Read a sensitivity label
read_sensitivity_label("myfile.xlsx")
```

## Supported Labels
- `Personal`
- `OFFICIAL`
- `OFFICIAL_SENSITIVE_VMO`

## Testing
Run all tests with:
```r
library(testthat)
testthat::test_dir("tests/testthat")
```

## License
MIT
