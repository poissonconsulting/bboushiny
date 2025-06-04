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

test_that("returns error and message", {
  foo <- function() {
    message("message 1")
    stop("RUNTIME ERROR: Compilation error on line 15")
  }
  output <- suppressMessages(catch_output_and_messages(foo()))

  expect_match(output[[1]], "RUNTIME ERROR: Compilation error on line 15")
  expect_match(output[[2]], "message 1")
})

test_that("returns error and two message", {
  foo <- function() {
    message("message 1")
    message("message 2")
    stop("RUNTIME ERROR: Compilation error on line 15")
  }
  output <- suppressMessages(catch_output_and_messages(foo()))

  expect_match(output[[1]], "RUNTIME ERROR: Compilation error on line 15")
  expect_equal(output[[2]], c("message 1", "message 2"))
})

test_that("returns result and two message", {
  foo <- function() {
    message("message 1")
    message("message 2")
    2 + 2
  }
  output <- suppressMessages(catch_output_and_messages(foo()))

  expect_equal(output[[1]], 4)
  expect_equal(output[[2]], c("message 1", "message 2"))
})

test_that("returns result with real example survival and 1 message", {
  withr::with_envvar(
    new = c(`_R_S3_METHOD_REGISTRATION_NOTE_OVERWRITES_` = "false"),
    {
      x <- bboudata::bbousurv_a

      expect_output(
        output <- suppressMessages(
          catch_output_and_messages(
            bboutools::bb_fit_survival(data = x, nthin = 1)
          )
        )
      )

      expect_type(output[[1]], "list")
      expect_equal(length(output[[1]]), 4L)
      expect_equal(
        output[[2]],
        c("Removed 1 rows with 'StartTotal' value of 0.")
      )
    }
  )
})

test_that("returns result with real example recruitment and 1 message", {
  withr::with_envvar(
    new = c(`_R_S3_METHOD_REGISTRATION_NOTE_OVERWRITES_` = "false"),
    {
      library(bboutools)
      x <- bboudata::bbourecruit_a
      x[1, 5] <- NA_integer_
      x[2, 5] <- NA_integer_

      expect_output(
        output <- suppressMessages(catch_output_and_messages(
          bboutools::bb_fit_recruitment(data = x, nthin = 1)
        ))
      )

      expect_type(output[[1]], "list")
      expect_equal(length(output[[1]]), 4L)
      expect_equal(
        output[[2]],
        c("Removed 2 rows with missing values.")
      )
    }
  )
})

test_that("returns error with real example of bbousurv", {
  withr::with_envvar(
    new = c(`_R_S3_METHOD_REGISTRATION_NOTE_OVERWRITES_` = "false"),
    {
      x <- bboudata::bbousurv_a[1:12, ]
      x[2, 3] <- NA_integer_

      output <- suppressMessages(
        catch_output_and_messages(
          bboutools::bb_fit_survival(data = x, nthin = 1)
        )
      )

      expect_match(
        output[[1]],
        "Month must not have any missing values."
      )
    }
  )
})

# Set Caribou Date ----

test_that("caribou year and month is adjusted and months are in sequence", {
  data <- data.frame(
    Month = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 1),
    Year = c(rep(2002, 12), rep(2003, 1))
  )

  output <- add_caribou_year(data, 2)

  expect_s3_class(output, "data.frame")
  expect_equal(
    output$Month,
    c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 1)
  )
  expect_equal(
    output$Year,
    c(
      2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002, 2002,
      2003
    )
  )
  expect_equal(
    output$CaribouMonth,
    c(12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
  )
  expect_equal(
    output$CaribouYear,
    c(
      "2001-2002", "2002-2003", "2002-2003", "2002-2003", "2002-2003",
      "2002-2003", "2002-2003", "2002-2003", "2002-2003", "2002-2003",
      "2002-2003", "2002-2003", "2002-2003"
    )
  )
})

test_that("caribou year and month when one month a missing in seq", {
  data <- data.frame(
    Month = c(1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 1, 2),
    Year = c(rep(2002, 11), rep(2003, 2))
  )
  output <- add_caribou_year(data, 2)
  expect_snapshot(output)
})

test_that("caribou year and month when starts at not 1", {
  data <- data.frame(
    Month = c(2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 1, 2, 3, 4, 5, 6, 7, 8),
    Year = c(rep(2002, 11), rep(2003, 8))
  )
  output <- add_caribou_year(data, 6)
  expect_snapshot(output)
})
