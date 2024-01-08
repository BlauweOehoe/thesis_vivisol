library(dplyr)
library(tidyverse)

patients<-read.csv("gen/temp/patients.csv")
communication_case<-read.csv("gen/temp/communications_case.csv")

test<-read.csv("gen/temp/comm_pat.csv")

#modifying patients file for AT
patients1<-patients %>% 
  mutate(Activation_Date__c = as_date(Activation_Date__c),
         Deactivation_Date__c = as.Date(Deactivation_Date__c))


##merge with AT
communication_at<-communication_case %>% 
  filter(Account_Treatment__c != "")
communication_at2<-left_join(communication_at, patients1, by = c("Account__c", "Account_Treatment__c"))
communication_at2b<-communication_at2 %>% 
  filter(!is.na(Activation_Date__c))

#modifying patients file for without at
patients2<-patients %>% 
  filter(!is.na(Deactivation_Date__c)) %>% 
  mutate(Deactivation_Date__c = as_date(Deactivation_Date__c),
         Activation_Date__c = as_date(Activation_Date__c))

patients3<-patients %>% 
  filter(is.na(Deactivation_Date__c)) %>% 
  mutate(Deactivation_Date__c = as_date("2025-06-30"), #replacing missing deactivation dates with a date far in the future
         Activation_Date__c = as_date(Activation_Date__c))

patients4<-rbind(patients2, patients3)
rm(patients2,patients3)

##merge without at
communication_no<-communication_case %>% 
  filter(Account_Treatment__c == "") %>% 
  mutate(communication_date = as_datetime(communication_date))

by<-join_by("Account__c" == "Account__c",
            "communication_date" >= "Activation_Date__c",
            "communication_date" < "Deactivation_Date__c")

communication_no2<-left_join(communication_no, patients4, by)

communication_no2b<-communication_no2 %>% 
  filter(!is.na(Activation_Date__c)) %>% 
  mutate(Account_Treatment__c = Account_Treatment__c.y,
         communication_date = as.character(communication_date)) %>% 
  select(-c(Account_Treatment__c.x, Account_Treatment__c.y))

comm_pat<-rbind(communication_at2b, communication_no2b)
summary(comm_pat$Activation_Date__c)



write.csv(comm_pat, "gen/temp/comm_pat.csv", row.names = FALSE)

#removing variables
rm(communication_case,
   patients)
rm(patients1,
   patients2,
   patients4)
rm(communication_at,
   communication_at2,
   communication_at2b,
   communication_no,
   communication_no2,
   communication_no2b,
   communication_no3)
rm(by,
   comm_pat,
   comm_pat2)

rm(patients1, patients4, )

