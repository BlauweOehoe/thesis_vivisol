ath_case<-read.csv("gen/temp/ath_case.csv")
cases<-read.csv("gen/temp/cases.csv")

ath_case1<-ath_case %>% 
  filter(Compliance_days_a_week__c == "0")

library(plyr)
detach("package:plyr", unload = TRUE)


count(ath_case1$AHI_After_treatment__c)

write.csv(cases_1<-"gen/temp/cases_1")
rm(
ath_case)