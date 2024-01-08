df_analysis<-read.csv("gen/output/preparation_df.csv")

##start aggregating to Case
df_case1<-df_analysis %>% 
  group_by(related_id) %>% 
  mutate(avg_email = sum(dummy_email) / unique(n_case_communications),
         avg_call =sum(dummy_call) / unique(n_case_communications),
         avg_Letter =sum(dummy_Letter) / unique(n_case_communications),) %>% 
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

##aggregate to case
df_agg1<-df_case2 %>% 
  filter(dummy_lastcomm == 1)


##aggregate to account
#add account frequency variable
dfa_fq1<-df_agg1 %>% 
  group_by(Account__c) %>% 
  mutate(n_account_communications = sum(n_case_communications)) %>% 
  ungroup() 

#dummy
df_case2<-dfa_fq1 %>% 
  group_by(Account__c) %>% 
  mutate(analysis_email =  sum(analysis_email)/n_account_communications,
         analysis_call =  sum(analysis_call)/n_account_communications,
         analysis_Letter =  sum(analysis_Letter/n_account_communications)) %>% 
    ungroup()

df_agg2<-df_case2 %>% 
  distinct(Account__c, .keep_all = TRUE)

library(plyr)
count(df_agg2$analysis_Letter)
count(df_agg2$analysis_email)
count(df_agg2$analysis_call)
detach("package:plyr", unload = TRUE)

write.csv(df_agg2, "gen/output/iv_dv_df.csv", row.names = FALSE)
write.csv(df_agg2, "gen/output/descriptive_patients.csv", row.names = FALSE)
