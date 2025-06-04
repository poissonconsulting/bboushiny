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

testServer(mod_survival_server, {
  survival_template <- readxl::read_excel(output$download_survival)

  expect_s3_class(survival_template, "data.frame")
  expect_equal(nrow(survival_template), 0L)
  expect_equal(
    colnames(survival_template),
    c(
      "PopulationName", "Year", "Month", "StartTotal", "MortalitiesCertain",
      "MortalitiesUncertain"
    )
  )
})


test_that("throws error when year column has character ", {
  df <- data.frame(
    PopulationName = c("PopA", "PopB"),
    Year = c("twothousandtwenty", 2020),
    Month = c(7, 8),
    StartTotal = c(5, 7),
    MortalitiesCertain = c(1, 0),
    MortalitiesUncertain = c(0, 0)
  )

  expect_error(
    check_survival_col_types(df),
    regexp = "The following value\\(s\\) in column 'Year' should be a integer:"
  )
})

test_that("throws error when year column has more then a 4 digit year ", {
  df <- data.frame(
    PopulationName = c("PopA", "PopB"),
    Year = c(202021, 202021),
    Month = c(7, 8),
    StartTotal = c(5, 7),
    MortalitiesCertain = c(1, 0),
    MortalitiesUncertain = c(0, 0)
  )

  expect_error(
    check_data_year(df),
    regexp = "The Year column must have years formatted as a 4 digit year \\(ex. 2023\\)\\."
  )
})

test_that("throws error when year column has less then a 4 digit year ", {
  df <- data.frame(
    PopulationName = c("PopA", "PopB"),
    Year = c(23, 24),
    Month = c(7, 8),
    StartTotal = c(5, 7),
    MortalitiesCertain = c(1, 0),
    MortalitiesUncertain = c(0, 0)
  )

  expect_error(
    check_data_year(df),
    regexp = "The Year column must have years formatted as a 4 digit year \\(ex. 2023\\)\\."
  )
})


test_that("throws error when month column has character ", {
  df <- data.frame(
    PopulationName = c("PopA", "PopB"),
    Year = c(2020, 2020),
    Month = c("seven", 8),
    StartTotal = c(5, 7),
    MortalitiesCertain = c(1, 0),
    MortalitiesUncertain = c(0, 0)
  )

  expect_error(
    check_survival_col_types(df),
    regexp = "The following value\\(s\\) in column 'Month' should be a integer:"
  )
})

test_that("throws error when month column has values greater then 12 ", {
  df <- data.frame(
    PopulationName = c("PopA", "PopB"),
    Year = c(2020, 2020),
    Month = c(8, 13),
    StartTotal = c(5, 7),
    MortalitiesCertain = c(1, 0),
    MortalitiesUncertain = c(0, 0)
  )

  expect_error(
    check_data_month(df),
    regexp = "The Month column can only contain values from 1 to 12\\."
  )
})

test_that("throws error when month column has values less then 1", {
  df <- data.frame(
    PopulationName = c("PopA", "PopB"),
    Year = c(2020, 2020),
    Month = c(0, 1),
    StartTotal = c(5, 7),
    MortalitiesCertain = c(1, 0),
    MortalitiesUncertain = c(0, 0)
  )

  expect_error(
    check_data_month(df),
    regexp = "The Month column can only contain values from 1 to 12\\."
  )
})

test_that("Does not error when month column has NA values", {
  df <- data.frame(
    PopulationName = c("PopA", "PopB"),
    Year = c(2020, 2020),
    Month = c(1L, NA_integer_),
    StartTotal = c(5, 7),
    MortalitiesCertain = c(1, 0),
    MortalitiesUncertain = c(0, 0)
  )

  expect_equal(
    nrow(check_data_month(df)),
    2
  )
})

test_that("throws error when StartTotal column has character ", {
  df <- data.frame(
    PopulationName = c("PopA", "PopB"),
    Year = c(2020, 2020),
    Month = c(7, 8),
    StartTotal = c("five", 7),
    MortalitiesCertain = c(1, 0),
    MortalitiesUncertain = c(0, 0)
  )

  expect_error(
    check_survival_col_types(df),
    regexp = "The following value\\(s\\) in column 'StartTotal' should be a integer:"
  )
})

