# Actuarial Theory and Practice A - Team Echo
By: Terence Chenh and Jian Wang

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

For all 4 hazard areas, the variance of the data was substantially greater than the mean, making the Poisson distribution unsuitable as the key assumption for the Poisson distribution is that the mean and variance is approximately equal. Therefore, the Negative Binomial was used to model the claim frequencies for each individual hazard area.

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

Based on these indicators, the Lognormal distribution was the best fit for the Business Interruption and Equipment Failure hazards as all test statistics and information criteria for the Lognormal distirbution were the lowest out of the 3 candidate models. Similarly, the Log-logistic distribution is the most suitable model for modelling Cargo Loss and Worker's Compensation claims.

## Aggregates and Simulation
Models for each of the hazards were then built using all covariates excluding ID related variables due to ID variables having too much granularity which would potentially overfit the datasets. The exposure covariate was also removed from the severity models as it was already accounted in the frequency models and the aggregate expected loss was calculated using the expected frequency, variance and claim amounts. 50000 simulations were then run for each hazard to produce projected values and confidence intervals for expected shortfall and value at risk.

## Pricing
The projected aggregate loss for each hazard was then divided by the total exposure in frequency to obtain a premium value per unit of annual exposure. Next, a risk loading factor based on the 95% (industry standard) confidence interval for value at risk was used over a percentage factor to account for different risk profiles and affordability for lower claim severities. Similarly, a 5% profit margin was chosen to support affordability and applied to the claim to obtain a final premium price per year of annual exposure.

## Solar Systems
The same process was then run across each solar system by selecting data rows from each individual solar system to investigate the different risk profiles. Cargo Loss was assumed to not be tied to a singular solar system and hence was excluded from the modelling process. Zeta was found to have the highest aggregate loss at $20668030903, followed by Epislon at $19011315936 and Helionis Cluster at $8886363866.

## Sensitivity Analysis and Scenario Testing
Three scenarios for sensitivity analysis were considered:
- Moderate Shock (+20% frequency, +25% severity)
- Significant Shock (+40% frequency, +50% severity)
- Worst Case Shock (+80% frequency, +100% severity)

## Capped Data
A final run through of the initial capped data was conducted to investigate model differences between datasets. The capped data model was found to have significantly lower, priced premiums which was expected as high claim frequencies and severities outside the given data range were truncated down to the maximum values. Additionally, as the original dataset was tail heavy, we concluded that the capped model was not realistic as it would not account for possible tail risk events.

# Risk Profiles
## Helionis Cluster
In the Helionis Cluster, the 2 planets used for mining have largely stable environments which have ‘hosted long-standing mining operations’, where high level risks would be extremely rare on the surface. The main risk on the ground revolves around the use of older equipment, where 5% of the machinery within the Helionis Cluster has been used for over 20 years. Conversely, the other 2 solar systems do not use any equipment over 20 years old to mitigate the risk of a natural breakdown, thus making extractors and carriers from the Helionis Cluster more susceptible to mechanical failures and increased maintenance costs. In addition to the risks faced on the surface, the main dangers which Galaxy General Insurance must consider what lies within the asteroid clusters in the outer system. From inventory damage caused by direct asteroid collisions to the occasional relocation of satellites, the logistics of the supply route creates the most volatility. Consequently, this has resulted in higher premiums for cargo loss and equipment failure insurance which reflects the higher risk of transporting goods in and out of a potentially dangerous asteroid zone in the Helionis Cluster.

## Bayesia System
The risk profile of the Bayesian system is almost the opposite of the Helionis cluster. Satellite communication and supply routes have been well established with stable asteroid movements, while the ground operations are prone to the most risk. With spikes in temperature and radiation, this places a large portion of exploration and extraction operators in danger of health issues such as hyperthermia or radiation induced cancer, while this extreme environment may also damage mining equipment. As a result, Galaxy General Insurance has set higher premiums when insuring worker’s compensation, since the main dangers in the Bayesian system affect the physical safety of employees.

## Oryn Delta
The Oryn Delta presents the greatest volatility to claim frequency and severity in all hazard areas. With increasing ventures beyond the habitable zone, accurate pricing of insurance policies becomes more difficult as there is no guarantee the developing infrastructure can sustain long-term operations in more dangerous regions. Even if these operations are successful, the supply routes are not well established and it is uncertain what other dangers lie beyond the habitable zone, which will significantly impact business interruption, cargo loss and equipment failure claims. Low knowledge of unreported risks to employees such as high levels of radiation or other toxic chemicals in the environment would pose a major threat to ground workers such as geologists and drilling operators. Similarly, unforeseen cosmic radiation would negatively affect spacecraft operators, leading to increased claims for worker’s compensation relative to the other solar systems. Therefore, insurance premiums for Oryn Delta are priced higher than the Helionis Cluster and the Bayesian system to reflect the increased risk.

See the full breakdown of risks per solar system and hazard area here: [Risk Assessment](https://github.com/terence-chen-h/group-page-showcase-team-echo/blob/main/Risk%20Assessment.docx)


