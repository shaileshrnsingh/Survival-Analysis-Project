# DDA project (Survival Analysis part)
# Part 1 : Kaplan Meier Curve

# Check the assumptions of Kplan Meier
# Edit the dataset to 0 and 1 for relapse
# find mean median SD with CI & make conclusions

# The assumptions are as follows, 
# {to be confirmed if the eanings are interpreted correctly}

# The survival probabilities are same for all the individuals who joined 
#late as well early. .....SATISFIED
# The occurrence of an event of interest happens at the specified time. ....SATISFIED we have specific dates of relapses.
# At any time, subjects who are censored have the same survival prospects as 
#those who continue to be followed up. .....SATISFIED 

# Start date of study : 2021-08-04
# End date of study : 2024-07-25
# Thus, observations that did not relapse (event) till the end of the study are censored.
# From domain knowledge we have split alcohol and drug to make significant findings.

data = Final_dataset_relapse
data$Event = ifelse(data$relapse == "Yes",1,0)
max_value = difftime("2024-07-25","2021-08-04",units = "days")
max_value
# censoring helps is avoiding overestimating the relapse rate.

library(dplyr)
data$`Time till Relapse (Days)` = data$`Time till Relapse (Days)` %>%
  replace(is.na(.),1086)
#View(data)
# Now, we have both the imp columns the time & event. Thus, moving ahead with KM curve for the same.
#--------------------------------- KAPLAN MEIER -----------------------------------------------------------------
#Outcome variable
library(survival)
y = Surv(data$`Time till Relapse (Days)`,data$Event)
y
curve1 = survfit(y~1,data = data,conf.type = "plain")
str(curve1)
#install.packages("ggsurvfit")
library(ggsurvfit)
??ggsurvfit
survfit2(Surv(data$`Time till Relapse (Days)`, data$Event) ~ 1, data = data) %>%
  ggsurvfit() +
  labs(
    x = "Days",
    y = "Overall survival probability for Alcohol addicts",
    color = "Legend"
  ) + 
  add_confidence_interval() +
  add_risktable() +
  add_censor_mark(shape = 3, size = 2) +
  scale_color_manual(values = "blue", labels = "Alcohol Addiction")
# observation : there's a sudden drop.

# yaha legend kyu add nhi ho rha?
summary(curve1,times = 182.625)
# 0.907.........................6 months
summary(curve1,times = 365.25)
# 0.382.........................1 yr
summary(curve1,times = 365.25+182.625)
# 0.242........................1 yr 6 months

# CONCLUSION
# cumulative survival index showed that in the first six months, about 91% of
# the subjects did not experience relapse to alcohol, 
# while this index was around 38.2% after a yr.
# The index drops further to 24.2% in 18 months 
#and was consistent in the next follow up.

curve1
# Median = 266 days
# 266 days is the time corresponding to 0.5 prob.
# Shorter median -> quicker relapse
# High short term risk

summary(curve1)$table[5:6]
#    rmean     se(rmean) 
#   463.04037  20.11163 
# on an avg. a person remains alcohol free for 15 months + - 20 days.
# ------------------------------------------------------------------------------


#------------------------------LOG RANK TEST -----------------------------------
# married and other group [isolation]
data = Final_dataset_relapse
data$isolation = ifelse(data$`Marital Status` == "M",0,1)
# 0 : married ; 1 : remaining
data$Event = ifelse(data$relapse == "Yes",1,0)
library(survival)
curve2 =survfit(Surv(data$`Time till Relapse (Days)`,data$Event)~data$isolation,conf.type = "plain")
curve2 %>%
  ggsurvfit() +
  labs(
    x = "Days",
    y = "Overall survival probability for Alcohol addicts",
    color = "Legend"
  ) + 
  add_confidence_interval() +
  add_censor_mark(shape = 3, size = 2) +
  scale_color_manual(values = c("red", "blue"), labels = c("Married", "Remaining"))
# Married people seem to have slightly high chances of relapse
# It is human psychology anything can happen no judgements
survdiff(Surv(data$`Time till Relapse (Days)`, Event) ~ isolation, data = data)
# p= 0.8 > 0.05; thus there is nosignificance difference in relapse that married and remaining have.
#-------------------------------------------------------------------------------


#------------------------COX REGRESSION-----------------------------------------
library("survival")
library("survminer")

# Assumptions of Cox regression
# i). Proportional hazards assumption.
# ii). Assumption of no  influential observations (or outliers).
# iii). Assumption of nonlinearity in relationship between the log hazard 
#and the covariates.
# iv). The Covariates are assumed to be time independent variables.

View(data)
#change categorical variables to dummy variables
data$isolation = ifelse(data$`Marital Status` == "M",0,1)
data$employ = ifelse(data$`Employment Status` == "Employed",1,
                   ifelse(data$`Employment Status` == "N.E.",2,
                          ifelse(data$`Employment Status` == "Part Time",3,
                                 ifelse(data$`Employment Status` == "Pensioner",4,
                                        ifelse(data$`Employment Status` == "S.E.",5,
                                               ifelse(data$`Employment Status` == "Employed",6,
                                                      ifelse(data$`Employment Status` == "U.E.",7,8)))))))
View(data) # 8 = student
data$qual <- ifelse(data$Qualification == "Graduate", 1,
                    ifelse(data$Qualification == "H.S.C.", 2,
                           ifelse(data$Qualification == "Masters", 3,
                                  ifelse(data$Qualification == "Middle School", 4, 5))))

# Cox regression is deleting missing values. Thus, doing it after missing value imputation.
# To test for the proportional-hazards (PH) assumption
res.cox <- coxph(Surv(data$`Time till Relapse (Days)`, Event) ~ data$Age+data$isolation+data$qual+data$employ+data$`Annual Income`, data =  data)
test.ph = cox.zph(res.cox)
test.ph
#The global test is not statistically significant
# thus we can assume proportional hazards.
#install.packages("survminer")
library(survminer)
ggcoxzph(test.ph)
#all the lines look pretty straight to me. Thus, no pattern is formed with time.

# Testing influential observations
ggcoxdiagnostics(res.cox, type = "dfbeta",
                 linear.predictions = FALSE, ggtheme = theme_bw())
barplot(data$employ)
barplot(data$qual)
#There seems to be outliers
# almost all these variables are categorical. Do they still need treatment?
# it's just the composition of your sample, not an outlier.

# Non - linearity
# 23% blanks in annual income.
# 
ggcoxfunctional(
  Surv(`Time till Relapse (Days)`, Event) ~ 
    Age + log(Age) + sqrt(Age) +
    `Annual Income` + log(`Annual Income`) + sqrt(`Annual Income`), 
  data = data
)


# cannot perform non linearity on categorical variables.
