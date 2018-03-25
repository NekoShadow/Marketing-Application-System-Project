# Import packages
library(amap)
library(RODBC)

# Initial settings
options(stringsAsFactors = FALSE)
rm(list = ls())
gc()

# Hided due to privacy issues
server.name <- 'XXXXXX'
server.user <- 'XXXXXX'
server.pwd <- 'XXXXXX'

# Connect to database
conn <- odbcConnect(server.name, server.user, server.pwd)

# Select the required variables from database. Note that these variables were chosen or derived from the Customer Feature Bazaar
data.sub <- sqlQuery(conn, 'select CUST_ADDR_ID,REG_DATE,SIL_RATIO,FEE_SUM,
                     USER_NORMAL_COUNT,PKG_NORMAL_COUNT,FEE_MONTH_MEAN,ACCRUAL_INCOME_MEAN,
                     FEE_MEAN,VOD_HD_COUNT,VOD_COUNT_SUM,VOD_COUNT_MEAN,BROADBAND_COUNT,DTV_COUNT,
                     VOD_EVER,REP_EVER,VOD_TIMES_MEAN,REP_TIMES_MEAN,TOTAL_AMOUNT from SYN_DA.T_CUST_TOTAL_INFO_201606_NEW_2')

#center1 and center2 are the initial clustering centers of the playback without VOD and with VOD, respectively
# The initial number of clusters were selected through two-step clustering
# The feature used for clustering were selected recursively manually to achieve the best performance. 
center1 <- as.matrix(data.frame(REG_DATE=c(105.495, 114.346, 106.274, 115.153, 105.341, 108.662), 
                                SIL_RATIO=c(0.056, 0.032, 0.036, 0.049, 0.012, 0.043), 
                                FEE_SUM=c(0.004, 145.019, 0.099, 20.428, 0.211, 0.001), 
                                USER_NORMAL_COUNT=c(0.507, 2.783, 3.679, 2.887, 3.159, 3.197), 
                                PKG_NORMAL_COUNT=c(0.105, 3.833, 6.775, 3.875, 4.4, 3.236), 
                                FEE_MONTH_MEAN=c(0.61, 27.769, 62.159, 23.921, 68.616, 24.456), 
                                ACCRUAL_INCOME_MEAN=c(0.063, 5.926, 6.122, 2.998, 35.441, 0.107), 
                                FEE_MEAN=c(0.001, 4.223, 0.028, 5.253, 0.055, 0), 
                                VOD_HD_COUNT=c(0.001, 15.298, 0.013, 2.325, 0.026, 0), 
                                VOD_COUNT_SUM=c(0.001, 34.46, 0.028, 4.218, 0.049, 0.001), 
                                VOD_COUNT_MEAN=c(0, 0.002, 0, 0.001, 0, 0), 
                                BROADBAND_COUNT=c(0.005, 0.089, 0.315, 0.054, 0.898, 0.031), 
                                DTV_COUNT=c(0.013, 1.37, 2.842, 1.251, 1.144, 0.107)))

center2<- as.matrix(data.frame(REG_DATE=c(87.652, 90.499), 
                               SIL_RATIO=c(0.015, 0.008), 
                               FEE_SUM=c(2.254, 126.205), 
                               USER_NORMAL_COUNT=c(3.366, 3.592), 
                               PKG_NORMAL_COUNT=c(7.019, 8.078), 
                               FEE_MONTH_MEAN=c(67.062, 66.661), 
                               ACCRUAL_INCOME_MEAN=c(15.033, 27.015), 
                               FEE_MEAN=c(0.693, 4.602), 
                               VOD_HD_COUNT=c(0.324, 16.038), 
                               VOD_COUNT_SUM=c(0.487, 28.849), 
                               VOD_COUNT_MEAN=c(0.012, 0.442), 
                               BROADBAND_COUNT=c(0.393, 0.284), 
                               DTV_COUNT=c(3.241, 4.131), 
                               VOD_EVER=c(0.998, 1), 
                               REP_EVER=c(0.772, 0.804), 
                               VOD_TIMES_MEAN=c(46.247, 83.645), 
                               REP_TIMES_MEAN=c(14.961, 15.671)))

# Dealing with threshold
data.sub$VOD_TIMES_MAX[data.sub$VOD_TIMES_MAX > 414] <- 414
data.sub$VOD_TIMES_MEAN[data.sub$VOD_TIMES_MEAN > 316] <- 316
data.sub$REP_TIMES_MAX[data.sub$REP_TIMES_MAX > 171] <- 171
data.sub$REP_TIMES_MEAN[data.sub$REP_TIMES_MEAN > 133] <- 133
data.sub$ACCRUAL_INCOME_MEAN[data.sub$ACCRUAL_INCOME_MEAN > 66] <- 66
data.sub$ACCRUAL_INCOME_MAX[data.sub$ACCRUAL_INCOME_MAX > 104] <- 104
data.sub$VOD_HD_COUNT[data.sub$VOD_HD_COUNT > 24] <- 24
data.sub$FEE_SUM[data.sub$FEE_SUM > 186] <- 186
data.sub$VOD_COUNT_SUM[data.sub$VOD_COUNT_SUM > 44] <- 44
data.sub$PKG_NORMAL_COUNT[data.sub$PKG_NORMAL_COUNT > 15] <- 15
data.sub$FEE_MONTH_MEAN[data.sub$FEE_MONTH_MEAN > 169] <- 169
data.sub$DTV_COUNT[data.sub$DTV_COUNT > 9] <- 9
data.sub$PAY_COUNT[data.sub$PAY_COUNT > 6] <- 6
data.sub$BB_COUNT[data.sub$BB_COUNT=='3+'] <- '3'
data.sub$ITV_COUNT[data.sub$ITV_COUNT=='3+'] <- '3'
data.sub$IF_COUNT[data.sub$IF_COUNT=='3+'] <- '3'
data.sub$BB_COUNT <- as.numeric(data.sub$BB_COUNT)
data.sub$ITV_COUNT <- as.numeric(data.sub$ITV_COUNT)
data.sub$IF_COUNT <- as.numeric(data.sub$IF_COUNT)
data.sub[is.na(data.sub)] <- 0

# 'noVOD' means that the customer has no playback with VOD. 'VOD' means (s)he has playback with VOD
data.noVOD <- data.sub[data.sub$VOD_EVER==0 & data.sub$REP_EVER==0,]

#Select the variables for clustering 'noVOD' customers
data.noVOD.forC <- data.frame(REG_DATE=data.noVOD$REG_DATE, 
                              SIL_RATIO=data.noVOD$SIL_RATIO, 
                              FEE_SUM=data.noVOD$FEE_SUM, 
                              USER_NORMAL_COUNT=data.noVOD$USER_NORMAL_COUNT, 
                              PKG_NORMAL_COUNT=data.noVOD$PKG_NORMAL_COUNT, 
                              FEE_MONTH_MEAN=data.noVOD$FEE_MONTH_MEAN, 
                              ACCRUAL_INCOME_MEAN=data.noVOD$ACCRUAL_INCOME_MEAN, 
                              FEE_MEAN=data.noVOD$FEE_MEAN, 
                              VOD_HD_COUNT=data.noVOD$VOD_HD_COUNT, 
                              VOD_COUNT_SUM=data.noVOD$VOD_COUNT_SUM, 
                              VOD_COUNT_MEAN=data.noVOD$VOD_COUNT_MEAN, 
                              BROADBAND_COUNT=data.noVOD$BROADBAND_COUNT, 
                              DTV_COUNT=data.noVOD$DTV_COUNT)

# Clustering 'noVOD' users
kc.noVOD <- amap::Kmeans(data.noVOD.forC, center1, iter.max = 50, method = "euclidean")
rm(data.noVOD.forC)
gc()

#Select the variables for clustering 'VOD' customers
data.VOD <- data.sub[data.sub$VOD_EVER==1 | data.sub$REP_EVER==1,]
data.VOD.forC <- data.frame(REG_DATE=data.VOD$REG_DATE, 
                            SIL_RATIO=data.VOD$SIL_RATIO, 
                            FEE_SUM=data.VOD$FEE_SUM, 
                            USER_NORMAL_COUNT=data.VOD$USER_NORMAL_COUNT, 
                            PKG_NORMAL_COUNT=data.VOD$PKG_NORMAL_COUNT, 
                            FEE_MONTH_MEAN=data.VOD$FEE_MONTH_MEAN, 
                            ACCRUAL_INCOME_MEAN=data.VOD$ACCRUAL_INCOME_MEAN, 
                            FEE_MEAN=data.VOD$FEE_MEAN, 
                            VOD_HD_COUNT=data.VOD$VOD_HD_COUNT, 
                            VOD_COUNT_SUM=data.VOD$VOD_COUNT_SUM, 
                            VOD_COUNT_MEAN=data.VOD$VOD_COUNT_MEAN, 
                            BROADBAND_COUNT=data.VOD$BROADBAND_COUNT, 
                            DTV_COUNT=data.VOD$DTV_COUNT, 
                            VOD_EVER=data.VOD$VOD_EVER, 
                            REP_EVER=data.VOD$REP_EVER, 
                            VOD_TIMES_MEAN=data.VOD$VOD_TIMES_MEAN, 
                            REP_TIMES_MEAN=data.VOD$REP_TIMES_MEAN)

# Clustering 'VOD' users
kc.VOD <- amap::Kmeans(data.VOD.forC, center2, iter.max = 50, method = "euclidean")
rm(data.VOD.forC)
gc()

# 'noVOD' clustering results ajustments
cluster.noVOD <- as.data.frame(kc.noVOD$centers)
cluster.noVOD$cluster <- 1:6
cls <- data.frame(cluster=kc.noVOD$cluster)
cls$km[cls$cluster==cluster.noVOD$cluster[cluster.noVOD$ACCRUAL_INCOME_MEAN==max(cluster.noVOD$ACCRUAL_INCOME_MEAN)]] <- '聚类6'

cls$km[cls$cluster==cluster.noVOD$cluster[cluster.noVOD$FEE_MONTH_MEAN==min(cluster.noVOD$FEE_MONTH_MEAN)]] <- '聚类1'
cls$km[cls$cluster==cluster.noVOD$cluster[cluster.noVOD$FEE_MONTH_MEAN==max(cluster.noVOD$FEE_MONTH_MEAN)]] <- '聚类3'
cls$km[cls$cluster==cluster.noVOD$cluster[cluster.noVOD$FEE_SUM==max(cluster.noVOD$FEE_SUM)]] <- '聚类4'
a.clst <- 1:6
b.clst <- c(cluster.noVOD$cluster[cluster.noVOD$FEE_MONTH_MEAN==min(cluster.noVOD$FEE_MONTH_MEAN)], 
            cluster.noVOD$cluster[cluster.noVOD$ACCRUAL_INCOME_MEAN==max(cluster.noVOD$ACCRUAL_INCOME_MEAN)], 
            cluster.noVOD$cluster[cluster.noVOD$FEE_MONTH_MEAN==max(cluster.noVOD$FEE_MONTH_MEAN)], 
            cluster.noVOD$cluster[cluster.noVOD$FEE_SUM==max(cluster.noVOD$FEE_SUM)])

if (kc.noVOD$size[setdiff(a.clst,b.clst)[1]] > kc.noVOD$size[setdiff(a.clst,b.clst)[2]]) {
  cls$km[cls$cluster==setdiff(a.clst,b.clst)[1]] <- '聚类5'; 
  cls$km[cls$cluster==setdiff(a.clst,b.clst)[2]] <- '聚类2'} else {
    cls$km[cls$cluster==setdiff(a.clst,b.clst)[1]] <- '聚类2'; 
    cls$km[cls$cluster==setdiff(a.clst,b.clst)[2]] <- '聚类5'
  }

#Add labels to different types of clusters.
data.noVOD$km <- cls$km
data.noVOD$k_means[data.noVOD$BROADBAND_COUNT >= 1] <- '宽带忠客'
data.noVOD$k_means[data.noVOD$km=='聚类1'] <-'低端沉默'
data.noVOD$k_means[data.noVOD$km=='聚类2' | data.noVOD$km=='聚类5'] <- '稳定中坚'
data.noVOD$k_means[data.noVOD$km=='聚类1' & (data.noVOD$ACCRUAL_INCOME_MEAN >= 5 | data.noVOD$USER_NORMAL_COUNT >= 2 |
                                             data.noVOD$PKG_NORMAL_COUNT >= 2 | data.noVOD$FEE_MONTH_MEAN > 20)] <- '稳定中坚'
data.noVOD$k_means[(data.noVOD$km=='聚类2' | data.noVOD$km=='聚类5') & 
                     (data.noVOD$USER_NORMAL_COUNT <= 1 & data.noVOD$PKG_NORMAL_COUNT <= 1 & 
                        data.noVOD$FEE_MONTH_MEAN < 20)] <- '低端沉默'
data.noVOD$k_means[(data.noVOD$km=='聚类3' | data.noVOD$km=='聚类6' | data.noVOD$km=='聚类4') & 
                     (data.noVOD$USER_NORMAL_COUNT > 1 | data.noVOD$PKG_NORMAL_COUNT > 1 | 
                        data.noVOD$FEE_MONTH_MEAN >= 20)] <- '稳定中坚'
data.noVOD$k_means[(data.noVOD$km=='聚类3' | data.noVOD$km=='聚类6' | data.noVOD$km=='聚类4') & 
                     (data.noVOD$USER_NORMAL_COUNT <= 1 | data.noVOD$PKG_NORMAL_COUNT <= 1 | 
                        data.noVOD$FEE_MONTH_MEAN < 20)] <- '低端沉默'
data.noVOD$k_means[data.noVOD$TOTAL_AMOUNT >= 200 & data.noVOD$FEE_MONTH_MEAN < 20 & 
                     data.noVOD$ACCRUAL_INCOME_MEAN < 5] <- '历史高端'
data.noVOD$k_means[data.noVOD$VOD_COUNT_SUM >= 10 & data.noVOD$TOTAL_AMOUNT >= 200] <- '点播达人'
data.noVOD <- data.noVOD[,-20]


# 'VOD' clustering results ajustments
#Add labels to different types of clusters.
if (kc.VOD$centers[1,"VOD_COUNT_SUM"] > kc.VOD$centers[2,"VOD_COUNT_SUM"]) {kc.VOD$k_means[kc.VOD$cluster==1] <- '聚类2'; 
kc.VOD$k_means[kc.VOD$cluster==2] <- '聚类1'} else {kc.VOD$k_means[kc.VOD$cluster==1] <- '聚类1'; 
kc.VOD$k_means[kc.VOD$cluster==2] <- '聚类2'}
data.VOD$k_means <- kc.VOD$k_means
data.VOD$k_means[data.VOD$k_means=='聚类1' & data.VOD$VOD_COUNT_SUM >= 10 & data.VOD$TOTAL_AMOUNT >= 200] <- '聚类2'
data.VOD$k_means[data.VOD$k_means=='聚类2' & (data.VOD$VOD_COUNT_SUM < 5 | data.VOD$TOTAL_AMOUNT < 10)] <- '聚类1'
data.VOD$k_means[data.VOD$k_means=='聚类1'] <- '点播忠客'
data.VOD$k_means[data.VOD$k_means=='聚类2'] <- '点播达人'

data.output <- rbind(data.noVOD,data.VOD)

close.connection(conn)
rm(list = ls())
gc()