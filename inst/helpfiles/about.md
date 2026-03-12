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

## About the Boreal Caribou Population Growth App

The Ministry of Environment and Climate Change Canada is responsible for
the recovery and protection of boreal caribou across Canada. This app
sets out to create a standardized method for analyzing boreal caribou
survival and recruitment data to estimate population growth.

The `bboushiny` app makes generating estimates easy by having a streamlined
design and uses the [bboutools](https://poissonconsulting.github.io/bboutools/) R package under the hood.
The app uses default values for most model parameters.
There will be the odd case where the default parameters will not get convergence of the model, in this case the
app will provide an error message and direct you to the [bboutools](https://poissonconsulting.github.io/bboutools/) package.
The [bboutools](https://poissonconsulting.github.io/bboutools/) package allows for customization of the models beyond the defaults set in the app.

### bboutools Documentation

For full details on the models, methods and features used by this app,
see the [bboutools](https://poissonconsulting.github.io/bboutools/) package documentation.

- [Getting Started](https://poissonconsulting.github.io/bboutools/articles/bboutools.html) —
Overview of data formats, model fitting, and predictions for survival, recruitment and population growth.

- [Analytical Methods](https://poissonconsulting.github.io/bboutools/articles/methods.html) —
Detailed model specifications for the survival and recruitment models used by this app,
including the Bayesian framework, random and fixed effects, and population growth calculations.

- [Prior Selection and Influence](https://poissonconsulting.github.io/bboutools/articles/priors.html) —
Explanation of the default priors and how they influence estimates.
Covers national disturbance-informed priors, which can be set in the app via the Anthropogenic Disturbance inputs.

- [Extensions](https://poissonconsulting.github.io/bboutools/articles/extensions.html) —
Multi-population analysis, aggregate annual survival data,
prediction for unobserved years (the "Allow Missing Years" option in the app),
and prior-only sampling.

### References

DeCesare, Nicholas J., Mark Hebblewhite, Mark Bradley, Kirby G. Smith,
David Hervieux, and Lalenia Neufeld. 2012. "Estimating Ungulate
Recruitment and Growth Rates Using Age Ratios." The Journal of Wildlife
Management 76 (1): 144–53. [https://doi.org/10.1002/jwmg.244](https://doi.org/10.1002/jwmg.244)

Hatter, Ian, and Wendy Bergerud. 1991. "Moose Recuriment Adult Mortality
and Rate of Change" 27: 65–73.