test_that("throws error when MortalitiesCertain column has character ", {
  df <- data.frame(
    PopulationName = c("PopA", "PopB"),
    Year = c(2020, 2020),
    Month = c(7, 8),
    StartTotal = c(5, 7),
    MortalitiesCertain = c("one", 0),
    MortalitiesUncertain = c(0, 0)
  )

  expect_error(
    check_survival_col_types(df),
    regexp = "The following value\\(s\\) in column 'MortalitiesCertain' should be a integer:"
  )
})

test_that("throws error when MortalitiesUncertain column has character ", {
  df <- data.frame(
    PopulationName = c("PopA", "PopB"),
    Year = c(2020, 2020),
    Month = c(7, 8),
    StartTotal = c(5, 7),
    MortalitiesCertain = c(1, 0),
    MortalitiesUncertain = c("zero", 0)
  )

  expect_error(
    check_survival_col_types(df),
    regexp = "The following value\\(s\\) in column 'MortalitiesUncertain' should be a integer:"
  )
})

test_that("Passes when all column datatypes are correct", {
  df <- data.frame(
    PopulationName = c("PopA", "PopB"),
    Year = c(2020, 2020),
    Month = c(7, 8),
    StartTotal = c(5, 7),
    MortalitiesCertain = c(1, 0),
    MortalitiesUncertain = c(0, 0)
  )

  expect_equal(
    nrow(check_survival_col_types(df)),
    2
  )
})

test_that("throws error when dataframe is empty ie no data added to template", {
  df <- setNames(
    data.frame(matrix(ncol = 6, nrow = 0)),
    c(
      "PopulationName", "Year", "Month", "StartTotal", "MortalitiesCertain",
      "MortalitiesUncertain"
    )
  )

  expect_error(
    check_data_not_empty(df),
    regexp = "The file uploaded is empty, please fill in the template\\."
  )
})

test_that("Error when new column name added", {
  df <- data.frame(
    PopulationName = c("PopA", "PopB"),
    Year = c(2020, 2020),
    Month = c(7, 8),
    StartTotal = c(5, 7),
    MortalitiesCertain = c(1, 0),
    MortalitiesUncertain = c(0, 0),
    NewCol = c(1, 1)
  )

  template <- readxl::read_excel(
    system.file(
      "app/www/template-survival.xlsx",
      package = "bboushiny"
    )
  )

  expect_error(
    check_col_names(template, df),
    regexp = "The column names in the uploaded file do not match the\n\\s+column names from the template."
  )
})

test_that("Error when column name removed", {
  df <- data.frame(
    PopulationName = c("PopA", "PopB"),
    Year = c(2020, 2020),
    Month = c(7, 8),
    StartTotal = c(5, 7),
    MortalitiesCertain = c(1, 0)
  )

  template <- readxl::read_excel(
    system.file(
      "app/www/template-survival.xlsx",
      package = "bboushiny"
    )
  )

  expect_error(
    check_col_names(template, df),
    regexp = "The column names in the uploaded file do not match the\n\\s+column names from the template."
  )
})

test_that("Passes when all column names are correct", {
  df <- data.frame(
    PopulationName = c("PopA", "PopB"),
    Year = c(2020, 2020),
    Month = c(7, 8),
    StartTotal = c(5, 7),
    MortalitiesCertain = c(1, 0),
    MortalitiesUncertain = c(0, 0)
  )

  template <- readxl::read_excel(
    system.file(
      "app/www/template-survival.xlsx",
      package = "bboushiny"
    )
  )

  expect_silent(check_col_names(template, df))
})

test_that("Error when no file supplied", {
  expect_error(
    check_file_type(NULL),
    regexp = "Please upload a file\\."
  )
})

test_that("Error when csv file supplied", {
  file_name <- withr::local_file("file.csv")
  upload <- list(name = file_name)

  expect_error(
    check_file_type(upload, "xlsx"),
    regexp = "We're not sure what to do with that file type\\.
        Please upload a xlsx\\."
  )
})

test_that("Pass when xlsx file supplied", {
  file_name <- withr::local_file("file.xlsx")
  upload <- list(name = file_name)

  expect_silent(check_file_type(upload, "xlsx"))
})
