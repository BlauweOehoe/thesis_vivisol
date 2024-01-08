library(tidyverse)
library(dplyr)

df2<-read.csv("gen/temp/df2.csv") 

df2.1<-df2 %>% 
  group_by(related_id) %>% 
  add_count(related_id, name = 'n_case_communications') %>% 
  ungroup()


df3<-df2.1 %>% 
  group_by(Account__c) %>% 
  add_count(related_id, name = 'n_account_communications') %>% 
  ungroup()

#create casestatus
cs_1 <- df3 %>% 
  filter(case_status == "Closed") %>% ##case is a succes
  mutate(case_status_analysis = 1)

cs_0<- df3 %>% 
  filter(case_status == "Canceled" | case_status == "failed") %>%  ##case is not a succes
  mutate(case_status_analysis = 0)

cs_na<- df3 %>% ##communication is not in a case
  filter(!comm_id %in% cs_1$comm_id,
         !comm_id %in% cs_0$comm_id) %>% 
  mutate(case_status_analysis = NA)

df_cs<-rbind(cs_1, cs_0) #communications not in case are not taken into account in the analysis, so they are excluded from the Rbind

rm(cs_1,cs_0, cs_na)

#frequency
#already added by case and account above to create df3

#timeframe case
tf1<-df_cs %>% 
  filter(n_case_communications != 1) %>% 
  group_by(related_id) %>% 
  mutate(last_comm = max(as_datetime(communication_date)),
         first_comm = min(as_datetime(communication_date))) %>% 
  ungroup() %>% 
  mutate(case_timeframe = (as.numeric(last_comm - first_comm)/86400),
         comm_timeframe = case_timeframe/(n_case_communications-1))
           
 
tf2<-df_cs %>% 
  filter(n_case_communications == 1) %>% 
  mutate(case_timeframe = NA,
         comm_timeframe = NA)

df_tf<-rbind(tf1, tf2)
rm(tf1, tf2)


##adding timeframe per account
tfa1<-  df_tf %>% 
  filter(n_account_communications != 1) %>% 
  group_by(Account__c) %>% 
  mutate(last_comm_account = max(as_datetime(communication_date)),
         first_comm_account = min(as_datetime(communication_date))) %>% 
  ungroup() %>% 
  mutate(account_timeframe = (as.numeric(last_comm_account - first_comm_account)/86400),
         comm_timeframe_account = account_timeframe/ (n_account_communications-1) )


tfa2<-df_tf %>% 
  filter(n_account_communications == 1) %>% 
  mutate(account_timeframe = NA,
         comm_timeframe_account = NA,
         last_comm_account = as_datetime(communication_date),#variables not necesary for analysis, only for Rbind
         first_comm_account = as_datetime(communication_date))#variables not necesary for analysis, only for Rbind

df_tfa<-rbind(tfa1, tfa2) 

write.csv(df_tfa, "gen/temp/df_variables.csv", row.names = FALSE)

library(plyr)
count(df_tfa$communication_type)
detach("package:plyr", unload = TRUE)


