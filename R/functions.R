# Copyright 2022-2023 Integrated Ecological Research and Poisson Consulting Ltd.
# Copyright 2024 Province of Alberta
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

plot_survival_data <- function(data) {
  chk::check_data(
    data,
    list(
      Month = c(1L, NA_integer_),
      CaribouMonth = c(1L, NA_integer_),
      CaribouYear = c("", NA_character_),
      StartTotal = c(1L, NA_integer_),
      MortalitiesCertain = c(1L, NA_integer_),
      MortalitiesUncertain = c(1L, NA_integer_)
    )
  )

  data <- data |>
    tidyr::drop_na()

  data$Month <- as.factor(data$Month)
  data$Alive <- data$StartTotal - data$MortalitiesCertain - data$MortalitiesUncertain

  data <- tidyr::pivot_longer(
    data,
    cols = c("MortalitiesCertain", "MortalitiesUncertain", "Alive"),
    values_to = "Count"
  )

  data$name <- factor(
    data$name,
    levels = c("MortalitiesCertain", "MortalitiesUncertain", "Alive")
  )

  gp <- ggplot(data) +
    geom_col(aes(
      x = forcats::fct_reorder(.data$Month, .data$CaribouMonth, min),
      y = .data$Count,
      fill = .data$name
    )) +
    facet_wrap(~PopulationName + CaribouYear) +
    theme_bw() +
    scale_y_continuous(
      breaks = scales::breaks_pretty(),
      expand = expansion(mult = 0, add = c(0, 1))
    ) +
    scale_x_discrete(
      "Month",
      labels = substr(month.name[c(2, 4, 6, 8, 10, 12)], 1, 3),
      breaks = c("2", "4", "6", "8", "10", "12"),
      expand = expansion(mult = 0, add = 0.2)
    ) +
    scale_fill_manual(
      "",
      values = c(
        "MortalitiesCertain" = "#D55E00",
        "MortalitiesUncertain" = "#7D7D7D",
        "Alive" = "#009E73"
      )
    ) +
    theme(
      axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)
    )
  gp
}

plot_recruitment_data <- function(data) {
  data$Date <- paste(data$Year, data$Month, data$Day, sep = "-")

  data_count <- data |>
    dplyr::select(
      -"Bulls", -"UnknownAdults", -"Yearlings", -"Year",
      -"Month", -"Day"
    ) |>
    dplyr::group_by(.data$Date) |>
    dplyr::summarise(
      Cows = sum(.data$Cows),
      Calves = sum(.data$Calves)
    ) |>
    tidyr::pivot_longer(cols = c("Cows", "Calves"), values_to = "Count")

  data_count$name <- factor(
    data_count$name,
    levels = c("Cows", "Calves")
  )

  data <- data |>
    dplyr::select(
      "Date", "Month", "Day", "CaribouYear", "CaribouMonth"
    ) |>
    dplyr::distinct()

  data_count <- data_count |>
    dplyr::left_join(data, by = c("Date")) |>
    dplyr::arrange(.data$CaribouYear, .data$CaribouMonth, .data$Day) |>
    dplyr::mutate(
      plot_order = seq_len(dplyr::n())
    )

  gp <- ggplot(data_count) +
    geom_col(
      aes(
        x = forcats::fct_reorder(.data$Date, .data$plot_order, min),
        y = .data$Count,
        fill = .data$name
      ),
      position = "dodge"
    ) +
    facet_wrap(~ .data$PopulationName + .data$CaribouYear, scales = "free_x") +
    scale_y_continuous(
      breaks = c(0, 40, 80, 120),
    ) +
    scale_x_discrete(
      ""
    ) +
    scale_fill_manual(
      "",
      values = c(
        "Cows" = "#D55E00",
        "Calves" = "#009E73"
      )
    ) +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))

  gp
}

#### Table Functions ####

DT_options <- function(data) {
  if (!is.data.frame(data)) {
    return()
  }
  DT::datatable(
    data,
    escape = FALSE,
    rownames = FALSE,
    class = "cell-border compact",
    options = list(
      ordering = TRUE,
      autowidth = TRUE,
      scrollX = TRUE,
      columnDefs = list(list(
        className = "dt-center",
        targets = "_all"
      ))
    )
  )
}

#### Display ####

