#################################################################################################################################################
#1) Done. Used excel for defining residuals and imported here as log_dif, log_ratio, norm_diff and residual+ratio
#2) Done
#3) Done
#4) done (plot e against forecasted flows, look for a "fanning" pattern), but there are other ways of measuring this, like standardized residuals against the predicted as I did this in excel, but can probaly do it here

library('fpp2')

# Distribution



ggplot(data=obsandforecast[my_range,], aes(x=(my_range), y=Q)) +
  geom_point(aes(y=Q, color = "black")) +
  geom_line(data = log_dif[my_range,], mapping =aes(x=my_range, y=residual), color = "black") +
  ggtitle("Observed and forecasted inflow") +
  scale_y_continuous(sec.axis =  sec_axis(~.*500)) +
  theme(
    # Change legend background color
    legend.background = element_rect(fill = "white"),
    legend.key = element_rect(fill = "lightblue", color = NA),
    # Change legend key size and key width
    legend.key.size = unit(1.5, "cm"),
    legend.key.width = unit(0.5,"cm") 
  )

ggplot(data=obsandforecast) +
  geom_point(mapping = aes(x=1:10756, y=logq), color = "blue") +
  geom_line(mapping =aes(x=1:10756, y=logforecast), color = "red")


#delta distance

full_range <- 1:20000
n=10756
change.in.flow <- obsandforecast$Q[2:n]-obsandforecast$Q[1:(n-1)]
change.in.flow.2 <- obsandforecast$Q[4:n]-obsandforecast$Q[1:(n-3)]
change.in.flow.3 <- obsandforecast$Q[7:n]-obsandforecast$Q[1:(n-6)]
change.in.flow.4 <- obsandforecast$Q[30:n]-obsandforecast$Q[1:(n-29)]
change.in.flow.5 <- fore.month.delta.test$obs[50:n]-fore.month.delta.test$obs[1:(n-49)]


plot(change.in.flow,log_dif$res[2:n])
plot(change.in.flow.2,log_dif$res[4:n])
plot(change.in.flow.3,log_dif$res[7:n])
plot(change.in.flow.4,log_dif$res[40:n])

acf(change.in.flow)
acf(change.in.flow.2)
acf(change.in.flow.3)
acf(change.in.flow.4)
acf(change.in.flow.5)

my_range=1:365

plot(full_range[my_range],obsandforecast$Q[my_range], type="l",ylim=c(0,200))
lines(full_range[my_range],obsandforecast$forecast[my_range], col="blue", type="l")
par(new=TRUE)
plot(full_range[my_range],norm_dif$residual[my_range], col="red", type="l", yaxt="n", xaxt="n", ylab = "",ylim=c(-120,50) )
axis(4)

plot(full_range[my_range],obsandforecast$logq[my_range], type="l",ylim=c(-5,7.5))
lines(full_range[my_range],obsandforecast$logforecast[my_range], col="blue", type="l")
par(new=TRUE)
lines(full_range[my_range],log_dif$residual[my_range], col="red", type="l",yaxt="n", xaxt="n",  ylab = "", ylim=c(-10,4) )
axis(4)


# Observed against predicted##########################################################

ggplot(data=obsandforecast) +
  geom_point(mapping = aes(x=Q, y=forecast)) +
  geom_smooth(mapping =aes(x=Q, y=forecast))+
  ggtitle("Observed and forecasted inflow") +
  geom_abline(intercept = 0, slope = 1, color = "red",size = 1)+
  # Change x and y axis labels, and limits
  scale_x_continuous(name="Observed inflow") +
  scale_y_continuous(name="Forecasted inflow")+
  theme(legend.position = 1)


#log
ggplot(data=obsandforecast) +
  geom_point(mapping = aes(x=logq, y=logforecast)) +
  geom_smooth(mapping =aes(x=logq, y=logforecast))


par(mfrow=c(1,1))

#plotting the residuals

par(mfrow=c(2,2))
plot.norm.dif=plot(norm_dif$residual)
plot.norm.rat=plot(residual_ratio$residual)
plot.log.dif=plot(log_dif$residual)
plot.log.rat=plot(log_ratio$residual)


ggplot(data=log_dif, aes(x=1:10756, y=residual))+
  #geom_point( color="darkblue")+
  geom_line()+
  ggtitle("Residuals along time") +
  # Change x and y axis labels, and limits
  scale_x_continuous(name="Time (days)") +
  scale_y_continuous(name="Residuals")+
  theme(legend.position = 1)

#log_diff shows the most varying residual profile


#Histogram

par(mfrow=c(2,2))


