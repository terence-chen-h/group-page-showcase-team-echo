# Actuarial Theory and Practice A

_"Actl. What doesn't kill us makes us stronger. Unless we die." – Benjamin Franklin_

---
# Data Cleaning
Before modelling, data cleaning was required as the raw data provided had missing values and a range of data entry errors. To correct this, rows with missing values were removed and claim counts were rounded to the nearest integer. Another issue found was that the claim amounts for Worker's Compensation was $5-170, according to the provided Data Dictionary, which is highy unfeasible for employees that are injured for an extended period of time. As a result, our team interpreted this as a data entry error, instead, analysing the data under the assumption that the intended range was 5,000 to 170,000 per claim.

Run the full data cleaning code here: [Initial Cleaning](https://github.com/terence-chen-h/group-page-showcase-team-echo/blob/main/Initial%20Cleaning.ipynb)

---
# Model Selection
## Claim Frequency
For claim frequency, the main candidate models were:
- Poisson
- Negative Binomial

For all 4 hazard areas, the variance of the data was substantially greater than the mean, thus making the Poisson distribution unsuitable since the key assumption for this model is that the mean and variance is approximately equal. Therefore, the Negative Binomial was used to model the claim frequencies for each individual hazard area.

## Claim Severity
The potential distributions considered for modelling claim amounts were:
- Lognormal
- Weibull
- Log-logistic

Each distribution was fitted to the Business Interruption, Cargo Loss, Equipment Failure and Worker's Compensation datasets, using a range of goodness-of-fit tests and information criteria such as AIC and BIC to determine the best distribution for each hazard area. The results are displayed below:

Criteria|Lognormal|Weibull|Log-logistic
----|----|----|----
**Business Interruption**|-|-|-
Kolgomorov-Smirnov|**0.34**|0.39005|0.49098
Anderson-Darling|**1,570.91**|1,727.88|3,559.82
Cramer-von Mises|**312.338**|315.463|758.560
AIC|**292,265.5**|284,811.3|344,944.9
BIC|**292,279.9**|284,825.7|344,959.3
**Cargo Loss**|-|-|-
Kolgomorov-Smirnov|0.21781|0.23678|**0.20932**
Anderson-Darling|2,059.32|2,187.67|**1,896.23**
Cramer-von Mises|330.15|328.60|**288.671**
AIC|829,164.8|831,415.5|**822,862.3**
BIC|829,181.4|831,432.1|**822,878.9**
**Equipment Failure**|-|-|-
Kolgomorov-Smirnov|**0.0083**|0.0759|0.0212
Anderson-Darling|**0.7897**|127.24|6.0442
Cramer-von Mises|**0.1051**|18.082|0.8928
AIC|**195,722.3**|197,519.8|195,817.1
BIC|**195,736.3**|197,533.8|195,831.1
**Workers Comp**|-|-|-
Kolgomorov-Smirnov|0.4167|0.3978|**0.3923**
Anderson-Darling|442.60|437.61|**420.95**
Cramer-von Mises|90.850|91.957|**78.302**
AIC|37,015.89|38,480.55|**36,152.54**
BIC|37,026.96|38,491.62|**36,163.62**

Based on these indicators, the Lognormal distribution was the best fit for the Business Interruption and Equipment Failure hazards, while the Log-logistic model was the best for modelling Cargo Loss and Worker's Compensation claims.




### Congrats on completing the [2026 SOA Research Challenge](https://www.soa.org/research/opportunities/2026-student-research-case-study-challenge/)!


> Now it's time to build your own website to showcase your work.  
> Creating a website using GitHub Pages is simple and a great way to present your project.

This page is written in Markdown.
- Click the [assignment link](https://classroom.github.com/a/FxAEmrI0) to accept your assignment.

---

> Be creative! You can embed or link your [data](player_data_salaries_2020.csv), [code](sample-data-clean.ipynb), and [images](ACC.png) here.

More information on GitHub Pages can be found [here](https://pages.github.com/).

![](Actuarial.gif)
