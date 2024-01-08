library(dplyr)
library(tidyverse)

sdocs_df<-read.csv("gen/data/SDOC.csv")

##creating final code
docs<-sdocs_df %>% 
  mutate(CreatedDate = as_datetime(CreatedDate),
         communication_date = CreatedDate,
         communication_type = "Letter",
         related_id =  SDOC__ObjectID18__c,
         comm_id = Id,
         CommCreatedById = CreatedById,
         Account__c = "NA",
         Account_Treatment__c = "NA") %>% 
  filter(SDOC__ObjectType__c == "Case", #Letters related to Case and WO, all have "case" as this id
         communication_date > as.Date("2021-06-30"),
         communication_date < as.Date("2023-11-02")) %>% 
  select(comm_id,
         related_id,
         communication_date,
         communication_type,
         CommCreatedById,
         Account__c,
         Account_Treatment__c,
  )


#removing duplicate letter sends
letters<-docs %>% 
  mutate(date = as_date(communication_date)) %>% 
  distinct(related_id, communication_date, .keep_all = TRUE) %>% 
  select(-date)

write.csv(letters, "gen/temp/letters.csv", row.names = FALSE)
rm(sdocs_df)
rm(docs)
rm(letters)



