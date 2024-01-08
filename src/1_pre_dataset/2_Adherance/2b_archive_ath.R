library(tidyverse)
library(dplyr)

ath_1<-read.csv2("gen/data/archive_ath_1.csv")

#get all data from a1
ath2<-ath_1 %>% 
  filter(Bron %in% c("Telemonitoring", "Uitleeskaart", "Machtiging")) %>% 
  select(Aangemaakt,
         Relatie..Code,
         Gemiddeld.aantal.dagen.gebruik.per.week,
         Gemiddeld.gebruik.in.uren...minuten.over.gebruikte.dagen,
         AHI,
         Bron)
rm(ath_1)

#making Relatie..Code compatible with External ID
ath4_4<-ath2 %>% 
  mutate(nchar = nchar(Relatie..Code)) %>% 
  filter(nchar == 4) %>% 
  mutate(Relatie..Code = paste("10000", Relatie..Code, sep="")) %>% 
  select(-nchar)


ath4_5<-ath2 %>% 
  mutate(nchar = nchar(Relatie..Code)) %>% 
  filter(nchar == 5) %>% 
  mutate(Relatie..Code = paste("1000", Relatie..Code, sep=""))%>% 
  select(-nchar)



ath4_6<-ath2 %>% 
  mutate(nchar = nchar(Relatie..Code)) %>% 
  filter(nchar == 6) %>% 
  mutate(Relatie..Code = paste("100", Relatie..Code, sep=""))%>% 
  select(-nchar)

ath4<- rbind(ath4_4, ath4_5, ath4_6)
rm(ath2, ath4_4, ath4_5, ath4_6)

##check if patients are compliant
ath5_1<-ath4 %>% 
  filter(AHI >= 10 | 
           Gemiddeld.aantal.dagen.gebruik.per.week < 5 |
           Gemiddeld.gebruik.in.uren...minuten.over.gebruikte.dagen < 4) %>% 
  mutate(NotCompliant__c = "1")

##
ath5_2<-ath4 %>% 
  filter(AHI < 10 &
           Gemiddeld.aantal.dagen.gebruik.per.week >= 5 &
           Gemiddeld.gebruik.in.uren...minuten.over.gebruikte.dagen >= 4) %>% 
  mutate(NotCompliant__c = "0")


ath5<-rbind(ath5_2, ath5_1) %>% 
  distinct(Relatie..Code, Aangemaakt, NotCompliant__c, .keep_all = TRUE) %>%  ##drops 1527 duplicate values
  group_by(Relatie..Code, Aangemaakt) %>%  
  mutate(n = dplyr::n(), ) %>% 
  ungroup() %>% 
  filter(n < 2) %>% 
  select(-n)

archive_ath<-ath5 %>% 
  mutate(VIV_Account_External_Id__c =  Relatie..Code,
         Registration_Date__c = Aangemaakt, 
         NotCompliant__c) %>% 
  select(VIV_Account_External_Id__c, 
         Registration_Date__c, 
         NotCompliant__c)
rm(ath5_1, ath5_2)

no_valid_arhief_compliance<-ath4 %>% 
  filter(!paste(Relatie..Code, 
                Aangemaakt,
                AHI,
                Gemiddeld.aantal.dagen.gebruik.per.week,
                Gemiddeld.gebruik.in.uren...minuten.over.gebruikte.dagen) 
         %in%
           paste(ath5$Relatie..Code, 
                ath5$Aangemaakt,
                ath5$AHI,
                ath5$Gemiddeld.aantal.dagen.gebruik.per.week,
                ath5$Gemiddeld.gebruik.in.uren...minuten.over.gebruikte.dagen))
rm(ath4, ath5)

#write the file of all compliance registrations which were excluded from the dataset, because of duplicate registrations with different results
write.csv(no_valid_arhief_compliance, "gen/output/invalid_ath_archive_registrations.csv", row.names = FALSE)


write.csv(archive_ath, "gen/temp/archive_ath.csv", row.names = FALSE)

rm(archive_ath)
rm(no_valid_arhief_compliance)

