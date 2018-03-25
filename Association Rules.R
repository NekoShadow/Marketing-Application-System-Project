#Import relevant packages
library(Matrix)
library(arules)
library(RODBC)
library(data.table)

#Initial Settings
options(stringsAsFactors = FALSE)
rm(list = ls())
gc()

#Connect database
conn.syn <- odbcConnect('edw_01_jl', 'XXXXXX', 'XXXXXX')
conn.aa <- odbcConnect('edw_01_jl', 'XXXXXX', 'XXXXXX')

#load the data
data.load1 <- sqlQuery(conn.syn, 'select PACKAGEID,PACKAGENAME,VERSION_END from dw_mkt.t3d_package_ext where rownum <= 10')

data.load1 <- data.load1[order(data.load1$PACKAGEID, +(data.load1$VERSION_END), decreasing = FALSE),]
for (i in 1:(nrow(data.load1)-1)){if (data.load1$PACKAGEID[i]==data.load1$PACKAGEID[i+1]) 
{data.load1$PACKAGENAME_NEW[i]<-data.load1$PACKAGENAME[i+1]} else {data.load1$PACKAGENAME_NEW[i]<-data.load1$PACKAGENAME[i]}}
rm(i)
data.load1$PACKAGENAME_NEW[nrow(data.load1)] <- data.load1$PACKAGENAME[nrow(data.load1)]
pkg.newname <- unique(data.frame(PACKAGENAME=data.load1$PACKAGENAME, PACKAGENAME_NEW=data.load1$PACKAGENAME_NEW))
rm(data.load1)



#Load the data
data.load2 <- sqlQuery(conn.syn, "select PROD_INST_ID,CUST_ADDR_ID,PACKAGEID,PACKAGENAME,VALID_DATE from T_SA_PACKAGE where rownum <= 10000")
#Processing data.load2
data.load2 <- dplyr::filter(data.load2, year(as.Date(data.load2$VALID_DATE))<=2099)

#Merge the dataframes
data.merge <- merge(pkg.newname, data.load2, by.x='PACKAGENAME', by.y='PACKAGENAME', all.y=TRUE)[,-1]
rm(data.load2)
rm(pkg.newname)
gc()

#Dealing with TV program names
data.merge$PACKAGENAME <- trimws(data.merge$PACKAGENAME)

data.merge$PACKAGENAME[startsWith(data.merge$PACKAGENAME,"◇") | startsWith(data.merge$PACKAGENAME,"○") | 
                         startsWith(data.merge$PACKAGENAME,"●") | startsWith(data.merge$PACKAGENAME,"◎") ] <- substring(
                           data.merge$PACKAGENAME[startsWith(data.merge$PACKAGENAME,"◇") | startsWith(data.merge$PACKAGENAME,"○") | 
                                                    startsWith(data.merge$PACKAGENAME,"●") | startsWith(data.merge$PACKAGENAME,"◎")], 2)

data.merge$PACKAGENAME[startsWith(data.merge$PACKAGENAME, "【") & grepl("】", data.merge$PACKAGENAME)] <-
  substring(data.merge$PACKAGENAME[startsWith(data.merge$PACKAGENAME, "【") & grepl("】", data.merge$PACKAGENAME)], 
            regexpr("】",data.merge$PACKAGENAME[startsWith(data.merge$PACKAGENAME, "【") & grepl("】", data.merge$PACKAGENAME)])+1
            ,nchar(data.merge$PACKAGENAME[startsWith(data.merge$PACKAGENAME, "【") & grepl("】", data.merge$PACKAGENAME)]))

data.merge$PACKAGENAME[startsWith(data.merge$PACKAGENAME, "[") & grepl("]", data.merge$PACKAGENAME)] <-
  substring(data.merge$PACKAGENAME[startsWith(data.merge$PACKAGENAME, "[") & grepl("]", data.merge$PACKAGENAME)], 
            regexpr("]",data.merge$PACKAGENAME[startsWith(data.merge$PACKAGENAME, "[") & grepl("]", data.merge$PACKAGENAME)])+1
            ,nchar(data.merge$PACKAGENAME[startsWith(data.merge$PACKAGENAME, "[") & grepl("]", data.merge$PACKAGENAME)]))

