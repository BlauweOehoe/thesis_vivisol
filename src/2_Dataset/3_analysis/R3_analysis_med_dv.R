library(haven)
library(dplyr)
library(ggplot2)
library(stats)
library(ResourceSelection)
library(broom)

df<-read.csv("gen/output/med_dv_df.csv")

# Run logistic Regression
df_Logistic <- glm(acc_status ~ avg_comp, data = df)
summary(df_Logistic)

# Obtain fit statistics
# Note: Null deviance= -2*LL0 (for Null model with constant only)
# Residual deviance = -2*LL for model including IVs
# Chisquare = difference between the two, df= # parameters in full model -1
df_Chisq <- df_Logistic$null.deviance - df_Logistic$deviance
df_Chidf <- df_Logistic$df.null-df_Logistic$df.residual
df_Chisq_prob=1-pchisq(df_Chisq,df_Chidf)
df_Chisq_prob
# Cox-Snell R2_CS=1-exp((-2*LL-(-2*LL0))/#obs), we use this as input to calculate Nagelkerke R2
# Nagelkerke R2 is our indication of % explained by variables
df_R2_CS <- 1-exp((df_Logistic$deviance-df_Logistic$null.deviance)/19439)
# Nagelkerke R2_N= R2_CS/(1-exp(-(-2*LL0)/#obs))
df_R2_N <- df_R2_CS/(1-(exp(-(df_Logistic$null.deviance/19439))))
df_R2_N
# Obtain Hosmer-Lemeshow test
df_hl <- hoslem.test(df_Logistic$y, df_Logistic$fitted.values, g=10)
df_hl
cbind(df_hl$observed, df_hl$expected)

# obtain classification table (rows=actual, columns=predicted)
df_prob <- fitted(df_Logistic)
df_CT <- table(df$case_status_analysis, df_prob>.5)
df_CT_rpct <- df_CT/rowSums(df_CT)*100
# Alternatively: add model results to original datafile with predicted 0-1
df <- augment(df_Logistic, type.predict="response") %>%
  mutate(Seen_hat=round(.fitted)) 
df %>%
  select(case_status_analysis, Seen_hat) %>%
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
df_Logistic_Part1 <- glm(case_status_analysis ~ dummy_call +dummy_email+ n_communications + comm_timeframe, data = df)
df_Part1 <- augment(df_Logistic_Part1, type.predict="response") %>%
  mutate(Seen_hat=round(.fitted)) 
#Use model to predict for new data set and add columns

df_Part2 <-augment(df_Logistic_Part1, newdata=df_Part2,type.predict="response") %>%
  mutate(Seen_hat=round(.fitted))

# Construct classification tables
df_Part1 %>%
  select(case_status_analysis, Seen_hat) %>%
  table
df_Part2 %>%
  select(case_status_analysis, Seen_hat) %>%
  table

