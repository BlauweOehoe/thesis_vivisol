library(dplyr)
library(tidyverse)


tasks_df<-read.csv("gen/data/Tasks.csv")
tasks2_df<-read.csv2("gen/data/tasks_archive.csv")


###get phone and email tasks not in archive
tasks <- tasks_df %>% 
  filter(
         WhatId!="", #every task needs to related to something
         CreatedDate > as.Date("2021-06-30"),
         CreatedDate < as.Date("2023-11-01"), # discard tasks which are made before system implementation and before cutoff date
         Account_Treatment_Job__c == "", #only keeps tasks without an account treatment job, so phonecalls emails etc.
         TaskSubtype %in% c("Call", "Email"),#selecting only phonecalls or emails
         Account__c != ""|Account_Treatment__c != ""
  ) %>% 
  mutate(
    comm_id = Id, #change name
    related_id = WhatId, #change name to system name, (watch out, case id can be case or personacount or WO)
    communication_date = CreatedDate, #change name
    communication_type = TaskSubtype, #change name
    CommCreatedById = CreatedById #change name
    ) %>% 
  select(
    comm_id, #unique identifier for each communication
    related_id, #higher level of communication watch out, case id can be case or perosnaccount
    communication_date, #communication date and time
    communication_type, #phone or email
    CommCreatedById,#type of communication
    Account__c, #personaccount
    Account_Treatment__c #account treatment
  ) 

##get phone and email tasks in archive
tasks2<-tasks2_df %>% 
  mutate(comm_id = ID,
         related_id = WHATID, 
         communication_date = CREATEDDATE,
         communication_type = TASKSUBTYPE,
         CommCreatedById = CREATEDBYID,
         Account__c = ACCOUNT__C,
         Account_Treatment__c = ACCOUNT_TREATMENT_JOB__C
         ) %>% 
  select(
    comm_id, #unique identifier for each communication
    related_id, #higher level of communication watch out, case id can be case or perosnaccount
    communication_date, #communication date and time
    communication_type,
    CommCreatedById,#type of communication
    Account__c, #personaccount
    Account_Treatment__c #account treatment
  ) 

communications<-rbind(tasks, tasks2)

write.csv(communications, "gen/temp/tasks.csv", row.names = FALSE)

rm(tasks_df)
rm(tasks)
rm(tasks2)
rm(tasks2_df)
rm(communications)

