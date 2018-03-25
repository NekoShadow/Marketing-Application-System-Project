#Import the required packages
library(caret)
library(psych)

#Import data for training
datasample <- read.csv('pca-sample.csv')
newdata <- read.csv('pca-sample.csv')

#Specify the selected variables
col_need <- c ("CUST_ID","CUST_ADDR_ID","REG_DATE", "TOTAL_AMOUNT","FIRST_ITV_TIME","FIRST_BB_TIME","FIRST_HD_TIME",
               "SIL_RATIO", "ACCRUAL_INCOME_MEAN","ACCRUAL_INCOME_MAX","ACCRUAL_INCOME_VAR",   "VOD_HD_COUNT" ,"FEE_SUM" ,
               "EARLY_PKG_VALID_DATE","EARLY_CREATE_TIME", "USER_NORMAL_COUNT","PKG_NORMAL_COUNT","FEE_MONTH_MEAN",
               "VOD_COUNT_SUM","VOD_COUNT_MEAN","VOD_COUNT_MAX", "VOD_COUNT_VAR","VOD_FEE_MEAN","VOD_FEE_MAX","VOD_FEE_VAR")

#Subset the dataframe
sample <- datasample[,col_need]
sample <- subset(sample,sample$SIL_RATIO<=1)

sample <- subset(sample,sample$ACCRUAL_INCOME_MEAN<=100&sample$ACCRUAL_INCOME_MAX<=100&sample$VOD_HD_COUNT<=22&sample$FEE_SUM<=172&sample$VOD_COUNT_SUM<=42&sample$VOD_FEE_MEAN<=5.6&sample$VOD_COUNT_MAX<=13&sample$FEE_MONTH_MEAN<=150)
sample$ACCRUAL_INCOME_VAR<-1/(sample$ACCRUAL_INCOME_VAR)
sample$VOD_FEE_VAR<- 1/(sample$VOD_FEE_VAR)
sample$VOD_COUNT_VAR <- 1/(sample$VOD_COUNT_VAR)
sample$SIL_RATIO <- (1-sample$SIL_RATIO)

sample[sample==Inf]<-NA
sample[is.na(sample)]<-0

newdata <- newdata[,col_need]
newdata$ACCRUAL_INCOME_VAR <- 1/(newdata$ACCRUAL_INCOME_VAR)
newdata$VOD_FEE_VAR <- 1/(newdata$VOD_FEE_VAR)
newdata$VOD_COUNT_VAR <- 1/(newdata$VOD_COUNT_VAR)
newdata$SIL_RATIO <- 1-newdata$SIL_RATIO
newdata[newdata==Inf]<-NA
newdata[is.na(newdata)]<-0

#Model training
start <- Sys.time()
pcaObject_a <- principal(sample[,-c(1,2)],nfactors = 8)
dir.create('data')
save(pcaObject_a,file='data/pca_model.RData')
print(Sys.time()-start)
target_new <- predict(object = pcaObject_a,data = newdata[,-c(1,2)])
var<-c(239,133,119,116,87,82,54,43)
for(i in 1:8){
  target_new[,i]<-target_new[,1]*var[i]
}
newdata$final_scores <- apply(target_new,1,sum)
newdata$level <- cut_number(newdata$final_scores,5,labels=c('label1','label2','label3','label4','label5'))




