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

# check the recruitment template is generated properly for download
testServer(mod_recruitment_server, args = list(survival = list()), {
  recruitment_template <- readxl::read_excel(output$download_recruitment)

  expect_s3_class(recruitment_template, "data.frame")
  expect_equal(nrow(recruitment_template), 0L)
  expect_equal(
    colnames(recruitment_template),
    c(
      "PopulationName", "Year", "Month", "Day", "Cows", "Bulls",
      "UnknownAdults", "Yearlings", "Calves"
    )
  )
})

test_that("throws error when Year column has a character value", {
  df <- data.frame(
    PopulationName = c("PopA", "PopB"),
    Year = c("twothousandtwenty", 2020),
    Month = c(7, 8),
    Day = c(1, 2),
    Cows = c(4, 5),
    Bulls = c(7, 9),
    UnknownAdults = c(0, 1),
    Yearlings = c(0, 0),
    Calves = c(4, 3)
  )

  expect_error(
    check_recruitment_col_types(df),
    regexp = "The following value\\(s\\) in column 'Year' should be a integer:"
  )
})

test_that("throws error when Year column has years as 200102", {
  df <- data.frame(
    PopulationName = c("PopA", "PopB"),
    Year = c(200102, 202021),
    Month = c(7, 8),
    Day = c(1, 2),
    Cows = c(4, 5),
    Bulls = c(7, 9),
    UnknownAdults = c(0, 1),
    Yearlings = c(0, 0),
    Calves = c(4, 3)
  )

  expect_error(
    check_data_year(df),
    regexp = "The Year column must have years formatted as a 4 digit year \\(ex. 2023\\)\\."
  )
})

test_that("throws error when Year column has years as 02", {
  df <- data.frame(
    PopulationName = c("PopA", "PopB"),
    Year = c(02, 03),
    Month = c(7, 8),
    Day = c(1, 2),
    Cows = c(4, 5),
    Bulls = c(7, 9),
    UnknownAdults = c(0, 1),
    Yearlings = c(0, 0),
    Calves = c(4, 3)
  )

  expect_error(
    check_data_year(df),
    regexp = "The Year column must have years formatted as a 4 digit year \\(ex. 2023\\)\\."
  )
})

test_that("throws error when Month column has a character value", {
  df <- data.frame(
    PopulationName = c("PopA", "PopB"),
    Year = c(2020, 2020),
    Month = c("seven", 8),
    Day = c(1, 2),
    Cows = c(4, 5),
    Bulls = c(7, 9),
    UnknownAdults = c(0, 1),
    Yearlings = c(0, 0),
    Calves = c(4, 3)
  )

  expect_error(
    check_recruitment_col_types(df),
    regexp = "The following value\\(s\\) in column 'Month' should be a integer:"
  )
})

test_that("throws error when Month column has values above 12", {
  df <- data.frame(
    PopulationName = c("PopA", "PopB"),
    Year = c(2020, 2020),
    Month = c(12, 13),
    Day = c(1, 2),
    Cows = c(4, 5),
    Bulls = c(7, 9),
    UnknownAdults = c(0, 1),
    Yearlings = c(0, 0),
    Calves = c(4, 3)
  )

  expect_error(
    check_data_month(df),
    regexp = "The Month column can only contain values from 1 to 12\\."
  )
})

test_that("throws error when Month column has values below 1", {
  df <- data.frame(
    PopulationName = c("PopA", "PopB"),
    Year = c(2020, 2020),
    Month = c(0, 1),
    Day = c(1, 2),
    Cows = c(4, 5),
    Bulls = c(7, 9),
    UnknownAdults = c(0, 1),
    Yearlings = c(0, 0),
    Calves = c(4, 3)
  )

  expect_error(
    check_data_month(df),
    regexp = "The Month column can only contain values from 1 to 12\\."
  )
})

test_that("Does not error when Month column has NA values", {
  df <- data.frame(
    PopulationName = c("PopA", "PopB"),
    Year = c(2020, 2020),
    Month = c(1L, NA_integer_),
    Day = c(1, 2),
    Cows = c(4, 5),
    Bulls = c(7, 9),
    UnknownAdults = c(0, 1),
    Yearlings = c(0, 0),
    Calves = c(4, 3)
  )

  expect_equal(
    nrow(check_data_month(df)),
    2
  )
})

test_that("throws error when Day column has a character value", {
  df <- data.frame(
    PopulationName = c("PopA", "PopB"),
    Year = c(2020, 2020),
    Month = c(7, 8),
    Day = c("one", 2),
    Cows = c(4, 5),
    Bulls = c(7, 9),
    UnknownAdults = c(0, 1),
    Yearlings = c(0, 0),
    Calves = c(4, 3)
  )

  expect_error(
    check_recruitment_col_types(df),
    regexp = "The following value\\(s\\) in column 'Day' should be a integer:"
  )
})

