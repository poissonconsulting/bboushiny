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

#### Instructions for using the App

**Overall workflow**

1. Download the templates and fill in with data
2. Upload the data and generate an estimate
3. Both survival and recruitment estimates are required before being able to 
calculate population growth

**Demo Data**

There is a demo data set built into the app. 
If it is your first time using the app we suggest you run through the steps using the demo data as it will help to teach you how to use the app and ensure all the functionality is working before trying to upload your own data. 
The demo data is an example for what the uploaded data set should look like.

**General template information**

- The template provided must be used.
- The column names cannot be altered.
- Do not add or delete columns.
- For descriptions on each columns check the instructions on the tab.
- If you are unsure of how the data should be structured then check out the demo data set for an example.

**Where is help located**

Each tab has its own Instructions help file which is a located in the
Instructions box next to the word Instructions. To have the instructions pop up 
press the circle with the question mark in it. 

**Clearing estimates**

When a new file is uploaded it will clear the estimate on the tab. 
Selecting a different population will clear the estimate on the tab. 
Restarting your browser will clear the entire app. 

**Please fix the following issue...**

The app will provide informative error and help messages to guide you through
the process. If a box pops up saying 'Please fix the following issue...' read the 
message to understand the instructions provided. This may include making changes 
to the data and uploading it again. If this box pops up you must rectify the
issue to continue.

**Model did not converge**

The app tries multiple values for the model thinning and checks after each run
to determine if the model converged. As thinning increases the run time for the 
model will increase. A pop up box will appear if the model does not converge and will direct you to use [bboutools](https://poissonconsulting.github.io/bboutools/).

Population growth cannot be calculated in the app unless both the survival and 
recruitment models converge. 

**App is not working**

If it appears that the app has frozen or is not responding try restarting your
browser. Different browsers may display information differently, try a different
browser if the app is not working. R shiny applications can take some time
to generate results; ensure you have waited enough time before restarting.

There is a progress box located in the bottom right corner of the app to show
when the app is performing a task in the background.

**How to report a problem**

Post an issue in the [GitHub Repository](https://github.com/poissonconsulting/bboushiny/issues).
