library(haven)
library(dplyr)
library(ggplot2)
library(stats)
library(ResourceSelection)
library(broom)
library(lmtest)

df<-read.csv("gen/output/iv_dv_df.csv")
library(plyr)
count(df$analysis_Letter)
count(df$analysis_email)
count(df$comm_timeframe)
detach("package:plyr", unload = TRUE)


# Run logistic Regression
df_Logistic1 <- glm(acc_status ~ analysis_email + n_account_communications + comm_timeframe, data = df)
summary(df_Logistic1)

df_Logistic2 <- glm(acc_status ~ analysis_call + n_account_communications + comm_timeframe, data = df)
summary(df_Logistic2)

df_Logistic3 <- glm(acc_status ~ analysis_Letter + n_account_communications + comm_timeframe, data = df)
summary(df_Logistic3)

df_Logistic4 <- glm(acc_status ~ analysis_email + analysis_call + analysis_Letter + n_account_communications + comm_timeframe, data = df)
summary(df_Logistic4)


# Obtain fit statistics
# Note: Null deviance= -2*LL0 (for Null model with constant only)
# Residual deviance = -2*LL for model including IVs
# Chisquare = difference between the two, df= # parameters in full model -1
df_Chisq1 <- df_Logistic1$null.deviance - df_Logistic1$deviance
df_Chidf1 <- df_Logistic1$df.null-df_Logistic1$df.residual
df_Chisq_prob1=1-pchisq(df_Chisq1,df_Chidf1)
df_Chisq_prob1

df_Chisq2 <- df_Logistic2$null.deviance - df_Logistic2$deviance
df_Chidf2 <- df_Logistic2$df.null-df_Logistic2$df.residual
df_Chisq_prob2=1-pchisq(df_Chisq2,df_Chidf2)
df_Chisq_prob2

df_Chisq3 <- df_Logistic3$null.deviance - df_Logistic3$deviance
df_Chidf3 <- df_Logistic3$df.null-df_Logistic3$df.residual
df_Chisq_prob3=1-pchisq(df_Chisq3,df_Chidf3)
df_Chisq_prob3

df_Chisq4 <- df_Logistic4$null.deviance - df_Logistic4$deviance
df_Chidf4 <- df_Logistic4$df.null-df_Logistic3$df.residual
df_Chisq_prob4=1-pchisq(df_Chisq4,df_Chidf4)
df_Chisq_prob4



# Cox-Snell R2_CS=1-exp((-2*LL-(-2*LL0))/#obs), we use this as input to calculate Nagelkerke R2
# Nagelkerke R2 is our indication of % explained by variables
df_R2_CS1 <- 1-exp((df_Logistic1$deviance-df_Logistic1$null.deviance)/15701)
# Nagelkerke R2_N= R2_CS/(1-exp(-(-2*LL0)/#obs))
df_R2_N1 <- df_R2_CS1/(1-(exp(-(df_Logistic1$null.deviance/15701))))

# Cox-Snell R2_CS=1-exp((-2*LL-(-2*LL0))/#obs), we use this as input to calculate Nagelkerke R2
# Nagelkerke R2 is our indication of % explained by variables
df_R2_CS2 <- 1-exp((df_Logistic2$deviance-df_Logistic2$null.deviance)/15701)
# Nagelkerke R2_N= R2_CS/(1-exp(-(-2*LL0)/#obs))
df_R2_N2 <- df_R2_CS2/(1-(exp(-(df_Logistic2$null.deviance/15701))))

# Cox-Snell R2_CS=1-exp((-2*LL-(-2*LL0))/#obs), we use this as input to calculate Nagelkerke R2
# Nagelkerke R2 is our indication of % explained by variables
df_R2_CS3 <- 1-exp((df_Logistic3$deviance-df_Logistic3$null.deviance)/15701)
# Nagelkerke R2_N= R2_CS/(1-exp(-(-2*LL0)/#obs))
df_R2_N3 <- df_R2_CS3/(1-(exp(-(df_Logistic3$null.deviance/15701))))

# Cox-Snell R2_CS=1-exp((-2*LL-(-2*LL0))/#obs), we use this as input to calculate Nagelkerke R2
# Nagelkerke R2 is our indication of % explained by variables
df_R2_CS4 <- 1-exp((df_Logistic4$deviance-df_Logistic4$null.deviance)/15701)
# Nagelkerke R2_N= R2_CS/(1-exp(-(-2*LL0)/#obs))
df_R2_N4 <- df_R2_CS4/(1-(exp(-(df_Logistic4$null.deviance/15701))))


# Obtain Hosmer-Lemeshow test
df_hl <- hoslem.test(df_Logistic$y, df_Logistic$fitted.values, g=10)
df_hl
cbind(df_hl$observed, df_hl$expected)

# obtain classification table (rows=actual, columns=predicted)
df_prob <- fitted(df_Logistic)
df_CT <- table(df$post_NotCompliant__c, df_prob>.5)
df_CT_rpct <- df_CT/rowSums(df_CT)*100
# Alternatively: add model results to original datafile with predicted 0-1
df <- augment(df_Logistic, type.predict="response") %>%
  mutate(Seen_hat=round(.fitted)) 
df %>%
  select(post_NotCompliant__c, Seen_hat) %>%
  table

# Stability and predictive model validation
# Create two random subsamples from original datafile
N <- nrow(df)
indices <- seq(1,N)
seed=(1234)
indices_Part1 <- sample(indices,floor(.5*N))
indices_Part2 <- indices[!(indices %in% indices_Part1)]
df_Part1 <- df[indices_Part1, ]
df_Part2 <- df[indices_Part2, ]

# Estimate model on first subsample and keep predictions (prob and binary)
df_Logistic_Part1 <- glm(post_NotCompliant__c ~ dummy_call +dummy_email+ n_communications + comm_timeframe, data = df)
df_Part1 <- augment(df_Logistic_Part1, type.predict="response") %>%
  mutate(Seen_hat=round(.fitted)) 
#Use model to predict for new data set and add columns

df_Part2 <-augment(df_Logistic_Part1, newdata=df_Part2,type.predict="response") %>%
  mutate(Seen_hat=round(.fitted))

# Construct classification tables
df_Part1 %>%
  select(post_NotCompliant__c, Seen_hat) %>%
  table
df_Part2 %>%
  select(post_NotCompliant__c, Seen_hat) %>%
  table

