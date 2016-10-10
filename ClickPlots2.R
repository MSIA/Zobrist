library(RPostgreSQL)
con <- dbConnect(dbDriver("PostgreSQL"), host="gpdb", dbname="scratch") # will look for and use .pgpass for user and password


myTable <- dbGetQuery(con, "SELECT count(*), CASE WHEN click_time_btw.timeuntilnextclick BETWEEN -1*\'1 second\'::INTERVAL AND 5*\'1 second\'::INTERVAL THEN \'<5 sec\' WHEN click_time_btw.timeuntilnextclick BETWEEN 5.001*\'1 second\'::INTERVAL AND 10*\'1 second\'::INTERVAL THEN \'5-10 sec\' WHEN click_time_btw.timeuntilnextclick BETWEEN 10.001*\'1 second\'::INTERVAL AND 30*\'1 second\'::INTERVAL THEN \'10-30 sec\' WHEN click_time_btw.timeuntilnextclick BETWEEN 30.001*\'1 second\'::INTERVAL AND 60*\'1 second\'::INTERVAL THEN \'30-60 sec\' WHEN click_time_btw.timeuntilnextclick BETWEEN 60.001*\'1 second\'::INTERVAL AND 120*\'1 second\'::INTERVAL THEN \'1-2 min\' WHEN click_time_btw.timeuntilnextclick BETWEEN 120.001*\'1 second\'::INTERVAL AND 300*\'1 second\'::INTERVAL THEN \'2-5 min\' WHEN click_time_btw.timeuntilnextclick BETWEEN 300.001*\'1 second\'::INTERVAL AND 600*\'1 second\'::INTERVAL THEN \'5-10 min\' WHEN click_time_btw.timeuntilnextclick BETWEEN 600.001*\'1 second\'::INTERVAL AND 1200*\'1 second\'::INTERVAL THEN \'10-20 min\' WHEN click_time_btw.timeuntilnextclick BETWEEN 1200.001*\'1 second\'::INTERVAL AND 3600*\'1 second\'::INTERVAL THEN \'20-60 min\' ELSE \'60 min+\' END AS Bin FROM click_time_btw GROUP BY Bin;")

myTable$bin <- factor(myTable$bin, levels=c("<5 sec","5-10 sec","10-30 sec","30-60 sec","1-2 min","2-5 min","5-10 min","10-20 min","20-60 min","60 min+"))


library(ggplot2)
ggplot(data=myTable, aes(x=bin,y=count)) + 
  geom_bar(stat='identity',position = 'dodge')+ 
  ylab('Time Between Clicks')+
  xlab('Count of Clicks')+
  ggtitle('Time Between Clicks')+
  ggsave(file='myPlot3.png')+
  theme(axis.text.x = element_text(angle = 90, vjust = 0))



TimesBtw <- dbGetQuery(con, "SELECT biggeststretch, count(*) FROM clickstream.user_day_clickstreak GROUP BY biggeststretch ORDER BY biggeststretch;")
library(scales)

?math_format()

scientific_10 <- function(x) {
  parse(text=gsub("e", " %*% 10^", scientific_format()(x)))
}

ggplot(data=TimesBtw, aes(x = biggeststretch, y = count))+
  geom_bar(stat='identity')+ 
  scale_y_log10(breaks = c(10,10^2,10^3,10^4,10^5,10^6,10^7,10^8),labels = scientific_10)+
  ylab('Count of Users')+
  xlab('Consecutive Days Clicked')+
  ggtitle('User Click Streak')+
  ggsave(file='myPlot4.png')

