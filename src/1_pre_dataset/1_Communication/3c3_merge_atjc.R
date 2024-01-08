library(dplyr)
library(tidyverse)

cases_1<-read.csv("gen/temp/cases_1.csv")
atj_names<-read.csv("gen/temp/atj_names.csv")

atj_cases<-left_join(cases_1, atj_names, by = "Account_Treatment_Job__c")

write.csv(atj_cases, "gen/temp/atj_cases.csv", row.names = FALSE)

rm(cases_1,
   atj_names,
   atj_cases)
