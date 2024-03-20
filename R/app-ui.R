# Copyright 2023 Environment and Climate Change Canada
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

app_ui <- function() {
  dashboardPage(
    dark = NULL,
    scrollToTop = TRUE,
    controlbar = NULL,
    footer = NULL,
    help = NULL,
    header = dashboardHeader(
      ... = div(
        h3("Boreal Caribou Survival, Recruitment & Population Growth"),
        style = "vertical-align: baseline;"
      )
    ),
    sidebar = dashboardSidebar(
      skin = "light",
      elevation = 3,
      sidebarMenu(
        id = "sidebarmenu",
        menuItem(
          "Survival",
          tabName = "survival",
          icon = icon(NULL, class = "fa-survival")
        ),
        menuItem(
          "Recruitment",
          tabName = "recruitment",
          icon = icon(NULL, "fa-recruitment")
        ),
        menuItem(
          "Population Growth",
          tabName = "populationgrowth",
          icon = icon(NULL, "fa-lambda")
        ),
        menuItem(
          "R Code",
          tabName = "rcode",
          icon = icon("code")
        ),
        menuItem(
          "Help",
          tabName = "help",
          icon = icon("question")
        ),
        menuItem(
          "About",
          tabName = "about",
          icon = icon("info")
        )
      )
    ),
    body = dashboardBody(
      shinyjs::useShinyjs(),
      css_styling(),
      tabItems(
        tabItem(
          tabName = "survival",
          mod_survival_ui("mod_survival_ui")
        ),
        tabItem(
          tabName = "recruitment",
          mod_recruitment_ui("mod_recruitment_ui")
        ),
        tabItem(
          tabName = "populationgrowth",
          mod_population_growth_ui("mod_population_growth_ui")
        ),
        tabItem(
          tabName = "rcode",
          mod_r_code_ui("mod_r_code_ui")
        ),
        tabItem(
          tabName = "help",
          mod_help_ui("mod_help_ui")
        ),
        tabItem(
          tabName = "about",
          mod_about_ui("mod_about_ui")
        )
      )
    )
  )
}
