##what This file does
#This file should be the first one run. It downloads all the raw data represented by the system.
#the data files were provided by vivisol. It makes sure the data is loaded as a DF in my PC
#it sets the working directory to the right place on my pc.

library(dplyr)
library(tidyverse)

#setwd
setwd("C:/Users/mikel/OneDrive/Bureaublad/Universitair/TuI/Thesis Vivisol/Thesis/Data_analysis")

setwd("C:/Users/miklam/OneDrive/Bureaublad/Universitair/TuI/Thesis Vivisol/Thesis/Data_analysis")

tasks_df<-read.csv("gen/data/Tasks.csv")
products_df<-read.csv("gen/data/Products.csv")
paph_df<-read.csv("gen/data/PAPH.csv")
cases_df<-read.csv("gen/data/Cases.csv")
atj_df<-read.csv("gen/data/ATJ.csv")
ath_df<-read.csv("gen/data/ATH.csv")
at_df<-read.csv("gen/data/AT.csv")
accounts_df<-read.csv("gen/data/Accounts.csv")
users_df<-read.csv("gen/data/Users.csv")
wo_df<-read.csv("gen/data/WO.csv")
stored_docs<-read.csv("gen/data/StoredDocuments.csv")
sdocs_df<-read.csv("gen/data/SDOC.csv")

tasks2<-read.csv2("gen/data/tasks_archive.csv")
