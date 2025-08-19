# phssensitivitylabels

An R package for applying and reading sensitivity labels in PHS Excel files using [openxlsx2](https://github.com/JanMarvin/openxlsx2).

**ALWAYS FOLLOW THESE INSTRUCTIONS FIRST**. Reference these comprehensive instructions before using search or bash commands. Only fallback to additional search and context gathering if the information in these instructions is incomplete or found to be in error.

## Working Effectively

### Bootstrap and Setup
NEVER CANCEL: All commands listed here take under 5 minutes. Set timeout to 10+ minutes.

- Install R and essential development tools:
  - `sudo apt-get update`
  - `sudo apt-get install -y r-base r-base-dev libcurl4-openssl-dev libssl-dev libxml2-dev`
  - `sudo apt-get install -y r-cran-testthat r-cran-devtools r-cran-openxlsx`

- **CRITICAL DEPENDENCY LIMITATION**: The package requires `openxlsx2` which is NOT available through Ubuntu apt repositories. Network restrictions in CI environments may prevent installation from CRAN or GitHub. Document this limitation in any changes.

### Package Development Commands
NEVER CANCEL: Package builds take under 1 minute. Set timeout to 5+ minutes.

- Build the package: 
  - `cd /path/to/phssensitivitylabels`
  - `R CMD build .` -- takes under 30 seconds. Creates `phssensitivitylabels_[version].tar.gz`

- Check package structure (will fail due to missing openxlsx2):
  - `R CMD check .` -- will fail with dependency errors but validates DESCRIPTION format

- Install package locally (will fail due to missing openxlsx2):
  - `sudo R CMD INSTALL phssensitivitylabels_[version].tar.gz`

### Testing
NEVER CANCEL: Tests take under 1 minute when dependencies are available. Set timeout to 5+ minutes.

- Run tests (will fail without openxlsx2):
  - `cd /path/to/phssensitivitylabels`
  - `R -e "library(testthat); test_dir('tests/testthat')"`

- Load package for development (will fail without openxlsx2):
  - `R -e "library(devtools); load_all('.')"`

### Validation
NEVER CANCEL: Manual validation steps take 2-5 minutes. Set timeout to 10+ minutes.

- Always run `R CMD build .` to verify package structure is valid
- Package builds successfully even without openxlsx2 dependency  
- Tests and package installation require openxlsx2 to be installed first
- In environments with network restrictions, document dependency installation limitations

**MANUAL VALIDATION REQUIREMENT**: After making changes, always validate functionality:
1. Verify package builds: `R CMD build .` (should complete without errors)
2. Check that essential development tools work: `R -e "library(testthat); library(devtools)"`
3. If openxlsx2 is available, test core functionality by running this validation script:
   ```r
   # Validation scenario for phssensitivitylabels
   library(phssensitivitylabels)
   
   # Create test Excel file
   tmp_file <- tempfile(fileext = ".xlsx")
   wb <- openxlsx2::wb_workbook()
   wb <- openxlsx2::wb_add_worksheet(wb)
   openxlsx2::wb_save(wb, tmp_file)
   
   # Test applying and reading each supported label
   for (label in c("Personal", "OFFICIAL", "OFFICIAL_SENSITIVE_VMO")) {
     result <- apply_sensitivity_label(tmp_file, label)
     read_label <- read_sensitivity_label(tmp_file)
     stopifnot(read_label == label)
     cat("SUCCESS: Applied and verified", label, "label\n")
   }
   
   # Test error handling
   try(apply_sensitivity_label(tmp_file, "INVALID_LABEL"))
   cat("SUCCESS: Error handling works for invalid labels\n")
   
   # Clean up
   file.remove(tmp_file)
   cat("All validation tests passed!\n")
   ```
4. Run the test suite to ensure no regressions: `R -e "library(testthat); test_dir('tests/testthat')"`

## Package Structure and Key Files

### Repository Root
```
.
..
.github/
  workflows/
    phs_package_checks.yaml
.gitignore
.Rbuildignore
DESCRIPTION
LICENSE
LICENSE.md
NAMESPACE
R/
  apply_sensitivity_label.R
README.md
man/
  apply_sensitivity_label.Rd
  read_sensitivity_label.Rd
phssensitivitylabels.Rproj
tests/
  testthat/
    test-apply_sensitivity_label.R
```

### DESCRIPTION File
The package metadata is defined in DESCRIPTION:
- Package: phssensitivitylabels
- Dependencies: openxlsx2 (Import), testthat (Suggests)
- Version: 0.1.0
- License: MIT + file LICENSE

### Key Functions
- `apply_sensitivity_label(file, label)` - Applies sensitivity labels to Excel files
- `read_sensitivity_label(file)` - Reads sensitivity labels from Excel files
- Supported labels: "Personal", "OFFICIAL", "OFFICIAL_SENSITIVE_VMO"

## CI/CD Pipeline
- Uses Public Health Scotland's reusable workflow: `Public-Health-Scotland/actions/.github/workflows/phs_package_checks.yaml@v1.6.0`
- Triggered on push/PR to main branch and workflow_dispatch
- The PHS workflow likely handles openxlsx2 installation internally

## Common Development Tasks

### Working with the Package Code
- Always check NAMESPACE after modifying exported functions
- Main package code is in `R/apply_sensitivity_label.R`
- Documentation is generated from roxygen2 comments - regenerate with `devtools::document()`

### Testing Strategy
- Tests are in `tests/testthat/test-apply_sensitivity_label.R`
- Tests create temporary Excel files using openxlsx2
- Always test both successful operations and error conditions
- Expected test structure: Create temp file → Apply operation → Verify result

### Dependency Management
- Core dependency: openxlsx2 (for Excel file manipulation)
- Development dependencies: testthat, devtools
- **CRITICAL**: openxlsx2 installation may fail in restricted environments:
  - Document alternative installation methods if found
  - Consider suggesting use of Docker or virtual environments
  - Note that CI pipeline may have different dependency resolution

## Build Artifacts to Ignore
The following files are generated during build and should not be committed:
- `*.tar.gz` (built package archives)
- `..Rcheck/` (package check results)
- `.Rproj.user/` (RStudio user files)
- `.Rhistory`, `.RData`, `.Ruserdata` (R session files)

## Troubleshooting Common Issues

### "openxlsx2 not available" Error
This is the most common issue when working with this package:
- Verify R and basic tools are installed first
- Check if openxlsx2 can be installed: `R -e "install.packages('openxlsx2')"`
- If CRAN access fails, try: `R -e "install.packages('openxlsx2', repos='https://cloud.r-project.org')"`
- If GitHub access works: `R -e "remotes::install_github('JanMarvin/openxlsx2')"`
- **Document the limitation** if no installation method works

### Package Check Failures
- "Required field missing or empty: 'Author'" - Normal with Authors@R format, use `R CMD build` instead
- Always run `R CMD build .` before `R CMD check` to ensure proper package structure

### Test Failures
- All tests will fail without openxlsx2 installation
- Focus on package structure validation if dependencies cannot be installed
- Use `R CMD build .` to verify code syntax and package structure

## Making Changes
- Always modify source files in `R/` directory, not generated files
- Update documentation in roxygen2 comments, then run `devtools::document()`
- Add tests for new functionality in `tests/testthat/`
- Verify package builds successfully with `R CMD build .`
- If adding dependencies, update DESCRIPTION file Imports or Suggests sections

## Quick Reference Commands

### Essential Commands (Copy and paste these)
```bash
# Setup R environment (run once)
sudo apt-get update
sudo apt-get install -y r-base r-base-dev libcurl4-openssl-dev libssl-dev libxml2-dev
sudo apt-get install -y r-cran-testthat r-cran-devtools r-cran-openxlsx

# Navigate to package directory
cd /path/to/phssensitivitylabels

# Build package (always works)
R CMD build .

# Test if development packages are working
R -e "library(testthat); library(devtools); cat('Development environment ready\n')"

# Run tests (only works if openxlsx2 is available)
R -e "library(testthat); test_dir('tests/testthat')"

# Load package for development (only works if openxlsx2 is available)
R -e "library(devtools); load_all('.')"
```

### File Structure Quick Check
```bash
ls -la .github/workflows/  # Should show phs_package_checks.yaml
ls -la R/                  # Should show apply_sensitivity_label.R
ls -la tests/testthat/     # Should show test-apply_sensitivity_label.R
cat DESCRIPTION            # Check package metadata
cat NAMESPACE              # Check exported functions
```