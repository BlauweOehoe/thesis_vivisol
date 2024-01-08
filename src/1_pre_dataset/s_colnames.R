install.packages("plyr")
install.packages("xlsx")
library(plyr)
library(xlsx)

#data preparation
colnames_at<-colnames(at_df)
colnames_ath<-colnames(ath_df)
colnames_atj<-colnames(atj_df)
colnames_cases<-colnames(cases_df)
colnames_paph<-colnames(paph_df)
colnames_products<-colnames(products_df)
colnames_tasks<-colnames(tasks_df)
colnames_accounts<-colnames(accounts_df)
colnames_wo<-colnames(wo_df)
colnames_letters<-colnames(letters_df)
colnames_users<-colnames(users_df)
colnames_sdocs<-colnames(sdocs_df)

#set column length
length(colnames_accounts)<-275
length(colnames_at) <- 275
length(colnames_ath) <- 275
length(colnames_atj) <- 275
length(colnames_cases) <- 275
length(colnames_paph) <- 275
length(colnames_products) <- 275
length(colnames_tasks)<- 275
length(colnames_wo)<- 275
length(colnames_letters)<-275
length(colnames_users)<-275
length(colnames_sdocs)<-275


#cbind all columns
total_colnames <- cbind(
  colnames_at,
  colnames_ath,
  colnames_atj,
  colnames_cases,
  colnames_paph,
  colnames_products,
  colnames_tasks,
  colnames_accounts,
  colnames_wo,
  colnames_letters,
  colnames_users,
  colnames_sdocs
)

write.xlsx(total_colnames, "gen/temp/colnames.xlsx", row.names = FALSE)
rm(  colnames_at,
     colnames_ath,
     colnames_atj,
     colnames_cases,
     colnames_paph,
     colnames_products,
     colnames_tasks,
     colnames_accounts,
     colnames_wo,
     colnames_letters,
     colnames_users,
     total_colnames)
