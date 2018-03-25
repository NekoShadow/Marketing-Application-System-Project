#Import required packages
library(AppliedPredictiveModeling)
library(caret)
library(randomForest)
library(CHAID)
library(rpart)
library(C50)
library(nnet)
library(bnlearn)

#Read the data
encoding = 'UTF-8'
datasample <- read.csv('classi_r_1.csv',sep = '=',encoding='UTF-8')
datasample_dif <- read.csv('classi_r_2.csv',sep = '=',encoding='UTF-8')

#Select the required variables
name_need <- c( "SIL_TARGET", "CARD_TYPE","GENDER" , "AGE","CONSTELLATIONS" , "PROVINCE","NATIONALITY","TRANS_DATE" , "TRANS_EVER",              
                "TRANS_REG", "REG_DATE","IS_OWNER","C_OPER", "BELONG_COMPANY"  , "BELONG_CODE" ,"BELONG_TYPE",
                "STREET_STATION_COUNT" ,"LIWEI_COUNT" ,   "COMMUNITY_COUNT" , "CUST_TYPE" ,"CUST_STATUS" ,  "HOMETOWN",
                "EOC_COUNT","CM_COUNT" ,"HD_STB_COUNT" , "SD_STB_COUNT", "IDLE_EOC_COUNT" ,  "IDLE_CM_COUNT",           
                "IDLE_HD_STB_COUNT" ,  "IDLE_SD_STB_COUNT" , "LAST_REPAIR_TIME" ,"REPAIR_NUM_30" ,         
                "FIRST_ITV_TIME" ,"FIRST_BB_TIME", "FIRST_HD_TIME" ,  "EOC_COUNT_RATIO","CM_COUNT_RATIO",
                "HD_STB_COUNT_RATIO","SD_STB_COUNT_RATIO" ,"TOTAL_AMOUNT_BIN", "VOD_EVER" , "REP_EVER", "VOD_DUR_MAX" ,
                "VOD_DUR_MEAN", "VOD_DUR_VAR"  , "VOD_DUR_GRA" ,"VOD_TIMES_MAX" , "VOD_TIMES_MEAN","VOD_TIMES_VAR"  , 
                "VOD_TIMES_GRA" , "REP_DUR_MAX"  , "REP_DUR_MEAN","REP_DUR_VAR", "REP_DUR_GRA","REP_TIMES_MAX",
                "REP_TIMES_MEAN" ,"REP_TIMES_VAR" , "REP_TIMES_GRA","VOD_DUR_DESC" , "VOD_TIMES_DESC","REP_TIMES_DESC",
                "REP_DUR_DESC"  ,"DUR_VOD_REP_RATIO_MAX" , "TIMES_VOD_REP_RATIO_MAX" , "TIMES_VOD_REP_RATIO_MEAN" ,
                "DUR_VOD_REP_RATIO_MEAN", "DUR_VOD_REP_RATIO_VAR"  , "TIMES_VOD_REP_RATIO_VAR", "DUR_VOD_REP_RATIO_GRA"  ,
                "TIMES_VOD_REP_RATIO_GRA","TIMES_VOD_REP_RATIO_DESC", "DUR_VOD_REP_RATIO_DESC" , "IS_STABLE_TENANT" , 
                "EARLY_PKG_VALID_DATE"  ,  "EARLY_CREATE_TIME" ,"LATE_CREATE_TIME","IS_NGB", "OFFLINE_CASH_PAY_RATIO" ,
                "OFFLINE_AGENCY_PAY_RATIO", "ONLINE_PAY_RATIO"  ,   "OTHER_PAY_RATIO" ,"PAY_CHANNEL_PREFER" ,
                "PAY_CHANNEL_PREFER_VAR" ,  "ACCRUAL_INCOME_MEAN" ,"ACCRUAL_INCOME_MAX"   ,  "ACCRUAL_INCOME_VAR",      
                "ACCRUAL_INCOME_DESC"  , "ACCRUAL_INCOME_GRA",  "LAST_VOD_FEE", "VOD_HD_COUNT" , "FEE_SUM" ,                
                "FEE_MEAN")
#Some data preprocessing
mysample <- datasample[,name_need]
data_2<- datasample_dif[,name_need]
mysample[mysample==Inf]<-NA
mysample[is.na(mysample)]<-0
data_2[is.na(data_2)]<-0

set.seed(1)

#Split train and test sets
trainingRows <- createDataPartition(datasample$SIL_TARGET,p=.7,list=FALSE)
trainingData <- mysample[trainingRows,]
testData <- mysample[-trainingRows,]

trainingData$SIL_TARGET<-as.factor(trainingData$SIL_TARGET)

#Define the cost matrix
matrix_cost <- matrix(c(0, 1,2, 0), 2, 2, byrow=TRUE)
rownames(matrix_cost) <- colnames(matrix_cost) <- c( "TRUE", "FALSE")

#Train with RandomForest
rf <- randomForest(SIL_TARGET~., data = trainingData)

#Train with C5.0
Sys.setlocale(locale="C")
C5tree <- C5.0(SIL_TARGET~., data = trainingData,control = C5.0Control(minCases = 50))

