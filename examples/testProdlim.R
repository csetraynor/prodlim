library(lava)
library(prodlim)
## library(survival)
m <- crModel()
addvar(m) <- ~X1+X2+X3+X4+X5+X6
distribution(m,"X3") <- binomial.lvm()
distribution(m,"X4") <- normal.lvm(mean=50,sd=10)
distribution(m,"eventtime1") <- coxWeibull.lvm(scale=1/200)
distribution(m,"censtime") <- coxWeibull.lvm(scale=1/1000)
m <- categorical(m,K=4,eventtime1~X5,beta=c(1,0,0,0),p=c(0.1,0.2,0.3))
m <- categorical(m,K=3,eventtime1~X1,beta=c(2,1,0),p=c(0.3,0.2))
regression(m,to="eventtime1",from=c("X2","X4")) <- c(0.3,0)
regression(m,to="eventtime2",from=c("X2","X4")) <- c(0.6,-0.07)
set.seed(17)
d <- sim(m,200)
d$X1 <- factor(d$X1,levels=c(0,1,2),labels=c("low survival","medium survival","high survival"))
## d$X3 <- factor(d$X3,levels=c(0,1),labels=c("high survival","low survival"))
d$X5 <- factor(d$X5,levels=c("0","1","2","3"),labels=c("one","two","three","four"))
d$Event <- factor(d$event,levels=c("0","1","2"),labels=c("0","cause-1","cause-2"))
d$status <- 1*(d$event!=0)
head(d)

s0 <- prodlim(Hist(time,status)~1,data=d)
print(s0)

summary(s0,intervals=TRUE)

stats::predict(s0,times=1:10)

plot(s0)

su <- prodlim(Hist(time,status)~1,data=d,subset=d$X1=="medium survival")
print(su)

s1 <- prodlim(Hist(time,status)~X1,data=d)
print(s1)

summary(s1,intervals=TRUE,newdata=data.frame(X1=c("medium survival","high survival","low survival")))

stats::predict(s1,times=0:10,newdata=data.frame(X1=c("medium survival","low survival","high survival")))

plot(s1)

s2 <- prodlim(Hist(time,status)~X2,data=d)
print(s2)

summary(s2,intervals=TRUE)

stats::predict(s2,times=0:10,newdata=data.frame(X2=quantile(d$X2)))

plot(s2)

s1a <- prodlim(Hist(time,status)~X1+X3,data=d)
print(s1a)

summary(s1a,intervals=TRUE)

stats::predict(s1a,times=0:10,newdata=expand.grid(X1=levels(d$X1),X3=unique(d$X3)))

plot(s1a,confint=FALSE,atrisk=FALSE,legend.x="bottomleft",legend.cex=0.8)

s3 <- prodlim(Hist(time,status)~X1+X2,data=d)
print(s3)

summary(s3,intervals=TRUE)

stats::predict(s3,times=0:10,newdata=expand.grid(X1=levels(d$X1),X2=c(quantile(d$X2,0.05),median(d$X2))))

plot(s3,confint=FALSE,atrisk=FALSE,legend.x="bottomleft",legend.cex=0.8,newdata=expand.grid(X1=levels(d$X1),X2=c(quantile(d$X2,0.05),median(d$X2))))

f0 <- prodlim(Hist(time,event)~1,data=d)
print(f0)

summary(f0,intervals=TRUE)

stats::predict(f0,times=1:10)

plot(f0)

f1 <- prodlim(Hist(time,event)~X1,data=d)
print(f1)

summary(f1,intervals=TRUE,newdata=data.frame(X1=c("medium survival","high survival","low survival")))

stats::predict(f1,times=0:10,newdata=data.frame(X1=c("medium survival","low survival","high survival")))

plot(f1)

f2 <- prodlim(Hist(time,event)~X2,data=d)
print(f2)

summary(f2,intervals=TRUE)

stats::predict(f2,times=0:10,newdata=data.frame(X2=quantile(d$X2)))

plot(f2)

f1a <- prodlim(Hist(time,event)~X1+X3,data=d)
print(f1a)

summary(f1a,intervals=TRUE)

stats::predict(f1a,times=0:10,newdata=expand.grid(X1=levels(d$X1),X3=unique(d$X3)))

plot(f1a,confint=FALSE,atrisk=FALSE,legend.x="bottomleft",legend.cex=0.8)

f3 <- prodlim(Hist(time,event)~X1+X2,data=d)
print(f3)

summary(f3,intervals=TRUE)

stats::predict(f3,times=0:10,newdata=expand.grid(X1=levels(d$X1),X2=c(quantile(d$X2,0.05),median(d$X2))))

plot(f3,confint=FALSE,atrisk=FALSE,legend.x="bottomleft",legend.cex=0.8,newdata=expand.grid(X1=levels(d$X1),X2=c(quantile(d$X2,0.05),median(d$X2))))

