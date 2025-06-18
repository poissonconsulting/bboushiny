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

mod_recruitment_ui <- function(id, label = "recruitment") {
  ns <- NS(id)

  instructions <- box(
    id = "rec",
    title = shinyhelper::helper(
      HTML("Instructions &nbsp &nbsp"),
      content = "recruitment",
      size = "l"
    ),
    width = 12,
    tags$label("1. Download Template"), br(),
    downloadButton(ns("download_recruitment"), "XLSX", class = "btn-primary"),
    br(), br(),
    uiOutput(ns("ui_start_month")), br(),
    tags$label("3. Upload Data or Use Demo Data"),
    uiOutput(ns("upload_recruitment")),
    uiOutput(ns("ui_demo_recruitment")),
    tags$label("4. Select Population"),
    uiOutput(ns("ui_select_population")),
    tags$label("5. Choose Sex Ratios"), br(),
    uiOutput(ns("ui_adult_sex_ratio")),
    uiOutput(ns("ui_calf_female_ratio")),
    tags$label("6. Choose Recruitment Type"),
    uiOutput(ns("ui_recruitment_type")),
    tags$label("7. Include Year Trend"),
    uiOutput(ns("ui_include_trend")),
    tags$label("8. Run Model"), br(),
    actionButton(
      ns("est_recruitment"),
      "Estimate Recruitment",
      icon = NULL,
      class = "btn-primary"
    )
  )

  data_raw <- box(
    title = "Data",
    width = 12,
    tabsetPanel(
      tabPanel(
        "Table",
        uiOutput(ns("ui_data_table"))
      ),
      tabPanel(
        "Plot",
        uiOutput(ns("ui_data_plot"))
      )
    )
  )

  results <- box(
    title = "Results",
    width = 12,
    tabsetPanel(
      id = "results",
      tabPanel(
        "Table Year",
        uiOutput(ns("download_results_table_year_button")),
        uiOutput(ns("ui_results_table_year"))
      ),
      tabPanel(
        "Plot Year",
        uiOutput(ns("download_results_plot_year_button")),
        uiOutput(ns("ui_results_plot_year"))
      ),
      tabPanel(
        "Table Trend",
        uiOutput(ns("download_results_table_trend_button")),
        uiOutput(ns("ui_results_table_trend"))
      ),
      tabPanel(
        "Plot Trend",
        uiOutput(ns("download_results_plot_trend_button")),
        uiOutput(ns("ui_results_plot_trend"))
      )
    )
  )

  fluidPage(
    fluidRow(
      column(width = 3, instructions),
      column(width = 9, data_raw, results)
    )
  )
}


