# bboushiny 0.3.1

- Fixed bug in R Code tab where generated code used wrong argument name for `read_excel()`.
- Added `nimbleQuad` to Depends.

# bboushiny 0.3.0

Updated for bboutools 1.3.0 and bboudata 0.4.0.

- Added support for multi-population joint models by selecting "All" in the population dropdown.
- Added "Allow Unobserved Years" checkbox for datasets with placeholder rows for years without observations.
- Added optional national disturbance priors inputs (% anthropogenic and % fire excluding anthropogenic).
- Replaced modal dialog notifications with persistent toast notifications (info, warning, error).
- Removed `sex_ratio` parameter from predict and plot calls (now stored as attribute on fit object).
- Updated data plots to facet by PopulationName and CaribouYear for multi-population data.
- Updated help files with documentation for new features.
- Rewrote About page to link to bboutools articles instead of duplicating model specifications.

# bboushiny 0.2.2

- Added option to select recruitment reporting method (adjusted recruitment or calves per adult female)
- Added clarification on this in help file. 

# bboushiny 0.2.1

- On the Survival tab the Data Plot now filters out missing data instead of throwing an error and not rendering the plot. 
- On the Survival tab the Data Table does not sort by the CaribouYear and CaribouMonth anymore.
- On the Survival tab Include Uncertain Mortalities is checked by default. 
- On the Recruitment tab under Choose Sex Ratio the option name has changed from Yearling Female to Calf Female.
- On the Population Growth tab the pop up that lets users know the code is running was updated to saying "Generating results."
- The R Code tab has sex ratio parameter added to the predict functions. 
- Bug fixes and internal changes. 

# bboushiny 0.2.0

- Ticked box added to allow for option to add Trend in the Survival and Recruitment tabs.
- Added button to load demo data for both the Survival and Recruitment tab.
- App will now show the error message in a pop-up box and stop the model instead of crashing when the model hits an error. 
- A new tab named R Code was added to the app that writes the bboutools R code that is used.
- A numeric input box on the Recruitment tab for the yearling female sex ratio was added. 
- The ability to uploaded both csv files and xslx files was added to the app for both the Survival and Recruitment tab. 
- A drop-down field was added to the Survival tab to allow users to select the start month of the Caribou year, this value is carried forward to the Recruitment tab.
- Instructions in the Survival tab were updated.
- Instructions in the Recruitment tab were updated.
- The Survival tab data plot is sorted by caribou year. 
- The Survival tab data table has a CaribouMonth and CaribouYear column added to it. 
- The Recruitment tab data plot is faceted by year and sorted by caribou year. 
- The Population Growth tab had Population Change outputs added to it. 
- Various bug fixes.

# bboushiny 0.1.0

- Added a `NEWS.md` file to track changes to the package.
