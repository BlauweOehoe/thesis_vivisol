library(dplyr)
library(tidyverse)

df_prep<-read.csv("gen/output/df_complete.csv")

##filter out all cases which don't have a Comp-registration after them, and account which dont have trial account
df_cases2<-df_prep %>% 
  filter(!is.na(post_NotCompliant__c),
         acc_trial == 1)

#filter out cases after 365 days
df_succes<-df_cases2 %>% 
  mutate(Case_ClosedDate1 = as_datetime(Case_ClosedDate1)) %>% 
  filter(Case_ClosedDate1 <= analysis_enddate)

##inverse Compliance
df_succes$post_Compliant__c<-ifelse(df_succes$post_NotCompliant__c == "1", 0, 1) 

##add limit cases to 8 communications
df_analysis<-df_succes %>% 
  filter(n_case_communications < 8,
         related_id != Account__c) 


write.csv(df_analysis, "gen/output/preparation_df.csv", row.names = FALSE)


library(plyr)
count(df_prep$communication_type)
count(df_cases2$communication_type)
count(df_succes$communication_type)
count(df_analysis$communication_type)
count(df_analysis$communication_type)
count(df_analysis$dummy_email)
count(df_analysis$dummy_call)
count(df_analysis$dummy_Letter)
count(df_analysis$dummy_lastcomm)
detach("package:plyr", unload = TRUE)
