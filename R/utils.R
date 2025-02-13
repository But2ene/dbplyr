deparse_trunc <- function(x, width = getOption("width")) {
  text <- deparse(x, width.cutoff = width)
  if (length(text) == 1 && nchar(text) < width) return(text)

  paste0(substr(text[1], 1, width - 3), "...")
}

is.wholenumber <- function(x) {
  trunc(x) == x
}

deparse_all <- function(x) {
  x <- purrr::map_if(x, is_formula, f_rhs)
  purrr::map_chr(x, expr_text, width = 500L)
}

#' Provides comma-separated string out of the parameters
#' @export
#' @keywords internal
#' @param ... Arguments to be constructed into the string
named_commas <- function(...) {
  x <- unlist(purrr::map(list2(...), as.character))
  if (is_null(names(x))) {
    paste0(x, collapse = ", ")
  } else {
    paste0(names(x), " = ", x, collapse = ", ")
  }
}

commas <- function(...) paste0(..., collapse = ", ")

in_travis <- function() identical(Sys.getenv("TRAVIS"), "true")

unique_table_name <- function() {
  # Needs to use option to unique names across reloads while testing
  i <- getOption("dbplyr_table_name", 0) + 1
  options(dbplyr_table_name = i)
  sprintf("dbplyr_%03i", i)
}
unique_subquery_name <- function() {
  # Needs to use option so can reset at the start of each query
  i <- getOption("dbplyr_subquery_name", 0) + 1
  options(dbplyr_subquery_name = i)
  sprintf("q%02i", i)
}
unique_subquery_name_reset <- function() {
  options(dbplyr_subquery_name = 0)
}

succeeds <- function(x, quiet = FALSE) {
  tryCatch(
    {
      x
      TRUE
    },
    error = function(e) {
      if (!quiet)
        message("Error: ", e$message) # nocov
      FALSE
    }
  )
}

c_character <- function(...) {
  x <- c(...)
  if (length(x) == 0) {
    return(character())
  }

  if (!is.character(x)) {
    cli_abort("Character input expected")
  }

  x
}

cat_line <- function(...) cat(paste0(..., "\n"), sep = "")

# nocov start
res_warn_incomplete <- function(res, hint = "n = -1") {
  if (dbHasCompleted(res)) return()

  rows <- big_mark(dbGetRowCount(res))
  cli::cli_warn("Only first {rows} results retrieved. Use {hint} to retrieve all.")
}

hash_temp <- function(name) {
  name <- ident(paste0("#", name))
  cli::cli_inform(
    paste0("Created a temporary table named ", name),
    class = c("dbplyr_message_temp_table", "dbplyr_message")
  )
  name
}
# nocov end

# Helper for testing
local_methods <- function(..., .frame = caller_env()) {
  local_bindings(..., .env = global_env(), .frame = .frame)
}

check_list <- function(x, ..., allow_null = FALSE, arg = caller_arg(x), call = caller_env()) {
  if (vctrs::vec_is_list(x)) {
    return()
  }
  stop_input_type(
    x,
    c("a list"),
    ...,
    allow_na = FALSE,
    allow_null = allow_null,
    arg = arg,
    call = call
  )
}

check_lazy_query <- function(x, ..., arg = caller_arg(x), call = caller_env()) {
  if (!inherits(x, "lazy_query")) {
    stop_input_type(
      x,
      what = "a lazy query",
      ...,
      arg = arg,
      call = call
    )
  }
}

check_con <- function(con, ..., arg = caller_arg(con), call = caller_env()) {
  if (is.null(con)) {
    cli_abort("{.arg {arg}} must not be NULL.", call = call)
  }
}

check_unsupported_arg <- function(x,
                                  allowed = NULL,
                                  ...,
                                  backend = NULL,
                                  arg = caller_arg(x),
                                  call = caller_env()) {
  if (is_missing(x)) {
    return()
  }

  if (identical(x, allowed)) {
    return()
  }

  if (is_null(allowed)) {
    msg <- "Argument {.arg {arg}} isn't supported"
  } else {
    msg <- "{.code {arg} = {.val {x}}} isn't supported"
  }

  if (is.null(backend)) {
    msg <- paste0(msg, " on database backends.")
  } else {
    msg <- paste0(msg, " in {backend} translation.")
  }

  if (!is_null(allowed)) {
    msg <- c(
      msg,
      i = "It must be {.val {allowed}} instead."
    )
  }
  cli_abort(msg, call = call)
}

stop_unsupported_function <- function(f, ..., with = NULL, call = caller_env()) {
  cli_abort(c(
    "{.fun {f}} is not supported on database backends.",
    i = if (!is_null(with)) "Please use {.fun {with}} instead."
  ), call = call)
}

check_named <- function(x, ..., arg = caller_arg(x), call = caller_env()) {
  if (!is_named2(x)) {
    cli_abort("All elements of {.arg {arg}} must be named.", call = call)
  }

  if (vctrs::vec_duplicate_any(names2(x))) {
    cli_abort("The names of {.arg {arg}} must be unique.", call = call)
  }
}
