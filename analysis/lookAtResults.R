library(dplyr)
library(ggplot2)
library(binom)
options(digits=4)

people = c(1,2,3)
dat = data.frame()
for (person in people)
{
	pdat = read.csv(paste("../results/", person, "_results.txt", sep=""), sep = " ")
	dat = rbind(dat, pdat)
}

names(dat) = c("person", "blockN", "block", "trial", "flanker", "targetSide", "respG", "respC", "targOri", "saccStart", "targDelay", "dotRemove", "targOnTime", "targOffTime")
dat$block = as.factor(dat$block)
levels(dat$block)=c("saccade", "fixation")
dat$person = as.factor(dat$person)
dat$flanker = factor(dat$flanker, levels(dat$flanker)[c(3,2,4,1)])


sDat = read.csv("saccades.csv")
# only keep valid saccades (from centre to a target box)
# asusme that observer always fixated the correct left/right target box! 
sDat = filter(sDat, aoi1==0, (aoi2==1 | aoi2==2))


tDat = read.csv("eventTimes.csv")

dat$okSacc = 0
dat$saccTimingOk = 0
dat$saccTimingFromTargOff = NaN
dat$saccLat = NaN
for (pp in levels(dat$person))
{
	for (tr in 1:40)
	{
		for (blk in 1:20)
		{
			trTimes = filter(tDat, person==pp, trial==tr, block==blk)
			trSaccs = filter(sDat, person==pp, trial==tr, block==blk)

			idx = which(dat$person==pp & dat$trial==tr & dat$blockN==blk)
			# first code up okSacc = 1 if we have a fixation block and no saccades.csv
			# or a saccade trial with a suitable saccae
			if (dat$block[idx] == "fixation" &
				nrow(trSaccs)==0)
			{
				dat$okSacc[idx] = 1
				dat$saccTimingOk[idx] = 1
			}
			if (dat$block[idx] == "saccade" &
				nrow(trSaccs)>0)
			{
				dat$okSacc[idx] = 1			

				# check if a saccade was recorded between dotRemoved and targOff
				if (nrow(trSaccs)>0)
				{

					dotRemove = filter(trTimes, events=="dotRemoved")$times
					targOff   = filter(trTimes, events=="targOff")$times
					targOn   = filter(trTimes, events=="targOn")$times

					if (length(dotRemove)>0)
					{
						saccTooEarly = (trSaccs$t1 >dotRemove) & (trSaccs$t1 < targOff)
						dat$saccLat[idx] = trSaccs$t1 - dotRemove
		
						if (sum( saccTooEarly)==0)
						{
							dat$saccTimingOk[idx] = 1
								
						}
						dat$saccTimingFromTargOff[idx] =  trSaccs$t1 - targOff

					}
				}
			}
		}
	}
}

 dat$saccTimingOk[dat$block=="fixation" & dat$okSacc==1] = 1


# number of trials in which data was collected
aggregate(respG ~ flanker+block+person, dat, FUN="length")
plt = ggplot(aggregate(respG ~ block+person, dat, FUN="length"), aes(x=block, y=respG, fill=person))
plt = plt + geom_bar(position=position_dodge(), stat="identity")
plt = plt + scale_y_continuous(name="num. trials completed")
ggsave("../plots/1_nTrialsCompleted.pdf")

# gabor response rates
aggregate(respG ~ flanker+block+person, dat, FUN="mean")
plt = ggplot(aggregate(respG ~ block+person, dat, FUN="mean"), aes(x=block, y=respG, fill=person))
plt = plt + geom_bar(position=position_dodge(), stat="identity")
plt = plt + scale_y_continuous(name="accuracy at Gabor discrimination")
ggsave("../plots/2_gaborAcc.pdf")

# take only trials with a valid gabor response
dat = filter(dat, respG==1)


dat = filter(dat, okSacc==1)
dat$saccTimingOk[dat$block=="fixation"] = 1

aggregate(data=dat, saccTimingOk ~ flanker+block, FUN="sum")
plt = ggplot(aggregate(saccTimingOk ~ block+person, dat, FUN="sum"), aes(x=block, y=saccTimingOk, fill=person))
plt = plt + geom_bar(position=position_dodge(), stat="identity")
plt = plt + scale_y_continuous(name="number of trials w/ valid saccade onset")
ggsave("../plots/3_nTrialsSaccOK.pdf")


dat = filter(dat, saccTimingOk==1)

dat$respC = droplevels(dat$respC)
dat$correct = as.numeric(as.character(dat$respC) == as.character(dat$targOri))


aggDat = (dat %>% 
	group_by(person, block, flanker) 
		%>% summarise(
			propCorrect= mean(correct),
			nCorrect=sum(correct),
			n = length(correct),
			lower = binom.test(nCorrect,n)$conf.int[1],
			upper = binom.test(nCorrect,n)$conf.int[2]))
			


plt = ggplot(aggDat, aes(x=flanker, y=propCorrect, ymin=lower, ymax=upper, colour=block))
plt = plt + geom_point() + geom_errorbar() + facet_wrap(~person)
# plt = plt + geom_hline(yintercept=0.25, colour=grey)
plt = plt + scale_y_continuous(limits=c(0,1))
plt = plt + theme_bw()

plt
ggsave("../plots/4_crowdingResults.pdf")


# plt = ggplot(filter(dat, block=="saccade", blockN==1), aes(x=trial, y=saccStart, colour=blockN))
# plt = plt + geom_path()
# plt