test_that("throws error when Cows column has a character value", {
  df <- data.frame(
    PopulationName = c("PopA", "PopB"),
    Year = c(2020, 2020),
    Month = c(7, 8),
    Day = c(1, 2),
    Cows = c("four", 5),
    Bulls = c(7, 9),
    UnknownAdults = c(0, 1),
    Yearlings = c(0, 0),
    Calves = c(4, 3)
  )

  expect_error(
    check_recruitment_col_types(df),
    regexp = "The following value\\(s\\) in column 'Cows' should be a integer:"
  )
})

test_that("throws error when Bulls column has a character value", {
  df <- data.frame(
    PopulationName = c("PopA", "PopB"),
    Year = c(2020, 2020),
    Month = c(7, 8),
    Day = c(1, 2),
    Cows = c(4, 5),
    Bulls = c("seven", 9),
    UnknownAdults = c(0, 1),
    Yearlings = c(0, 0),
    Calves = c(4, 3)
  )

  expect_error(
    check_recruitment_col_types(df),
    regexp = "The following value\\(s\\) in column 'Bulls' should be a integer:"
  )
})

test_that("throws error when UnkownAdults column has a character value", {
  df <- data.frame(
    PopulationName = c("PopA", "PopB"),
    Year = c(2020, 2020),
    Month = c(7, 8),
    Day = c(1, 2),
    Cows = c(4, 5),
    Bulls = c(7, 9),
    UnknownAdults = c("zero", 1),
    Yearlings = c(0, 0),
    Calves = c(4, 3)
  )

  expect_error(
    check_recruitment_col_types(df),
    regexp = "The following value\\(s\\) in column 'UnknownAdults' should be a integer:"
  )
})

test_that("throws error when Yearlings column has a character value", {
  df <- data.frame(
    PopulationName = c("PopA", "PopB"),
    Year = c(2020, 2020),
    Month = c(7, 8),
    Day = c(1, 2),
    Cows = c(4, 5),
    Bulls = c(7, 9),
    UnknownAdults = c(0, 1),
    Yearlings = c("zero", 0),
    Calves = c(4, 3)
  )

  expect_error(
    check_recruitment_col_types(df),
    regexp = "The following value\\(s\\) in column 'Yearlings' should be a integer:"
  )
})

test_that("throws error when Calves column has a character value", {
  df <- data.frame(
    PopulationName = c("PopA", "PopB"),
    Year = c(2020, 2020),
    Month = c(7, 8),
    Day = c(1, 2),
    Cows = c(4, 5),
    Bulls = c(7, 9),
    UnknownAdults = c(0, 1),
    Yearlings = c(0, 0),
    Calves = c("four", 3)
  )

  expect_error(
    check_recruitment_col_types(df),
    regexp = "The following value\\(s\\) in column 'Calves' should be a integer:"
  )
})

test_that("Passes when all data types are correct", {
  df <- data.frame(
    PopulationName = c("PopA", "PopB"),
    Year = c(2020, 2020),
    Month = c(7, 8),
    Day = c(1, 2),
    Cows = c(4, 5),
    Bulls = c(7, 9),
    UnknownAdults = c(0, 1),
    Yearlings = c(0, 0),
    Calves = c(4, 3)
  )

  expect_equal(
    nrow(check_recruitment_col_types(df)),
    2
  )
})

test_that("throws error when dataframe is empty ie no data added to template", {
  df <- setNames(
    data.frame(matrix(ncol = 9, nrow = 0)),
    c(
      "PopulationName", "Year", "Month", "Day", "Cows", "Bulls",
      "UnknownAdults", "Yearlings", "Calves"
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
    Day = c(1, 2),
    Cows = c(4, 5),
    Bulls = c(7, 9),
    UnknownAdults = c(0, 1),
    Yearlings = c(0, 0),
    Calves = c(4, 3),
    NewCol = c(4, 5)
  )

  template <- readxl::read_excel(
    system.file(
      "app/www/template-recruitment.xlsx",
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
    Day = c(1, 2),
    Cows = c(4, 5),
    Bulls = c(7, 9),
    UnknownAdults = c(0, 1),
    Yearlings = c(0, 0)
  )

  template <- readxl::read_excel(
    system.file(
      "app/www/template-recruitment.xlsx",
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
    Day = c(1, 2),
    Cows = c(4, 5),
    Bulls = c(7, 9),
    UnknownAdults = c(0, 1),
    Yearlings = c(0, 0),
    Calves = c(4, 3)
  )

  template <- readxl::read_excel(
    system.file(
      "app/www/template-recruitment.xlsx",
      package = "bboushiny"
    )
  )

  expect_silent(check_col_names(template, df))
})
