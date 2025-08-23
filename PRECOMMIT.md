# Pre-commit Hooks Setup

This repository includes pre-commit hooks that run the same checks as the CI:
- Style with `styler::style_package()`
- Document with `devtools::document()`
- Test with `devtools::test()`

## Quick Setup

1. **Install required R packages** (if not already installed):
   ```r
   install.packages(c("styler", "devtools", "testthat"))
   ```

2. **Install pre-commit** (requires Python):
   ```bash
   pip install pre-commit
   ```

3. **Install the hooks**:
   ```bash
   pre-commit install
   ```

## Usage

After setup, the hooks will run automatically before each commit. You can also run them manually:

```bash
# Run all hooks on all files
pre-commit run --all-files

# Run a specific hook
pre-commit run style-r
pre-commit run document-r
pre-commit run test-r
```

## Customization

The hooks are configured in `.pre-commit-config.yaml`. You can:
- Skip hooks temporarily: `git commit --no-verify`
- Modify which files trigger each hook by editing the `files` patterns
- Add additional hooks as needed

## Troubleshooting

If you encounter package installation issues, run the setup script:
```bash
./setup-precommit.R
```

Or install packages manually:
```r
# For user library (recommended)
install.packages(c("styler", "devtools", "testthat"), 
                 lib = file.path(Sys.getenv("HOME"), "R", "library"))
```