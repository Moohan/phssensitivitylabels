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
  wb <- openxlsx2::wb_load(file)

  mips <- openxlsx2::wb_get_mips(wb)

  if (is.null(mips) || length(mips) == 0 || mips == "") {
    return("no label")
  }

  # Try to extract label name from XML
  xml_map <- .get_sensitivity_xml_map()

  label_name <- which(xml_map == mips) |> names()

  if (length(label_name) == 0) {
    stop("Unknown sensitivity label ID found.")
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
  match.arg(label, c("Personal", "OFFICIAL", "OFFICIAL_SENSITIVE_VMO"), several.ok = FALSE)

  if (!file.exists(file)) {
    stop("File does not exist: ", file)
  }

  wb <- openxlsx2::wb_load(file)

  # Real XML for each label
  xml_map <- .get_sensitivity_xml_map()

  if (!label %in% names(xml_map)) {
    stop("Invalid sensitivity label.")
  }

  xml <- xml_map[[label]]

  wb <- openxlsx2::wb_add_mips(wb, xml)

  openxlsx2::wb_save(wb, file)

  invisible(file)
}
