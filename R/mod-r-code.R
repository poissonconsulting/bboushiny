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

mod_r_code_ui <- function(id, label = "r code") {
  ns <- NS(id)

  mainPanel(
    width = 12,
    p(
      "Copy and paste the code to an R script to reproduce what the app is doing.
      The code will be written as you use the app.
      For example, after the Estimate Recruitment button is clicked the
      code to generate the recruitment estimate will be written below."
    ),
    box(
      width = 12,
      collapsible = FALSE,
      uiOutput(ns("code_head")),
      uiOutput(ns("lib_readr")),
      uiOutput(ns("lib_readxl")),
      uiOutput(ns("lib_bboudata")),
      uiOutput(ns("survival_data")),
      uiOutput(ns("survival_select_pop")),
      uiOutput(ns("survival_model")),
      uiOutput(ns("survival_result")),
      uiOutput(ns("recruitment_data")),
      uiOutput(ns("recruitment_model")),
      uiOutput(ns("recruitment_select_pop")),
      uiOutput(ns("recruitment_result")),
      uiOutput(ns("population_growth"))
    )
  )
}

mod_r_code_server <- function(id, survival, recruitment, population_growth) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    rv <- reactiveValues(
      readr_survival = FALSE,
      readr_recruitment = FALSE,
      readxl_survival = FALSE,
      readxl_recruitment = FALSE,
      bboudata_survival = FALSE,
      bboudata_recruitment = FALSE,
    )

    output$code_head <- renderUI({
      l1 <- '# install.packages("bboutools")'
      l2 <- "library(bboutools)"

      HTML(paste(l1, l2, sep = "<br/>"))
    })

    output$lib_readr <- renderUI({
      if (rv$readr_survival | rv$readr_recruitment) {
        l1 <- "library(readr)"
        HTML(paste(l1, sep = "<br/>"))
      }
    })

    output$lib_readxl <- renderUI({
      if (rv$readxl_survival | rv$readxl_recruitment) {
        l1 <- "library(readxl)"
        HTML(paste(l1, sep = "<br/>"))
      }
    })

    output$lib_bboudata <- renderUI({
      if (rv$bboudata_survival | rv$bboudata_recruitment) {
        l1 <- "library(bboudata)"
        HTML(paste(l1, sep = "<br/>"))
      }
    })

    observeEvent(survival$data,
      {
        rv$readr_survival <- FALSE
        rv$readxl_survival <- FALSE
        rv$bboudata_survival <- FALSE
      },
      label = "clears pkg associated with getting survival data when data in survival tab changes"
    )

    observeEvent(recruitment$data,
      {
        rv$readr_recruitment <- FALSE
        rv$readxl_recruitment <- FALSE
        rv$bboudata_recruitment <- FALSE
      },
      label = "clears pkg associated with getting recruitment data when data in recruitment tab changes"
    )

    output$survival_data <- renderUI({
      if (survival$data_type == "upload" & grepl("\\.csv", survival$upload_file)) {
        l1 <- ""
        l2 <- paste0("data_survival <- read_csv(file = '", survival$upload_file, "')")
        rv$readr_survival <- TRUE
      }

      if (survival$data_type == "upload" & grepl("\\.xlsx", survival$upload_file)) {
        l1 <- ""
        l2 <- paste0("data_survival <- read_excel(file = '", survival$upload_file, "')")
        rv$readxl_survival <- TRUE
      }

      if (survival$data_type == "demo") {
        l1 <- ""
        l2 <- paste0("data_survival <- bbousurv_a")
        rv$bboudata_survival <- TRUE
      }

      if (!isFALSE(survival$data_type)) {
        HTML(paste(l1, l2, sep = "<br/>"))
      }
    })

    output$survival_select_pop <- renderUI({
      if (survival$data_type == "upload") {
        l1 <- paste0(
          "data_survival <- data_survival[data_survival$PopulationName == '",
          survival$select_population,
          "', ]"
        )
        HTML(paste(l1, sep = "<br/>"))
      }
    })

    output$survival_model <- renderUI({
      req(survival$results)

      if (survival$model) {
        l0 <- ""

        l1 <- "fit_survival <- bb_fit_survival("

        l2 <- "&nbsp data = data_survival,"

        if (survival$include_trend) {
          l3 <- "&nbsp year_trend = TRUE,"
        } else {
          l3 <- NULL
        }

        if (survival$include_uncertain_morts) {
          l4 <- "&nbsp include_uncertain_morts = TRUE,"
        } else {
          l4 <- NULL
        }

        l5 <- paste0("&nbsp year_start = ", survival$start_month_num, ",")

        l6 <- paste0(
          "&nbsp nthin = ",
          survival$results_dl_list_year$glance_survival$nthin
        )

        l7 <- ")"
      }

      if (survival$model) {
        text <- paste(l0, l1, l2, l3, l4, l5, l6, l7, sep = "<br/>")
        text <- gsub("(<br/>){2,}", "<br/>", text)
        HTML(text)
      }
    })

    output$survival_result <- renderUI({
      req(survival$results)

      l0 <- ""

      l1 <- "glance(fit_survival)"

      l2 <- "coef(fit_survival)<br/>"

      l3 <- " "

      l4 <- "bb_predict_survival(fit_survival, year = TRUE)"

      l5 <- "bb_plot_year_survival(fit_survival)"

      l6 <- " "

      l7 <- "bb_predict_survival(fit_survival, year = FALSE, month = TRUE)"

      l8 <- "bb_plot_month_survival(fit_survival)"

      if (survival$include_trend) {
        l9 <- "bb_predict_survival_trend(fit_survival)<br/>bb_plot_year_trend_survival(fit_survival)"
      } else {
        l9 <- NULL
      }

      text <- paste(l0, l1, l2, l3, l4, l5, l6, l7, l8, l9, sep = "<br/>")
      text <- gsub("(<br/>){2,}", "<br/>", text)
      HTML(text)
    })


    output$recruitment_data <- renderUI({
      if (recruitment$data_type == "upload" & grepl("\\.csv", recruitment$upload_file)) {
        l1 <- ""
        l2 <- paste0("data_recruitment <- read_csv(file = '", recruitment$upload_file, "')")
        rv$readr_recruitment <- TRUE
      }

      if (recruitment$data_type == "upload" & grepl("\\.xlsx", recruitment$upload_file)) {
        l1 <- ""
        l2 <- paste0("data_recruitment <- read_excel(file = '", recruitment$upload_file, "')")
        rv$readxl_recruitment <- TRUE
      }

      if (recruitment$data_type == "demo") {
        l1 <- ""
        l2 <- paste0("data_recruitment <- bbourecruit_a")
        rv$bboudata_recruitment <- TRUE
      }

      if (!isFALSE(recruitment$data_type)) {
        HTML(paste(l1, l2, sep = "<br/>"))
      }
    })

    output$recruitment_select_pop <- renderUI({
      if (recruitment$data_type == "upload") {
        l1 <- paste0(
          "data_recruitment <- data_recruitment[data_recruitment$PopulationName == '",
          recruitment$select_population,
          "', ]"
        )
        HTML(paste(l1, sep = "<br/>"))
      }
    })

    output$recruitment_model <- renderUI({
      req(recruitment$results)

      if (recruitment$model) {
        l0 <- ""

        l1 <- "fit_recruitment <- bb_fit_recruitment("

        l2 <- "&nbsp data = data_recruitment,"

        if (is.na(recruitment$adult_sex_ratio)) {
          l3 <- paste0("&nbsp adult_female_proportion = ", "NULL", ",")
        } else {
          if (recruitment$adult_sex_ratio) {
            l3 <- paste0("&nbsp adult_female_proportion = ", recruitment$adult_sex_ratio, ",")
          } else {
            l3 <- NULL
          }
        }

        if (recruitment$calf_female_ratio) {
          l4 <- paste0("&nbsp sex_ratio = ", recruitment$calf_female_ratio, ",")
        } else {
          l4 <- NULL
        }

        if (recruitment$include_trend) {
          l5 <- "&nbsp year_trend = TRUE,"
        } else {
          l5 <- NULL
        }

        l6 <- paste0("&nbsp year_start = ", survival$start_month_num, ",")

        l7 <- paste0(
          "&nbsp nthin = ",
          recruitment$results_dl_list_year$glance_recruitment$nthin
        )

        l8 <- ")"
      }

      if (recruitment$model) {
        text <- paste(l0, l1, l2, l3, l4, l5, l6, l7, l8, sep = "<br/>")
        text <- gsub("(<br/>){2,}", "<br/>", text)
        HTML(text)
      }
    })

    output$recruitment_result <- renderUI({
      req(recruitment$results)

      l0 <- ""

      l1 <- "glance(fit_recruitment)"

      l2 <- "coef(fit_recruitment)<br/>"

      l3 <- " "

      if (recruitment$recruitment_type == "recruitment_adjusted") {
        l4 <- paste0("bb_predict_recruitment(fit_recruitment, sex_ratio = ", recruitment$calf_female_ratio, ")")
        l5 <- paste0("bb_plot_year_recruitment(fit_recruitment, sex_ratio = ", recruitment$calf_female_ratio, ")")
      } else {
        l4 <- "bb_predict_calf_cow_ratio(fit_recruitment)"
        l5 <- "bb_plot_year_calf_cow_ratio(fit_recruitment)"
      }

      l6 <- " "

      if (recruitment$include_trend) {
        if (recruitment$recruitment_type == "recruitment_adjusted") {
          l7 <- paste0(
            "bb_predict_recruitment_trend(fit_recruitment, sex_ratio = ", recruitment$calf_female_ratio, ")",
            "<br/>bb_plot_year_trend_recruitment(fit_recruitment, sex_ratio = ", recruitment$calf_female_ratio, ")"
          )
        } else {
          l7 <- "bb_predict_calf_cow_ratio_trend(fit_recruitment)<br/>bb_plot_year_trend_calf_cow_ratio(fit_recruitment)"
        }
      } else {
        l7 <- NULL
      }

      text <- paste(l0, l1, l2, l3, l4, l5, l6, l7, sep = "<br/>")
      text <- gsub("(<br/>){2,}", "<br/>", text)
      HTML(text)
    })

    output$population_growth <- renderUI({
      req(population_growth$results_pop_change)

      l1 <- paste0("lambda <- bb_predict_growth(fit_survival, fit_recruitment, sex_ratio = ", recruitment$calf_female_ratio, ")")

      l2 <- "bb_plot_year_growth(lambda)"

      l3 <- " "

      l4 <- paste0("pop_change <- bb_predict_population_change(fit_survival, fit_recruitment, sex_ratio = ", recruitment$calf_female_ratio, ")<br/>")

      l5 <- "bb_plot_year_population_change(pop_change)"

      l6 <- ""

      text <- paste(l1, l2, l3, l4, l5, l6, sep = "<br/>")
      text <- gsub("(<br/>){2,}", "<br/>", text)
      HTML(text)
    })
  })
}
