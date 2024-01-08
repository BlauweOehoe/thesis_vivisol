library(dplyr)
library(tidyverse)

##making a list of all the hospitals and merging involvement

#imput
h_involvement<-read.csv2("gen/data/h_involvement.csv")
accounts_df<-read.csv("gen/data/Accounts.csv")

##taking all usefull hospital information from account
hospitals<-accounts_df %>% 
  filter(Entity_type__c == "ZHOSPI"| Entity_type__c == "ZVENCT" | Entity_type__c == "RehabilitationCenter") %>% 
  mutate(Hospital__c = Id,
         hospital_name = Name,
         hospital_extid = Account_External_Id__c) %>% 
  select(
    Hospital__c,
    hospital_extid,
    hospital_name,
    Entity_type__c,
  )

#mutate external Id of hospitals
h_involvement1<-h_involvement %>% 
  mutate(nchar_ = nchar(Code))

#h_involvement4<-h_involvement1 %>% 
#  filter(nchar_ == "4")  %>% 
#  mutate(hospital_extid = paste("010000", Code, sep = ""))

h_involvement5<-h_involvement1 %>% 
  filter(nchar_ == "5")  %>% 
  mutate(hospital_extid = paste("01000", Code, sep = ""))

h_involvement6<-h_involvement1 %>%
  filter(nchar_ == "6")  %>% 
  mutate(hospital_extid = paste("0100", Code, sep = ""))

h_involvement9<-h_involvement1 %>% 
  filter(nchar_ == "9") %>% 
  mutate(hospital_extid = paste("0", Code, sep = ""))

h_involvement2  <-rbind( h_involvement5, h_involvement6, h_involvement9)#add h_involvement4 back in if that needs to happen
rm(h_involvement1, h_involvement5, h_involvement6, h_involvement9) #add h_involvement4 back in if that needs to happen


#hospitals<-hospitals_p %>% 
#  left_join(h_involvement, by = c("hospital_extid"="hospital_extid"))
hospitals_2<-left_join(hospitals, h_involvement2, by =  c("hospital_extid" = "hospital_extid")) 

hospitals_3 <- hospitals_2 %>% 
  filter(!is.na(Code)) %>% 
  mutate(h_involvement = Hospital.involvement) %>% 
  select(Hospital__c,
         h_involvement)


##missinghospitals - code is not working, but the missing hospitals are sent to Vivisol
#missinghospitals<-hospitals %>% 
  #filter(!"hospital_extid" %in% "hospitals_2$hospital_extid") # filter doesnt work for the 20 who have extid with less  than 4 characters
write.csv(hospitals_3, "gen/temp/hospitals.csv", row.names = FALSE)

rm(h_involvement,
   h_involvement2,
   hospitals_2)

rm(hospitals,
   accounts_df)

rm(hospitals_3)


