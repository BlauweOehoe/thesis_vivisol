library(tidyverse)
library(dplyr)

atj_df<-read.csv("gen/data/ATJ.csv")

atj_names<-atj_df %>% 
  mutate(Account_Treatment_Job__c = Id) %>% 
  select(Account_Treatment_Job__c,
         Contract_Treatment_Job_Name__c,
  ) %>% 
  distinct(Account_Treatment_Job__c, .keep_all = TRUE)

write.csv(atj_names, "gen/temp/atj_names.csv", row.names = FALSE)

rm(atj_names)
rm(atj_df)