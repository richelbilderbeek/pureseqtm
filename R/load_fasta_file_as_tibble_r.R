#' Parse a FASTA file to a table
#' with a \code{name} and \code{sequence} column
#' @inheritParams default_params_doc
#' @return a \link[tibble]{tibble}
#'   with a \code{name} and \code{sequence} column
#' @export
load_fasta_file_as_tibble_r <- function(fasta_filename) {
  text <- readr::read_lines(fasta_filename)
  if (length(text) == 0) {
    return(
      tibble::tibble(
        name = character(0),
        sequence = character(0)
      )
    )
  }
  t <- tibble::tibble(
    name = stringr::str_sub(
      stringr::str_subset(text, "^>.*"),
      start = 2
    ),
    sequence = NA
  )
  n_lines <- length(text)

  table_index <- 1
  line_index <- 1
  state <- "need_name"
  sequence <- NA

  while (line_index <= n_lines) {
    line <- text[line_index]
    line_index <- line_index + 1
    if (state == "need_name") {
      testthat::expect_equal(">", stringr::str_sub(line, 1, 1))
      sequence <- "" # Reset
      state <- "need_sequence"
      next
    } else if (state == "need_sequence") {
      testthat::expect_false(stringr::str_sub(line, 1, 1) == ">")
      testthat::expect_false(is.na(sequence))
      testthat::expect_equal("", sequence)
      sequence <- line
      state <- "reading_sequence"
    } else {
      testthat::expect_true(state == "reading_sequence")
      if (">" == stringr::str_sub(line, 1, 1)) {
        # Found a new gene
        t$sequence[table_index] <- sequence
        sequence <- ""
        table_index <- table_index + 1
        state <- "need_sequence"
      } else {
        # Add to sequence
        sequence <- paste0(sequence, line)
      }
    }
  }
  t$sequence[table_index] <- sequence
  t
}
