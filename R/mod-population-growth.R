# Copyright 2022-2023 Environment and Climate Change Canada
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

mod_population_growth_ui <- function(id, label = "population growth") {
  ns <- NS(id)

  instructions <- box(
    id = "rec",
    title = shinyhelper::helper(
      HTML("Instructions &nbsp &nbsp"),
      content = "population-growth",
      size = "l"
    ),
    width = 12,
    tags$label("1. Calculate Population Growth"), br(),
    actionButton(
      ns("calc_pop_growth"),
      "Calculate Population Growth",
      icon = NULL,
      class = "btn-primary"
    )
  )

  data_raw <- box(
    title = "Estimates",
    width = 12,
    tabsetPanel(
      tabPanel(
        "Survival",
        uiOutput(ns("ui_survival_table"))
      ),
      tabPanel(
        "Recruitment",
        uiOutput(ns("ui_recruitment_table"))
      )
    )
  )

  results <- box(
    title = "Results",
    width = 12,
    tabsetPanel(
      tabPanel(
        "Table Growth",
        uiOutput(ns("download_results_table_growth_button")),
        uiOutput(ns("ui_results_table_growth"))
      ),
      tabPanel(
        "Plot Growth",
        uiOutput(ns("download_results_plot_growth_button")),
        uiOutput(ns("ui_results_plot_growth"))
      ),
      tabPanel(
        "Table Population Change",
        uiOutput(ns("download_results_table_pop_change_button")),
        uiOutput(ns("ui_results_table_pop_change"))
      ),
      tabPanel(
        "Plot Population Change",
        uiOutput(ns("download_results_plot_pop_change_button")),
        uiOutput(ns("ui_results_plot_pop_change"))
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


mod_population_growth_server <- function(id, survival, recruitment) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    rv <- reactiveValues(
      results_growth = NULL,
      results_plot_growth = NULL,
      results_dl_list_growth = NULL,
      results_pop_change = NULL,
      results_plot_pop_change = NULL,
      results_dl_list_pop_change = NULL
    )

    # Data Tables -------------------------------------------------------------
    output$survival_table <- DT::renderDT({
      req(survival$results)
      DT::formatRound(
        DT_options(
          survival$results_table_year
        ),
        columns = c("estimate", "lower", "upper"),
        digits = 3
      )
    })

    output$ui_survival_table <- renderUI({
      req(survival$results)
      DT::DTOutput(ns("survival_table"))
    })

    output$recruitment_table <- DT::renderDT({
      req(recruitment$results)
      DT::formatRound(
        DT_options(
          recruitment$results_table_year
        ),
        columns = c("estimate", "lower", "upper"),
        digits = 3
      )
    })

    output$ui_recruitment_table <- renderUI({
      req(recruitment$results)
      DT::DTOutput(ns("recruitment_table"))
    })


    # Calculate Results -------------------------------------------------------
    observeEvent(input$calc_pop_growth, {
      if (is.null(survival$results)) {
        return(showModal(calculate_modal("Survival")))
      }
      if (is.null(recruitment$results)) {
        return(showModal(calculate_modal("Recruitment")))
      }

      req(survival$results)
      req(recruitment$results)

      withProgress(message = "Generating results", value = 0, {
        rv$results_growth <- bboutools::bb_predict_growth(
          survival$results,
          recruitment$results
        )

        rv$results_pop_change <- bboutools::bb_predict_population_change(
          survival$results,
          recruitment$results
        )
      })
    })

    # Results Table Growth ---------------------------------------------------
    output$results_table_growth <- DT::renderDT({
      req(rv$results_growth)
      DT::formatRound(
        DT_options(
          rv$results_growth
        ),
        columns = c("estimate", "lower", "upper"),
        digits = 3
      )
    })

    output$ui_results_table_growth <- renderUI({
      req(rv$results_growth)
      DT::DTOutput(ns("results_table_growth"))
    })

    output$download_results_table_growth_button <- renderUI({
      req(rv$results_growth)
      req(rv$results_dl_list_growth)
      downloadButton(
        ns("download_results_table_growth"),
        "XLSX",
        class = "btn-results-table"
      )
    })

    observe({
      req(rv$results_growth)
      req(survival$results_dl_list_year)
      req(recruitment$results_dl_list_year)

      growth_list <- list(lambda = rv$results_growth)

      rv$results_dl_list_growth <- c(
        growth_list,
        survival$results_dl_list_year,
        recruitment$results_dl_list_year
      )
    })

    output$download_results_table_growth <- downloadHandler(
      filename = "results_population_growth.xlsx",
      content = function(file) {
        writexl::write_xlsx(rv$results_dl_list_growth, file)
      }
    )

    # Results Table Population Change -----------------------------------------
    output$results_table_pop_change <- DT::renderDT({
      req(rv$results_pop_change)
      DT::formatRound(
        DT_options(
          rv$results_pop_change
        ),
        columns = c("estimate", "lower", "upper"),
        digits = 3
      )
    })

    output$ui_results_table_pop_change <- renderUI({
      req(rv$results_pop_change)
      DT::DTOutput(ns("results_table_pop_change"))
    })

    output$download_results_table_pop_change_button <- renderUI({
      req(rv$results_pop_change)
      req(rv$results_dl_list_pop_change)
      downloadButton(
        ns("download_results_table_pop_change"),
        "XLSX",
        class = "btn-results-table"
      )
    })

    observe({
      req(rv$results_pop_change)
      req(survival$results_dl_list_year)
      req(recruitment$results_dl_list_year)

      pop_change_list <- list(population_change = rv$results_pop_change)

      rv$results_dl_list_pop_change <- c(
        pop_change_list,
        survival$results_dl_list_year,
        recruitment$results_dl_list_year
      )
    })

    output$download_results_table_pop_change <- downloadHandler(
      filename = "results_population_pop_change.xlsx",
      content = function(file) {
        writexl::write_xlsx(rv$results_dl_list_pop_change, file)
      }
    )

    # Results Plot Growth -----------------------------------------------------
    output$results_plot_growth <- renderPlot(
      {
        req(rv$results_growth)
        withProgress(message = "Generating results", value = 0, {
          rv$results_plot_growth <- bboutools::bb_plot_year_growth(rv$results_growth)
          rv$results_plot_growth
        })
      },
      height = 375
    )

    output$ui_results_plot_growth <- renderUI({
      req(rv$results_growth)
      plotOutput(ns("results_plot_growth"))
    })

    output$download_results_plot_growth_button <- renderUI({
      req(rv$results_growth)
      downloadButton(ns("download_results_plot_growth"), "PNG", class = "btn-results")
    })

    output$download_results_plot_growth <- downloadHandler(
      filename = "results_population_growth.png",
      content = function(file) {
        plot <- rv$results_plot_growth +
          ggplot2::ggtitle("Annual population growth with credible limits")

        ggplot2::ggsave(
          file,
          plot,
          device = "png"
        )
      }
    )

    # Results Plot Population Change ------------------------------------------
    output$results_plot_pop_change <- renderPlot(
      {
        req(rv$results_pop_change)
        withProgress(message = "Generating results", value = 0, {
          rv$results_plot_pop_change <- bboutools::bb_plot_year_population_change(rv$results_pop_change)
          rv$results_plot_pop_change
        })
      },
      height = 375
    )

    output$ui_results_plot_pop_change <- renderUI({
      req(rv$results_pop_change)
      plotOutput(ns("results_plot_pop_change"))
    })

    output$download_results_plot_pop_change_button <- renderUI({
      req(rv$results_pop_change)
      downloadButton(ns("download_results_plot_pop_change"), "PNG", class = "btn-results")
    })

    output$download_results_plot_pop_change <- downloadHandler(
      filename = "results_population_pop_change.png",
      content = function(file) {
        plot <- rv$results_plot_pop_change +
          ggplot2::ggtitle("Annual population change (%) with credible limits")

        ggplot2::ggsave(
          file,
          plot,
          device = "png"
        )
      }
    )

    # Clean Up -------------------------------------------------------
    observe(
      {
        if (is.null(survival$results)) {
          rv$results_growth <- NULL
          rv$results_plot_growth <- NULL

          rv$results_pop_change <- NULL
          rv$results_plot_pop_change <- NULL
        }

        if (is.null(recruitment$results)) {
          rv$results_growth <- NULL
          rv$results_plot_growth <- NULL

          rv$results_pop_change <- NULL
          rv$results_plot_pop_change <- NULL
        }
      },
      label = "clears results when new file uploaded"
    )

    return(rv)
  })
}
