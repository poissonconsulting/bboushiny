<!---
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
-->

## Instructions for Using the Recruitment Analysis Tab

### Overview

Complete the steps in order. 

1. Download the template.
2. Confirm the Caribou Year start month is correct.
3. Fill in the template with your data and upload the file (csv or xlsx).
4. Select a population and confirm the data is correct by checking the table and plot section under the Data box.
5. Enter the sex ratio for Adults and Yearlings.
6. Select whether to include year trend.
7. Press the Estimate Recruitment button which will run the model and generate the outputs for the Results Box.

### Detailed Instructions

#### Download Template

Click the button to download an excel file to fill in with your data.

The data is checked against a basic set of checks when the Estimate Recruitment button is pressed. 
The description and rules for each column are listed below.

- PopulationName
  - Name of the herd or population
- Year
  - The calendar year the observation occurred 
  - Values must be an integer
- Month
  - The calendar month the observation occurred
  - Values must be an integer between 1 and 12
- Day
  - The day the observation occurred
  - Values must be an integer between 1 and 31
- Cows
  - The total number of cows counted in each group in a survey/year
  - Values must be a positive integer
- Bulls
  - The total number of bulls counted in each group in a survey/year
  - Values must be a positive integer
- UnknownAdults
  - The total number of adults counted that the sex could not be identified in each group in a survey/year
  - Values must be a positive integer
- Yearlings
  - The total number of yearlings that did not have the sex identified in each group in a survey/year
  - Values must be a positive integer
- Calves
  - The total number of calves counted in each group in a survey/year
  - Values must be a positive integer

#### Start Month of Caribou Year

This parameter is selected on the Survival tab.
This parameter allows a user to shift the time frame from using a calendar year where the first month of the year is January to a Caribou year where the start month of the twelve-month period can be selected.

If the start month is changed on the Survival tab after the results are run it will clear the results.

#### Upload Data or Use Demo Data

Click the Browse button and navigate to the template file you have filled in with your data. 
Select the file to upload your data into the app and the Table and Plot tabs in the Data box will be populated your data. 

There is also a sample data set provided to allow users to test the app without having to upload their own data.
Click on the Load Demo Data button to load in a sample data set. 

If a new dataset is loaded after the results are run it will clear the results.

#### Select Population

This option will contain a list of the PopulationName values once a dataset has been loaded into the app.
Only a single population can be selected at once.
The options will be sorted alphabetically.

To select a population click on the arrow in the drop-down box and select a different population. 

If the Select Population option is changed after the results are run it will clear the results.

#### Choose Sex Ratios

Recruitment is the expected number of calves per adult female.
The model sets the default probability of an unknown adult being female as 0.65.
The model sets the default probability of a yearling being female as 0.50.
The user can adjust this proportion with the Sex Ratio input boxes.

For adults enter a number between 0 and 1 for the expected proportion of unknown adults that are female.
If the sex ratio box is blank, then the probability is estimated from the proportion of bulls and cows using an informative prior of Beta(65, 35).
The probability of an unknown adult being female is assumed to be the same in all days in all years.

For yearlings enter a number between 0 and 1 for the expected proportion of yearlings that are female. 

The sex ratios that are chosen for the analysis will be included in the downloaded results tables. 

If the Sex Ratios option is changed after the results are run it will clear the results.

#### Include Year Trend

The default setting is to not have a year trend effect. 

If Include Year Trend is ticked **yes** the model will include a year trend effect.
When ticked **yes** you will see Table Trend and Plot Trend appear in the Results box.

If the Include Year Trend option is changed after the results are run it will clear the results.

#### Run Model & Results

Once data is loaded and all the correct options are selected, hit the Estimate Recruitment button.

The data is then run through a set of internal checks against the template rules.
If the internal checks fail, a pop-up window will appear providing a message of which data check did not pass.
The issue needs to be fixed by changing the data in the template file, uploading the corrected file and hitting the Estimate Survival button again.
This may take a few attempts as the app will only detect one issue at a time. 

The model will start running once the data follows all the required rules of the template and a box will appear in the bottom right corner of the screen to indicate which thinning value the model is running. 
The model run time will vary depending on the options and data provided, the model can  take upwards of 20 minutes to finish running. 
Be patient. 

If any additional data cleaning is done before feeding the data into the model a pop-up box will appear with notes about what was done. 

Once the model is done running the results will appear in the Results box. 

##### Table Year and Plot Year

- Predict recruitment by year.
  - CaribouYear Column
    - For example, when the Start Month of Caribou Year is set to April then each year starts in April so if the row has the CaribouYear of 1990, it represents April 1990 to March 1991.
- Plot annual recruitment estimates with credible limits.

##### Table Trend and Plot Trend

- Predict recruitment by year as trend line.
- Plots annual recruitment estimates as trend line with credible limits.

##### Downloading Results

The results can be downloaded as an excel or png file by clicking the download button on the right side of the Results box.

##### Clearing the Results

The results will be cleared when:

- the start month of the Caribou year is changed on the Survival tab.
- a new data set is loaded.
- a different population is selected from the drop-down menu.
- a sex ratio is changed.
- the include trend box is changed. 

#### Need More Help

Check out the Help tab for more information or trouble shooting. 
