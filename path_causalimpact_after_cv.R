library("CausalImpact")
library("lattice")
library("Metrics")
library("gtools")
library("plyr")
library("readr")
library("RCurl")
library("devtools")
source_url("https://raw.githubusercontent.com/zboraon/causalimpactfor4_2kaBPevent/master/functions/causal_impact_4_2ka.R") #add the causal_impact_4_2ka.R function to source


responseseturl <- getURL("https://raw.githubusercontent.com/zboraon/causalimpactfor4_2kaBPevent/master/data/impact_set_after_cleared_27_74ka.csv")
  possible <- read.csv(text = responseseturl) # response variables
  
  controlseturl <- getURL("https://raw.githubusercontent.com/zboraon/causalimpactfor4_2kaBPevent/master/data/training_set_after_cleared_27_74ka.csv")
  training <- read.csv(text = controlseturl) # control set
  


age <- possible$age

trainingwoage <- training[,2:15]

lp=length(possible)
  
controldata=training[,2:15]  
set.seed=1234

# organize data according to the cross-validation results
mydir = "min_cv_results/"
myfiles = list.files(path=mydir, pattern="*.csv", full.names=TRUE)
myfiles = mixedsort(sort(myfiles))
dat_csv = ldply(myfiles, read_csv)

preimpact.all<-zoo() 
postimpact.all<-zoo() 
response.all<-zoo() 
limitdata.all<-zoo()

for (k in 1:(lp-1)){ 

impact_result <- c()
data_united <- c()

cv_mins=read_csv(myfiles[k])
sel_prior_sd=min(cv_mins$prior_sd)

# evaluate causal impact
impact_result=causal_impact_4_2ka(data_fortest =  possible[,(k+1)],data_fortraining =  trainingwoage,age = age,pre_period = c(which(age==-7450),which(age==-4400)),post_period = c(which(age==-4350),which(age==-3950)),iterations = 20000,prior_sd = sel_prior_sd, number_of_seasons=1, season=1,DR=FALSE)

# save results, it takes amount from your disk, you can close this to save space in your disk.
dir.create("resultdata")
save(impact_result,file=paste0("resultdata/",names(possible)[(k+1)],".RData"))

# tidy things up 

data_united=merge.zoo(impact_result$series$response,impact_result$series$point.pred,impact_result$series$point.pred.lower,impact_result$series$point.pred.upper)

colnames(data_united) = c(paste0(names(possible)[(k+1)],"_response") ,paste0(names(possible)[(k+1)],"_point.pred"),paste0(names(possible)[(k+1)],"_point.pred.lower"),paste0(names(possible)[(k+1)],"_point.pred.upper"))
responsedata=data_united[, 1, drop = FALSE]
limitdata=data_united[, 3:4, drop = FALSE]


preimpact=window(data_united, start = -7450, end = -4400)
postimpact=window(data_united, start = -4350, end = -2700)

colnames(preimpact) = c(paste0(names(possible)[(k+1)],"_pre.response") ,paste0(names(possible)[(k+1)],"_pre.point.pred"),paste0(names(possible)[(k+1)],"_pre.point.pred.lower"),paste0(names(possible)[(k+1)],"_pre.point.pred.upper"))

colnames(postimpact) = c(paste0(names(possible)[(k+1)],"_post.response") ,paste0(names(possible)[(k+1)],"_post.point.pred"),paste0(names(possible)[(k+1)],"_post.point.pred.lower"),paste0(names(possible)[(k+1)],"_post.point.pred.upper"))

preimpact.all=merge.zoo(preimpact.all,preimpact)
postimpact.all=merge.zoo(postimpact.all,postimpact)
response.all=merge.zoo(response.all,responsedata)
limitdata.all=merge.zoo(limitdata.all,limitdata)

# create useful plots and save them
dir.create("plots")

pdf(paste0("plots/",names(possible)[(k+1)],"coeffs.pdf"), width = 14 , height = 7)
plot(impact_result$model$bsts.model, "coefficients")
dev.off()

pdf(paste0("plots/",names(possible)[(k+1)],"comps.pdf"), width = 14 , height =6)
plot(impact_result$model$bsts.model, "components",xlim= c(-7500,-2700))
dev.off()

impact_plot=plot(impact_result)

pdf(paste0("plots/",names(possible)[(k+1)],"impact.pdf"), width = 14 , height = 8.50)
print(impact_plot)
dev.off()

sink(file=paste0("resultdata/",names(possible)[(k+1)],".txt"))
print(impact_result, "report")
sink()

}

#save each period to different text files
write.zoo(preimpact.all, file = "resultdata/preimpactall.csv")
write.zoo(postimpact.all, file = "resultdata/postimpactall.csv")
write.zoo(response.all, file = "resultdata/responseall.csv")
write.zoo(limitdata.all, file = "resultdata/limitdataall.csv")