library(survival)
data(pbc)
prodlim.0 <- prodlim(Hist(time,status!=0)~1,data=pbc)
survfit.0 <- survfit(Surv(time,status!=0)~1,data=pbc)
plot(survfit.0)
plot(prodlim.0,add=TRUE,col=2,lwd=3)

ttt <- sort(unique(d$time)[d$event==1])
ttt <- ttt[-length(ttt)]
sum0.s <- summary(survfit.0,times=ttt)
plot(survfit.0,lwd=6)
plot(prodlim.0,add=TRUE,col=2)
## There is arounding issue:
library(survival)
testdata <- data.frame(time=c(16.107812,3.657545,1.523978),event=c(0,1,1))
sum0 <- summary(survfit(Surv(time,event)~1,data=testdata),times=sort(testdata$time))
testdata$timeR <- round(testdata$time,1)
sum1 <- summary(survfit(Surv(timeR,event)~1,data=testdata),times=sort(testdata$time))
sum0
sum1
## sum0 != sum1
## summary(survfit.0,times=c(0,0.1,0.2,0.3))
result.survfit <- data.frame(time=sum0.s$time,n.risk=sum0.s$n.risk,n.event=sum0.s$n.event,surv=sum0.s$surv,std.err=sum0.s$std.err,lower=sum0.s$lower,upper=sum0.s$upper)
result.prodlim <- data.frame(summary(prodlim.0,times=ttt)$table[,c("time","n.risk","n.event","n.lost","surv","se.surv","lower","upper")])
cbind(result.survfit[,c("time","n.risk","n.event","surv")],result.prodlim[,c("time","n.risk","n.event","surv")])
a <- round(result.survfit$surv,8)
b <- round(result.prodlim$surv[!is.na(result.prodlim$se.surv)],8)
if (all(a==b)){cat("\nOK\n")}else{cat("\nERROR\n")}
if (all(round(result.survfit$std.err,8)==round(result.prodlim$se.surv[!is.na(result.prodlim$se.surv)],8))){cat("\nOK\n")}else{cat("\nERROR\n")}

pbc <- pbc[order(pbc$time,-pbc$status),]
set.seed(17)
boot <- sample(1:NROW(pbc),size=NROW(pbc),replace=TRUE)
boot.weights <- table(factor(boot,levels=1:NROW(pbc)))
s1 <- prodlim(Hist(time,status>0)~1,data=pbc,caseweights=boot.weights)
plot(s1,col=1,confint=FALSE,lwd=8)
s2 <- prodlim(Hist(time,status>0)~1,data=pbc[sort(boot),])
plot(s2,add=TRUE,col=2,confint=FALSE,lwd=3)

library(survey)
library(survival)
library(prodlim)
pbc <- pbc[order(pbc$time,-pbc$status),]
## pbc$randprob<-fitted(biasmodel)
## pbc$randprob <- as.numeric(pbc$sex=="m")+0.1
set.seed(17)
pbc$randprob <- abs(rnorm(NROW(pbc)))
dpbc <- svydesign(id=~id, weights=~randprob, strata=NULL, data=pbc)
survey.1<-svykm(Surv(time,status>0)~1, design=dpbc)
plot(survey.1,lwd=8)
prodlim.1 <- prodlim(Hist(time,status>0)~1,data=pbc,caseweights=pbc$randprob)
plot(prodlim.1,add=TRUE,col=2,confint=FALSE)

pbc$entry <- round(pbc$time/5)
survfit.delay <- survfit(Surv(entry,time,status!=0)~1,data=pbc)
prodlim.delay <- prodlim(Hist(time,status!=0,entry=entry)~1,data=pbc)
plot(survfit.delay,lwd=8)
plot(prodlim.delay,lwd=4,col=2,add=TRUE,confint=FALSE)

pbc0 <- pbc
pbc0$entry <- round(pbc0$time/5)
survfit.delay.edema <- survfit(Surv(entry,time,status!=0)~edema,data=pbc0)
## survfit.delay.edema.0.5 <- survfit(Surv(entry,time,status!=0)~1,data=pbc0[pbc0$edema==0.5,])
prodlim.delay.edema <- prodlim(Hist(time,status!=0,entry=entry)~edema,data=pbc0)
## prodlim.delay.edema.0.5 <- prodlim(Hist(time,status!=0,entry=entry)~1,data=pbc0[pbc0$edema==0.5,])
plot(survfit.delay.edema,conf.int=FALSE,col=1:3,lwd=8)
plot(prodlim.delay.edema,add=TRUE,confint=FALSE,col=c("gray88","orange",5),lwd=4)

library(riskRegression)
data(Melanoma)
aj <- prodlim(Hist(time,Event)~1,data=d)
plot(aj,cause="stacked")

