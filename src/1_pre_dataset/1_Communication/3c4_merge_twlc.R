library(dplyr)
library(tidyverse)
library(plyr)
detach("package:plyr", unload = TRUE)
library(data.table)
library(tibble)

#load in the data
cases<-read.csv("gen/temp/atj_cases.csv")
communications<-read.csv("gen/temp/communications.csv")

#join the cases to the communications
merge_twc<-left_join(communications, cases, by =c("related_id" = "case_id" )) 
 
##adding the number of case communications for every communication which has a case
#split up dataset into groups with case and without

#group 1: communications with case
comm_case<-merge_twc %>%
  filter(!is.na(case_status)) %>% 
  mutate(communication_date = as_datetime(communication_date),
         Account__c = Account__c.y,
         Account_Treatment__c = Account_Treatment__c.y,
         ) %>% 
  filter(!is.na(communication_date)) %>% 
  select(comm_id,
         related_id,
         communication_date, 
         communication_type, 
         case_status, 
         Case_ClosedDate,
         Account__c,
         Account_Treatment__c,
         Account_Treatment_Job__c,   
         Contract_Treatment_Job_Name__c,) 

comm_case_2<-comm_case %>% 
  group_by(related_id) %>% 
  mutate(last_comm = max(communication_date),
         first_comm = min(communication_date)) %>% 
  ungroup(related_id) 

#group 2 communications with no case
comm_nocase<-merge_twc %>% 
  filter(is.na(case_status)) %>% 
  mutate(communication_date = as_datetime(communication_date),
         Account__c = Account__c.x,
         Account_Treatment__c = Account_Treatment__c.x) %>% 
  filter(!is.na(communication_date)) %>% 
  select(comm_id,
         related_id,
         communication_date, 
         communication_type, 
         case_status, 
         Case_ClosedDate,
         Account__c,
         Account_Treatment__c,
         Account_Treatment_Job__c,   
         Contract_Treatment_Job_Name__c)

##add last& first communication of the RelatedId
comm_nocase_2<-comm_nocase %>% 
  group_by(related_id) %>% 
  mutate(last_comm = max(communication_date),
         first_comm = min(communication_date)) %>% 
  ungroup(related_id) 

#join communication with and without case back together
communications_case<-rbind(comm_case_2, comm_nocase_2) %>% 
  filter(!is.na(Account__c))
  
write.csv(communications_case, "gen/temp/communications_case.csv", row.names = FALSE)

rm(cases)
rm(comm_case)
rm(comm_nocase)
rm(comm_case_2)
rm(comm_nocase_2)
rm(communications)
rm(merge_twc)
rm(merge_twc2)
rm(merge_twc3)
rm(merge_twc4)
rm(communications_case)

