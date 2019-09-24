library('fpp2') #required to generate the acf, pacf and checkresiduals

#the next lines add the delta of lag 50 to the dataset, which was done this way so I could quickly change the lag and assess any possible changes or sensitivities:
#if the change30 is set to 15, it is the best performance
fore.month.delta.60$all.change.30<- replicate(10756, 0)
fore.month.delta.60$all.change.30[100:10756]<- fore.month.delta.test$obs[100:n]-fore.month.delta.test$obs[1:(n-99)]

fore.month.delta.60$all.change.50<- replicate(10756, 0)
fore.month.delta.60$all.change.50[50:10756]<- fore.month.delta.test$obs[50:n]-fore.month.delta.test$obs[1:(n-49)]

#### First model: monthly, season = 12. 
syn.month = prcp_synthetic_forecast_delta_test(1,obs.month.delta.60,fore.month.delta.60)

ggplot(data=fore.month.delta.60) +
  ggtitle("Residuals vs. Observed inflow 3-day lag") +
  geom_point(shape=3,mapping = aes(x=exp(obs), y=residual), show.legend = TRUE)+
  geom_point(data=syn.month, colour='red', shape=1, mapping = aes(x=exp(obs), y=res), show.legend = TRUE)


acf(syn.month$res[syn.month$season==5&6&7&8&9], lag.max = 30,plot=TRUE)
acf(syn.month$res[syn.month$season==1&2&3&4&10&11&12], lag.max = 30,plot=TRUE)


acf(fore.month.delta.60$residual[fore.month.delta.60$season==5&6&7&8&9], lag.max = 30,plot=TRUE)
acf(fore.month.delta.60$residual[fore.month.delta.60$season==1&2&3&4&10&11&12], lag.max = 30,plot=TRUE)



checkresiduals(syn.month$res[23742:(23742+10755)])

#### Second model: summer/winter seasons. If the lag is changed from 30 to 100 days, the memory is greatly improved.
par(mfrow=c(1,1))

fore.season.60$all.change.30<- replicate(10756, 0)
fore.season.60$all.change.30[100:10756]<- fore.month.delta.test$obs[100:n]-fore.month.delta.test$obs[1:(n-99)]

fore.season.60$all.change.50<- replicate(10756, 0)
fore.season.60$all.change.50[50:10756]<- fore.month.delta.test$obs[50:n]-fore.month.delta.test$obs[1:(n-49)]

syn.seasonal = prcp_synthetic_forecast_delta_test(1,obs.season.60,fore.season.60)

ggplot(data=fore.month.delta.60) +
  ggtitle("Residuals vs. Observed inflow 3-day lag") +
  geom_point(shape=3,mapping = aes(x=exp(obs), y=residual), show.legend = TRUE)+
  geom_point(data=syn.seasonal, colour='red', shape=1, mapping = aes(x=exp(obs), y=res), show.legend = TRUE)


idx = c( which(syn.seasonal$season==0),  23742:(23742+10755))
idx2 = c( which(syn.seasonal$season==1),  23742:(23742+10755))
acf(syn.seasonal$res[syn.seasonal$season==0], lag.max = 30,plot=TRUE, main='ACF for summer')
acf(syn.seasonal$res[syn.seasonal$season==1], lag.max = 30,plot=TRUE,  main='ACF for winter')

acf(syn.seasonal$res[idx], lag.max = 30,plot=TRUE, main='ACF for summer')
acf(syn.seasonal$res[idx2], lag.max = 30,plot=TRUE,  main='ACF for winter')

checkresiduals(syn.month$res[23742:(23742+10755)])
