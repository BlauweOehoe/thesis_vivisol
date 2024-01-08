library(tidyverse)
library(dplyr)

wo_df<-read.csv("gen/data/WO.csv")

##get all the different workorders in system
#use: merginmg 
workorders<-wo_df %>% 
  filter(CaseId!="") %>% 
  mutate(wo_id = Id,
         wo_CreatedDate = as.Date(CreatedDate),
         wo_related_caseid = CaseId,
         wo_status = Status
         ) %>% 
  select(wo_id,
         wo_related_caseid)

write.csv(workorders, "gen/temp/workorders.csv", row.names = FALSE)

rm(wo_df)
rm(workorders)
