hospitals<-read.csv("gen/temp/hospitals.csv")
merge_at_info<-read.csv("gen/temp/merge_at_info.csv")

patients<-left_join(merge_at_info, hospitals, by = "Hospital__c") %>% 
  select(-Account_External_Id__c)

write.csv(patients, "gen/temp/patients.csv", row.names = FALSE)

rm(hospitals,
   merge_at_info)
rm(patients)


#lots of hospitals are still missing, which could be easily translated over by adding their Code in ZIBS, about 28 hospitals of which 3 are quite important
patients2<-patients %>% 
  filter(is.na(h_involvement),
         acc_trial == "1")

h_accs<-accounts_df %>% 
  mutate(Hospital__c = Id,
       hospital_name = Name) %>% 
  select(Hospital__c,
         hospital_name,
         AccountExtId__pc)

h_accs2<-left_join(patients2, h_accs, by = c("Hospital__c" = "Hospital__c"))

library(plyr)
count(h_accs2$hospital_name)
detach("package:plyr", unload = TRUE)
count

rm(h_accs,
   h_accs2,
   patients2)
