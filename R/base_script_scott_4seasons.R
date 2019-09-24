
#setwd("C:/Users/ss3378/Box/1_Scotts_Documents/Students_Staff_Collaborators/Henrique_Goulart/current_scripts")
setwd("C:/Users/henri/Documents/Henrique/1 - POLIMI/s4/thesis/data/R")

#source("synthetic_forecasts.R")

#load in observed and forecasted flows
obs_fore_data <- read.csv("obs_fore_data.csv",header=T)
obs_fore_data$Date <- as.Date(obs_fore_data$Date)
obs_fore_data$Month <- as.numeric(format(obs_fore_data$Date,"%m"))
#define seasons
obs_fore_data$Season <- obs_fore_data$Month
obs_fore_data$Season[obs_fore_data$Month%in%c(1,2,3)] <- 0
obs_fore_data$Season[obs_fore_data$Month%in%c(4,5,6)] <- 1
obs_fore_data$Season[obs_fore_data$Month%in%c(7,8,9)] <- 2
obs_fore_data$Season[obs_fore_data$Month%in%c(10,11,12)] <- 3


#adjust zero flows to 0.0001 for log transform
obs_fore_data$Obs[obs_fore_data$Obs==0] <- 0.0001
obs_fore_data$Fore[obs_fore_data$Fore==0] <- 0.0001

#define inputs to synthetic forecast function
obs.period.data <- data.frame('date'=obs_fore_data$Date,'season'=obs_fore_data$Season,'obs'=obs_fore_data$Obs)
obs.period.data$lag.7 <- replicate(36888, 0)
obs.period.data$lag.7[2:36888] <- obs.period.data$obs[1:36887]
obs.period.data$lag.15 <- replicate(36888, 0)
obs.period.data$lag.15[2:36888] <- obs.period.data$obs[2:36888]-obs.period.data$obs[1:36887]

#subset the reforecast period (post 1980)
obs_fore_data.subset <- subset(obs_fore_data,obs_fore_data$Date>=as.Date("1980-01-01"))
obs_fore_data.subset$resid <- log(obs_fore_data.subset$Fore) - log(obs_fore_data.subset$Obs)

fore.period.data <- data.frame('season'=obs_fore_data.subset$Season,'obs'=obs_fore_data.subset$Obs,'residual'=obs_fore_data.subset$resid)
fore.period.data$lag.7.all <- replicate(13147, 0)
fore.period.data$lag.7.all[2:13147] <- fore.period.data$obs[1:13146] 
fore.period.data$lag.15.all <- replicate(13147, 0)
fore.period.data$lag.15.all[2:13147] <- fore.period.data$obs[2:13147] - fore.period.data$obs[1:13146]


#################Develop synthetic forecasts####################
syn.fore.data <- prcp_synthetic_forecast(1,obs.period.data,fore.period.data)
#subset the synthetic forecasts to only the pre 1980 period (since no reforecast data was available from this period)
syn.fore.data.subset <- subset(syn.fore.data,syn.fore.data$date<=as.Date("1980-01-01"))
################################################################

#plot diagnostics of synthetic forecasts for the pre-1980 period against available reforecasts from the post 1980 period 
layout(matrix(c(1,2,3,4,5,6,7,8),byrow=T,ncol=2))
par(mar=c(2.5,2.5,1,1),mgp=c(3,.4,0))
my.pch <- 2
my.col <- 'red'

#observations vs residuals
hist.x <- obs_fore_data.subset$Obs
hist.y <- obs_fore_data.subset$resid
syn.x <- syn.fore.data.subset$obs
syn.y <- syn.fore.data.subset$resid
plot(hist.x,hist.y,xlim=c(min(hist.x,syn.x),max(hist.x,syn.x)),ylim=c(min(hist.y,syn.y),max(hist.y,syn.y)))
points(syn.x,syn.y,col=my.col,pch=my.pch)
mtext("obs",side=1,line=1.5)
mtext("resid",side=2,line=1.5)
legend("topright",c("hist","syn"),col=c("black","red"),pch=c(1,my.pch),bty="n")

#observations vs forecasts
hist.x <- obs_fore_data.subset$Obs
hist.y <- obs_fore_data.subset$Fore
syn.x <- syn.fore.data.subset$obs
syn.y <- syn.fore.data.subset$fore
plot(hist.x,hist.y,xlim=c(min(hist.x,syn.x),max(hist.x,syn.x)),ylim=c(min(hist.y,syn.y),max(hist.y,syn.y)))
points(syn.x,syn.y,col=my.col,pch=my.pch)
abline(0,1)
mtext("obs",side=1,line=1.5)
mtext("fore",side=2,line=1.5)
legend("topright",c("hist","syn"),col=c("black","red"),pch=c(1,my.pch),bty="n")

#distribution of residuals
hist(syn.fore.data.subset$resid,main="Synthetic")
hist(obs_fore_data.subset$resid,main="Historic")

acf(syn.fore.data.subset$resid[syn.fore.data.subset$season==0&3],lag.max = 40)
title("Synthetic Winter")
acf(obs_fore_data.subset$resid[obs_fore_data.subset$Season==0&3],lag.max = 40)
title("Historic Winter")

acf(syn.fore.data.subset$resid[syn.fore.data.subset$season==1&2],lag.max = 40)
title("Synthetic Summer")
acf(obs_fore_data.subset$resid[obs_fore_data.subset$Season==1&2],lag.max = 40)
title("Historic Summer")