hist(norm_dif$residual) 
hist(residual_ratio$residual) + ggtitle("Histogram of residuals")
hist(log_dif$residual) + ggtitle("Histogram of residuals")
hist(log_ratio$residual) + ggtitle("Histogram of residuals")

gghistogram(norm_dif$residual) + ggtitle("Histogram of residuals")
gghistogram(residual_ratio$residual) + ggtitle("Histogram of residuals")
gghistogram(log_dif$residual) + ggtitle("Histogram of residuals")
gghistogram(log_ratio$residual) + ggtitle("Histogram of residuals")
+ facet_wrap(~ fl)

gghistogram((log_dif$obs)-(log_dif$residual+log_dif$obs)) + ggtitle("Histogram of residuals")

grid.arrange(plot1, plot2, ncol=2)

#log_diff shows the biggest similarity to a bell curve


#QQ Plot

par(mfrow=c(2,2))
qqnorm(norm_dif$residual)
qqline(norm_dif$residual)
qqnorm(residual_ratio$residual)
qqline(residual_ratio$residual)
qqnorm(log_dif$residual)
qqline(log_dif$residual)
qqnorm(log_ratio$residual)
qqline(log_ratio$residual)


#The inclination of them is almost flat (expection for log_diff)



#Autocorrelation aand partial autocorrelation#############################
par(mfrow=c(2,2))
acf.norm.dif=acf(norm_dif$residual, plot=TRUE)
acf.norm.r=acf(residual_ratio$residual, plot=TRUE)
acf.log.dif=acf(log_dif$residual, plot=TRUE)
acf.log.r=acf(log_ratio$residual, plot=TRUE)

#diffs show bigger memory (esecially log_diff)


par(mfrow=c(2,2))
pacf.norm.dif=pacf(norm_dif$residual, plot=TRUE)
pacf.norm.r=pacf(residual_ratio$residual, plot=TRUE)
pacf.log.dif=pacf(log_dif$residual, plot=TRUE)
pacf.log.r=acf(log_ratio$residual, plot=TRUE)
#diffs show bigger memory (esecially log_diff)


#Heteroskedasticity 1 ##########################################################
#Residueals against predicted value (saw many ways of calculating it, but followed the email instructions)
par(mfrow=c(2,2))
plot(obsandforecast$forecast, norm_dif$residual)
plot(obsandforecast$forecast, residual_ratio$residual)
plot(obsandforecast$forecast, log_dif$residual)
plot(obsandforecast$forecast, log_ratio$residual)

#addtive cases show increasing variance while ratios a constant one


#Heteroskedasticity 2 ##########################################################
#based on what i found on the web, i used standardized residuals but the results were equal
#Check residuals, a function that summarizes what I have done so far and supports the conclusions

checkresiduals(norm_dif$residual) 
checkresiduals(residual_ratio$residual) 
checkresiduals(log_dif$residual) 
checkresiduals(log_ratio$residual) 
checkresiduals(syn.fore.data.subset$resid.1[(1+365*50):(10000+365*50)])

#################################################################################################################################################

#chosen type of residual: log + additive


syn.add.log= prcp_synthetic_forecast(1,obs_log,log_dif)

syn.add.log2= prcp_synthetic_forecast_dif_lag(1,obs.period.data,log.dif.yest.two)
syn.add.log3= prcp_synthetic_forecast_dif_lag3(1,obs.period.data,log.dif.yest.three)

#for the additive log########################################################################################

theme_set(theme_bw())

ggplot(data=log_dif) +
  ggtitle("Residuals vs. Observed inflow 3-day lag") +
  geom_point(shape=3,mapping = aes(x=exp(obs), y=residual), show.legend = TRUE)+
  geom_point(data=syn.add.log3, colour='red', shape=1, mapping = aes(x=obs, y=res), show.legend = TRUE)
acf(syn.add.log3$res, plot=TRUE)
pacf(syn.add.log3$res, plot=TRUE)

#### Newest version

syn.add.log.ma = prcp_synthetic_forecast_dif_lag3.ma(1,obs.period.data.yest,log.dif.yest.three.ma)

ggplot(data=log_dif) +
  ggtitle("Residuals vs. Observed inflow 3-day lag") +
  geom_point(shape=3,mapping = aes(x=exp(obs), y=residual), show.legend = TRUE)+
  geom_point(data=syn.add.log.ma, colour='red', shape=1, mapping = aes(x=exp(obs), y=res), show.legend = TRUE)
acf(syn.add.log.ma$res, plot=TRUE)
#pacf(syn.add.log.ma$res, plot=TRUE)

