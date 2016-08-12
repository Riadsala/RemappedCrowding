options(digits=3)

as.numeric.factor <- function(x) {as.numeric(levels(x))[x]}

ProcessASC <- function(asc)
{
	fixDat =  data.frame(observer=numeric(), trial=numeric(), n=numeric(), x=numeric(), y=numeric(), dur=numeric())
	saccDat = data.frame(observer=numeric(), trial=numeric(), n=numeric(), x1=numeric(), y1=numeric(),x2=numeric(), y2=numeric(),t1=numeric(), t2=numeric(), dur=numeric())
	timeDat = data.frame(observer=numeric(), trial=numeric(), times=numeric(), events=character())
	trialStarts = grep("start_trial", asc)
	trialEnds   = grep("stimulus", asc)
	nTrials = length(trialStarts)

	for (t in 1:nTrials)
	{
		
		trial = asc[trialStarts[t]:trialEnds[t]]

		t0 = as.numeric(regmatches(trial[[1]], regexpr(pat, trial[[1]], perl=T)))

		fixationLines = grep("EFIX", trial)
		saccadeLines = grep("ESACC", trial)
		
		if (length(fixationLines)>0)
		{
			fixations = as.data.frame(matrix(unlist(trial[fixationLines]), byrow=T, ncol=6))
			pat = "[0-9]+"
			trialDat = data.frame(
				observer=person, 
				trial=t,				
				x=as.numeric.factor(fixations$V4), 
				y=as.numeric.factor(fixations$V5), 
				dur=as.numeric.factor(fixations$V3),				
				on = as.numeric(regmatches(fixations$V1, regexpr(pat, fixations$V1, perl=T))),
				off = as.numeric.factor(fixations$V2))			 		
			 trialDat$n = 1:length(trialDat$x)		
			
			txt = unlist(trial[grep("remove_dot", trial)])
			dotRemoveTime = as.numeric(regmatches(txt, regexpr(pat, txt, perl=T)))
			txt = unlist(trial[grep("target_on", trial)])
			targOnTime = as.numeric(regmatches(txt, regexpr(pat, txt, perl=T)))
			txt = unlist(trial[grep("target_off", trial)])
			targOffTime = as.numeric(regmatches(txt, regexpr(pat, txt, perl=T)))
			rm(txt)

			trialDat$timeInt = "waiting"
			trialDat$timeInt[which(trialDat$on>dotRemoveTime)] = "dotOff"	
			trialDat$timeInt[which(trialDat$on>targOnTime)] = "targVis"		
			trialDat$timeInt[which(trialDat$on>targOffTime)] = "targOff"		
			
			trialDat$off = trialDat$off - t0
			trialDat$on = trialDat$on - t0

			fixDat = rbind(fixDat, trialDat)


			if (length(targOffTime)>0)
			{
				timeDat = rbind(timeDat,data.frame(
					observer=person, 
					trial=t,					
					times=c(dotRemoveTime-t0, targOnTime-t0, targOffTime-t0),
					events=c("dotRemoved", "targOn", "targOff")))
			}
		}

		
		if (length(saccadeLines)>0){
			saccades = as.data.frame(matrix(unlist(trial[saccadeLines]), byrow=T, ncol=9))
			trialDat = data.frame(
				observer=person, 
				trial=t,				
				t1 = as.numeric(regmatches(saccades$V1, regexpr(pat, saccades$V1, perl=T)))-t0,
				t2 = as.numeric.factor(saccades$V2)-t0,
				x1=as.numeric.factor(saccades$V4), 
				y1=as.numeric.factor(saccades$V5), 
				x2=as.numeric.factor(saccades$V6), 
				y2=as.numeric.factor(saccades$V7))			 		
			 trialDat$n = 1:length(trialDat$x1)	

			saccDat = rbind(saccDat, trialDat)
		}
	
	}

	fDat$t[fDat$t==0]=36
	sDat$t[sDat$t==0]=36
	tDat$t[tDat$t==0]=36
	
	return(list(fixDat, timeDat, saccDat))
} 

SortOutTrialNumbers <- function(dat)
{
# remove practise trials
	dat = filter(dat, trial>30)
	dat$trial = dat$trial - 30

	dat$block = ceiling(dat$trial/36)
	dat$trial = dat$trial %% 36
	dat$trial[dat$trial==0] = 36

	return(dat)
}

people = c(9,10)

fDat = data.frame(observer=numeric(), trial=numeric(), targLoc=numeric(), distLoc=numeric(), x=numeric(), y=numeric(), n=numeric())
tDat =  data.frame(observer=numeric(), trial=numeric(), times=numeric(), events=character())
sDat = data.frame(observer=numeric(), trial=numeric(), n=numeric(), x1=numeric(), y1=numeric(),x2=numeric(), y2=numeric(),t1=numeric(), t2=numeric(), dur=numeric())

for (person in people)
{
	print(person)
	asc = readLines(paste("../results/cwdrmp", person, "_events.asc", sep=""))
	asc = strsplit(asc, "\t")
	dat = ProcessASC(asc)
	fDat = rbind(fDat, dat[[1]])
	tDat = rbind(tDat, dat[[2]])
	sDat = rbind(sDat, dat[[3]])
	rm(dat, asc)
}

# the first 30 trials are practise - so remove!
fDat = SortOutTrialNumbers(fDat)
sDat = filter(sDat, trial>30)
tDat = filter(tDat, trial>30)


write.csv(fDat, "fixations.csv", row.names=F, quote=F)
write.csv(sDat, "saccades.csv", row.names=F, quote=F)
write.csv(tDat, "eventTimes.csv", row.names=F, quote=F)