#################################################################
KNN1.new <- function(change.in.flow.4, change.in.flow.7, cur.obs,all.obs,all.residuals,yest.obs, two.yest.obs, cur.change.obs, yest.all.obs,two.yest.all.obs, all.change.obs, kk) {

  #dist1 <-(0*((all.obs-cur.obs)/sd(all.obs))) ^2
  dist2 <-(0*((yest.all.obs-yest.obs)/sd(yest.all.obs))) ^2
  dist3 <-(0*((two.yest.all.obs-two.yest.obs)/sd(two.yest.all.obs))) ^2
  dist4 <-(1*((all.change.obs-cur.change.obs)/sd(all.change.obs))) ^2
  dist5 <-(0*((all.change.obs-change.in.flow.4)/sd(all.obs))) ^2
  dist6 <-(0*((all.change.obs-change.in.flow.7)/sd(all.change.obs))) ^2
  
  
  distance <- sqrt( dist2 +dist3 + dist4 + dist5 + dist6) 
  
  sorted.residuals <- all.residuals[order(distance)[1:kk]]  #store the kk residuals associated with the kk smallest distances
  probs <- (1/(1:kk)) / sum((1/(1:kk)))                     #kernel density for sampling
  selection <- sample(1:kk,size=1,prob=probs,replace=TRUE)  #sample the position of one of the K nearest neigbors
  selected.residual <- sorted.residuals[selection]          #sample the residual
  return(selected.residual)
}
#################################################################

#################################################################
prcp_synthetic_forecast_delta <- function(num.sim,obs.period.data,fore.period.data) {
  
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
      cur.change.obs <- obs.period.data$cur.change.obs[j]
      
      fore.period.data.cur <- fore.period.data[fore.period.data$season==cur.season,]   #subset reforecast data for the current season
      #if (cur.season==1){
      #  fore.period.data.cur <- fore.period.data[fore.period.data$season==12,]
      #} else {
      #  fore.period.data.cur <- fore.period.data[fore.period.data$season==(cur.season-1),]   #subset reforecast data for the current season
      #}
      
      if (j<=4){
        change.in.flow.4 <- cur.change.obs
      } else {
        change.in.flow.4 <- cur.obs - obs.period.data$obs[(j-4)]
      }
      
      if (j<=40){
        change.in.flow.7 <- cur.change.obs
      } else {
        change.in.flow.7 <- cur.obs - obs.period.data$obs[(j-40)]
      }
      
      cur.resid <- KNN1.new (change.in.flow.4, change.in.flow.7, cur.obs,fore.period.data.cur$obs,fore.period.data.cur$residual,yest.obs,two.yest.obs,cur.change.obs,fore.period.data.cur$yest.all.obs,fore.period.data.cur$two.yest.all.obs,fore.period.data.cur$all.change.obs, kk)   #resample a residual for the current observation
      simulated.forecasts[j,i] <- cur.obs - cur.resid    #add the residual to the current observation to develop a synthetic forecast
      res.calc[j] <- cur.obs - simulated.forecasts[j,i]
      
    }
  }
  
  final.synthetic.forecasts <- data.frame('date'=obs.period.data$date, 'season'=obs.period.data$season,'obs'=obs.period.data$obs, simulated.forecasts, 'res'= res.calc)
  
  
  
  return(final.synthetic.forecasts)
  
}
