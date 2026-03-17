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

Environment and Climate Change Canada is responsible for the recovery and protection of boreal caribou across Canada.
This app supports that mandate by providing a standardized approach for estimating boreal caribou survival, recruitment and population growth from monitoring data.

The app is built on the [bboutools](https://poissonconsulting.github.io/bboutools/) R package, which fits Bayesian models with sensible default parameters so that users can generate estimates without needing to write R code.
In cases where the model fails to converge, the app will notify you and recommend using [bboutools](https://poissonconsulting.github.io/bboutools/) directly, which offers full control over model parameters and priors.

### Documentation

For detailed information on the underlying models, methods and features, see the [bboutools](https://poissonconsulting.github.io/bboutools/) package documentation:

- [Getting Started](https://poissonconsulting.github.io/bboutools/articles/bboutools.html) — An introduction to data formats, model fitting, and generating predictions for survival, recruitment and population growth.

- [Analytical Methods](https://poissonconsulting.github.io/bboutools/articles/methods.html) — Full model specifications for the survival and recruitment models, including the Bayesian framework, random and fixed effects, and population growth calculations.

- [Prior Selection and Influence](https://poissonconsulting.github.io/bboutools/articles/priors.html) — An explanation of the default priors and how they influence parameter estimates. This article also covers national disturbance-informed priors, which are available in the app through the Anthropogenic Disturbance inputs.

- [Extensions](https://poissonconsulting.github.io/bboutools/articles/extensions.html) — Coverage of multi-population analysis, aggregate annual survival data, prediction for unobserved years (the "Allow Unobserved Years" option in the app), and prior-only sampling.

### References

DeCesare, Nicholas J., Mark Hebblewhite, Mark Bradley, Kirby G. Smith,
David Hervieux, and Lalenia Neufeld. 2012. "Estimating Ungulate
Recruitment and Growth Rates Using Age Ratios." The Journal of Wildlife
Management 76 (1): 144–53. [https://doi.org/10.1002/jwmg.244](https://doi.org/10.1002/jwmg.244)

Hatter, Ian, and Wendy Bergerud. 1991. "Moose Recruitment, Adult Mortality
and Rate of Change" 27: 65–73.
