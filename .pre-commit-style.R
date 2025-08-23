#!/usr/bin/env Rscript

# Style R code using styler
tryCatch({
  if (!requireNamespace("styler", quietly = TRUE)) {
    cat("\n❌ Error: styler package is not installed.\n")
    cat("📦 Please install it with:\n")
    cat("   R: install.packages('styler')\n")
    cat("   Terminal: Rscript -e \"install.packages('styler')\"\n")
    cat("   Or run: ./setup-precommit.R\n\n")
    cat("ℹ️  This hook would run: styler::style_package()\n")
    quit(status = 1)
  }
  
  cat("🎨 Styling R code with styler::style_package()...\n")
  result <- styler::style_package()
  
  if (any(result$changed)) {
    cat("✏️  Some files were styled. Please review and commit the changes.\n")
  } else {
    cat("✅ All files are already properly styled.\n")
  }
}, error = function(e) {
  cat("❌ Error running styler::style_package():\n")
  cat(conditionMessage(e), "\n")
  cat("ℹ️  This hook would run: styler::style_package()\n")
  quit(status = 1)
})