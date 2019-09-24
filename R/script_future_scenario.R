#Repeat original's code for the new data including the 100 years of forecast, can use the thirty traces.
#
#don't forget to source synthetic_forecast(1)! (updated version)
#RUN TRACES


setwd("C:/Users/henri/Documents/Henrique/1 - POLIMI/s4/thesis/data/R")
library("fpp2")

#load in observed and forecasted flows
obs_fore_data <- read.csv("test_inflow_future_82.csv",header=T)
obs_fore_data$Date <- as.Date(obs_fore_data$Date)
obs_fore_data$Month <- as.numeric(format(obs_fore_data$Date,"%m"))
#define seasons
obs_fore_data$Season <- obs_fore_data$Month

#test
#obs_fore_data <- obs_fore_data[obs_fore_data$Fore != 0]

obs_fore_data$Season[obs_fore_data$Month%in%c(1,2,3)] <- 0
obs_fore_data$Season[obs_fore_data$Month%in%c(4,5,6)] <- 1
obs_fore_data$Season[obs_fore_data$Month%in%c(7,8,9)] <- 2
obs_fore_data$Season[obs_fore_data$Month%in%c(10,11,12)] <- 3


#adjust zero flows to 0.0001 for log transform ------ this affects the histogram, with a small "hill" on the right or left
obs_fore_data$Obs[obs_fore_data$Obs==0] <- 0.0001
obs_fore_data$Fore[obs_fore_data$Fore==0] <- 0.0001
obs_fore_data$Fore2[obs_fore_data$Fore2==0] <- 0.0001
#to create the conditions for the others
for (i in 2:30){
  print(paste0("obs_fore_data$Fore",i, collapse = "", "[obs_fore_data$Fore",i, "==0] <- 0.0001")) 
}
obs_fore_data$Fore3[obs_fore_data$Fore3==0] <- 0.0001
obs_fore_data$Fore4[obs_fore_data$Fore4==0] <- 0.0001
obs_fore_data$Fore5[obs_fore_data$Fore5==0] <- 0.0001
obs_fore_data$Fore6[obs_fore_data$Fore6==0] <- 0.0001
obs_fore_data$Fore7[obs_fore_data$Fore7==0] <- 0.0001
obs_fore_data$Fore8[obs_fore_data$Fore8==0] <- 0.0001
obs_fore_data$Fore9[obs_fore_data$Fore9==0] <- 0.0001
obs_fore_data$Fore10[obs_fore_data$Fore10==0] <- 0.0001
obs_fore_data$Fore11[obs_fore_data$Fore11==0] <- 0.0001
obs_fore_data$Fore12[obs_fore_data$Fore12==0] <- 0.0001
obs_fore_data$Fore13[obs_fore_data$Fore13==0] <- 0.0001
obs_fore_data$Fore14[obs_fore_data$Fore14==0] <- 0.0001
obs_fore_data$Fore15[obs_fore_data$Fore15==0] <- 0.0001
obs_fore_data$Fore16[obs_fore_data$Fore16==0] <- 0.0001
obs_fore_data$Fore17[obs_fore_data$Fore17==0] <- 0.0001
obs_fore_data$Fore18[obs_fore_data$Fore18==0] <- 0.0001
obs_fore_data$Fore19[obs_fore_data$Fore19==0] <- 0.0001
obs_fore_data$Fore20[obs_fore_data$Fore20==0] <- 0.0001
obs_fore_data$Fore21[obs_fore_data$Fore21==0] <- 0.0001
obs_fore_data$Fore22[obs_fore_data$Fore22==0] <- 0.0001
obs_fore_data$Fore23[obs_fore_data$Fore23==0] <- 0.0001
obs_fore_data$Fore24[obs_fore_data$Fore24==0] <- 0.0001
obs_fore_data$Fore25[obs_fore_data$Fore25==0] <- 0.0001
obs_fore_data$Fore26[obs_fore_data$Fore26==0] <- 0.0001
obs_fore_data$Fore27[obs_fore_data$Fore27==0] <- 0.0001
obs_fore_data$Fore28[obs_fore_data$Fore28==0] <- 0.0001
obs_fore_data$Fore29[obs_fore_data$Fore29==0] <- 0.0001
obs_fore_data$Fore30[obs_fore_data$Fore30==0] <- 0.0001