data.merge$PACKAGENAME[startsWith(data.merge$PACKAGENAME, "（") & grepl("）", data.merge$PACKAGENAME)] <-
  substring(data.merge$PACKAGENAME[startsWith(data.merge$PACKAGENAME, "（") & grepl("）", data.merge$PACKAGENAME)], 
            regexpr("）",data.merge$PACKAGENAME[startsWith(data.merge$PACKAGENAME, "（") & grepl("）", data.merge$PACKAGENAME)])+1
            ,nchar(data.merge$PACKAGENAME[startsWith(data.merge$PACKAGENAME, "（") & grepl("）", data.merge$PACKAGENAME)]))

data.merge$PACKAGENAME[startsWith(data.merge$PACKAGENAME,"-")] <- substring(data.merge$PACKAGENAME[startsWith(data.merge$PACKAGENAME,"-")], 2)

data.merge$PACKAGENAME[startsWith(data.merge$PACKAGENAME,"购买-")] <- 
  substring(data.merge$PACKAGENAME[startsWith(data.merge$PACKAGENAME,"购买-")], 4, nrow(data.merge$PACKAGENAME[startsWith(data.merge$PACKAGENAME,"购买-")]))

data.merge$PACKAGENAME[startsWith(data.merge$PACKAGENAME,"VIP-") | startsWith(data.merge$PACKAGENAME,"礼品卡-")] <- 
  substring(data.merge$PACKAGENAME[startsWith(data.merge$PACKAGENAME,"VIP-") | startsWith(data.merge$PACKAGENAME,"礼品卡-")], 5)

data.merge$PACKAGENAME[grepl('-',data.merge$PACKAGENAME)] <- substring(data.merge$PACKAGENAME[grepl('-',data.merge$PACKAGENAME)],
                                                                       1,regexpr('-',data.merge$PACKAGENAME[grepl('-',data.merge$PACKAGENAME)])-1)


data.merge$PACKAGENAME[grepl('－',data.merge$PACKAGENAME)] <- substring(data.merge$PACKAGENAME[grepl('－',data.merge$PACKAGENAME)],
                                                                       1,regexpr('－',data.merge$PACKAGENAME[grepl('－',data.merge$PACKAGENAME)])-1)

data.merge$PACKAGENAME <- trimws(data.merge$PACKAGENAME)

data.merge$PACKAGENAME[endsWith(data.merge$PACKAGENAME, ']') & grepl('\\[', data.merge$PACKAGENAME)] <- 
  substring(data.merge$PACKAGENAME[endsWith(data.merge$PACKAGENAME, ']') & grepl('\\[', data.merge$PACKAGENAME)], 1, 
            regexpr('\\[', data.merge$PACKAGENAME[endsWith(data.merge$PACKAGENAME, ']') & grepl('\\[', data.merge$PACKAGENAME)])-1)

data.merge$PACKAGENAME[endsWith(data.merge$PACKAGENAME, "新装") | endsWith(data.merge$PACKAGENAME, "续订") | 
                         endsWith(data.merge$PACKAGENAME, "增订") | endsWith(data.merge$PACKAGENAME, "促销") | endsWith(data.merge$PACKAGENAME, "续费")] <- substring(data.merge$PACKAGENAME[
                           endsWith(data.merge$PACKAGENAME, "新装") | endsWith(data.merge$PACKAGENAME, "续订") | 
                             endsWith(data.merge$PACKAGENAME, "增订") | endsWith(data.merge$PACKAGENAME, "促销") | endsWith(data.merge$PACKAGENAME, "续费")],1,nchar(data.merge$PACKAGENAME[
                               endsWith(data.merge$PACKAGENAME, "新装") | endsWith(data.merge$PACKAGENAME, "续订") | 
                                 endsWith(data.merge$PACKAGENAME, "增订") | endsWith(data.merge$PACKAGENAME, "促销") | endsWith(data.merge$PACKAGENAME, "续费")])-2)

