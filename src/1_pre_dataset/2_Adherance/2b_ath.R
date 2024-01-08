ath_df<-read.csv("gen/data/ATH.csv")


#filter registrations made by CPAP device
ath_all<-ath_df %>% 
  filter(ComplianceSource__c %in% c("SD_CS", "SD_FS","TL_CS","TL_FS")) %>% 
  mutate(ath_id = Id) %>% 
  select(ath_id,
         Account_Treatment__c,
         AccountExtId__c, #different number, which is traceable to patient for compliance registrations
         NotCompliant__c,
         Compliance_days_a_week__c,
         Compliance_Hours_Night_h_min__c,
         AHI_After_treatment__c,
         ComplianceSource__c,
         Registration_Date__c
)

##remove duplicates, filter out invalid registrations
#find all invalid registrations
invalid_adh_registrations<-ath_all %>%  #invalid registrations, are different registrations made for the patient, on the same day
  distinct(Account_Treatment__c, Registration_Date__c, NotCompliant__c,  .keep_all = TRUE) %>% 
  group_by(Account_Treatment__c, Registration_Date__c) %>% 
  filter(n() >= 2) %>% 
  ungroup()

#filter out invalid registrations & remove duplicates, keep all relevant columns
ath_case<-ath_all %>% 
  filter(!paste(Account_Treatment__c, Registration_Date__c) %in% 
           paste(invalid_adh_registrations$Account_Treatment__c, invalid_adh_registrations$Registration_Date__c)) %>% 
  distinct(Account_Treatment__c, Registration_Date__c, NotCompliant__c,  .keep_all = TRUE) %>% 
  select(ath_id,
         Account_Treatment__c,
         Registration_Date__c,
         Compliance_days_a_week__c,
         Compliance_Hours_Night_h_min__c,
         AHI_After_treatment__c,
         NotCompliant__c,)


write.csv(ath_case, "gen/temp/ath_case.csv", row.names = FALSE)
write.csv(invalid_adh_registrations, "gen/output/invalid_adh_registrations.csv", row.names = FALSE)

rm(ath_all,
   ath_df,
   ath_case,
   invalid_adh_registrations)

library(plyr)
detach("package:plyr", unload = TRUE)