ggplot(data=syn.add.log.ma) +
  geom_point(mapping = aes(x=1:36888, y=res), color = "blue")

acf(syn.add.log.ma$res[syn.add.log.ma$season==1], plot=TRUE)
acf(syn.add.log.ma$res[syn.add.log.ma$season==0], plot=TRUE)
checkresiduals(syn.add.log.ma$res)

# one day lag obs

syn.add.log1= prcp_synthetic_forecast_dif_lag1.new(1,obs.period.data.yest,fore.period.data.yest.new)

ggplot(data=syn.add.log1) +
  geom_point(mapping = aes(x=1:36888, y=res), color = "blue")

ggplot(data=log_dif) +
  ggtitle("Residuals vs. Observed inflow 3-day lag") +
  geom_point(shape=3,mapping = aes(x=exp(obs), y=residual), show.legend = TRUE)+
  geom_point(data=syn.add.log1, colour='red', shape=1, mapping = aes(x=exp(obs), y=res), show.legend = TRUE)

acf(syn.add.log1$res[syn.add.log.ma$season==1], plot=TRUE)
acf(syn.add.log1$res[syn.add.log.ma$season==0], plot=TRUE)
checkresiduals(syn.add.log.ma$res)


##### Season = month ###### new



fore.month.delta.60$all.change.80<- replicate(10756, 0)
fore.month.delta.60$all.change.80[50:10756]<- fore.month.delta.test$obs[50:n]-fore.month.delta.test$obs[1:(n-49)]
#####################
acf(fore.month.delta.60$residual[fore.month.delta.60$season==5&6&7&8&9], lag.max = 30,plot=TRUE)
acf(fore.month.delta.60$residual[fore.month.delta.60$season==1&2&3&4&10&11&12], lag.max = 30,plot=TRUE)


syn.month= prcp_synthetic_forecast_delta(1,obs.month.delta2,fore.month.delta2)

syn.seasonal= prcp_synthetic_forecast_delta_test(1,obs.month.delta_test,fore.month.delta.test)

#syn.month= prcp_synthetic_forecast_delta_test(1,obs.month.delta.test.30,fore.month.delta.test.30)

ggplot(data=log_dif) +
  ggtitle("Residuals vs. Observed inflow 3-day lag") +
  geom_point(shape=3,mapping = aes(x=exp(obs), y=residual), show.legend = TRUE)+
  geom_point(data=syn.month, colour='red', shape=1, mapping = aes(x=exp(obs), y=res), show.legend = TRUE)

acf(syn.month$res,lag.max = 30, plot=TRUE)
pacf(syn.month$res, plot=TRUE)
checkresiduals(syn.month$res[23742:(23742+10755)])
checkresiduals(syn.month$res[12000:(12000+10755)])

acf(syn.month$res[syn.month$season==5&6&7&8&9], lag.max = 30,plot=TRUE)
acf(syn.month$res[syn.month$season==1&2&3&4&10&11&12], lag.max = 30,plot=TRUE)

acf(syn.month$res[syn.month$season==0], lag.max = 30,plot=TRUE, main='ACF for summer')
acf(syn.month$res[syn.month$season==1], lag.max = 30,plot=TRUE,  main='ACF for winter')



acf(log_dif$residual)
acf(log_dif$residual[log_dif$season==0], lag.max = 30, plot=TRUE, main='ACF for summer')
acf(log_dif$residual[log_dif$season==1], lag.max = 30, plot=TRUE, main='ACF for winter')
pacf(log_dif$residual[log_dif$season==0], lag.max = 30, plot=TRUE, main='ACF for summer')
pacf(log_dif$residual[log_dif$season==1], lag.max = 30, plot=TRUE, main='ACF for winter')


#####
#matlab: standard clustering kmin

adf.test(log_dif$residual, alternative = "stationary")
adf.test(syn.add.log3$res, alternative = "stationary")
#original

tsdisplay(log_dif$residual, lag.max=90, main='(0,0,0) Model behaviour')
tsdisplay(syn.month$res, lag.max=90, main='(0,0,0) Model behaviour')

fit = auto.arima(log_dif$residual, seasonal=FALSE)
fit
tsdisplay(residuals(fit), lag.max=45, main='(3,0,2) Model Residuals')
tsdisplay(fitted(fit), lag.max=90, main='(3,0,2) Model behaviour')

fit2 = arima(log_dif$residual, order=c(3,0,0))
tsdisplay(residuals(fit2), lag.max=45, main='(3,0,0) Model Residuals')
tsdisplay(fitted(fit2), lag.max=90, main='(3,0,0) Model behaviour')

