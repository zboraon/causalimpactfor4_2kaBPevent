loop_4_2ka_BP <- function(data_combined,                         
                         prior_sd,
                         age,
                         horizon,
                         number_of_folds,do.plot=FALSE) {
  rmse_v <- c()
  mae_v <- c()
  mase_v <- c()
  for (fold in 1:number_of_folds) {
    # construct data_train/data_test
    l <- which(age == -4400) - (fold-1)*horizon
    
    preinterval<-c(1,(l-horizon))
	  postinterval<-c((l-horizon+1),l)
    data_test<-data_combined[1:l, ]
    

    # fit model & predict
    model <- CausalImpact(data_test,preinterval,postinterval,
                  model.args = list(niter=20000, prior.level.sd=prior_sd))

    if (do.plot) { print(plot(model, "original"))}

   
	predicted_vect <- unclass(model$series$point.pred[(l-horizon+1):l])
	response_post_vect <- unclass(model$series$response[(l-horizon+1):l])
	
	# find the forecast accuracy measures
    rmserr <- rmse(response_post_vect,predicted_vect)
    rmse_v <- c(rmse_v, rmserr)
    maerr <- mae(response_post_vect,predicted_vect)
    mae_v <- c(mae_v, maerr)
    maserr <- mase(response_post_vect,predicted_vect)
    mase_v <- c(mase_v, maserr)

   
  }
  return(data.frame(rmserr=rmse_v,maerr=mae_v, maserr=mase_v))
}
