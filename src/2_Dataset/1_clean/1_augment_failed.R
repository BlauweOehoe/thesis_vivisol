library(tidyverse)
library(dplyr)

##this code is for augmenting the cases.
##several cases have different flows and if they dont succeed, case still gets completed, 
#this is seen as the last compliance registration, which is made at the closing day is 0 0 NA

df<-read.csv("gen/output/dataset.csv") %>% 
  mutate(Case_ClosedDate1 = as.Date(Case_ClosedDate1))
ath_filter<-read.csv("gen/temp/ath_case.csv") %>% 
  mutate(Registration_Date__c = as.Date(Registration_Date__c))

#count case status beforehand
library(plyr)
count(df$case_status)
detach("package:plyr", unload = TRUE)


##create value with all exception contract treatment jobs
u_ctj<- c("Uitlezen Telemonitoring PAP",
          "Uitlezen na 6 maanden PAP",
          "Uitlezing na 1 maand PAP",
          "Uitlezing na 12 maanden PAP",
          "Uitlezing na 2 weken PAP",
          "Uitlezing na 3 maanden PAP",
          "Uitlezen PAP",
          "Periodiek uitlezen Telemonitoring PAP")

#give filter dataframe adherance on which to filter out
colnames(ath_filter) <- paste("filter", colnames(ath_filter), sep = "_") 

ath_filter2<- ath_filter %>%   
  mutate(Account_Treatment__c = filter_Account_Treatment__c,
         validation_date = filter_Registration_Date__c) %>% ##for a valid change in communi
  select(-c(filter_Account_Treatment__c,
  ))

by_filter<- join_by("Account_Treatment__c" == "Account_Treatment__c",
                  closest("Case_ClosedDate1" <= "validation_date"))

df_ath_filter<-left_join(df, ath_filter2, by_filter) %>% ##keep validation date, as this is needed to filter out shizzle
  select(-validation_date)
rm(ath_filter,
   by_filter)

##filter all contract treatment jobs which have Compliance registration on closure date, which signifies failure
f_ctj1<-df_ath_filter %>% 
  filter(Contract_Treatment_Job_Name__c %in% u_ctj) %>% 
  mutate(filter_Registration_Date__c1 = as.Date(filter_Registration_Date__c)) %>% 
  filter(Case_ClosedDate1 == filter_Registration_Date__c1,
         is.na(filter_AHI_After_treatment__c),
         filter_Compliance_days_a_week__c == "0",
         filter_Compliance_Hours_Night_h_min__c == "0h 0min") %>% 
  select(related_id) %>% 
  distinct()

df_failed <- df %>% 
  filter(related_id %in% f_ctj1$related_id) %>% 
  mutate(case_status = "failed")
df_notfailed <- df %>% 
  filter(!related_id %in% f_ctj1$related_id)

df2<-rbind(df_failed, df_notfailed) 

write.csv(df2, "gen/temp/df2.csv", row.names = FALSE)

#count alterations made
library(plyr)
count(df2$case_status)
detach("package:plyr", unload = TRUE)

