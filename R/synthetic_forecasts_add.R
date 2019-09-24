#################################################################
KNN1.new <- function(cur.obs,all.obs,all.residuals,yest.obs, two.yest.obs, three.yest.obs, yest.all.obs,two.yest.all.obs, three.yest.all.obs, kk) {
  
  dist1 <-(1*((all.obs-cur.obs))) ^2
  dist2 <-(1*((yest.all.obs-yest.obs))) ^2
  dist3 <-(0*((two.yest.all.obs-two.yest.obs))) ^2
  dist4 <-(0*((three.yest.all.obs-three.yest.obs))) ^2
  #dist5 <-(1*((all.change.obs-cur.change.obs))) ^2
  
  
  distance <- sqrt( dist1 + dist2 +dist3 + dist4) 
  
  sorted.residuals <- all.residuals[order(distance)[1:kk]]  #store the kk residuals associated with the kk smallest distances
  probs <- (1/(1:kk)) / sum((1/(1:kk)))                     #kernel density for sampling
  selection <- sample(1:kk,size=1,prob=probs,replace=TRUE)  #sample the position of one of the K nearest neigbors
  selected.residual <- sorted.residuals[selection]          #sample the residual
  return(selected.residual)
}
#################################################################

#################################################################
prcp_synthetic_forecast_dif_lag1.new <- function(num.sim,obs.period.data,fore.period.data) {
  
  #num.sim:             the total number of synthetic traces to develop (e.g., 30)
  #obs.period.data:     observed data for entire record. structured as a 3-column dataframe ('date','season','obs'). 
  #                     dates are in date format (as.Date("1980-01-01")), season is 0 (summer) or 1 (winter), obs is in mm
  #fore.period.data:    observed and forecast residual data for days when we have forecasts and observations. structured as a 3-column dataframe ('season','obs',residual'). 
  #                     season is 0 (summer) or 1 (winter), obs is in mm, residual is in mm
  #+ yest.residual    
  
  n.obs <- dim(obs.period.data)[1]          #length of observed record
  n.reforecast <- dim(fore.period.data)[1]  #length of reforecast record
  kk <- round(sqrt(n.reforecast/12))     #K in KNN algorithm. we divide by 2 since we resample separately by season
  
  simulated.forecasts <- array(NA,c(n.obs,num.sim))  
  res.calc <- array(NA,c(n.obs,num.sim))
  
  
  for (i in 1:num.sim) {    #loop through different synthhetic traces
    for (j in 1:n.obs) {        #loop through each observation for which we will develop a synthetic forecast
      cur.season <- obs.period.data$season[j]
      cur.obs <- obs.period.data$obs[j]
      yest.obs <- obs.period.data$yest.obs[j]
      two.yest.obs <- obs.period.data$two.yest.obs[j]
      three.yest.obs <- obs.period.data$three.yest.obs[j]
      
      fore.period.data.cur <- fore.period.data[fore.period.data$season==cur.season,]   #subset reforecast data for the current season
      
      #if (cur.season==1){
      #  fore.period.data.cur <- fore.period.data[fore.period.data$season==12,]
      #} else {
      #  fore.period.data.cur <- fore.period.data[fore.period.data$season==(cur.season-1),]   #subset reforecast data for the current season
      #}
      
      cur.resid <- KNN1.new (cur.obs,fore.period.data.cur$obs,fore.period.data.cur$residual,yest.obs,two.yest.obs,three.yest.obs,fore.period.data.cur$yest.all.obs,fore.period.data.cur$two.yest.all.obs,fore.period.data.cur$three.yest.all.obs, kk)   #resample a residual for the current observation
      simulated.forecasts[j,i] <- cur.obs - cur.resid    #add the residual to the current observation to develop a synthetic forecast
      res.calc[j] <- cur.obs - simulated.forecasts[j,i]
      
    }
  }
  
  final.synthetic.forecasts <- data.frame('date'=obs.period.data$date, 'season'=obs.period.data$season,'obs'=obs.period.data$obs,simulated.forecasts, 'res'= res.calc)
  
  
  
  return(final.synthetic.forecasts)
  
}
