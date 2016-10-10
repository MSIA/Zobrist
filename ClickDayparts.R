library(RPostgreSQL)
con <- dbConnect(dbDriver("PostgreSQL"), host="gpdb", 
                 dbname="scratch") # will look for and use .pgpass for user and password

ClickTimes <- dbGetQuery(con, "SELECT click_date, click_time 
                                FROM clickstream.log_sample 
                                ORDER BY click_time DESC;")

ClickTimes$DOW <- weekdays(as.Date(ClickTimes$click_date))

library(ggplot2)
## Try a couple different ways of plotting DOW distribution.
DOWplot <- barplot(prop.table(table(ClickTimes$DOW)))
DOWplot2 <- ggplot(data.frame(ClickTimes$DOW), aes(x = ClickTimes$DOW))
DOWplot2 + geom_histogram(fill="lightgreen")

library(lubridate)

ClickTimes2 <- na.omit(ClickTimes)
ClickTimes2$Time <- strptime(ClickTimes2$click_time, "%H:%M:%S")


hist(ClickTimes2$Time, breaks = "hours", xlab = "Time of Day")
