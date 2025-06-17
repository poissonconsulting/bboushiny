<!-- NEWS.md is maintained by https://fledge.cynkra.com, contributors should not edit this file -->

# bboushiny 0.3.0

- Merge pull request #9 from poissonconsulting/joss_review.

  Joss review

- Merge pull request #6 from poissonconsulting/updates.

  Updates since changes to bboutools

- Merge pull request #4 from poissonconsulting/dev.

  changes to documentation following bboutools changes


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
