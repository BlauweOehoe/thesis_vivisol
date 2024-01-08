library(dplyr)

library(tidyverse)

library(plyr)
detach("package:plyr", unload = TRUE)

comm_acc1<-read.csv("gen/temp/comm_pat.csv") %>% 
  mutate(communication_date1 = as.Date(communication_date),
         first_comm = as.Date(first_comm),
         last_comm = as.Date(last_comm),
         Case_ClosedDate1 = as.Date(Case_ClosedDate))

ath<-read.csv("gen/temp/ath_case.csv") %>% 
  mutate(Registration_Date__c = as.Date(Registration_Date__c))

comm_acc2<- comm_acc1 %>% 
  filter(is.na(Case_ClosedDate)) %>% 
  mutate(Case_ClosedDate1 = last_comm)

comm_acc2.1 <- comm_acc1 %>% 
  filter(!is.na(Case_ClosedDate)) 

comm_acc<-rbind(comm_acc2, comm_acc2.1)

#make different dataframes for post and pre compliance and add prefixes
#pre
#pre was deleted, as this was no longer necessary

#post
ath_post<-ath %>% 
  mutate(Registration_Date__c = as.Date(Registration_Date__c))

colnames(ath_post) <- paste("post", colnames(ath), sep = "_") 

ath_post2<- ath_post %>%   
  mutate(Account_Treatment__c = post_Account_Treatment__c,
         validation_date = post_Registration_Date__c+7) %>% ##for a valid change in communi
  select(-c(post_Account_Treatment__c,
            ))
rm(ath_post)

#trying to leftjoin colls
by_post<- join_by("Account_Treatment__c" == "Account_Treatment__c",
                  closest("Case_ClosedDate1" <= "validation_date")
)
comm_pat_ath2<-left_join(comm_acc, ath_post2, by_post) %>% ##keep validation date, as this is needed to filter out shizzle
  select(-validation_date)


comm_pat_ath5<-comm_pat_ath2 %>%
  select(-c(post_Compliance_days_a_week__c,
            post_Compliance_Hours_Night_h_min__c,
            post_AHI_After_treatment__c,
            ))

write.csv(comm_pat_ath5, "gen/output/dataset.csv", row.names = FALSE)

rm(ath,
   ath_post2,
   by_post,
   comm_acc,
   comm_pat_ath2
)

rm(comm_acc1,
   comm_acc2,
   comm_acc2.1)

rm(comm_pat_ath5)
