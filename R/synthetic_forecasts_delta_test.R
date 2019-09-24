#################################################################
KNN1.new <- function(all.sixty, all.change.30, all.change.50, sixty.obs, cur.change.lag.30, cur.change.lag.50, cur.obs, all.obs, all.residuals, yest.obs, four.yest.obs, seven.yest.obs, cur.change.obs, yest.all.obs, four.yest.all.obs, seven.yest.all.obs, all.change.obs, kk) {
  
  #distances based on lagged observations
  dist1 <-(1*((all.obs-cur.obs)/sd(all.obs))) ^2
  dist2 <-(1*((yest.all.obs-yest.obs)/sd(yest.all.obs))) ^2
  dist3 <-(1*((four.yest.all.obs-four.yest.obs)/sd(four.yest.all.obs))) ^2
  dist4 <-(1*((seven.yest.all.obs-seven.yest.obs)/sd(seven.yest.all.obs))) ^2
  dist5 <-(1*((all.sixty-sixty.obs)/sd(all.sixty))) ^2 
  
  #distances based on the difference between observations (delta).
  #dist6 <-(0*((all.change.obs-cur.change.obs)/sd(all.change.obs))) ^2 # turned off because it didn't improve the acf
  dist7 <-(1*((all.change.30-cur.change.lag.30)/sd(all.change.30))) ^2
  dist8 <-(1*((all.change.50-cur.change.lag.50)/sd(all.change.50))) ^2
  
  distance <- sqrt(dist1+ dist2 + dist3 + dist4 + dist5 + dist7 + dist8) 
  
  sorted.residuals <- all.residuals[order(distance)[1:kk]]  #store the kk residuals associated with the kk smallest distances
  probs <- (1/(1:kk)) / sum((1/(1:kk)))                     #kernel density for sampling
  selection <- sample(1:kk,size=1,prob=probs,replace=TRUE)  #sample the position of one of the K nearest neigbors
  selected.residual <- sorted.residuals[selection]          #sample the residual
  return(selected.residual)
}
#################################################################

#################################################################
prcp_synthetic_forecast_delta_test <- function(num.sim,obs.period.data,fore.period.data) {
  
  n.obs <- dim(obs.period.data)[1]          #length of observed record
  n.reforecast <- dim(fore.period.data)[1]  #length of reforecast record
  kk <- round(sqrt(n.reforecast/12))     #K in KNN algorithm. we divide by 12 since we resample separately by season
  simulated.forecasts <- array(NA,c(n.obs,num.sim))  
  res.calc <- array(NA,c(n.obs,num.sim))
  
  for (i in 1:num.sim) {    #loop through different synthhetic traces
    for (j in 1:n.obs) {        #loop through each observation for which we will develop a synthetic forecast
      cur.season <- obs.period.data$season[j]
      cur.obs <- obs.period.data$obs[j]
      yest.obs <- obs.period.data$yest.obs[j]
      four.yest.obs <- obs.period.data$four.day.obs[j]
      seven.yest.obs <- obs.period.data$seven.day.obs[j]
      cur.change.obs <- obs.period.data$forty.change.obs[j]
      sixty.obs <- obs.period.data$sixty.obs[j]
      fore.period.data.cur <- fore.period.data[fore.period.data$season==cur.season,]   #subset reforecast data for the current season
     #the following functions are to create the change of obs. at a given lead time. So everytime I want to change the lag, I have to change here and in the base_script (lines 5 and 25) 
      if (j<=50){
        cur.change.lag.50 <- cur.change.obs
      } else {
        cur.change.lag.50 <- cur.obs - obs.period.data$obs[(j-50)]
      }
      
      if (j<=100){
        cur.change.lag.30 <- cur.change.obs
      } else {
        cur.change.lag.30 <- cur.obs - obs.period.data$obs[(j-100)]
      }
      
      cur.resid <- KNN1.new (fore.period.data.cur$all.sixty, fore.period.data.cur$all.change.30, fore.period.data.cur$all.change.50, sixty.obs,cur.change.lag.30, cur.change.lag.50, cur.obs, fore.period.data.cur$obs, fore.period.data.cur$residual, yest.obs, four.yest.obs, seven.yest.obs , cur.change.obs, fore.period.data.cur$yest.all.obs, fore.period.data.cur$four.yest.all.obs, fore.period.data.cur$seven.yest.all.obs , fore.period.data.cur$all.forty.change, kk)   #resample a residual for the current observation
      simulated.forecasts[j,i] <- cur.obs - cur.resid    #add the residual to the current observation to develop a synthetic forecast
      res.calc[j] <- cur.obs - simulated.forecasts[j,i]
      
    }
  }
  
  final.synthetic.forecasts <- data.frame('date'=obs.period.data$date, 'season'=obs.period.data$season,'obs'=obs.period.data$obs, simulated.forecasts, 'res'= res.calc)
  
  
  
  return(final.synthetic.forecasts)
  
}
