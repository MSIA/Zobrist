# libraries
library(gbm)
library(randomForest)
library(ggplot2)

# load in and merge data
jobmetrics = read.csv('select___FROM_____select_guid_major_name.csv')
unemployee = read.csv('unemployement rate.csv')
jobtype = read.csv('output.csv',stringsAsFactors = FALSE)
jobfull = merge(x=jobmetrics,y=unemployee,by.x = 'state',by.y = 'state')
jobfull = merge(x=jobfull,y=jobtype,by.x='guid',by.y='guid',all.x = TRUE)


for (i in 1:length(jobfull$top1)){
  if (is.na(jobfull$top1[i])){
    jobfull$top1[i]='Unclassified'
  }
}
jobfull$top1 = as.factor(jobfull$top1)
jobfull$top1 = relevel(jobfull$top1,'Unclassified')

# log transformation
jobfull = cbind(jobfull,log10(jobfull$days_online),log10(jobfull$mean_click_per_day_online))
colnames(jobfull)[c(23,24)]=c('log_days_online','log_mean_click_per_day')

# match company names and fortune 500
guidcompany = read.csv('GUID_COMPANY.csv')
jobfull = merge(x=jobfull,y=guidcompany)

names(jobtype)[5]='top'
excludelist=c('job requirement',"employment equality" ,"random noise","general", "work environment",'Unclassified','NA')
for (i in 1:length(jobtype$guid)){
  jobtype$top[i]=jobtype$top1[i]
  if (is.na(jobtype$top[i]) ||  is.element(jobtype$top[i],excludelist)){
    jobtype$top[i]=jobtype$top2[i]
  }

  if (is.na(jobtype$top[i]) ||  is.element(jobtype$top[i],excludelist)){
    jobtype$top[i]=jobtype$top3[i]
  }

}

c = ggplot(jobtype,aes(top))
 c+geom_bar(fill='slateblue')+coord_flip()
# Boosting
ntree=5000
job.boost = gbm(log_mean_click_per_day~local_ratio+rate+zone_full+top1,data=jobfull,distribution = 'gaussian',
                n.trees=ntree, interaction.depth = 2,verbose = T,shrinkage = 0.01)
summary(job.boost)
yhat.boost = predict(job.boost,newdata = jobfull,n.trees = ntree)
mean((yhat.boost - jobfull$log_mean_click_per_day)^2)

# residual plot
df = as.data.frame(cbind(yhat.boost,yhat.boost-jobfull$log_days_online ))
names(df)
ggplot(data=df,aes(x=yhat.boost, y=V2))+geom_point(alpha=.1)

# prediction plot
df = as.data.frame(cbind(yhat.boost,jobfull$log_mean_click_per_day))
names(df)
ggplot(data=df,aes(x=jobfull$log_mean_click_per_day, y=yhat.boost))+geom_point(alpha=.1)