#Train with CarTree
carTree <- rpart(SIL_TARGET~., data = trainingData,parms=list(loss=matrix_cost),control=rpart.control(minsplit=100,minbucket=50))

#Train with Neural Network
start<-Sys.time()
nnet_model=nnet(SIL_TARGET~., data = trainingData,size=20,rang=0.2,decay=5e-4,maxit=200,MaxNWts=10000)
Sys.time()-start

#Define a function to turn each column into factors
factor_convert <- function(trainingData){    
  for (i in 1:length(names(trainingData))){
    if (is.integer(trainingData[,i])){
      b<-min(length(unique(trainingData[,i])),10)
      trainingData[,i]<- cut(trainingData[,i],breaks=b,dig.lab=2,labels=1:b)
    }else if (is.double(trainingData[,i])){
      b<-min(length(unique(trainingData[,i])),10)
      trainingData[,i]<- cut(trainingData[,i],breaks=b,dig.lab=2,labels=1:b)
    }
  }
  for (i in 1:length(names(trainingData))){
    if (!is.numeric(trainingData[,i])){
      trainingData[,i]<- as.factor(trainingData[,i])
    }
  }
  for (i in 1:length(names(trainingData))){
    if (is.numeric(trainingData[,i])){
      b<-min(length(unique(trainingData[,i])),10)
      trainingData[,i]<- cut(trainingData[,i],breaks=b,dig.lab=2,labels=1:b)
    }
  }
  return(trainingData)
}

trainingData <- factor_convert(trainingData)
#Train based on Bayes Tree
tree_bayes <- tree.bayes(trainingData[,-c(31,37)],'SIL_TARGET')
fitted = bn.fit(tree_bayes, trainingData[,-c(31,37)])

#Predict based on test data, and save the results
resultrf <-predict(object = rf, newdata = data_2,type='prob')
resultcar <-predict(object = carTree, newdata = datasample_dif,type='prob')
resultc5 <- predict(object = C5tree, newdata = datasample_dif,type='prob')
resultnnet <- predict(object = nnet_model, newdata = datasample_dif,type=c('class'))
resultnnet_pro <- predict(object = nnet_model, newdata = datasample_dif,type=c('raw'))
data_2<- factor_convert(data_2)
resultbayes = predict(fitted, data_2[,-c(31,37)],prob=TRUE)
prob <- attr(resultbayes,'prob')
resultbayes_prob <- as.data.frame(array(,dim = c(97377,2)))
colnames(resultbayes_prob)<- c('false','true')
for (i in 1:length(prob)){
  if (i%%2==1){
    resultbayes_prob[i%/%2+1,'false']<- prob[i]
  }else{
    resultbayes_prob[i%/%2,'true']<- prob[i]
  }
}

#Model Evaluation
data_2$rf_true <- resultrf[,2]
data_2$rf_false <- resultrf[,1]
data_2$car_true <- resultcar[,2]
data_2$car_false <- resultcar[,1]
data_2$c5_true <- resultc5[,2]
data_2$c5_false <- resultc5[,1]
data_2$nnet_true <- NA
data_2$nnet_false <-NA
resultnnet_pro[is.na(resultnnet_pro)]<-0
data_2$nnet_true <- resultnnet_pro
data_2$nnet_false <- 1-resultnnet_pro
data_2$bayes_false <- resultbayes_prob$false
data_2$bayes_true <- resultbayes_prob$true
data_2$bayes_true[is.na(data_2$bayes_true)]<-0
data_2$bayes_false[is.na(data_2$bayes_false)]<-0
#Get the recall and precision of the result
recall <- function(result){
  print('recall:')
  print(result[1,1]/(result[1,1]+result[1,2])*1.0)
  print('precision:')
  print(result[1,1]/(result[1,1]+result[2,1])*1.0)
}

#Get the final label for each row according to votes given by each model.
start_time <- Sys.time()
for (i in 1:length(data_2[,1])){
  rf<-0;c5<-0;car<-0;nnet<-0;bayes<-0
  if(data_2$rf_true[i]>0.75){rf<-1}
  if(data_2$c5_true[i]>0.9){c5 <- 1}
  if(data_2$car_true[i]>0.75){car <- 1}
  if(data_2$nnet_true[i]>0.75){nnet <- 1}
  if(data_2$bayes_true[i]>0.75){bayes <- 1}
  if(data_2$rf_true[i]<0.25){rf<-(-1)}
  if(data_2$c5_true[i]<0.4){c5 <- (-1)}
  if(data_2$car_true[i]<0.4){car <- (-1)}
  if(data_2$nnet_true[i]<0.25){nnet <- (-1)}
  if(data_2$bayes_true[i]<0.25){bayes <- (-1)}
  if (sum(rf,c5,car,nnet,bayes)>=2){
    data_2$pre_target[i]<-'TRUE'
  }else{
    data_2$pre_target[i]<-'FALSE'
  }
}


result_dif <- table(data_2$SIL_TARGET,data_2$pre_target)

print(result_dif)
recall(result_dif)
print(Sys.time()-start_time)

data_2<-data_2[with(data_2, order(-pre_false_pro)),]


table(data_2$SIL_TARGET,resultnnet)