toast_info <- function(messages) {
  bs4Dash::toast(
    title = "Info",
    body = paste(messages, collapse = "<br>"),
    options = list(
      autohide = FALSE,
      position = "topRight",
      close = TRUE,
      class = "bg-info bbou-toast"
    )
  )
}

toast_error <- function(check, title = "Please fix the following issue") {
  msg <- gsub("^Error [^:]*\\) : \n  ", "", check[1])
  msg <- gsub("Error : ", "", msg)
  bs4Dash::toast(
    title = title,
    body = paste(msg),
    options = list(
      autohide = FALSE,
      icon = "fas fa-exclamation-triangle",
      position = "topRight",
      close = TRUE,
      class = "bg-danger bbou-toast"
    )
  )
}

toast_warning <- function(msg, title = "Warning") {
  bs4Dash::toast(
    title = title,
    body = msg,
    options = list(
      autohide = FALSE,
      icon = "fas fa-exclamation-circle",
      position = "topRight",
      close = TRUE,
      class = "bg-warning bbou-toast"
    )
  )
}

toast_missing_data <- function() {
  toast_warning(
    "Please upload data or use the demo data.",
    title = "Missing data"
  )
}

catch_output_and_messages <- function(expr) {
  res <- NULL
  msgs <- c()
  err <- function(e) {
    e <- e[[1]]
    return(e)
  }
  res <- tryCatch(
    expr = {
      withCallingHandlers(
        expr = expr,
        message = function(m) {
          msg <- gsub("\n", "", m[[1]])
          msg <- cli::ansi_strip(msg)
          msg <- gsub("[\u2139\u26A0\u2716\u2714\u2022\u25CF]\\s*", "", msg)
          msg <- trimws(msg)
          msgs <<- c(msgs, msg)
          msgs
        }
      )
    },
    error = err
  )
  msgs <- msgs[!grepl("^Registered S3 method", msgs)]
  if (length(msgs) == 0) msgs <- NULL
  return(list(result = res, messages = msgs))
}

#### Check Functions ####

is_try_error <- function(x) inherits(x, "try-error")


check_file_type <- function(x, ext = "csv") {
  if (is.null(x)) {
    chk::abort_chk("Please upload a file.")
  }
  if (!any(grep(ext, x$name))) {
    ext <- paste0(ext, collapse = " or ")
    chk::abort_chk(
      paste(
        "We're not sure what to do with that file type.
        Please upload a", ext
      )
    )
  }
  invisible(x$name)
}

check_col_names <- function(template, upload_data) {
  template_colnames <- colnames(template)
  data_colnames <- colnames(upload_data)

  if (!chk::vld_identical(template_colnames, data_colnames)) {
    chk::abort_chk("The column names in the uploaded file do not match the
                   column names from the template.")
  }
}

safe_as_integer <- function(x, name) {
  bad <- unique(x[!is.na(x) & suppressWarnings(is.na(as.integer(x)))])
  if (length(bad) > 0) {
    chk::abort_chk(paste0(
      "The following value(s) in column '", name,
      "' should be a integer: ", chk::cc(bad, " and ")
    ))
  }
  as.integer(x)
}

check_survival_col_types <- function(data) {
  integer_cols <- c(
    "Year", "Month", "StartTotal", "MortalitiesCertain",
    "MortalitiesUncertain"
  )
  char_cols <- c("PopulationName")

  for (i in integer_cols) {
    data[[i]] <- safe_as_integer(data[[i]], i)
  }

  for (i in char_cols) {
    data[[i]] <- as.character(data[[i]])
  }

  data
}

check_recruitment_col_types <- function(data) {
  integer_cols <- c(
    "Year", "Month", "Day", "Cows", "Bulls", "UnknownAdults",
    "Yearlings", "Calves"
  )
  char_cols <- c("PopulationName")

  for (i in integer_cols) {
    data[[i]] <- safe_as_integer(data[[i]], i)
  }

  for (i in char_cols) {
    data[[i]] <- as.character(data[[i]])
  }

  data
}

check_data_not_empty <- function(data) {
  if (nrow(data) == 0) {
    chk::abort_chk("The file uploaded is empty, please fill in the template")
  }
}

check_data_year <- function(data) {
  if (!chk::vld_range(nchar(data$Year), c(4, 4))) {
    chk::abort_chk("The Year column must have years formatted as a 4 digit year (ex. 2023)")
  }
  data
}

check_data_month <- function(data) {
  if (!all(data$Month %in% c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, NA_integer_))) {
    chk::abort_chk("The Month column can only contain values from 1 to 12")
  }
  data
}

