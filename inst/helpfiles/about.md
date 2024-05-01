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

## About the Boreal Caribou Population Growth App

The Ministry of Environment and Climate Change Canada is responsible for
the recovery and protection of boreal caribou across Canada. This app
sets out to create a standardized method for analyzing boreal caribou
survival and recruitment data to estimate population growth. 

The `bboushiny` app makes generating estimates easy by having a streamlined 
design and uses the [bboutools](https://poissonconsulting.github.io/bboutools/) R package under the hood. 
The app sets default values for the model parameters and does not allow customization through the app. 
There will be the odd case where the default parameters will not get convergence of the model, in this case the
app will provide an error message and direct you to the [bboutools](https://poissonconsulting.github.io/bboutools/) package. 
The [bboutools](https://poissonconsulting.github.io/bboutools/) package allows for customization of the models beyond the defaults set in the app. 

### bboutools

[bboutools](https://poissonconsulting.github.io/bboutools/) estimates parameter values using a fully Bayesian approach
with random effects where appropriate and biologically reasonable
informative priors by default. It provides relatively simple general
models that can be used to compare survival, recruitment and population
growth estimates across jurisdictions. 
[bboutools](https://poissonconsulting.github.io/bboutools/) saves 1,000 MCMC
samples from each of three chains (after discarding the first halves).
As a result the user only has to increment the thinning rate as required
to achieve convergence (automated by Shiny app).

#### Survival Model

The annual survival in boreal caribou population is typically estimated
from the monthly fates of collared adult females.

[bboutools](https://poissonconsulting.github.io/bboutools/)
fits a Bayesian binomial monthly survival model to the
number of collared females and mortalities. The user can choose whether
to include individuals with uncertain fates with the certain
mortalities. By default weakly informative prior distributions that
are consistent with boreal caribou biology are used. Month is treated as
a random effect and by default, if there are five or more years, year is
also a random effect otherwise it is a fixed effect.

The survival model with annual random effect and trend is specified below in a
simplified form of the BUGS language for readability.

    b0 ~ Normal(4, 2)
    bYear ~ Normal(0, 1)
    sMonth ~  Normal(0, 2) T(0,)
    for(i in 1:nMonth)  bMonth[i] ~ Normal(0, sMonth)
    sAnnual ~  Exponential(1)
    for(i in 1:nAnnual)  bAnnual[i] ~ Normal(0, sAnnual)
    for(i in 1:nObs) {
      logit(eSurvival[i]) = b0 + bMonth[Month[i]] + bAnnual[Annual[i]] + bYear * Year[i]
      Mortalities[i] ~ Binomial(1 - eSurvival[i], StartTotal[i])
    }

#### Recruitment Model

The annual recruitment in boreal caribou population is typically
estimated from annual calf:cow ratios.

[bboutools](https://poissonconsulting.github.io/bboutools/)
fits a Bayesian Binomial recruitment model to the
annual counts of calves, cows, yearlings, unknown adults and potentially, bulls. 
The default values assume each calf is a female with a 
probability of 0.5 while each unknown adult is a female with a 
probability of 0.65 to account for the higher mortality of males. 
The user can adjust the sex ratios from the default as well as estimate the adult female ratio from the counts of bulls and cows. 
As with survival, weakly informative priors are used by default and if there are
five or more years, year is a random effect otherwise it is a fixed
effect. It is up to the user to ensure that the data are from surveys
that were conducted at the same time of year when calf survival is
expected to be similar to adult survival.

The recruitment model with annual random effect and year trend is specified below in a simplified form of the BUGS language for readability.

    b0 ~ Normal(-1, 5)
    bYear ~ Normal(0, 1)
    adult_female_proportion ~ Beta(65, 35)
    sAnnual ~  Exponential(1)
    for(i in 1:nAnnual)  bAnnual[i] ~ Normal(0, sAnnual)

    for(i in 1:nAnnual) {
    FemaleYearlings[i] ~ Binomial(0.5, Yearlings[i])
    Cows[i] ~ Binomial(adult_female_proportion, CowsBulls[i])
    OtherAdultsFemales[i] ~ Binomial(adult_female_proportion, UnknownAdults[i])
    logit(eRecruitment[i]) <- b0 + bAnnual[Annual[i]] + bYear * Year[i]
    AdultsFemales[i] <- max(FemaleYearlings[i] + Cows[i] + OtherAdultsFemales[i], 1)
    Calves[i] ~ Binomial(eRecruitment[i], AdultsFemales[i])
    }

The annual predicted rescruitment estimates are adjusted following methods outlined in DeCesare et al. (2012). See below for details. 

#### Growth Prediction

Following DeCesare et al. (2012), before calculating *λ* the annual
recruitment is first divided by two to give the expected number of
female calves per adult female (under the assumption of a 1:1 sex
ratio).

$$R_F = R/2$$

Next the annual recruitment is adjusted to give the proportional change
in the population.

$$R_\Delta =  \frac{R_F}{1 + R_F}$$

Finally *λ* is calculated using

$$\lambda = \frac{S}{1-R_\Delta}$$

Population change (%) is calculated with uncertainty as the cumulative product of population growth.

### References

DeCesare, Nicholas J., Mark Hebblewhite, Mark Bradley, Kirby G. Smith,
David Hervieux, and Lalenia Neufeld. 2012. “Estimating Ungulate
Recruitment and Growth Rates Using Age Ratios.” The Journal of Wildlife
Management 76 (1): 144–53. [https://doi.org/10.1002/jwmg.244](https://doi.org/10.1002/jwmg.244)

Hatter, Ian, and Wendy Bergerud. 1991. “Moose Recuriment Adult Mortality
and Rate of Change” 27: 65–73.
