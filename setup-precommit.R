#!/usr/bin/env Rscript

# Setup script for pre-commit hooks
# This installs the required R packages for the pre-commit hooks

cat("Setting up R packages for pre-commit hooks...\n")

# Create user library directory if it doesn't exist
user_lib <- Sys.getenv("R_LIBS_USER")
if (user_lib == "") {
  user_lib <- file.path(Sys.getenv("HOME"), "R", "library")
}
if (!dir.exists(user_lib)) {
  cat("Creating user library directory:", user_lib, "\n")
  dir.create(user_lib, recursive = TRUE)
}

# Add user library to library paths
.libPaths(user_lib)

# Install required packages
required_packages <- c("styler", "devtools", "testthat", "openxlsx2", "cli", "tools")

for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    cat("Installing package:", pkg, "\n")
    install.packages(pkg, repos = "https://cran.rstudio.com/", lib = user_lib)
  } else {
    cat("Package", pkg, "is already installed\n")
  }
}

cat("Setup complete!\n")
cat("You can now use the pre-commit hooks.\n")