data.merge$PACKAGENAME[endsWith(data.merge$PACKAGENAME, "新装")| endsWith(data.merge$PACKAGENAME, "促销") | endsWith(data.merge$PACKAGENAME, "续费")] <- substring(data.merge$PACKAGENAME[
  endsWith(data.merge$PACKAGENAME, "新装") | endsWith(data.merge$PACKAGENAME, "促销") | endsWith(data.merge$PACKAGENAME, "续费")],1,nchar(data.merge$PACKAGENAME[
    endsWith(data.merge$PACKAGENAME, "新装") | endsWith(data.merge$PACKAGENAME, "促销") | endsWith(data.merge$PACKAGENAME, "续费")])-2)

data.merge$PACKAGENAME[endsWith(data.merge$PACKAGENAME, '）') & grepl('（', data.merge$PACKAGENAME)] <- 
  substring(data.merge$PACKAGENAME[endsWith(data.merge$PACKAGENAME, '）') & grepl('（', data.merge$PACKAGENAME)], 1, 
            regexpr('（', data.merge$PACKAGENAME[endsWith(data.merge$PACKAGENAME, '）') & grepl('（', data.merge$PACKAGENAME)])-1)

data.merge$PACKAGENAME[endsWith(data.merge$PACKAGENAME, ')') & grepl('\\(', data.merge$PACKAGENAME)] <- 
  substring(data.merge$PACKAGENAME[endsWith(data.merge$PACKAGENAME, ')') & grepl('\\(', data.merge$PACKAGENAME)], 1, 
            regexpr('\\(', data.merge$PACKAGENAME[endsWith(data.merge$PACKAGENAME, ')') & grepl('\\(', data.merge$PACKAGENAME)])-1)

data.merge$PACKAGENAME[endsWith(data.merge$PACKAGENAME, "团购")| endsWith(data.merge$PACKAGENAME, "自购") | 
                         endsWith(data.merge$PACKAGENAME, "包年") | endsWith(data.merge$PACKAGENAME, "包月")] <- 
  substring(data.merge$PACKAGENAME[endsWith(data.merge$PACKAGENAME, "团购") | endsWith(data.merge$PACKAGENAME, "自购") | 
                                     endsWith(data.merge$PACKAGENAME, "包年") | endsWith(data.merge$PACKAGENAME, "包月")],
            1,nchar(data.merge$PACKAGENAME[endsWith(data.merge$PACKAGENAME, "团购") | 
                                             endsWith(data.merge$PACKAGENAME, "自购") | endsWith(data.merge$PACKAGENAME, "包年") | 
                                             endsWith(data.merge$PACKAGENAME, "包月")])-2)

data.merge$PACKAGENAME[grepl('有线通大客户部团购',data.merge$PACKAGENAME)] <- '有线通大客户部团购'
data.merge$PACKAGENAME[grepl('互动家庭B套餐',data.merge$PACKAGENAME)] <- '互动家庭B套餐'
data.merge$PACKAGENAME[grepl('互动家庭合并包',data.merge$PACKAGENAME)] <- '互动家庭合并包'
data.merge$PACKAGENAME[data.merge$PACKAGENAME=='有线通30M+' | data.merge$PACKAGENAME=='有线通+30M'] <- '有线通30M'
data.merge$PACKAGENAME[grepl('高清互动家庭15M',data.merge$PACKAGENAME)] <- '高清互动家庭15M'
data.merge$PACKAGENAME[grepl('高清基础套餐',data.merge$PACKAGENAME)] <- '高清基础套餐'
data.merge$PACKAGENAME[grepl('高清互动家庭A套餐',data.merge$PACKAGENAME)] <- '高清互动家庭A套餐'
data.merge$PACKAGENAME[grepl('高清合家欢节目包',data.merge$PACKAGENAME)] <- '高清合家欢节目包'
data.merge$PACKAGENAME <- sub("[0-9]*元/[0-9]*个月", "", data.merge$PACKAGENAME)

#Remove duplicate items
data.package <- unique(data.frame(item = data.merge$PACKAGENAME, id = data.merge$CUST_ADDR_ID))
rm(data.merge)
gc()

str(data.package)
#Turn to transaction type data
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
rules.sub <- subset(rules.set, subset = rhs %in% rhs.set & lift >= 1)

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
rules.finall <- redundant.rm(rules.sub)

close.connection(conn.syn)
close.connection(conn.aa)
rm(list = ls())
gc()
