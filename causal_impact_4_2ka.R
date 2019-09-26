causal_impact_4_2ka <- function(data_fortest,
                         data_fortraining,
                         age,
                         pre_period,
                         post_period,
                         iterations,
                         prior_sd,
                         number_of_seasons,
                         season,
                         DR) {
  data_impact=cbind(data_fortest,data_fortraining)
  data_ts <- zoo(data_impact, age)
  causal_impact_4_2ka <- CausalImpact(data_ts, age[pre_period], age[post_period],model.args = list(niter=iterations,prior.level.sd=prior_sd,nseasons=number_of_seasons,season.duration=season,dynamic.regression=DR))
  
}
