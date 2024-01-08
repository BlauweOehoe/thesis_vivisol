library(dplyr)
library(tidyverse)

cases_df<-read.csv("gen/data/Cases.csv")

#creating case number and status
cases_1<- cases_df %>% 
  mutate(
         Account_Treatment__c, ##treatment of patient
         case_id = Id, #id of case
         case_status =  Status, #status of case, pivotal variable for analysis
         Account__c = Patient__c, ##patient unique identifier
         Case_ClosedDate = ClosedDate #date at which the case is finalised
  ) %>%
  filter(case_status == "Canceled" |
         case_status == "Closed",) %>% ##•	Filter only cases which are relevant for our research
  select(#select all the relevant variabels
    case_id,
    case_status,
    Account_Treatment_Job__c,
    Account__c,
    Account_Treatment__c,
    Case_ClosedDate
  )

write.csv(cases_1, "gen/temp/cases_1.csv", row.names = FALSE)

rm(cases_df,
   cases_1)

