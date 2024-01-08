accounts_df<-read.csv("gen/data/Accounts.csv")
library(plyr)
count(acc_status$Status_Contact__pc)
detach("package:plyr", unload = TRUE)


acc_status<-accounts_df %>% 
  mutate(Account__c = Id,
         account_system_status = Status__c) %>% 
  select(Account__c,
         Account_External_Id__c,
         Status_Contact__pc
  )

write.csv(acc_status , "gen/temp/acc_status.csv", row.names = FALSE)

rm(acc_status,
   accounts_df)