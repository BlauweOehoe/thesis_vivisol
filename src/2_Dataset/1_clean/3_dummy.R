library(dplyr)
library(tidyverse)

df<-read.csv("gen/temp/df_variables.csv")

##create dummy's
df<- df%>% 
  mutate(last_comm = as_datetime(last_comm),
         communication_date1 = as_datetime(communication_date),
         Deactivation_Date__c = as_datetime(Deactivation_Date__c))

df$dummy_email<-  ifelse(df$communication_type == "Email", 1, 0)
df$dummy_call<-  ifelse(df$communication_type == "Call", 1, 0)
df$dummy_Letter<-  ifelse(df$communication_type == "Letter", 1, 0)

df2<-df %>% 
  group_by(related_id) %>% 
  mutate(max_commdate = max(communication_date)) %>% 
  ungroup()

df2$dummy_lastcomm<-ifelse(df2$max_commdate == df2$communication_date, 1, 0)

library(plyr)
count(df2$communication_type)
detach("package:plyr", unload = TRUE)

df2<-df2 %>% 
  group_by(related_id, dummy_lastcomm) %>% 
  filter(sum(dummy_lastcomm) < 2 ) %>% 
  ungroup()

length(unique(df$comm_id))

write.csv(df2, "gen/output/df_complete.csv", row.names = FALSE)

rm(df)
