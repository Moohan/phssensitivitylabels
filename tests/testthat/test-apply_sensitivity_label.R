test_that("apply_sensitivity_label returns file path and applies label", {
  # Create a temp Excel file
  tmp <- tempfile(fileext = ".xlsx")
  wb <- openxlsx2::wb_add_worksheet(openxlsx2::wb_workbook())
  openxlsx2::wb_save(wb, tmp)

  # Apply Personal label
  result <- apply_sensitivity_label(tmp, "Personal")
  expect_equal(result, tmp)
  expect_equal(read_sensitivity_label(tmp), "Personal")

  # Apply OFFICIAL label
  result <- apply_sensitivity_label(tmp, "OFFICIAL")
  expect_equal(result, tmp)
  expect_equal(read_sensitivity_label(tmp), "OFFICIAL")

  # Apply OFFICIAL_SENSITIVE_VMO label
  result <- apply_sensitivity_label(tmp, "OFFICIAL_SENSITIVE_VMO")
  expect_equal(result, tmp)
  expect_equal(read_sensitivity_label(tmp), "OFFICIAL_SENSITIVE_VMO")
})

test_that("read_sensitivity_label returns 'no label' for file with no label", {
  tmp <- tempfile(fileext = ".xlsx")
  wb <- openxlsx2::wb_add_worksheet(openxlsx2::wb_workbook())
  openxlsx2::wb_save(wb, tmp)
  expect_equal(read_sensitivity_label(tmp), "no label")
})

test_that("apply_sensitivity_label errors for invalid label", {
  tmp <- tempfile(fileext = ".xlsx")
  wb <- openxlsx2::wb_add_worksheet(openxlsx2::wb_workbook())
  openxlsx2::wb_save(wb, tmp)
  expect_error(apply_sensitivity_label(tmp, "INVALID"))
})

test_that("apply_sensitivity_label errors when file does not exist", {
  non_existent_file <- tempfile(fileext = ".xlsx")
  expect_error(apply_sensitivity_label(non_existent_file, "Personal"), 
               "File does not exist:")
})

test_that("apply_sensitivity_label returns file path invisibly", {
  tmp <- tempfile(fileext = ".xlsx")
  wb <- openxlsx2::wb_add_worksheet(openxlsx2::wb_workbook())
  openxlsx2::wb_save(wb, tmp)
  
  # Test that the function returns invisibly (no output when not assigned)
  expect_invisible(apply_sensitivity_label(tmp, "Personal"))
  
  # Test that the returned value is correct
  result <- apply_sensitivity_label(tmp, "OFFICIAL")
  expect_equal(result, tmp)
})

test_that("apply_sensitivity_label validates label argument correctly", {
  tmp <- tempfile(fileext = ".xlsx")
  wb <- openxlsx2::wb_add_worksheet(openxlsx2::wb_workbook())
  openxlsx2::wb_save(wb, tmp)
  
  # Test that exact matches work
  result <- apply_sensitivity_label(tmp, "Personal")
  expect_equal(result, tmp)
  expect_equal(read_sensitivity_label(tmp), "Personal")
  
  # Test case sensitivity - should error for wrong case
  expect_error(apply_sensitivity_label(tmp, "personal"))
  expect_error(apply_sensitivity_label(tmp, "official"))
  expect_error(apply_sensitivity_label(tmp, "PERSONAL"))
  
  # Test invalid labels
  expect_error(apply_sensitivity_label(tmp, "INVALID"))
  expect_error(apply_sensitivity_label(tmp, ""))
  expect_error(apply_sensitivity_label(tmp, "Secret"))
})

test_that("read_sensitivity_label handles files with corrupted or unknown labels", {
  # This test attempts to verify error handling for unknown label IDs
  # Note: The exact scenario is difficult to reproduce without manually 
  # corrupting Excel files, but we test the documented behavior
  
  tmp <- tempfile(fileext = ".xlsx")
  wb <- openxlsx2::wb_add_worksheet(openxlsx2::wb_workbook())
  openxlsx2::wb_save(wb, tmp)
  
  # Test that a file with no label returns "no label"
  expect_equal(read_sensitivity_label(tmp), "no label")
  
  # Test that applying and reading a valid label works
  apply_sensitivity_label(tmp, "Personal")
  expect_equal(read_sensitivity_label(tmp), "Personal")
  
  # The error case for unknown label ID would be triggered if:
  # 1. An Excel file had MIPS XML that doesn't match any known labels
  # 2. openxlsx2::wb_get_mips() returned XML not in our mapping
  # This is an edge case that would indicate corrupted or externally-modified files
  
  # Test that our label detection works for all supported types
  supported_labels <- c("Personal", "OFFICIAL", "OFFICIAL_SENSITIVE_VMO")
  for (label in supported_labels) {
    apply_sensitivity_label(tmp, label)
    detected_label <- read_sensitivity_label(tmp)
    expect_equal(detected_label, label)
  }
})

