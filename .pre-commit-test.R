#!/usr/bin/env Rscript

# Test R package using devtools
tryCatch({
  if (!requireNamespace("devtools", quietly = TRUE)) {
    cat("\n❌ Error: devtools package is not installed.\n")
    cat("📦 Please install it with:\n")
    cat("   R: install.packages('devtools')\n")
    cat("   Terminal: Rscript -e \"install.packages('devtools')\"\n")
    cat("   Or run: ./setup-precommit.R\n\n")
    cat("ℹ️  This hook would run: devtools::test()\n")
    quit(status = 1)
  }
  
  cat("🧪 Running tests with devtools::test()...\n")
  result <- devtools::test()
  
  if (any(result$failed > 0)) {
    cat("❌ Some tests failed. Please fix them before committing.\n")
    quit(status = 1)
  } else {
    cat("✅ All tests passed successfully.\n")
  }
}, error = function(e) {
  cat("❌ Error running devtools::test():\n")
  cat(conditionMessage(e), "\n")
  cat("ℹ️  This hook would run: devtools::test()\n")
  quit(status = 1)
})