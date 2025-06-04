<!---
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
-->

## Instructions for Using the Survival Analysis Tab

### Overview

Complete the steps in order. 

1. Download the template.
2. Select Start Month of Caribou Year.
3. Fill in the template with your data and upload the file (csv or xlsx).
4. Select a population and confirm the data is correct by checking the
table and plot section under the Data box.
5. Select whether to include uncertain mortalities by ticking the box (see section below for how uncertain mortalities and censoring work).
6. Select whether to include year trend.
7. Press the Estimate Survival button which will run the model and generate the outputs for the Results Box.

### Detailed Instructions

#### Download Template

Click the button to download an excel file to fill in with your data.

The data is checked against a basic set of checks when the Estimate Survival button is pressed. 
The description and rules for each column are listed below.

- PopulationName
  - Name of the herd or population
- Year
  - The calendar year the observation occurred 
  - Values must be an integer
- Month
  - The calendar month the observation occurred
  - Values must be an integer between 1 and 12
- StartTotal
  - The total number of collared caribou at the start of the month
  - Values must be a positive integer
- MortalitiesCertain
  - The total number of confirmed mortalities in that month
  - Values must be a positive integer
- MortalitiesUncertain
  - The total number of mortalities that were not confirmed in that month
  - Values must be a positive integer

#### Select Start Month of Caribou Year

The year and month column in the data should be the calendar year and month.
The app will add columns to the loaded data called CaribouMonth and CaribouYear based on the start month entered in Start Month of Caribou Year field.

The data table and plot will be updated if Select Start Month of Caribou Year option is changed after the data has been uploaded. 
The data that is fed into the model will use the caribou month and adjusted year values. 

If the Select Start Month of Caribou Year option is changed after the results are run it will clear the results.

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

#### Include Uncertain Mortalities

It is the user's responsibility to determine the fate of each individual that was alive and tagged at the start of a month.

If Include Uncertain Mortalities is ticked **yes** then the total mortalities used to fit the model is the sum of the certain mortalities and uncertain mortalities (MortalitiesCertain and MortalitiesUncertain columns); otherwise, only certain mortalities are used to fit the model.

The MortalitiesUncertain column is a place to represent mortalities the user is unsure if the individual died.
This may be due to collar failure, being unable to investigate the mortality or other circumstances.

Including the uncertain mortalities can be a helpful tool to determine how sensitive the survival estimates are to the fates of these individuals.
You can do this by first running the analysis with the Include Uncertain Mortalities box not ticked then rerun the analysis with the box ticked and compare the estimates. 
Don't forget to download your results after each run. 

The default setting is to include uncertain mortalities. 

To include the uncertain mortalities tick **yes**.

If the Include Uncertain Mortalities option is changed after the results are run it will clear the results.

#### Include Year Trend

If Include Year Trend is ticked **yes** the model will include a year trend effect.
When ticked **yes** you will see Table Trend and Plot Trend appear in the Results box.

The default setting is to not have a year trend effect. 

To include the year trend tick **yes**.

If the Include Year Trend option is changed after the results are run it will clear the results.

#### Run Model & Results

Once data is loaded and all the correct options are selected, hit the Estimate Survival button.

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

- Predict survival by year.
  - CaribouYear Column
    - For example, when the Start Month of Caribou Year is set to April then each year starts in April so if the row has the CaribouYear of 1990, it represents April 1990 to March 1991.
- Plots annual survival estimates with credible limits.

##### Table Month and Plot Month

- Predict survival by month.
- Plots monthly survival estimates with credible limits.
- Estimates represent annual survival if a given month lasted the entire year.

##### Table Trend and Plot Trend

- Predict survival by year as trend line.
- Plots annual survival estimates as trend line with credible limits.

##### Downloading Results

The results can be downloaded as an excel or png file by clicking the download button on the right side of the Results box.

##### Clearing the Results

The results will be cleared when:

- the start month of the Caribou year is changed.
- a new data set is loaded.
- a different population is selected from the drop-down menu.
- the include uncertain mortalities box is changed.
- the include trend box is changed. 

#### Need More Help

Check out the Help tab for more information or trouble shooting. 
