  library("CausalImpact")
  library("lattice")
  library("Metrics")
  library("RCurl")
  library(devtools)
  source_url("https://raw.githubusercontent.com/zboraon/causalimpactfor4_2kaBPevent/master/loop_4_2ka_BP.R") #add the loop_4_2ka_BP.R function to source
 
  responseseturl <- getURL("https://raw.githubusercontent.com/zboraon/causalimpactfor4_2kaBPevent/master/impact_set_after_cleared_27_74ka.csv")
  possible <- read.csv(text = responseseturl) # response variables
  
  controlseturl <- getURL("https://raw.githubusercontent.com/zboraon/causalimpactfor4_2kaBPevent/master/training_set_after_cleared_27_74ka.csv")
  training <- read.csv(text = controlseturl) # control set
  

  age=possible$age 
  
  lp <- length(possible)
  
   
  controldata <- training[,2:15]
  
    
    
  set.seed=1234
  sdseq=seq(0.01, 0.1, by = 0.01) # possible k values used for cross-validation
  
  for (j in 2:lp){
    horizon <- 9
    number_of_folds <- 3
    
    data_combined <- cbind(possible[,j,drop=FALSE],controldata)
    
    
    NonNAindex <- which(!is.na(possible[,j]))
    lastinitialNA <- min(NonNAindex)-1
    testNA=(horizon+1)*number_of_folds
    if (which(age == -4400)-lastinitialNA>30) { # for relatively longer data
      horizon <- horizon 
      number_of_folds <- number_of_folds 
    }
    
    
    else
      horizon <- 5 # for relatively short data
      number_of_folds <- 3 

  
      res_df <- c()
  for (prior_sd in sdseq) { 
      
    
    res <-loop_4_2ka_BP(data_combined=data_combined,
                        prior_sd=prior_sd,
                        age=age,
                        horizon=horizon,
                        number_of_folds=number_of_folds)
    
                        print(paste0("prior_sd ", prior_sd,
                       ": mean(rmse) ", mean(res$rmserr),
                       " / mean(mape) ", mean(res$maerr),
                       " / mean(mase) ", mean(res$maserr)))
          res_row <- data.frame(prior_sd=prior_sd,
                                mean_rmse=mean(res$rmserr),
                                mean_mape=mean(res$maerr),
                                mean_mase=mean(res$maserr))
          res_df <- rbind(res_df, res_row)
          
  
  
      write.csv(res_df, paste0("cv_res_locallineartrend_",j-1,"_",names(data_combined)[1] ,".csv"),
            row.names=FALSE) # write the results of accuracy measures
      
      minres_df=res_df[res_df$mean_mase <= min(res_df$mean_mase)*1.025 &
                +           res_df$mean_mase >= min(res_df$mean_mase)*0.975,]
      
      write.csv(minres_df, paste0("min_cv_res_locallineartrend_",j-1,"_",names(data_combined)[1] ,".csv"),
                row.names=FALSE) # min values of accuracy measures
                      }
                  }
            
    
