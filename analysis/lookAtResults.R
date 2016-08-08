library(dplyr)
library(ggplot2)
library(binom)
options(digits=2)


dat = read.csv("../results/8_results.txt", sep = " ")
names(dat) = c("person", "blockN", "block", "trial", "flanker", "targetSide", "respG", "respC", "targOri", "saccStart", "targOnTime", "targOffTime")
dat$block = as.factor(dat$block)
levels(dat$block)=c("saccade", "fixation")

dat$flanker = factor(dat$flanker, levels(dat$flanker)[c(2,1,3)])

aggregate(respG ~ flanker+block, dat, FUN="mean")
aggregate(respG ~ flanker+block, dat, FUN="length")

# remove trials with incorrect Gabor response
 dat = filter(dat, respG==1)

 # change cross responses as this person answered them backwards!
# tmp = dat$respC
# dat$respC[which(tmp=="right")] = "left"
# dat$respC[which(tmp=="down")] = "up"
# dat$respC[which(tmp=="left")] = "right"
# dat$respC[which(tmp=="up")] = "down"

dat$respC = droplevels(dat$respC)
dat$correct = as.numeric(as.character(dat$respC) == as.character(dat$targOri))


aggDat = (dat %>% 
	group_by(block, flanker) 
		%>% summarise(
			propCorrect= mean(correct),
			nCorrect=sum(correct),
			n = length(correct),
			lower = binom.test(nCorrect,n)$conf.int[1],
			upper = binom.test(nCorrect,n)$conf.int[2]))
			


plt = ggplot(aggDat, aes(x=flanker, y=propCorrect, ymin=lower, ymax=upper))
plt = plt + geom_point() + geom_errorbar() + facet_wrap(~block)
# plt = plt + geom_hline(yintercept=0.25, colour=grey)
plt = plt + scale_y_continuous(limits=c(0,1))
plt = plt + theme_bw()
plt
ggsave("crowdingResults.pdf")