fit3 = arima(log_dif$residual, order=c(3,0,3))
tsdisplay(residuals(fit3), lag.max=45, main='(5,0,5) Model Residuals')
tsdisplay(fitted(fit3), lag.max=90, main='(3,0,3) Model behaviour')



fit.syn=arima(syn.add.log3$res, order=c(1,0,1))
fit.syn
tsdisplay(residuals(fit.syn), lag.max=45, main='(1,0,1) Model Residuals')
tsdisplay(fitted(fit.syn), lag.max=90, main='(1,0,1) Model behaviour')

log_dif$res.ma=ma(log_dif$residual, 2)
plot(log_dif$res.ma)

max(syn.add.log2$res)
max(log_dif$residual)

#test
qqnorm(syn.month$res)
qqline(syn.month$res)

plot(obsandforecast$forecast, log_dif$residual)
plot(obsandforecast$forecast, syn.month$res[23742:(23742+10755)])


NSE(obsandforecast$logforecast, obsandforecast$logq)
NSE(syn.month$simulated.forecasts[23742:(23742+10755)],obsandforecast$logforecast)
#not really similar


####proposition: lag 3 and moving average 2
#HOW TO ADD MA TO THE KNN DISTANCE FUNCTION?

#soultion for meomory, k==6 or 7
#what else can be done?


#how to calculate the distance with a one day lag?

#nearest neighbour bootstrap
############################################### GENERATION OF THE SCENARIOS SELECTED FOR THE WHOLE FUTURE - attention 17 huge spikes



setwd("C:/Users/henri/Documents/Henrique/1 - POLIMI/s4/thesis/data/R")
library("fpp2")
library("zoo")

#load in observed and forecasted flows
fut_scen_17 <- read.csv("test_inflow_future_17.csv",header=T)
fut_scen_52 <- read.csv("test_inflow_future_52.csv",header=T)
fut_scen_82 <- read.csv("test_inflow_future_82.csv",header=T)

fut_scen_17$Date <- as.Date(fut_scen_17$Date)
fut_scen_17$Month <- as.numeric(format(fut_scen_17$Date,"%m"))
fut_scen_52$Date <- as.Date(fut_scen_52$Date)
fut_scen_52$Month <- as.numeric(format(fut_scen_52$Date,"%m"))
fut_scen_82$Date <- as.Date(fut_scen_82$Date)
fut_scen_82$Month <- as.numeric(format(fut_scen_82$Date,"%m"))
fut_scen_all <- data.frame("Date" = fut_scen_17$Date, "Obs_17"=fut_scen_17$Obs, "Obs_52"=fut_scen_52$Obs, "Obs_82"=fut_scen_82$Obs)

avg_scenarios <- data.frame("Date" = fut_scen_17$Date) 
avg_scenarios$Obs_17 <- rollmean(fut_scen_17$Obs, k=1, fill=NA)
avg_scenarios$Obs_52 <- rollmean(fut_scen_52$Obs, k=1, fill=NA)
avg_scenarios$Obs_82 <- rollmean(fut_scen_82$Obs, k=1, fill=NA)

ggplot(data=fut_scen_all) +
  geom_line(mapping = aes(x=Date, y=Obs_52, colour = 'Wet (52)'), show.legend = TRUE,size = 1) +
  #geom_smooth(mapping = aes(x=Date, y=Obs_av)) +
  scale_x_date(limits = as.Date(c('2090-01-01','2099-12-12')))+
  geom_line(mapping = aes(x=Date, y=Obs_17, colour = 'Intermediate (17)'), show.legend = TRUE, size = 1) +
  geom_line(mapping = aes(x=Date, y=Obs_82, colour = 'Dry (82)'), show.legend = TRUE,size = 1) +
  scale_colour_manual(name = "Legend", values = c("black", "red", "blue"))+
  ylim(0,300)
  
ggplot(data=avg_scenarios) +
  geom_smooth(mapping = aes(x=Date, y=Obs_52, colour = 'Wet (52)'), show.legend = TRUE,size = 1) +
  #geom_smooth(mapping = aes(x=Date, y=Obs_av)) +
  scale_x_date(limits = as.Date(c('2015-01-01','2099-12-12')))+
  geom_smooth(mapping = aes(x=Date, y=Obs_17, colour = 'Intermediate (17)'), show.legend = TRUE, size = 1) +
  geom_smooth(mapping = aes(x=Date, y=Obs_82, colour = 'Dry (82)'), show.legend = TRUE,size = 1) +
  scale_colour_manual(name = "Legend", values = c("black", "red", "blue"))
  
