library(dplyr)
library(ggplot2)
library(binom)
options(digits=2)


dat = read.csv("../results/99_results.txt", sep = " ")
names(dat) = c("person", "block", "trial", "flanker", "targetSide", "respG", "respC", "targOri", "saccStart")
dat$block = as.factor(dat$block)
levels(dat$block)=c("saccade", "fixation")

dat$flanker = factor(dat$flanker, levels(dat$flanker)[c(2,1,3)])

aggregate(respG ~ flanker+block, dat, FUN="mean")

# remove trials with incorrect Gabor response
dat = filter(dat, respG==1)

dat = droplevels(dat)
dat$correct = as.numeric(dat$respC == dat$targOri)
aggDat = aggregate(correct ~ flanker+block, dat, FUN="mean")


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
plt = plt + ylim(0,1) + geom_hline(yintercept=0.25, colour=grey)
plt = plt = theme_bw()