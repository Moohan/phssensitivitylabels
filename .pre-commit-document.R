#!/usr/bin/env Rscript

# Document R package using devtools
tryCatch({
  if (!requireNamespace("devtools", quietly = TRUE)) {
    cat("\n❌ Error: devtools package is not installed.\n")
    cat("📦 Please install it with:\n")
    cat("   R: install.packages('devtools')\n")
    cat("   Terminal: Rscript -e \"install.packages('devtools')\"\n")
    cat("   Or run: ./setup-precommit.R\n\n")
    cat("ℹ️  This hook would run: devtools::document()\n")
    quit(status = 1)
  }
  
  cat("📚 Generating documentation with devtools::document()...\n")
  devtools::document()
  cat("✅ Documentation updated successfully.\n")
}, error = function(e) {
  cat("❌ Error running devtools::document():\n")
  cat(conditionMessage(e), "\n")
  cat("ℹ️  This hook would run: devtools::document()\n")
  quit(status = 1)
})