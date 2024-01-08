library(dplyr)
library(tidyverse)

acc_status<- read.csv("gen/temp/acc_status.csv")
at_info<-read.csv("gen/temp/at_info.csv")

merge_at_info<-left_join(at_info, acc_status, by = "Account__c") 

write.csv(merge_at_info, "gen/temp/merge_at_info.csv", row.names = FALSE)

##descriptive stats
library(plyr)

#at's from dead patiens
count(merge_at_info$account_system_status)

df<-merge_at_info %>% 
  distinct(Account__c, .keep_all = TRUE)
count(df$account_system_status)
rm(df)
  
detach("package:plyr", unload = TRUE)


##remove the accounts
rm(acc_status,
   at_info,
   merge_at_info)