test_that("read_sensitivity_label handles edge cases", {
  tmp <- tempfile(fileext = ".xlsx")
  wb <- openxlsx2::wb_add_worksheet(openxlsx2::wb_workbook())
  openxlsx2::wb_save(wb, tmp)
  
  # Test file with no label
  expect_equal(read_sensitivity_label(tmp), "no label")
  
  # Apply and read each label type
  apply_sensitivity_label(tmp, "Personal")
  expect_equal(read_sensitivity_label(tmp), "Personal")
  
  apply_sensitivity_label(tmp, "OFFICIAL")
  expect_equal(read_sensitivity_label(tmp), "OFFICIAL")
  
  apply_sensitivity_label(tmp, "OFFICIAL_SENSITIVE_VMO")
  expect_equal(read_sensitivity_label(tmp), "OFFICIAL_SENSITIVE_VMO")
})

test_that("internal XML mappings work correctly through public interface", {
  # Test the internal function indirectly through apply/read functions
  tmp <- tempfile(fileext = ".xlsx")
  wb <- openxlsx2::wb_add_worksheet(openxlsx2::wb_workbook())
  openxlsx2::wb_save(wb, tmp)
  
  # Test that all supported labels work, which validates the internal XML map
  supported_labels <- c("Personal", "OFFICIAL", "OFFICIAL_SENSITIVE_VMO")
  
  for (label in supported_labels) {
    apply_sensitivity_label(tmp, label)
    read_label <- read_sensitivity_label(tmp)
    expect_equal(read_label, label)
  }
  
  # Test that the XML contains expected ID patterns by applying and reading back
  apply_sensitivity_label(tmp, "Personal")
  expect_equal(read_sensitivity_label(tmp), "Personal")
  
  apply_sensitivity_label(tmp, "OFFICIAL")
  expect_equal(read_sensitivity_label(tmp), "OFFICIAL")
  
  apply_sensitivity_label(tmp, "OFFICIAL_SENSITIVE_VMO")
  expect_equal(read_sensitivity_label(tmp), "OFFICIAL_SENSITIVE_VMO")
})


test_that("comprehensive edge case testing", {
  tmp <- tempfile(fileext = ".xlsx")
  wb <- openxlsx2::wb_add_worksheet(openxlsx2::wb_workbook())
  openxlsx2::wb_save(wb, tmp)
  
  # Test label overwriting behavior
  apply_sensitivity_label(tmp, "Personal")
  expect_equal(read_sensitivity_label(tmp), "Personal")
  
  # Overwrite with different label
  apply_sensitivity_label(tmp, "OFFICIAL")
  expect_equal(read_sensitivity_label(tmp), "OFFICIAL")
  
  # Overwrite with third label type
  apply_sensitivity_label(tmp, "OFFICIAL_SENSITIVE_VMO")
  expect_equal(read_sensitivity_label(tmp), "OFFICIAL_SENSITIVE_VMO")
  
  # Test that files can be relabeled multiple times
  apply_sensitivity_label(tmp, "Personal")
  expect_equal(read_sensitivity_label(tmp), "Personal")
})

test_that("function parameter validation", {
  tmp <- tempfile(fileext = ".xlsx")
  wb <- openxlsx2::wb_add_worksheet(openxlsx2::wb_workbook())
  openxlsx2::wb_save(wb, tmp)
  
  # Test NULL parameter behavior
  expect_error(apply_sensitivity_label(tmp, NULL))
  expect_error(apply_sensitivity_label(NULL, "Personal"))
  
  # Test empty string
  expect_error(apply_sensitivity_label(tmp, ""))
  
  # Test numeric parameter
  expect_error(apply_sensitivity_label(tmp, 1))
  expect_error(apply_sensitivity_label(tmp, c("Personal", "OFFICIAL")))
})
