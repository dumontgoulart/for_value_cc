

#################################################################
KNN <- function(cur.obs,all.obs,all.residuals,kk) {
  #cur.obs:       the current observation for which to develop a synthtic forecast
  #all.obs:       a vector of observations for which forecast residuals are available
  #all.residuals: the forecast residuals associated with all.obs
  #kk:            the number K of nearest neighbors to sample from
  
  distance <- sqrt((all.obs-cur.obs)^2)                     #distance between current observation and all observations that have associated forecast values
  sorted.residuals <- all.residuals[order(distance)[1:kk]]  #store the kk residuals associated with the kk smallest distances
  probs <- (1/(1:kk)) / sum((1/(1:kk)))                     #kernel density for sampling
  selection <- sample(1:kk,size=1,prob=probs,replace=TRUE)  #sample the position of one of the K nearest neigbors
  selected.residual <- sorted.residuals[selection]          #sample the residual
  return(selected.residual)
}
#################################################################



#################################################################
prcp_synthetic_forecast <- function(num.sim,obs.period.data,fore.period.data) {

  #num.sim:             the total number of synthetic traces to develop (e.g., 30)
  #obs.period.data:     observed data for entire record. structured as a 3-column dataframe ('date','season','obs'). 
  #                     dates are in date format (as.Date("1980-01-01")), season is 0 (summer) or 1 (winter), obs is in mm
  #fore.period.data:    observed and forecast residual data for days when we have forecasts and observations. structured as a 3-column dataframe ('season','obs',residual'). 
  #                     season is 0 (summer) or 1 (winter), obs is in mm, residual is in mm
  
  
  n.obs <- dim(obs.period.data)[1]          #length of observed record
  n.reforecast <- dim(fore.period.data)[1]  #length of reforecast record
  kk <- round(sqrt(n.reforecast/2))     #K in KNN algorithm. we divide by 2 since we resample separately by season
  
  simulated.forecasts <- array(NA,c(n.obs,num.sim)) 
  res.calc <- array(NA,c(n.obs,num.sim))
  for (i in 1:num.sim) {    #loop through different synthhetic traces
    for (j in 1:n.obs) {        #loop through each observation for which we will develop a synthetic forecast
      cur.season <- obs.period.data$season[j]
      cur.obs <- obs.period.data$obs[j]
      fore.period.data.cur <- fore.period.data[fore.period.data$season==cur.season,]   #subset reforecast data for the current season
      cur.resid <- KNN(cur.obs,fore.period.data.cur$obs,fore.period.data.cur$residual,kk)   #resample a residual for the current observation
      simulated.forecasts[j,i] <- cur.obs - cur.resid   #add the residual to the current observation to develop a synthetic forecast
      res.calc[j] <- cur.obs - simulated.forecasts[j,i]
    }
  }
  
  final.synthetic.forecasts <- data.frame('date'=obs.period.data$date,'obs'=obs.period.data$obs,simulated.forecasts,'res'= res.calc)
  
  return(final.synthetic.forecasts)

}