mod_recruitment_server <- function(id, survival) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    rv <- reactiveValues(
      data = NULL,
      population_choices = NULL,
      data_filtered = NULL,
      results = NULL,
      results_plot = NULL,
      results_plot_ccr = NULL,
      results_plot_trend = NULL,
      results_plot_trend_ccr = NULL,
      results_table = NULL,
      results_table_ccr = NULL,
      results_table_trend = NULL,
      results_table_trend_ccr = NULL,
      adult_sex_ratio = NULL,
      calf_female_ratio = NULL,
      recruitment_type = NULL,
      results_dl_list = NULL,
      data_type = FALSE,
      upload_file = FALSE,
      model = FALSE,
      include_trend = FALSE,
      select_population = FALSE
    )

    # access template for downloading
    template_recruitment <- readxl::read_excel(
      system.file(
        package = "bboushiny",
        "app/www/template-recruitment.xlsx"
      )
    )

    output$download_recruitment <- downloadHandler(
      filename = "template-recruitment.xlsx",
      content = function(file) {
        writexl::write_xlsx(template_recruitment, file)
      }
    )

    # upload data widget
    output$upload_recruitment <- renderUI({
      fileInput(
        ns("upload"),
        label = NULL,
        accept = c(".xlsx", ".csv")
      )
    })

    observeEvent(input$upload,
      {
        # check type of file is correct
        file_type <- try(
          check_file_type(input$upload, ext = "(csv)|(xlsx)"),
          silent = TRUE
        )
        if (is_try_error(file_type)) {
          return(showModal(check_modal(file_type)))
        }

        if (grepl("\\.xlsx", input$upload$datapath)) {
          data <- readxl::read_excel(input$upload$datapath)
        } else {
          data <- readr::read_csv(input$upload$datapath)
        }

        # check that there is data (ie upload is not empty)
        num_rows <- try(check_data_not_empty(data), silent = TRUE)
        if (is_try_error(num_rows)) {
          return(showModal(check_modal(num_rows)))
        }

        # check column names
        col_names <- try(check_col_names(template_recruitment, data), silent = TRUE)
        if (is_try_error(col_names)) {
          return(showModal(check_modal(col_names)))
        }

        # check column types
        data <- try(check_recruitment_col_types(data), silent = TRUE)
        if (is_try_error(data)) {
          return(showModal(check_modal(data)))
        }

        # check year values
        data <- try(check_data_year(data), silent = TRUE)
        if (is_try_error(data)) {
          return(showModal(check_modal(data)))
        }

        # check month values
        data <- try(check_data_month(data), silent = TRUE)
        if (is_try_error(data)) {
          return(showModal(check_modal(data)))
        }

        rv$population_choices <- sort(unique(data[["PopulationName"]]))
        rv$data <- data

        # for code tab
        rv$data_type <- "upload"
        rv$upload_file <- input$upload$name
      },
      label = "generating data"
    )

    output$ui_demo_recruitment <- renderUI({
      actionButton(
        ns("demo_recruitment"),
        "Load Demo Data",
        icon = NULL,
        class = "btn-primary"
      )
    })

    observeEvent(input$demo_recruitment, {
      data <- bboudata::bbourecruit_a
      rv$population_choices <- sort(unique(data[["PopulationName"]]))
      rv$data <- data
      rv$data_type <- "demo" # for code tab
    })

    output$ui_select_population <- renderUI({
      selectInput(
        ns("select_population"),
        label = NULL,
        choices = rv$population_choices
      )
    })

    observe({
      req(input$select_population)
      rv$select_population <- input$select_population

      rv$data_filtered <-
        rv$data |>
        dplyr::filter(.data$PopulationName == input$select_population)
    })

    output$data_table <- DT::renderDT(DT_options(rv$data_filtered))

    output$ui_data_table <- renderUI({
      req(rv$data_filtered)
      DT::DTOutput(ns("data_table"))
    })

    output$data_plot <- renderPlot({
      req(rv$data_filtered)
      req(survival$start_month_num)
      withProgress(message = "Generating Plot", value = 0, {
        isolate(plot_recruitment_data(add_caribou_year(rv$data_filtered, survival$start_month_num)))
      })
    })

    output$ui_data_plot <- renderUI({
      req(rv$data_filtered)
      plotOutput(ns("data_plot"), height = 500)
    })

    output$ui_adult_sex_ratio <- renderUI({
      numericInput(
        ns("adult_sex_ratio"),
        label = "Adult Female",
        value = 0.65,
        min = 0,
        max = 1,
        step = 0.05
      )
    })

    observe({
      rv$adult_sex_ratio <- input$adult_sex_ratio
      rv$adult_sex_ratio
    })

    output$ui_calf_female_ratio <- renderUI({
      numericInput(
        ns("calf_female_ratio"),
        label = "Calf Female",
        value = 0.50,
        min = 0,
        max = 1,
        step = 0.05
      )
    })

    observe({
      rv$calf_female_ratio <- input$calf_female_ratio
      rv$calf_female_ratio
    })

    output$ui_recruitment_type <- renderUI({
      radioButtons(
        ns("recruitment_type"),
        label = NULL,
        choices = list(
          "Calves per Female Adult" = "recruitment_cf",
          "Adjusted Recruitment" = "recruitment_adjusted"
        ),
        selected = "recruitment_adjusted"
      )
    })

    observe({
      rv$recruitment_type <- input$recruitment_type
      rv$recruitment_type
    })

    output$ui_include_trend <- renderUI({
      checkboxInput(
        ns("include_trend"),
        label = "Yes",
        value = FALSE
      )
    })

    output$ui_start_month <- renderText({
      paste("<b>2. Start Month of Caribou Year:</b>", survival$start_month)
    })

    observeEvent(input$est_recruitment, {
      # for code tab
      rv$model <- TRUE
      rv$include_trend <- input$include_trend

      # check data is present
      if (is.null(rv$data_filtered)) {
        return(modal_missing_data())
      }

      if (is.na(rv$adult_sex_ratio)) {
        rv$adult_sex_ratio <- NULL
      }

      if (is.na(rv$calf_female_ratio)) {
        return(
          modal_error_modal(
            "The Yearling Female ratio cannot be left blank.
            Please fill in a value under 5. Choose Sex Ratios in the Yearling Female box.
            You can select any value between 0 and 1."
          )
        )
      }

      withProgress(
        message = "Running model...",
        value = 0,
        {
          fit <- fit_recruitment_estimate(
            data = rv$data_filtered,
            adult_female_ratio = rv$adult_sex_ratio,
            calf_female_ratio = rv$calf_female_ratio,
            year_trend = input$include_trend,
            year_start = survival$start_month_num,
            nthin = c(10, 50, 100, 500)
          )

          if (!is.null(fit[[1]]) & !is.null(fit[[2]])) {
            showModal(
              modalDialog(
                paste(fit[[2]], collapse = " "),
                footer = modalButton("Ok"),
              )
            )
          }
        }
      )
      rv$results <- fit[[1]]
    })

    # show/hide trend tabs
    shinyjs::hide(selector = "#results li a[data-value='Table Trend']")
    shinyjs::hide(selector = "#results li a[data-value='Plot Trend']")
    observeEvent(input$include_trend, {
      if (input$include_trend) {
        shinyjs::show(selector = "#results li a[data-value='Table Trend']")
        shinyjs::show(selector = "#results li a[data-value='Plot Trend']")
      } else {
        shinyjs::hide(selector = "#results li a[data-value='Table Trend']")
        shinyjs::hide(selector = "#results li a[data-value='Plot Trend']")
      }
    })

    # Results Year Table ------------------------------------------------------
    observeEvent(rv$results,
                 {
                   withProgress(message = "Generating Results", value = 0, {

                     rv$results_table <- bboutools::bb_predict_recruitment(
                       rv$results,
                       sex_ratio = rv$calf_female_ratio
                     )

                     rv$results_table_ccr <- bboutools::bb_predict_calf_cow_ratio(
                       rv$results
                     )

                   })
                 },
                 label = "create results summary"
    )

    output$results_table_year <- DT::renderDT({
      req(rv$results_table)
      req(rv$results_table_ccr)
      print(rv$results_table_ccr)
      if(rv$recruitment_type == "recruitment_adjusted"){
        x <- rv$results_table
      } else {
        x <- rv$results_table_ccr
      }
      print(x)
      DT::formatRound(
        DT_options(
          x
        ),
        columns = c("estimate", "lower", "upper"),
        digits = 3
      )
    })

    output$ui_results_table_year <- renderUI({
      req(rv$results_table)
      req(rv$results_table_ccr)
      DT::DTOutput(ns("results_table_year"))
    })

    output$download_results_table_year_button <- renderUI({
      req(rv$results_dl_list_year)
      downloadButton(
        ns("download_results_table_year"),
        "XLSX",
        class = "btn-results-table"
      )
    })

    observe(
      {
        req(rv$results_table)

        glance_tbl <- bboutools::glance(rv$results)
        glance_tbl$AdultFemaleSexRatio <- input$adult_sex_ratio
        glance_tbl$CalfFemaleSexRatio <- rv$calf_female_ratio
        glance_tbl$RecruitmentType <- rv$recruitment_type
        coef <- bboutools::coef(rv$results)

        if(rv$recruitment_type == "recruitment_adjusted") {
          pred_results_table <- rv$results_table
        } else {
          pred_results_table <- rv$results_table_ccr
        }

        rv$results_dl_list_year <- list(
          data_recruitment = rv$data_filtered,
          predict_recruitment = pred_results_table,
          glance_recruitment = glance_tbl,
          coef_recruitment = coef
        )
        rv$results_dl_list_year
      },
      label = "creates results list for downloading"
    )


    output$download_results_table_year <- downloadHandler(
      filename = "results_recruitment_year.xlsx",
      content = function(file) {
        writexl::write_xlsx(rv$results_dl_list_year, file)
      }
    )

    # Results Year Plot -------------------------------------------------------
    output$results_plot_year <- renderPlot(
      {
        req(rv$results_table)
        req(rv$results_table_ccr)
        withProgress(message = "Generating Results", value = 0, {
          if (rv$recruitment_type == "recruitment_adjusted") {
            rv$results_plot_year <- bboutools::bb_plot_year_recruitment(rv$results_table)
          } else if (rv$recruitment_type == "recruitment_cf") {
            rv$results_plot_year <- bboutools::bb_plot_year_calf_cow_ratio(rv$results_table_ccr)
          }
          rv$results_plot_year
        })
      },
      height = 375
    )

    output$ui_results_plot_year <- renderUI({
      req(rv$results)
      plotOutput(ns("results_plot_year"))
    })

    output$download_results_plot_year_button <- renderUI({
      req(rv$results)
      downloadButton(ns("download_results_plot_year"), "PNG", class = "btn-results")
    })

    output$download_results_plot_year <- downloadHandler(
      filename = "results_recruitment_year.png",
      content = function(file) {
        plot <- rv$results_plot_year +
          ggplot2::ggtitle("Annual recruitment estimates with credible limits")

        ggplot2::ggsave(
          file,
          plot,
          device = "png"
        )
      }
    )

    # Results Trend Plot ------------------------------------------------------
    output$results_plot_trend <- renderPlot(
      {
        req(rv$results_table)
        req(rv$results_table_ccr)
        withProgress(message = "Generating Results", value = 0, {
          if (rv$recruitment_type == "recruitment_adjusted") {
            rv$results_plot_trend <- bboutools::bb_plot_year_trend_recruitment(rv$results_table_trend)
          } else if (rv$recruitment_type == "recruitment_cf") {
            rv$results_plot_trend <- bboutools::bb_plot_year_trend_calf_cow_ratio(rv$results_table_trend_ccr)
          }
          rv$results_plot_trend
        })
      },
      height = 375
    )

    output$ui_results_plot_trend <- renderUI({
      req(rv$results)
      plotOutput(ns("results_plot_trend"))
    })

    output$download_results_plot_trend_button <- renderUI({
      req(rv$results)
      downloadButton(ns("download_results_plot_trend"), "PNG", class = "btn-results")
    })

    output$download_results_plot_trend <- downloadHandler(
      filename = "results_recruitment_trend.png",
      content = function(file) {
        plot <- rv$results_plot_trend +
          ggplot2::ggtitle("Annual recruitment estimates as trend line with credible limits")

        ggplot2::ggsave(
          file,
          plot,
          device = "png"
        )
      }
    )

    # Results Trend Table -----------------------------------------------------
    observeEvent(rv$results,
      {
        req(input$include_trend)
        withProgress(message = "Generating Results", value = 0, {

          rv$results_table_trend <- bboutools::bb_predict_recruitment_trend(
            rv$results,
            sex_ratio = rv$calf_female_ratio
          )
          rv$results_table_trend_ccr <- bboutools::bb_predict_calf_cow_ratio_trend(
            rv$results
          )
        })
      },
      label = "create results summary"
    )

    output$results_table_trend <- DT::renderDT({
      req(rv$results_table_trend)
      req(rv$results_table_trend_ccr)
      if (rv$recruitment_type == "recruitment_adjusted") {
        x <- rv$results_table_trend
      } else {
        x <- rv$results_table_trend_ccr
      }
      DT::formatRound(
        DT_options(
          x
        ),
        columns = c("estimate", "lower", "upper"),
        digits = 3
      )
    })

    output$ui_results_table_trend <- renderUI({
      req(rv$results_table_trend)
      req(rv$results_table_trend_ccr)
      DT::DTOutput(ns("results_table_trend"))
    })

    output$download_results_table_trend_button <- renderUI({
      req(rv$results_dl_list_trend)
      downloadButton(
        ns("download_results_table_trend"),
        "XLSX",
        class = "btn-results-table"
      )
    })

    observe(
      {
        req(rv$results_table_trend)
        req(rv$results_table_trend_ccr)

        glance_tbl <- bboutools::glance(rv$results)
        glance_tbl$AdultFemaleSexRatio <- input$adult_sex_ratio
        glance_tbl$CalfFemaleSexRatio <- rv$calf_female_ratio
        glance_tbl$RecruitmentType <- rv$recruitment_type
        coef <- bboutools::coef(rv$results)

        if(rv$recruitment_type == "recruitment_adjusted") {
          pred_rec <- rv$results_table_trend
        } else {
          pred_rec <- rv$results_table_trend_ccr
        }
        rv$results_dl_list_trend <- list(
          data_recruitment = rv$data_filtered,
          predict_recruitment = pred_rec,
          glance_recruitment = glance_tbl,
          coef_recruitment = coef
        )
      },
      label = "creates results list for downloading"
    )

    output$download_results_table_trend <- downloadHandler(
      filename = "results_recruitment_trend.xlsx",
      content = function(file) {
        writexl::write_xlsx(rv$results_dl_list_trend, file)
      }
    )

    # Clean Up ----------------------------------------------------------------
    observeEvent(input$upload,
      {
        rv$results = NULL
        rv$results_plot = NULL
        rv$results_plot_ccr = NULL
        rv$results_plot_trend = NULL
        rv$results_plot_trend_ccr = NULL
        rv$results_table = NULL
        rv$results_table_ccr = NULL
        rv$results_table_trend = NULL
        rv$results_table_trend_ccr = NULL
        rv$results_dl_list_trend <- NULL
      },
      label = "clears results when new file uploaded"
    )

    observeEvent(input$select_population,
      {
        rv$results = NULL
        rv$results_plot = NULL
        rv$results_plot_ccr = NULL
        rv$results_plot_trend = NULL
        rv$results_plot_trend_ccr = NULL
        rv$results_table = NULL
        rv$results_table_ccr = NULL
        rv$results_table_trend = NULL
        rv$results_table_trend_ccr = NULL
        rv$results_dl_list_trend <- NULL
      },
      label = "clears results when new population selected"
    )

    observeEvent(input$adult_sex_ratio,
      {
        rv$results = NULL
        rv$results_plot = NULL
        rv$results_plot_ccr = NULL
        rv$results_plot_trend = NULL
        rv$results_plot_trend_ccr = NULL
        rv$results_table = NULL
        rv$results_table_ccr = NULL
        rv$results_table_trend = NULL
        rv$results_table_trend_ccr = NULL
        rv$results_dl_list_trend <- NULL
      },
      label = "clears results when new adult female ratio selected"
    )

    observeEvent(input$calf_female_ratio,
      {
        rv$results = NULL
        rv$results_plot = NULL
        rv$results_plot_ccr = NULL
        rv$results_plot_trend = NULL
        rv$results_plot_trend_ccr = NULL
        rv$results_table = NULL
        rv$results_table_ccr = NULL
        rv$results_table_trend = NULL
        rv$results_table_trend_ccr = NULL
        rv$results_dl_list_trend <- NULL
      },
      label = "clears results when new yearling female ratio selected"
    )

    observeEvent(survival$start_month,
      {
        rv$results = NULL
        rv$results_plot = NULL
        rv$results_plot_ccr = NULL
        rv$results_plot_trend = NULL
        rv$results_plot_trend_ccr = NULL
        rv$results_table = NULL
        rv$results_table_ccr = NULL
        rv$results_table_trend = NULL
        rv$results_table_trend_ccr = NULL
        rv$results_dl_list_trend <- NULL
      },
      label = "clears results when start month selected in the survival tab"
    )

    observeEvent(input$include_trend,
      {
        rv$results = NULL
        rv$results_plot = NULL
        rv$results_plot_ccr = NULL
        rv$results_plot_trend = NULL
        rv$results_plot_trend_ccr = NULL
        rv$results_table = NULL
        rv$results_table_ccr = NULL
        rv$results_table_trend = NULL
        rv$results_table_trend_ccr = NULL
        rv$results_dl_list_trend <- NULL
      },
      label = "clears results when include trend is clicked"
    )

    return(rv)
  })
}
