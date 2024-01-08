library(haven)
library(tidyverse)
library(dplyr)

#load the data
merge_tw<-read.csv("gen/temp/merge_tw.csv")
letters<-read.csv("gen/temp/letters.csv")

#rbind the letters to the emails and phonecalls
merge_twl<-rbind(merge_tw, letters)

#write to temp files
write.csv(merge_twl, "gen/temp/communications.csv", row.names = FALSE)

#remove all variables
rm(merge_tw, letters)
rm(merge_twl)



