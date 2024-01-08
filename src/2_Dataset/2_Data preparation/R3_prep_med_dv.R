df_analysis<-read.csv("gen/output/preparation_df.csv")

df_cases<-df_analysis %>% 
  filter(!is.na(post_Compliant__c))

##start aggregating to account
df_dummy<-df_cases %>% 
  group_by(Account__c) %>% 
  add_count(Account__c, name = 'n_cases') %>% 
  mutate(avg_comp = sum(post_Compliant__c) / (n_cases),
         avg_succes = sum(case_status_analysis) / (n_cases)) %>% 
  ungroup()

library(plyr)
count(df_dummy$avg_comp)
detach("package:plyr", unload = TRUE)

##aggregate to case
df_agg1<-df_dummy %>% 
  distinct(Account__c, .keep_all = TRUE)


write.csv(df_agg1, "gen/output/med_dv_df.csv", row.names = FALSE)
write.csv(df_agg1, "gen/output/descriptive_patients2.csv", row.names = FALSE)

#different size of dataset compared to iv-dv has to do with the amount of communications per account
#if account has 1 communication, its not taken into account for the first analysis, but it is for this one. 