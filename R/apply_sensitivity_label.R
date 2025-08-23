#' @keywords internal
.get_sensitivity_xml_map <- function() {
  list(
    Personal = '<clbl:labelList xmlns:clbl="http://schemas.microsoft.com/office/2020/mipLabelMetadata"><clbl:label id="{9569d428-cde8-4093-8c72-538d9175bce5}" enabled="1" method="Privileged" siteId="{10efe0bd-a030-4bca-809c-b5e6745e499a}" contentBits="0" removed="0"/></clbl:labelList>',
    OFFICIAL = '<clbl:labelList xmlns:clbl="http://schemas.microsoft.com/office/2020/mipLabelMetadata"><clbl:label id="{b4199b9c-a89e-442f-9799-431511f14748}" enabled="1" method="Privileged" siteId="{10efe0bd-a030-4bca-809c-b5e6745e499a}" contentBits="0" removed="0"/></clbl:labelList>',
    OFFICIAL_SENSITIVE_VMO = '<clbl:labelList xmlns:clbl="http://schemas.microsoft.com/office/2020/mipLabelMetadata"><clbl:label id="{155b7326-c67d-4d6b-b15a-6628f0f8cfe7}" enabled="1" method="Privileged" siteId="{10efe0bd-a030-4bca-809c-b5e6745e499a}" contentBits="3" removed="0"/></clbl:labelList>'
  )
}

#' Read Sensitivity Label
#' @description Reads the sensitivity label from an Excel file using openxlsx2::wb_get_mips. Returns the label name, 'no label' if none is found, or errors if unexpected.
#'
#' @param file Path to the Excel file
#' @return The sensitivity label name, or 'no label' if none is found.
#' @export
read_sensitivity_label <- function(file) {
  # Parameter validation
  if (missing(file)) {
    cli::cli_abort("{.arg file} is missing with no default.")
  }
  
  if (is.null(file)) {
    cli::cli_abort("{.arg file} must not be {.val NULL}.")
  }
  
  if (!is.character(file) || length(file) != 1 || is.na(file) || file == "") {
    cli::cli_abort("{.arg file} must be a single non-empty character string.")
  }

  # Check file existence
  if (!file.exists(file)) {
    cli::cli_abort("File {.path {file}} does not exist.")
  }

  wb <- openxlsx2::wb_load(file)
  mips <- openxlsx2::wb_get_mips(wb)

  if (is.null(mips) || length(mips) == 0 || mips == "") {
    return("no label")
  }

  # Try to extract label name from XML
  xml_map <- .get_sensitivity_xml_map()
  label_name <- which(xml_map == mips) |> names()

  if (length(label_name) == 0) {
    cli::cli_abort("Unknown sensitivity label ID found in file {.path {file}}.")
  }

  return(label_name)
}


#' Apply Sensitivity Label
#' @description Applies a sensitivity label to an Excel file using openxlsx2 and built-in XML. Supported labels are 'Personal', 'OFFICIAL', and 'OFFICIAL_SENSITIVE_VMO' (visual markings only).
#'
#' The function loads the Excel file, applies the specified sensitivity label using the appropriate XML, and saves the modified file. If successful, it silently returns the file path.
#'
#' @param file Path to the Excel file
#' @param label Sensitivity label. One of: 'Personal', 'OFFICIAL', 'OFFICIAL_SENSITIVE_VMO'.
#' @return Silently returns the file path if successful.
#' @export
apply_sensitivity_label <- function(file, label) {
  # Parameter validation
  if (missing(file)) {
    cli::cli_abort("{.arg file} is missing with no default.")
  }
  
  if (missing(label)) {
    cli::cli_abort("{.arg label} is missing with no default.")
  }
  
  if (is.null(file)) {
    cli::cli_abort("{.arg file} must not be {.val NULL}.")
  }
  
  if (is.null(label)) {
    cli::cli_abort("{.arg label} must not be {.val NULL}.")
  }
  
  if (!is.character(file) || length(file) != 1 || is.na(file) || file == "") {
    cli::cli_abort("{.arg file} must be a single non-empty character string.")
  }
  
  if (!is.character(label) || length(label) != 1 || is.na(label)) {
    cli::cli_abort("{.arg label} must be a single character string.")
  }

  # Validate label against supported options
  valid_labels <- c("Personal", "OFFICIAL", "OFFICIAL_SENSITIVE_VMO")
  if (!label %in% valid_labels) {
    cli::cli_abort(
      "{.arg label} must be one of {.or {.val {valid_labels}}}, not {.val {label}}."
    )
  }

  # Check file existence
  if (!file.exists(file)) {
    cli::cli_abort("File {.path {file}} does not exist.")
  }

  # Load workbook and apply label
  wb <- openxlsx2::wb_load(file)
  xml_map <- .get_sensitivity_xml_map()
  xml <- xml_map[[label]]
  wb <- openxlsx2::wb_add_mips(wb, xml)
  openxlsx2::wb_save(wb, file)

  invisible(file)
}
