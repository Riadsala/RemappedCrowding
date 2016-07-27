as.numeric.factor <- function(x) {as.numeric(levels(x))[x]}

ProcessASC <- function(asc)
{
	fixDat =  data.frame(observer=numeric(), trial=numeric(), n=numeric(), x=numeric(), y=numeric(), dur=numeric())

	trialStarts = grep("TRIAL_START[0-9]*", asc)
	trialEnds   = grep("TRIAL_END[0-9]*", asc)
	nTrials = length(trialStarts)

	for (t in 1:nTrials)
	{
		
		trial = asc[trialStarts[t]:trialEnds[t]]
		fixationLines = grep("EFIX", trial)
		
		if (length(fixationLines)>0)
		{
			fixations = as.data.frame(matrix(unlist(trial[fixationLines]), byrow=T, ncol=6))

			trialDat = data.frame(
				observer=person, 
				trial=t, 
				x=as.numeric.factor(fixations$V4), y=as.numeric.factor(fixations$V5), dur=as.numeric.factor(fixations$V3))

			# convert to stimulus coordinates
			 		
			 trialDat$n = 1:length(trialDat$x)
		
			 fixDat = rbind(fixDat, trialDat)
		}
	}
	return(fixDat)
} 

people = c(1:12, 14:32)
options(digits=3)
fDat = data.frame(observer=numeric(), trial=numeric(), targLoc=numeric(), distLoc=numeric(), x=numeric(), y=numeric(), n=numeric())
for (person in people)
{
print(person)
	asc = readLines(paste("../results/objscn", person, ".asc", sep=""))
	asc = strsplit(asc, "\t")
	dat = ProcessASC(asc)
	fDat = rbind(fDat, dat)
	rm(dat)
}

fDat$x = round(fDat$x - (1920-800)/2)
fDat$y = round(fDat$y - (1080-600)/2)

write.csv(fDat, "fixations.csv", row.names=F, quote=F)