#### Bboutool wrappers ####

fit_recruitment_estimate <- function(data, adult_female_ratio,
                                     calf_female_ratio, year_trend,
                                     year_start, nthin,
                                     priors = NULL,
                                     allow_missing = FALSE) {
  chk::chk_data(data)
  chk::chk_vector(nthin)

  for (n in nthin) {
    incProgress(1 / 4, detail = paste("Trying nthin = ", n))
    fit <- catch_output_and_messages(
      bboutools::bb_fit_recruitment(
        data = data,
        nthin = n,
        adult_female_proportion = adult_female_ratio,
        sex_ratio = calf_female_ratio,
        year_trend = year_trend,
        year_start = year_start,
        priors = priors,
        allow_missing = allow_missing
      )
    )

    if (!chk::vld_is(fit[[1]], "bboufit")) {
      toast_error(fit[[1]], title = "Model error")
      fit <- NULL
      return(fit)
    }

    convergence <- bboutools::glance(fit[[1]])$converged

    if (convergence) {
      incProgress(1)
      return(fit)
    }
  }
  toast_warning(
    paste(
      "The model did not reach convergence after trying several thinning",
      "values with the highest value being nthin =", n, ". The data set exceeds",
      "the capacity of the default settings in the bboushiny app. Please use",
      "the bboutools package to analyse the data. Check out the About tab for",
      "more info on the models."
    ),
    title = "Model did not converge"
  )
}

fit_survival_estimate <- function(data, year_trend, include_uncertain_morts,
                                  year_start, nthin,
                                  priors = NULL,
                                  allow_missing = FALSE) {
  chk::chk_data(data)
  chk::chk_vector(nthin)

  for (n in nthin) {
    incProgress(1 / 4, detail = paste("Trying nthin = ", n))
    fit <- catch_output_and_messages(
      bboutools::bb_fit_survival(
        data = data,
        year_trend = year_trend,
        include_uncertain_morts = include_uncertain_morts,
        year_start = year_start,
        nthin = n,
        priors = priors,
        allow_missing = allow_missing
      )
    )

    if (!chk::vld_is(fit[[1]], "bboufit")) {
      toast_error(fit[[1]], title = "Model error")
      fit <- NULL
      return(fit)
    }

    convergence <- bboutools::glance(fit[[1]])$converged

    if (convergence) {
      incProgress(1)
      return(fit)
    }
  }
  toast_warning(
    paste(
      "The model did not reach convergence after trying several thinning",
      "values with the highest value being nthin =", n, ". The data set exceeds",
      "the capacity of the default settings in the bboushiny app. Please use",
      "the bboutools package to analyse the data. Check out the About tab for",
      "more info on the models."
    ),
    title = "Model did not converge"
  )
}

#### Other ####
month_to_numeric <- function(month) {
  if (is.null(month)) {
    return(NULL)
  }
  num_month <- c(
    January = 1L, February = 2L, March = 3L, April = 4L, May = 5L, June = 6L,
    July = 7L, August = 8L, September = 9L, October = 10L, November = 11L,
    December = 12L
  )
  num_month[[month]]
}

add_caribou_year <- function(data, start_month) {
  chk::chk_whole_number(start_month)
  chk::chk_range(start_month, c(1, 12))
  chk::chk_data(data)

  if (start_month == 1) {
    data <-
      data |>
      dplyr::mutate(
        Month = as.integer(.data$Month),
        CaribouMonth = as.integer(data$Month),
        CaribouYear = as.character(data$Year)
      )
  } else {
    data <-
      data |>
      dplyr::mutate(
        Month = as.integer(.data$Month),
        CaribouMonth = dplyr::if_else(
          start_month <= .data$Month,
          .data$Month - start_month + 1L,
          .data$Month - start_month + 1L + 12L
        ),
        CaribouMonth = as.integer(.data$CaribouMonth),
        CaribouYear = ifelse(
          start_month <= .data$Month,
          paste(data$Year, data$Year + 1L, sep = "-"),
          paste(data$Year - 1L, data$Year, sep = "-")
        )
      )
  }
  data
}