#subset the reforecast period (post 1980)
obs_fore_data.subset <- subset(obs_fore_data,obs_fore_data$Date>=as.Date("1980-01-01")  & obs_fore_data$Date<=as.Date("2015-12-29")  )
obs_fore_data.subset$resid <- log(obs_fore_data.subset$Fore) - log(obs_fore_data.subset$Obs_av)

#define inputs to synthetic forecast function
obs.period.data <- data.frame('date'=obs_fore_data$Date,'season'=obs_fore_data$Season,'obs'=obs_fore_data$Obs)
fore.period.data <- data.frame('season'=obs_fore_data.subset$Season,'obs'=obs_fore_data.subset$Obs,'residual'=obs_fore_data.subset$resid)


#################Develop synthetic forecasts####################################################################################################
syn.fore.data <- prcp_synthetic_forecast(1,obs.period.data,fore.period.data)
#subset the synthetic forecasts to only the pre 1980 period (since no reforecast data was available from this period)
syn.fore.data.subset <- syn.fore.data[36889:73413, c(1:5)]
syn.fore.data.subset[1:36525, c(1)] <- seq(as.Date("2000/01/01"), by = "day", length.out = 36525)
#syn.fore.data.subset <- subset(syn.fore.data,syn.fore.data$date<=as.Date("2015-01-01"))
# Attention to the typeo of subset used (histogram better use 20th century, others 21th)

# ONLY UNCOMENT WHEN READY TO EXPORT !!!!!!!!!!!!!!!!!!!!!!!!!!!
######################## export to CSV FILE - #############################################################################################
#generate a new datafile where the initial date is 01/01/2000 for the cell 36889, remember to save file according to scenario used (82, )
#forecast_future2 <- syn.fore.data[36889:73413, c(1,3:33)]
#forecast_future2[1:36525, c(1)] <- seq(as.Date("2000/01/01"), by = "day", length.out = 36525)
#write.csv(forecast_future2,'forecast_future_scen82.csv', row.names=F)
########################################################################################################################################



#plot diagnostics of synthetic forecasts for the pre-1980 period against available reforecasts from the post 1980 period 

#Time series inflows ######################################## This image shows how bigger synthetic forecast is wrt both obs and forecast inflows

ggplot(data=syn.fore.data.subset) +
  geom_line(mapping = aes(x=(date), y=fore), colour = 'red', show.legend = TRUE) +
  scale_x_date(limits = as.Date(c('2000-01-01','2015-12-12')))+
  ylim(0,300)+
  geom_line(data=obs_fore_data.subset, colour='black', mapping = aes(x=Date, y=Fore), show.legend = TRUE)+
  geom_line(data=obs_fore_data.subset, colour='blue', mapping = aes(x=Date, y=Obs), show.legend = TRUE)+
  theme(legend.position = "top")+
  scale_fill_discrete(name = "tile", labels=c("A","B"))+
  ggtitle("Observed and forecasted inflows")+
  ylab("Inflow (TAF/day")+
  xlab("Year")

# times series residuals -> synthetic much more frequent
ggplot(data=syn.fore.data.subset) +
  geom_line(mapping = aes(x=(date), y=resid), colour = 'red', show.legend = TRUE) +
  scale_x_date(limits = as.Date(c('2000-01-01','2015-12-12')))+
  #ylim(0,2.5)+
  geom_line(data=obs_fore_data.subset, colour='black', mapping = aes(x=Date, y=resid), show.legend = TRUE)+
  theme(legend.position = "top")+
  scale_fill_discrete(name = "tile", labels=c("A","B"))+
  ggtitle("Observed and forecasted inflows")+
  ylab("Inflow (TAF/day")+
  xlab("Year")

