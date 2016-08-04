options(digits=3)

as.numeric.factor <- function(x) {as.numeric(levels(x))[x]}

ProcessASC <- function(asc)
{
	fixDat =  data.frame(observer=numeric(), trial=numeric(), n=numeric(), x=numeric(), y=numeric(), dur=numeric())

	trialStarts = grep("start_trial", asc)
	trialEnds   = grep("stimulus", asc)
	nTrials = length(trialStarts)

	for (t in 1:nTrials)
	{
		
		trial = asc[trialStarts[t]:trialEnds[t]]
		 # trial start time

		fixationLines = grep("EFIX", trial)
		
		if (length(fixationLines)>0)
		{
			fixations = as.data.frame(matrix(unlist(trial[fixationLines]), byrow=T, ncol=6))

			trialDat = data.frame(
				observer=person, 
				trial=t, 
				x=as.numeric.factor(fixations$V4), 
				y=as.numeric.factor(fixations$V5), 
				dur=as.numeric.factor(fixations$V3),
				on = as.numeric(regmatches(fixations$V1, regexpr(pat, fixations$V1, perl=T))),
				off = as.numeric.factor(fixations$V2))

			# convert to stimulus coordinates
			 		
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
			
			trialDat$off = trialDat$off - trialDat$on[1]
			trialDat$on = trialDat$on - trialDat$on[1]

			fixDat = rbind(fixDat, trialDat)
	
		}

	
	}
	
	return(fixDat)
} 

people = c(6)

fDat = data.frame(observer=numeric(), trial=numeric(), targLoc=numeric(), distLoc=numeric(), x=numeric(), y=numeric(), n=numeric())

for (person in people)
{
	print(person)
	asc = readLines(paste("../results/cwdrmp", person, "_fix.asc", sep=""))
	asc = strsplit(asc, "\t")
	dat = ProcessASC(asc)
	fDat = rbind(fDat, dat)
	rm(dat)
}



write.csv(fDat, "fixations.csv", row.names=F, quote=F)