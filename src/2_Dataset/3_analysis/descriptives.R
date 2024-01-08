df_communications<-read.csv("gen/output/preparation_df.csv")


library(plyr)
length(unique(df_communications$comm_id))
tb<-count(df_communications$communication_type)
tb
detach("package:plyr", unload=TRUE)

#percentage of emails
tb$freq[tb$x=="Email"] / sum(tb$freq)

#percentage of calls
tb$freq[tb$x=="Call"] / sum(tb$freq)

#percentage of letters
tb$freq[tb$x=="Letter"] / sum(tb$freq)


##aggregate to case
df_case<-df_communications %>% 
  group_by(related_id) %>% 
  mutate(avg_email = sum(dummy_email) / sum(dummy_email, dummy_call, dummy_Letter),
         avg_call = sum(dummy_call) / sum(dummy_email, dummy_call, dummy_Letter),
         avg_Letter =sum(dummy_Letter) / sum(dummy_email, dummy_call, dummy_Letter),) %>% 
  ungroup() %>% 
  distinct(related_id, .keep_all = TRUE) %>% 
  filter(related_id != Account__c)

length(df_case$related_id)
summary(df_case$post_Compliant__c)

summary(df_case$avg_email)
summary(df_case$avg_call)
summary(df_case$avg_Letter)

summary(df_case$n_case_communications)
summary(df_case$comm_timeframe)

#explanation of differentiation in percentages (see appendix)
df_case2<-df_case %>% 
  filter(n_case_communications == 1) 
summary(df_case2$avg_email)
summary(df_case2$avg_call)
summary(df_case2$avg_Letter)

##aggregate to account
df_account<-df_communications %>% 
  group_by(Account__c) %>% 
  mutate(avg_email = sum(dummy_email) / sum(dummy_email, dummy_call, dummy_Letter),
         avg_call = sum(dummy_call) / sum(dummy_email, dummy_call, dummy_Letter),
         avg_Letter =sum(dummy_Letter) / sum(dummy_email, dummy_call, dummy_Letter)) %>% 
         add_count(Account__c, name = "n_account_comms") %>% 
    ungroup() %>% 
  distinct(Account__c, .keep_all = TRUE) 

length(df_account$Account__c)
library(plyr)
tb2<-count(df_account$acc_status)
tb2
detach("package:plyr", unload = TRUE)
tb2$freq[tb2$x=="1"] / sum(tb2$freq)

summary(df_account$avg_email)
summary(df_account$avg_call)
summary(df_account$avg_Letter)

summary(df_account$n_account_comms)
summary(df_account$comm_timeframe_account)