####################### Scatterplot - distribution of errors
#observations vs forecasts
ggplot(data=syn.fore.data.subset) +
  geom_point(mapping = aes(x=obs, y=fore, colour = 'Synthetic data',shape='y'), show.legend = TRUE,size=2) +
  geom_point(data=obs_fore_data.subset, mapping = aes(x=Obs, y=Fore, colour = 'Historical data', shape='x'), size=2,  show.legend = TRUE)+
  theme(legend.position = c(0.05,0.95), legend.justification = c("left", "top"))+
  ggtitle("Observed and forecasted inflows")+
  ylab("Forecasted inflows (TAF/day)")+
  xlab("Obseved inflows (TAF/day)")+
  scale_colour_manual(name = "Legend", values=c('black', 'red'))+
  scale_shape_manual(name = "Legend", labels = c('Historical data','Synthetic data'), values=c(17, 19))

  
#observations vs residuals
ggplot(data=syn.fore.data.subset) +
  geom_point(mapping = aes(x=(obs), y=resid, colour = 'Synthetic data', shape='y'), show.legend = TRUE, size=2) +
  geom_point(data=obs_fore_data.subset, mapping = aes(x=Obs, y=resid, colour='Historical data', shape='x'), size=2, show.legend = TRUE)+
  theme(legend.position = c(0.75,0.35), legend.justification = c("left", "top"))+
  ggtitle("Observed and residual inflows")+
  ylab("Residual inflows (TAF/day)")+
  xlab("Observed inflows (TAF/day)")+
  scale_colour_manual(name = "Legend", labels = c('Historical data','Synthetic data'), values=c("black", "red"))+
  scale_shape_manual(name = "Legend", labels = c('Historical data','Synthetic data'), values=c(17, 19))


#grid.arrange(fig.obs_fore, fig.obs_res, ncol=2)
################################################### Histogram

ggplot(data=syn.fore.data.subset) +
  geom_histogram(bins=140, mapping = aes(x=resid, fill = 'Synthetic data'),show.legend = TRUE)+
  geom_histogram(bins=140,data=obs_fore_data.subset, mapping = aes(x=resid,fill='Historical data'), show.legend = TRUE)+
  theme(legend.position = c(0.05,0.95), legend.justification = c("left", "top"))+
  ggtitle("Distribution of residuals and their frequencies")+
  ylab("Count")+
  xlab("Inflow (TAF/day)")+
  scale_fill_manual(name = "Legend", labels = c('Historical data','Synthetic data'), values=c("black", "red"))
  


hist(obs_fore_data.subset$resid, main="Historical")
mtext("Residual value (TAF/day)",side=1,line=1.5)
mtext("Count",side=2,line=1.5)

hist(syn.fore.data.subset$resid, main="Synthetic")
mtext("Residual value (TAF/day)",side=1,line=1.5)
mtext("Count",side=2,line=1.5)

###################################### AUtocorrelation 

layout(matrix(c(1,2,3,4),byrow=T,ncol=2))
par(mar=c(2.5,2.5,1,1),mgp=c(3,.4,0))
my.pch <- 3
my.col <- 'red'
acf(obs_fore_data.subset$resid[obs_fore_data.subset$Season==0&3],lag.max = 40)
title("Historic Winter")
acf(syn.fore.data.subset$resid[syn.fore.data.subset$season==0&3],lag.max = 40)
title("Synthetic Winter")

acf(obs_fore_data.subset$resid[obs_fore_data.subset$Season==1&2],lag.max = 40)
title("Historic Summer")
acf(syn.fore.data.subset$resid[syn.fore.data.subset$season==1&2],lag.max = 40)
title("Synthetic Summer")
