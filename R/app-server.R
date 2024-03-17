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

app_server <- function(input, output, session) {
  shinyhelper::observe_helpers(
    help_dir = system.file("helpfiles", package = "bboushiny")
  )

  addResourcePath("www", system.file("app/www", package = "bboushiny"))

  survival <- mod_survival_server(
    "mod_survival_ui"
  )

  recruitment <- mod_recruitment_server(
    "mod_recruitment_ui",
    survival
  )

  population_growth <- mod_population_growth_server(
    "mod_population_growth_ui",
    survival,
    recruitment
  )

  mod_r_code_server(
    "mod_r_code_ui",
    survival,
    recruitment,
    population_growth
  )

  mod_help_server(
    "mod_help_ui"
  )

  mod_about_server(
    "mod_about_ui"
  )
}
