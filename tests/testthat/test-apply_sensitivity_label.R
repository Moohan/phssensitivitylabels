library(testthat)
library(phssensitivitylabels)

test_that("apply_sensitivity_label returns file path and applies label", {
  # Create a temp Excel file
  tmp <- tempfile(fileext = ".xlsx")
  wb <- openxlsx2::wb_add_worksheet()
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
  wb <- openxlsx2::wb_add_worksheet()
  openxlsx2::wb_save(wb, tmp)
  expect_equal(read_sensitivity_label(tmp), "no label")
})

test_that("apply_sensitivity_label errors for invalid label", {
  tmp <- tempfile(fileext = ".xlsx")
  wb <- openxlsx2::wb_add_worksheet()
  openxlsx2::wb_save(wb, tmp)
  expect_error(apply_sensitivity_label(tmp, "INVALID"))
})
