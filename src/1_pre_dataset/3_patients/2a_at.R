library(plyr)
detach("package:plyr", unload = TRUE)
library(tidyverse)
library(dplyr)

at_df<-read.csv("gen/data/AT.csv")

v1_at<-at_df %>% 
  filter(Treatment_Type__c == "PAP") %>% ##make sure only pap patients enter the dataset
  mutate(Account_Treatment__c = Id) %>% 
  add_count(Account__c, name = 'n_at') %>% 
  select(Account__c,
         Account_Treatment__c,
         VIV_Account_External_Id__c,
         Trial_Contract_Treatment__c,
         Activation_Date__c,
         Deactivation_Date__c,
         Status__c,
         n_at
  )

#add the first activation date and last deactivation date per an account
v2_at<-v1_at %>% 
  mutate(Activation_Date__c = as_datetime(Activation_Date__c),
         Deactivation_Date__c = as_datetime(Deactivation_Date__c)) %>% 
  group_by(Account__c) %>% 
  mutate(min_activation_date = min(Activation_Date__c),
         max_Deactivation_Date__c = max(Deactivation_Date__c)) %>% 
  ungroup()

##show if an account had trial
trial_account<-v2_at %>% 
  filter(Trial_Contract_Treatment__c == "1") %>% 
  mutate(acc_trial = Trial_Contract_Treatment__c,
         analysis_enddate = Deactivation_Date__c +days(366))%>% 
  select(Account__c,
         acc_trial,
         analysis_enddate,) %>% 
  distinct(Account__c, .keep_all = TRUE)

no_trial_account<-v2_at %>% 
  filter(!Account__c %in% trial_account$Account__c) %>% 
  mutate(acc_trial = Trial_Contract_Treatment__c,
         analysis_enddate = as_datetime("2025-01-01")) %>% 
  select(Account__c,
         acc_trial,
         analysis_enddate) %>% 
  distinct(Account__c, .keep_all = TRUE)

trial_status<-rbind(trial_account, no_trial_account) 
rm(trial_account, no_trial_account)

##get all active accounts
v3a_df<-v2_at %>% 
  filter(Status__c == "A") %>% 
  distinct(Account_Treatment__c, .keep_all = TRUE) %>% 
  mutate(acc_status = 1)
v4a_df<-left_join(v3a_df, trial_status, by = ("Account__c"))
  
##get all inactive accounts
v3b_df <- v2_at %>% 
  filter(Status__c != "A",
         !Account_Treatment__c %in% v3a_df$Account_Treatment__c) %>% 
  distinct(Account_Treatment__c, .keep_all = TRUE) %>% 
  mutate(acc_status = 0) 
v4b_df<-left_join(v3b_df, trial_status, by = ("Account__c"))

#rectify acc_status
v4a_df$acc_status<-ifelse(v4a_df$analysis_enddate < v4a_df$max_Deactivation_Date__c, 1,  0)
v4b_df$acc_status<-ifelse(v4b_df$analysis_enddate < v4b_df$max_Deactivation_Date__c, 1,  0)

v5b<-rbind(v4a_df, v4b_df) 

#make sure that patient who are never deactivated have an active account
v6a<-v5b %>% 
  filter(is.na(acc_status)) 
v6a$acc_status<-ifelse(is.na(v6a$max_Deactivation_Date__c) == TRUE, 1, 0)

v6b<-v5b %>% 
  filter(!is.na(acc_status))

v6<-rbind(v6a, v6b) %>% 
  select(Account__c, #merging residual communications
         Account_Treatment__c,#merging communications
         VIV_Account_External_Id__c, #merging adherance
         acc_trial, #indicates if account has a trial account
         n_at, ##indicates the total number of account treatment in dataset
         acc_status, ##indicates if account is still active at analysis enddate
         Activation_Date__c, ##indicates when the AT was activated
         Deactivation_Date__c, ##indicates when AT was deactivated
         max_Deactivation_Date__c, ##indicates when the last time a AT deactivation was
         analysis_enddate) ##indicates when our research stops

write.csv(v6, "gen/temp/patients.csv", row.names = FALSE)

##patient descriptives
rm(at_df)
rm(
  v1_at)
rm(v2_at)
rm(trial_status)
rm(v3a_df,
   v3b_df,
   v4a_df,
   v4b_df,
   v5b,
   v6,
   v6a,
   v6b)



