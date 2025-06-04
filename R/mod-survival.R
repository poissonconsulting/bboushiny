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

mod_survival_ui <- function(id, label = "survival") {
  ns <- NS(id)

  instructions <- box(
    title = shinyhelper::helper(
      HTML("Instructions &nbsp &nbsp"),
      content = "survival",
      size = "l"
    ),
    width = 12,
    tags$label("1. Download Template"), br(),
    downloadButton(ns("download_survival"), "XLSX", class = "btn-primary"),
    br(), br(),
    tags$label("2. Select Start Month of Caribou Year"),
    uiOutput(ns("ui_select_start_month")),
    tags$label("3. Upload Data or Use Demo Data"),
    uiOutput(ns("upload_survival")),
    uiOutput(ns("ui_demo_survival")),
    tags$label("4. Select Population"),
    uiOutput(ns("ui_select_population")),
    tags$label("5. Include Uncertain Mortalities"),
    uiOutput(ns("ui_include_morts_uncertain")),
    tags$label("6. Include Year Trend"),
    uiOutput(ns("ui_include_trend")),
    tags$label("7. Run Model"), br(),
    actionButton(
      ns("est_survival"),
      "Estimate Survival",
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
        uiOutput(ns("download_results_table_button_year")),
        uiOutput(ns("ui_results_table_year"))
      ),
      tabPanel(
        "Plot Year",
        uiOutput(ns("download_results_plot_button_year")),
        uiOutput(ns("ui_results_plot_year"))
      ),
      tabPanel(
        "Table Month",
        uiOutput(ns("download_results_table_button_month")),
        uiOutput(ns("ui_results_table_month"))
      ),
      tabPanel(
        "Plot Month",
        uiOutput(ns("download_results_plot_button_month")),
        uiOutput(ns("ui_results_plot_month"))
      ),
      tabPanel(
        "Table Trend",
        uiOutput(ns("download_results_table_button_trend")),
        uiOutput(ns("ui_results_table_trend"))
      ),
      tabPanel(
        "Plot Trend",
        uiOutput(ns("download_results_plot_button_trend")),
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


mod_survival_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    rv <- reactiveValues(
      data = NULL,
      population_choices = NULL,
      start_month = NULL,
      start_month_num = NULL,
      data_filtered = NULL,
      results = NULL,
      results_plot_year = NULL,
      results_plot_month = NULL,
      results_table_year = NULL,
      results_table_month = NULL,
      data_type = FALSE,
      upload_file = FALSE,
      model = FALSE,
      include_trend = FALSE,
      include_uncertain_morts = FALSE,
      select_population = FALSE
    )

    # access template for downloading
    template_survival <- readxl::read_excel(
      system.file(
        package = "bboushiny",
        "app/www/template-survival.xlsx"
      )
    )

    output$download_survival <- downloadHandler(
      filename = "template-survival.xlsx",
      content = function(file) {
        writexl::write_xlsx(template_survival, file)
      }
    )

    output$ui_select_start_month <- renderUI({
      selectInput(
        ns("select_start_month"),
        label = NULL,
        choices = c(
          "January", "February", "March", "April", "May", "June", "July",
          "August", "September", "October", "November", "December"
        ),
        selected = "April"
      )
    })

    observe({
      rv$start_month <- input$select_start_month
      rv$start_month_num <- month_to_numeric(rv$start_month)
      rv$start_month
    })

    # upload data widget
    output$upload_survival <- renderUI({
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
        col_names <- try(check_col_names(template_survival, data), silent = TRUE)
        if (is_try_error(col_names)) {
          return(showModal(check_modal(col_names)))
        }

        # check column types
        data <- try(check_survival_col_types(data), silent = TRUE)
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
        data <- add_caribou_year(data, rv$start_month_num)
        rv$data <- data

        # for code tab
        rv$data_type <- "upload"
        rv$upload_file <- input$upload$name
      },
      label = "generating data"
    )

    output$ui_demo_survival <- renderUI({
      actionButton(
        ns("demo_survival"),
        "Load Demo Data",
        icon = NULL,
        class = "btn-primary"
      )
    })

    observeEvent(input$demo_survival, {
      data <- bboudata::bbousurv_a
      rv$population_choices <- sort(unique(data[["PopulationName"]]))
      data <- add_caribou_year(data, rv$start_month_num)
      rv$data <- data
      rv$data_type <- "demo" # for code tab
    })

    observeEvent(input$select_start_month, {
      req(rv$data_filtered)
      rv$data_filtered <- add_caribou_year(rv$data_filtered, rv$start_month_num)
      rv$data_filtered
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
      withProgress(message = "Generating Plot", value = 0, {
        isolate(plot_survival_data(rv$data_filtered))
      })
    })

    output$ui_data_plot <- renderUI({
      req(rv$data_filtered)
      plotOutput(ns("data_plot"))
    })

    output$ui_include_morts_uncertain <- renderUI({
      checkboxInput(
        ns("include_morts_uncertain"),
        label = "Yes",
        value = TRUE
      )
    })

    output$ui_include_trend <- renderUI({
      checkboxInput(
        ns("include_trend"),
        label = "Yes",
        value = FALSE
      )
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

    observeEvent(input$est_survival, {
      rv$model <- TRUE
      rv$include_trend <- input$include_trend
      rv$include_uncertain_morts <- input$include_morts_uncertain

      # check data is present
      if (is.null(rv$data_filtered)) {
        return(modal_missing_data())
      }

      rv$data_filtered$Month <- as.integer(rv$data_filtered$Month)

      withProgress(
        message = "Running model...",
        value = 0,
        {
          fit <- fit_survival_estimate(
            data = rv$data_filtered,
            year_trend = input$include_trend,
            include_uncertain_morts = input$include_morts_uncertain,
            year_start = rv$start_month_num,
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

    # Results Table Year ------------------------------------------------------
    observeEvent(rv$results,
      {
        withProgress(message = "Generating Results", value = 0, {
          rv$results_table_year <- bboutools::bb_predict_survival(
            rv$results,
            year = TRUE
          )
          rv$results_table_year
        })
      },
      label = "create results summary"
    )

    output$results_table_year <- DT::renderDT({
      req(rv$results)
      DT::formatRound(
        DT_options(
          rv$results_table_year
        ),
        columns = c("estimate", "lower", "upper"),
        digits = 3
      )
    })

    output$ui_results_table_year <- renderUI({
      req(rv$results)
      req(rv$results_table_year)
      DT::DTOutput(ns("results_table_year"))
    })

    output$download_results_table_button_year <- renderUI({
      req(rv$results_dl_list_year)
      downloadButton(
        ns("download_results_table_year"),
        "XLSX",
        class = "btn-results-table"
      )
    })

    observe(
      {
        req(rv$results_table_year)

        glance_tbl <- bboutools::glance(rv$results)
        glance_tbl$includeuncertainmortalities <- input$include_morts_uncertain

        coef <- bboutools::coef(rv$results)

        rv$results_dl_list_year <- list(
          data_survival = rv$data_filtered,
          predict_survival = rv$results_table_year,
          glance_survival = glance_tbl,
          coef_survival = coef
        )
        rv$results_dl_list_year
      },
      label = "creates year results list for downloading"
    )

    output$download_results_table_year <- downloadHandler(
      filename = "results_survival_year.xlsx",
      content = function(file) {
        writexl::write_xlsx(rv$results_dl_list_year, file)
      }
    )

    # Results Table Month -----------------------------------------------------
    observeEvent(rv$results,
      {
        withProgress(message = "Generating Results", value = 0, {
          rv$results_table_month <- bboutools::bb_predict_survival(
            rv$results,
            year = FALSE,
            month = TRUE
          )
          rv$results_table_month
        })
      },
      label = "create results summary"
    )

    output$results_table_month <- DT::renderDT({
      req(rv$results_table_month)
      DT::formatRound(
        DT_options(
          rv$results_table_month
        ),
        columns = c("estimate", "lower", "upper"),
        digits = 3
      )
    })

    output$ui_results_table_month <- renderUI({
      req(rv$results_table_month)
      DT::DTOutput(ns("results_table_month"))
    })

    output$download_results_table_button_month <- renderUI({
      req(rv$results_dl_list_month)
      downloadButton(
        ns("download_results_table_month"),
        "XLSX",
        class = "btn-results-table"
      )
    })

    observe(
      {
        req(rv$results_table_month)

        glance_tbl <- bboutools::glance(rv$results)
        glance_tbl$includeuncertainmortalities <- input$include_morts_uncertain
        coef <- bboutools::coef(rv$results)

        rv$results_dl_list_month <- list(
          data_survival = rv$data_filtered,
          predict_survival = rv$results_table_month,
          glance_survival = glance_tbl,
          coef_survival = coef
        )
        rv$results_dl_list_month
      },
      label = "creates months results list for downloading"
    )

    output$download_results_table_month <- downloadHandler(
      filename = "results_survival_month.xlsx",
      content = function(file) {
        writexl::write_xlsx(rv$results_dl_list_month, file)
      }
    )

    # Results Plot Year -------------------------------------------------------
    output$results_plot_year <- renderPlot(
      {
        req(rv$results)
        withProgress(message = "Generating Results", value = 0, {
          rv$results_plot_year <- bboutools::bb_plot_year_survival(rv$results)
          rv$results_plot_year
        })
      },
      height = 375
    )

    output$ui_results_plot_year <- renderUI({
      req(rv$results)
      plotOutput(ns("results_plot_year"))
    })

    output$download_results_plot_button_year <- renderUI({
      req(rv$results)
      downloadButton(ns("download_results_plot_year"), "PNG", class = "btn-results")
    })

    output$download_results_plot_year <- downloadHandler(
      filename = "results_survival_year.png",
      content = function(file) {
        plot <- rv$results_plot_year +
          ggplot2::ggtitle("Annual survival estimates with credible limits")

        ggplot2::ggsave(
          file,
          plot,
          device = "png"
        )
      }
    )

    # Results Month Plot ------------------------------------------------------
    output$results_plot_month <- renderPlot(
      {
        req(rv$results)
        withProgress(message = "Generating Results", value = 0, {
          rv$results_plot_month <- bboutools::bb_plot_month_survival(rv$results)
          rv$results_plot_month
        })
      },
      height = 375
    )

    output$ui_results_plot_month <- renderUI({
      req(rv$results)
      plotOutput(ns("results_plot_month"))
    })

    output$download_results_plot_button_month <- renderUI({
      req(rv$results)
      downloadButton(ns("download_results_plot_month"), "PNG", class = "btn-results")
    })

    output$download_results_plot_month <- downloadHandler(
      filename = "results_survival_month.png",
      content = function(file) {
        plot <- rv$results_plot_month +
          ggplot2::ggtitle("Monthly survival estimates with credible limits")

        ggplot2::ggsave(
          file,
          plot,
          device = "png"
        )
      }
    )

    # Results Table Trend -----------------------------------------------------
    observeEvent(rv$results,
      {
        req(input$include_trend)
        withProgress(message = "Generating Results", value = 0, {
          rv$results_table_trend <- bboutools::bb_predict_survival_trend(
            rv$results
          )
          rv$results_table_trend
        })
      },
      label = "create results summary"
    )

    output$results_table_trend <- DT::renderDT({
      req(rv$results_table_trend)
      DT::formatRound(
        DT_options(
          rv$results_table_trend
        ),
        columns = c("estimate", "lower", "upper"),
        digits = 3
      )
    })

    output$ui_results_table_trend <- renderUI({
      req(rv$results_table_trend)
      DT::DTOutput(ns("results_table_trend"))
    })

    output$download_results_table_button_trend <- renderUI({
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

        glance_tbl <- bboutools::glance(rv$results)
        glance_tbl$includeuncertainmortalities <- input$include_morts_uncertain
        coef <- bboutools::coef(rv$results)

        rv$results_dl_list_trend <- list(
          data_survival = rv$data_filtered,
          predict_survival = rv$results_table_trend,
          glance_survival = glance_tbl,
          coef_survival = coef
        )
      },
      label = "creates trend results list for downloading"
    )

    output$download_results_table_trend <- downloadHandler(
      filename = "results_survival_trend.xlsx",
      content = function(file) {
        writexl::write_xlsx(rv$results_dl_list_trend, file)
      }
    )

    # Results Trend Plot ------------------------------------------------------
    output$results_plot_trend <- renderPlot(
      {
        req(rv$results)

        withProgress(message = "Generating Results", value = 0, {
          rv$results_plot_trend <- bboutools::bb_plot_year_trend_survival(rv$results)
          rv$results_plot_trend
        })
      },
      height = 375
    )

    output$ui_results_plot_trend <- renderUI({
      req(rv$results)
      plotOutput(ns("results_plot_trend"))
    })

    output$download_results_plot_button_trend <- renderUI({
      req(rv$results)
      downloadButton(ns("download_results_plot_trend"), "PNG", class = "btn-results")
    })

    output$download_results_plot_trend <- downloadHandler(
      filename = "results_survival_trend.png",
      content = function(file) {
        plot <- rv$results_plot_trend +
          ggplot2::ggtitle("Annual survival estimates as trend line with credible limits")

        ggplot2::ggsave(
          file,
          plot,
          device = "png"
        )
      }
    )

    # Clear Variables ---------------------------------------------------------
    observeEvent(input$select_start_month,
      {
        rv$results <- NULL
        rv$results_plot_year <- NULL
        rv$results_plot_month <- NULL
        rv$results_plot_trend <- NULL
        rv$results_table_year <- NULL
        rv$results_table_month <- NULL
        rv$results_table_trend <- NULL
        rv$results_dl_list_year <- NULL
        rv$results_dl_list_month <- NULL
        rv$results_dl_list_trend <- NULL
      },
      label = "clears results when caribou start month changed"
    )

    observeEvent(input$upload,
      {
        rv$results <- NULL
        rv$results_plot_year <- NULL
        rv$results_plot_month <- NULL
        rv$results_plot_trend <- NULL
        rv$results_table_year <- NULL
        rv$results_table_month <- NULL
        rv$results_table_trend <- NULL
        rv$results_dl_list_year <- NULL
        rv$results_dl_list_month <- NULL
        rv$results_dl_list_trend <- NULL
      },
      label = "clears results when new file uploaded"
    )

    observeEvent(input$select_population,
      {
        rv$results <- NULL
        rv$results_plot_year <- NULL
        rv$results_plot_month <- NULL
        rv$results_plot_trend <- NULL
        rv$results_table_year <- NULL
        rv$results_table_month <- NULL
        rv$results_table_trend <- NULL
        rv$results_dl_list_year <- NULL
        rv$results_dl_list_month <- NULL
        rv$results_dl_list_trend <- NULL
      },
      label = "clears results when new population selected"
    )

    observeEvent(input$include_morts_uncertain,
      {
        rv$results <- NULL
        rv$results_plot_year <- NULL
        rv$results_plot_month <- NULL
        rv$results_plot_trend <- NULL
        rv$results_table_year <- NULL
        rv$results_table_month <- NULL
        rv$results_table_trend <- NULL
        rv$results_dl_list_year <- NULL
        rv$results_dl_list_month <- NULL
        rv$results_dl_list_trend <- NULL
      },
      label = "clears results when uncertain mortalities changed"
    )

    observeEvent(input$include_trend,
      {
        rv$results <- NULL
        rv$results_plot_year <- NULL
        rv$results_plot_month <- NULL
        rv$results_plot_trend <- NULL
        rv$results_table_year <- NULL
        rv$results_table_month <- NULL
        rv$results_table_trend <- NULL
        rv$results_dl_list_year <- NULL
        rv$results_dl_list_month <- NULL
        rv$results_dl_list_trend <- NULL
      },
      label = "clears results when trend checked or unchecked"
    )

    return(rv)
  })
}
