# Read in avg length of time jobs were posted by city, query to retreive is below (only cities with at least 100 postings were kept)
      # SELECT N.location, AVG(E.dateexpired - to_date(N.datenew,'YYYY-MM-DD' )) AS AvgLengthPosted, count(*)
      # FROM clickstream.expire E INNER JOIN clickstream.new N ON E.guid = N.guid
      # GROUP BY N.location
      # ORDER BY count(*) DESC
PostingLength <- read.table('JobPostings2/Unemployment by City/PostLengths100.txt', sep = '\t',quote = "", fill = T, stringsAsFactors = F, header = T)
PostingLength$location <- gsub('-',' ', PostingLength$location)
PostingLength$location <- gsub('Metropolitan','', PostingLength$location)


# Read in unemployment rate by city, eliminate extraneous word then rearrange City so that state comes first 
  # http://www.bls.gov/lau/lamtrk14.htm
Unemployment <- read.table('JobPostings2/Unemployment by City/UnemploymentByMetro.csv', sep = ',' , fill = T, stringsAsFactors = F, header = T)
Unemployment$City <- gsub('Metropolitan','', Unemployment$City)
Unemployment$City <- gsub('Statistical','', Unemployment$City)
Unemployment$City <- gsub('Area','', Unemployment$City)
x <- read.csv(textConnection(Unemployment[["City"]]),header = F)
colnames(x) <- c('CityName',"State")
Unemployment$City <- paste(trimws(x$State), trimws(x$CityName))

######################## Function for finding closest match using levenshtein disance ##############
library(RecordLinkage)
ClosestMatch2 = function(string, stringVector){
  distance = levenshteinSim(string, stringVector)
  which.max(distance)
}
###################################################################################################

# For each job on unemployment table, match it up with closest name match on PostingLength table
Unemployment$AvgPost <- 0
Unemployment$MatchedLoc <- ""
for (i in 1:nrow(Unemployment)) {
  myMatch <- ClosestMatch2(Unemployment$City[i], PostingLength$location)
  Unemployment$AvgPost[i] <- PostingLength[myMatch,'avglengthposted']
  Unemployment$MatchedLoc[i] <- PostingLength[myMatch,'location']
}

# plot, find correlation between AvgPost and Unemployment rate
plot(Unemployment$Rate, Unemployment$AvgPost, xlab = 'Unemployment Rate', ylab = 'Avg Posting Duration')
cor(Unemployment$Rate, Unemployment$AvgPost)

# plot, find correlation between AvgPost and Unemployment rate --- exclude outlier unemployment
with(Unemployment[Unemployment$Rate<15,],plot(Rate,AvgPost, xlab = 'Unemployment Rate', ylab = 'Avg Posting Duration'))
with(Unemployment[Unemployment$Rate<15,],cor(Rate,AvgPost))



                       