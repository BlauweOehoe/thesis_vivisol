library(tidyverse)
library(dplyr)

df_cases<-read.csv("gen/output/preparation_df.csv")

##start aggregating to Case
df_case1<-df_cases %>% 
  group_by(related_id) %>% 
  mutate(avg_email = sum(dummy_email) / sum(dummy_email, dummy_call, dummy_Letter),
         avg_call = sum(dummy_call) / sum(dummy_email, dummy_call, dummy_Letter),
         avg_Letter =sum(dummy_Letter) / sum(dummy_email, dummy_call, dummy_Letter),) %>% 
  add_count(related_id, name = "n_case_communications")
  ungroup() 



#succesfull comms
df_case2a<-df_case1 %>% 
  filter(case_status_analysis == 1) %>% 
  filter(dummy_lastcomm == 1) %>% 
  mutate(analysis_email =  dummy_email,
         analysis_call =  dummy_call,
         analysis_Letter =  dummy_Letter)
  
df_case2b<-df_case1 %>% 
  filter(case_status_analysis != 1) %>% 
  filter(dummy_lastcomm == 1) %>% 
  mutate(analysis_email =  avg_email,
         analysis_call =  avg_call,
         analysis_Letter =  avg_Letter)

df_case2<-rbind(df_case2a, df_case2b)

##aggregate to case,
df_agg1<-df_case2 %>% 
  filter(dummy_lastcomm == 1) %>% 
  filter(related_id != Account__c)  #filter out communications not related to case, as adherance only gets measured for a case

write.csv(df_agg1, "gen/output/adherance_df.csv", row.names = FALSE)

