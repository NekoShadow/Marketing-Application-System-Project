#Import relevant packages
library(Matrix)
library(arules)

#Initial settings
options(stringsAsFactors = FALSE)
rm(list = ls())
gc()

#Read the data
data.load <- read.csv("06.package_apriori_100W.csv")

#Data Preprocessing
data.load$PACKAGENAME[data.load$PACKAGENAME == "有线通30M"] <- "有线通+30M"
data.load$PACKAGENAME[startsWith(data.load$PACKAGENAME,"□")] <- substring(data.load$PACKAGENAME[startsWith(data.load$PACKAGENAME,"□")], 2)
data.load$PACKAGENAME[data.load$PACKAGENAME == ""] <- "NULL"
data.load$PACKAGENAME[endsWith(data.load$PACKAGENAME, "新装") | endsWith(data.load$PACKAGENAME, "续订") | 
                        endsWith(data.load$PACKAGENAME, "增订") | endsWith(data.load$PACKAGENAME, "促销")] <- substring(
                          endsWith(data.load$PACKAGENAME, "新装") | endsWith(data.load$PACKAGENAME, "续订") | 
                            endsWith(data.load$PACKAGENAME, "增订") | endsWith(data.load$PACKAGENAME, "促销"),1,nchar(
                              endsWith(data.load$PACKAGENAME, "新装") | endsWith(data.load$PACKAGENAME, "续订") | 
                                endsWith(data.load$PACKAGENAME, "增订") | endsWith(data.load$PACKAGENAME, "促销"))-2)

#Remove duplicate items
data.package <- unique(data.frame(item = data.load$PACKAGENAME, id = data.load$CUST_ADDR_ID))
rm(data.load)
gc()
str(data.package)

#Turn into transaction type data
data.apriori <- as(split(data.package$item, data.package$id), "transactions")
rm(data.package)
gc()
rules.set <- apriori(data.apriori, parameter = list(supp=0.005, conf=0.5, maxlen = 5))

#Right hand side sets used for extracting rules
rhs.set <- c("高清合家欢节目包", "有线通+100M", "DOX高清影视节目包", "1+云游戏", 
             "高清回看组合包", "新视觉高清节目", "有线通20M", "宜家39套餐", 
             "DOX高清影视点播包", "百灵K歌专区", "爱家69套餐10M", "标清点播回看", 
             "高清点播回看组合包", "高清互动家庭50M", "有线通+50M", "高清点播回看", 
             "高清点播", "高清回看", "爱家89套餐30M", "高清乐享单向套餐", 
             "高清点播回看组合置换", "标清家庭特惠节目包", "文广高清精选节目包", 
             "高清互动家庭10M", "有线通2M", "宜家79套餐", "爱家49套餐", "高清互动家庭15M", 
             "高清互动家庭30M", "高清基本节目包Ⅱ", "爱家39套餐", "有线通10M", "爱家59套餐", 
             "有线通+30M", "高清乐享互动套餐", "有线通15M")
rules.sub <- subset(rules.set, subset = rhs %in% rhs.set & lift >= 1 & !is.null(lhs))

#Define a function to remove duplicate rules
redundant.rm <- function(rule,by="lift")  
{  
  #rule：Rules that need to be simplified  
  #by：The variable to be based on to remove rules  
  #Possible values,"lift","confidence"  
  a <- sort(rule,by=by)  
  m<- is.subset(a,a,proper=TRUE)  
  m[lower.tri(m, diag=TRUE)] <- NA  
  r <- colSums(m, na.rm=TRUE) >= 1  
  finall.rules <- a[!r]  
  return(finall.rules)   
} 

#Obtain the rule set
rules.finall <- redundant.rm(rules.sub)


