#' @keywords internal
.get_sensitivity_xml_map <- function() {
  list(
    Personal = '<clbl:labelList xmlns:clbl="http://schemas.microsoft.com/office/2020/mipLabelMetadata"><clbl:label id="{9569d428-cde8-4093-8c72-538d9175bce5}" enabled="1" method="Privileged" siteId="{10efe0bd-a030-4bca-809c-b5e6745e499a}" contentBits="0" removed="0"/></clbl:labelList>',
    OFFICIAL = '<clbl:labelList xmlns:clbl="http://schemas.microsoft.com/office/2020/mipLabelMetadata"><clbl:label id="{b4199b9c-a89e-442f-9799-431511f14748}" enabled="1" method="Privileged" siteId="{10efe0bd-a030-4bca-809c-b5e6745e499a}" contentBits="0" removed="0"/></clbl:labelList>',
    OFFICIAL_SENSITIVE_VMO = '<clbl:labelList xmlns:clbl="http://schemas.microsoft.com/office/2020/mipLabelMetadata"><clbl:label id="{155b7326-c67d-4d6b-b15a-6628f0f8cfe7}" enabled="1" method="Privileged" siteId="{10efe0bd-a030-4bca-809c-b5e6745e499a}" contentBits="3" removed="0"/></clbl:labelList>'
  )
}

#' Read Sensitivity Label
#' @description Reads the sensitivity label from an Excel or Word doc file. Returns the label name, 'no label' if none is found, or errors if unexpected.
#'
#' @param file Path to the Excel or Word file (.xlsx, .xls or .docx)
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

  # Check file is valid
  file_ext <- tolower(tools::file_ext(file))
  if (!file_ext %in% c("xlsx", "xls", "docx")) {
    cli::cli_abort("{.arg file} must be an Excel workbook or Word document with {.val .xlsx}, {.val .xls} or {.val .docx} extension, not {.val .{file_ext}}.")
  }

  ## Extracting label within Excel workbooks ----

  if(file_ext %in% c("xlsx", "xls")){

    wb <- openxlsx2::wb_load(file)
    mips <- openxlsx2::wb_get_mips(wb)

  }

  ## Extracting label within Word docs ----

  if(file_ext == "docx"){

    mips <- openxlsx2::read_xml(unzip(file,'docMetadata/LabelInfo.xml'))

  }

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
#' @description Applies a sensitivity label to files using openxlsx2 and built-in XML. Supported labels are 'Personal', 'OFFICIAL', and 'OFFICIAL_SENSITIVE_VMO' (visual markings only).
#'
#' The function loads the Excel file, applies the specified sensitivity label using the appropriate XML, and saves the modified file. If successful, it silently returns the file path.
#'
#' @param file Path to the Excel or Word file (.xlsx, .xls, or .docs)
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

  if (!is.character(label) || length(label) != 1 || is.na(label) || label == "") {
    cli::cli_abort("{.arg label} must be a single non-empty character string.")
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

  # Check file is valid
  file_ext <- tolower(tools::file_ext(file))
  if (!file_ext %in% c("xlsx", "xls", "docx")) {
    cli::cli_abort("{.arg file} must be an Excel workbook or Word document with {.val .xlsx}, {.val .xls} or {.val .docx} extension, not {.val .{file_ext}}.")
  }



  ## Apply label to Excel workbooks ----

  if(file_ext %in% c("xlsx", "xls")){

    wb <- openxlsx2::wb_load(file)
    xml_map <- .get_sensitivity_xml_map()
    xml <- xml_map[[label]]
    wb <- openxlsx2::wb_add_mips(wb, xml)
    openxlsx2::wb_save(wb, file)

  }

  ## Apply label to Word docs ----

  if(file_ext == "docx"){

    # Parsing input
    file_path <- dirname(path)
    file_name <- basename(path)
    file_type <- tools::file_ext(path)
    # Removing file type from actual name
    file_name <- sub(paste0(".", file_type), "", file_name)

    # Zipping process needs its own directory
    # We'll reset it using on.exit later
    current_wd <- getwd()

    zipdir <- paste0(file_path, "/", file_name)

    # Create the dir using that name
    dir.create(zipdir)

    # Unzip the file into the dir
    unzip(x, exdir= zipdir)

    xml_map <- .get_sensitivity_xml_map()
    xml <- xml_map[[label]]

    # Create the dir using that name
    dir.create(paste0(zipdir, "/docMetadata"))

    # Write the XML data to the temp directory
    write_xml(xml, paste0(zipdir, "/docMetadata/LabelInfo.xml"), useBytes = TRUE)

    # Update content file with new child node
    openxlsx2:::write_file(
      head = "",
      body = xml_add_child(
        xml_node = paste0(zipdir, "/[Content_Types].xml"),
        xml_child = '<Override PartName="/docMetadata/LabelInfo.xml" ContentType="application/vnd.ms-office.classificationlabels+xml"/>'
      ),
      tail = "",
      fl = paste0(zipdir, "/[Content_Types].xml")
    )

    # Update .rels file with new child node
    openxlsx2:::write_file(
      head = "",
      body = xml_add_child(
        xml_node = paste0(zipdir, "/_rels/.rels"),
        xml_child = '<Relationship Id="rId6" Type="http://schemas.microsoft.com/office/2020/02/relationships/classificationlabels" Target="docProps/custom.xml" />'
      ),
      tail = "",
      fl = paste0(zipdir, "/_rels/.rels")
    )

    # Delete original file
    file.remove(x)

    newzip <- paste0(file_path, "/", file_name, ".zip")
    file.create(newzip)

    setwd(zipdir) # Setting new base directory to avoid needless recursion in file zipping
    # will be reset on.exit() anyway so don't change.

    suppressWarnings(
      zip::zip(zipfile = newzip,
               files = list.files(zipdir, all.files = TRUE, full.names = FALSE, recursive = TRUE, include.dirs = TRUE),
               recurse = FALSE,
               include_directories = FALSE,
               root = ".") # end of zip()
    ) # End of suppressWarnings

    # Delete un-zipped files
    file.remove(zipdir)

    # Re-naming file
    file.rename(from = newzip,
                to = file)

    # Keep this as last-evaluated function - keeps files stable
    on.exit(setwd(current_wd))

  }


  invisible(file)
}
