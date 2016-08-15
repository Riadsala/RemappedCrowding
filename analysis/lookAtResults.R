library(dplyr)
library(ggplot2)
library(binom)
options(digits=2)

people = c(9,10)
dat = data.frame()
for (person in people)
{
	pdat = read.csv(paste("../results/", person, "_results.txt", sep=""), sep = " ")
	dat = rbind(dat, pdat)
}

names(dat) = c("person", "blockN", "block", "trial", "flanker", "targetSide", "respG", "respC", "targOri", "saccStart", "targOnTime", "targOffTime")
dat$block = as.factor(dat$block)
levels(dat$block)=c("saccade", "fixation")
dat$person = as.factor(dat$person)

sDat = read.csv("saccades.csv")
# only keep valid saccades (from centre to a target box)
# asusme that observer always fixated the correct left/right target box! 
sDat = filter(sDat, aoi1==0, (aoi2==4 | aoi2==8))


tDat = read.csv("eventTimes.csv")

dat$okSacc = 0
dat$saccTimingOk = 0
for (pp in levels(dat$person))
{
	for (tr in 1:36)
	{
		for (blk in 1:16)
		{
			trTimes = filter(tDat, person==pp, trial==tr, block==blk)
			trSaccs = filter(sDat, person==pp, trial==tr, block==blk)

			# first code up okSacc = 1 if we have a fixation block and no saccades.csv
			# or a saccade trial with a suitable saccae
			if (dat$block[dat$person==pp & dat$trial==tr & dat$blockN==blk] == "fixation" &
				nrow(trSaccs)==0)
			{
				dat$okSacc[dat$person==pp & dat$trial==tr & dat$blockN==blk] = 1
			}
			if (dat$block[dat$person==pp & dat$trial==tr & dat$blockN==blk] == "saccade" &
				nrow(trSaccs)>0)
			{
				dat$okSacc[dat$person==pp & dat$trial==tr & dat$blockN==blk] = 1
			}

			# check if a saccade was recorded between dotRemoved and targOff
			if (nrow(trSaccs)==0)
			{

				dotRemove = filter(trTimes, events=="dotRemoved")$times
				targOff   = filter(trTimes, events=="targOff")$times
				if (length(dotRemove)>0)
				{
					saccTooEarly = (trSaccs$t1 >dotRemove) & (trSaccs$t1 < targOff)
					if (sum( saccTooEarly)==0)
					{
						dat$saccTimingOk[dat$person==pp & dat$trial==tr & dat$blockN==blk] = 1	
					}
				}
			}
		}
	}
}

 dat$saccTimingOk[dat$block=="fixation" & dat$okSacc==1] = 1

dat$flanker = factor(dat$flanker, levels(dat$flanker)[c(2,1,3)])

aggregate(respG ~ flanker+block+person, dat, FUN="mean")
aggregate(respG ~ flanker+block+person, filter(dat, respG==1), FUN="length")


dat$respC = droplevels(dat$respC)
dat$correct = as.numeric(as.character(dat$respC) == as.character(dat$targOri))


aggDat = (filter(dat, respG==1,  saccTimingOk==1) %>% 
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
ggsave("crowdingResults.pdf")


# plt = ggplot(filter(dat, block=="saccade", blockN==1), aes(x=trial, y=saccStart, colour=blockN))
# plt = plt + geom_path()
# plt
