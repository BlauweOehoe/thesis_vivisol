library(dplyr)
library(tidyverse)
library(plyr)

tasks<-read.csv("gen/temp/tasks.csv")
workorders<-read.csv("gen/temp/workorders.csv")

###Replacing all relatedId which are workorders, by the CaseID
#joining workorders to tasks
merge_tw1<-left_join(tasks, workorders, by = c("related_id" = "wo_id" ))
#count(is.na(merge_tw$wo_related_caseid))

##get RelatedId's which were workorders, en make the relatedId's cases
merge_tw2<-merge_tw1 %>% 
  filter(!is.na(wo_related_caseid)) %>% 
  mutate(related_id = wo_related_caseid) %>% 
  select(-c(wo_related_caseid))

##get RelatedId's which were not workorders
merge_tw3<-merge_tw1 %>% 
  filter(is.na(wo_related_caseid)) %>% 
  select(-c(wo_related_caseid))

##columbind the previous datasets together
merge_tw <- rbind(
  merge_tw2,
  merge_tw3)

write.csv(merge_tw, "gen/temp/merge_tw.csv", row.names = FALSE)

##Remove all previous noise datasets
rm(merge_tw,
   merge_tw1,
   merge_tw2,
   merge_tw3)

rm(tasks,
   workorders)