library(etm)
data(abortion)
cif.ab.etm <- etmCIF(Surv(entry, exit, cause != 0) ~ 1,abortion,etype = cause,failcode = 3)
cif.ab.prodlim <- prodlim(Hist(time=exit, event=cause,entry=entry) ~ 1,data=abortion)
plot(cif.ab.etm,lwd=8,col=3)
plot(cif.ab.prodlim,add=TRUE,lwd=4,col=5,cause=3)

library(etm)
data(abortion)
x <- prodlim(Hist(time=exit, event=cause,entry=entry) ~ 1,data=abortion)
x0 <- etmCIF(Surv(entry, exit, cause != 0) ~ 1,abortion,etype = cause)
graphics::par(mfrow=c(2,2))
cif.ab.etm <- etmCIF(Surv(entry, exit, cause != 0) ~ 1,abortion,etype = cause,failcode = 3)
cif.ab.prodlim <- prodlim(Hist(time=exit, event=cause,entry=entry) ~ 1,data=abortion)
# cause 3
plot(cif.ab.etm, ci.type = "bars", pos.ci = 24, col = c(1, 2), lty = 1,which.cif=3,lwd=8)
plot(cif.ab.prodlim,add=TRUE,cause=3,confint=TRUE,col=2)
# cause 2
plot(cif.ab.etm, ci.type = "bars", pos.ci = 24, col = c(1, 2), lty = 1,which.cif=2,lwd=8)
plot(cif.ab.prodlim,add=TRUE,cause=2,confint=TRUE,col=2)
# cause 1
plot(cif.ab.etm, ci.type = "bars", pos.ci = 24, col = c(1, 2), lty = 1,which.cif=1,lwd=8)
plot(cif.ab.prodlim,add=TRUE,cause=1,confint=TRUE,col=2)

library(etm)
data(abortion)
cif.ab.etm <- etmCIF(Surv(entry, exit, cause != 0) ~ group,abortion,etype = cause,failcode = 3)
names(cif.ab.etm[[1]])
head(cbind(cif.ab.etm[[1]]$time,cif.ab.etm[[1]]$n.risk))
cif.ab.prodlim <- prodlim(Hist(time=exit, event=cause,entry=entry) ~ group,data=abortion)
plot(cif.ab.etm, ci.type = "bars", pos.ci = 24, col = c(1, 2), lty = 1, curvlab = c("Control", "Exposed"),lwd=8)
plot(cif.ab.prodlim,add=TRUE,cause=3,confint=FALSE,col="yellow")

library(survival)
library(prodlim)
library(etm)
testdata <- data.frame(entry=c(1,5,2,8,5),exit=c(10,6,4,12,33),event=c(0,1,0,1,0))
cif.test.etm <- etmCIF(Surv(entry, exit, event) ~ 1,data=testdata,etype = event,failcode = 1)
cif.test.survival <- survfit(Surv(entry, exit, event) ~ 1,data=testdata)
cif.test.prodlim <- prodlim(Hist(exit,event,entry=entry)~1,data=testdata)
plot(cif.test.etm, ci.type = "bars", pos.ci = 24, lwd=5)
plot(cif.test.etm, ci.type = "bars", pos.ci = 24, lwd=5)
plot(cif.test.prodlim,add=TRUE,cause=2,col=2,confint=TRUE,type="cuminc")

library(SmoothHazard)
library(survival)
library(prodlim)
## simulate data from an illness-death model
mod <- idmModel(K=10,schedule=0,punctuality=1)
regression(mod,from="X",to="lifetime") <- log(2)
regression(mod,from="X",to="waittime") <- log(2)
regression(mod,from="X",to="illtime") <- log(2)
set.seed(137)
## we round the event times to have some ties
testdata <- round(sim(mod,250),1)
## the data enter with delay into the intermediate state (ill)
## thus, to estimate the cumulative incidence of
## the absorbing state (death) after illness we 
## have left-truncated data
illdata <- testdata[testdata$illstatus==1,]
illdata <- illdata[order(illdata$lifetime,-illdata$seen.exit),]
## sindex(jump.times=illdata$illtime,eval.times=illdata$lifetime)
## F <- prodlim(Hist(lifetime,status,entry=illtime)~1,data=illdata[1:5,])
## f <- survfit(Surv(illtime,lifetime,status)~1,data=illdata[1:5,],type="kaplan-meier")
survfit.delayed.ill <- survfit(Surv(illtime,lifetime,seen.exit)~1,data=illdata)
prodlim.delayed.ill <- prodlim(Hist(lifetime,seen.exit,entry=illtime)~1,data=illdata)
plot(survfit.delayed.ill,lwd=5)
plot(prodlim.delayed.ill,lwd=2,col=2,add=TRUE)

icens <- prodlim(Hist(time=list(L,R),event=seen.ill)~1,data=illdata)
plot(icens)
