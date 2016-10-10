library(RPostgreSQL)
con <- dbConnect(dbDriver("PostgreSQL"), host="gpdb", dbname="scratch") # will look for and use .pgpass for user and password
ClickCountsByUser <- dbGetQuery(con, "SELECT click_date, click_time FROM clickstream.log WHERE user_id IS NOT NULL GROUP BY user_id ORDER BY Clicks DESC;")



cHist <- hist(ClickCountsByUser$clicks, breaks = c(0,10^0,10^1,10^2,10^3,10^4,10^5))

HistData <- data.frame(cHist$breaks[-1],cHist$counts)
colnames(HistData) <- c('Group','Count')
HistData
library(ggplot2)
ggplot(data=HistData, aes(x=Group,y=Count+1)) + 
  geom_bar(stat='identity',position = 'dodge')+ 
  scale_y_log10(expand=c(0,0),breaks=c(10,10^3,10^5,10^7),labels=c("10","1k","100k","10M")) +
  scale_x_log10(breaks=c(1,10^1,10^2,10^3,10^4,10^5),labels=c("1","2-10","11-100","101-1k","1k-10k","10k-100k"))+
  ylab('# of Users')+
  xlab('# of Clicks')+
  ggtitle('Clicks per User 12/01/13 -- 06/01/14')+
  geom_text(data=HistData,aes(x=Group,y=Count*0.1+10,label=prettyNum(Count,big.mark = ",")),color='darkblue')+
  ggsave(file='myPlot1.png')


HistMaxClicksInDay <- data.frame(read.csv(file='~/z/QueryResults1.csv',header = FALSE))
colnames(HistMaxClicksInDay) <- c('Group','Count')
HistMaxClicksInDay$Group <- factor(HistMaxClicksInDay$Group, levels=c("1","2","3-5","6-10","11-100","101-1000","1000+"))
ggplot(data=HistMaxClicksInDay, aes(x=Group,y=Count+1)) + 
  geom_bar(stat='identity',position = 'dodge')+ 
  scale_y_log10(expand=c(0,0),breaks=c(10,10^3,10^5,10^7),labels=c("10","1k","100k","10M")) +
  ylab('# of Users')+
  xlab('Max Clicks in 1-day')+
  ggtitle('Max Clicks in 1-day by User -- 12/01/13 to 06/01/14')+
  geom_text(data=HistMaxClicksInDay,aes(x=Group,y=Count*0.1+10,label=prettyNum(Count,big.mark = ",")),color='darkblue')+
  ggsave(file='myPlot2.png')


