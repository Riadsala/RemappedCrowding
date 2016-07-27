# power analysis for glmer

library(lme4)

# specify fixed effects to simulate:
fixef_groundtruth = data.frame(
	saccade = c("no", "no", "yes", "yes"),
	flanker = c("inner", "outer", "inner", "outer"),
	prob = c(0.8, 0.8, 0.8, 0.8))

nTrials = 50
nPeople = 12
n_sd = 0.0


n_sim = 100

simResults = data.frame(n=as.numeric(), factor=as.character(), p=as.numeric())

for (ii in 1:n_sim)
{
	
	fakeData = data.frame(person = as.numeric(), saccade = as.character(), flanker=as.character(), correct = as.numeric())
	
	for (p in 1:nPeople)
	{
		person_probs = fixef_groundtruth
		person_probs$prob = rnorm(mean=fixef_groundtruth$prob, n=4, sd=n_sd)
	
		personSim = rbind(
			data.frame(person=p, saccade="no", flanker="inner", correct = runif(nTrials)<person_probs$prob[1]),
			data.frame(person=p, saccade="no", flanker="outer", correct = runif(nTrials)<person_probs$prob[2]),
			data.frame(person=p, saccade="yes", flanker="inner", correct = runif(nTrials)<person_probs$prob[3]),
			data.frame(person=p, saccade="yes", flanker="outer", correct = runif(nTrials)<person_probs$prob[4]))
	
		fakeData = rbind(fakeData, personSim)
	}
	
	
	
	fakeData$person = as.factor(fakeData$person)
	fakeData$saccade = as.factor(fakeData$saccade)
	fakeData$flanker = as.factor(fakeData$flanker)
	fakeData$correct = as.numeric(fakeData$correct)
	
	model = glmer(correct ~ saccade * flanker + (1|person), family="binomial", fakeData)

	simResults = rbind(simResults,
		data.frame(
			n=ii,
			factor = c("saccade", "flanker", "interaction"),
			p = summary(model)$coefficients[2:4,4] ))

}
summary(model)

library(ggplot2)
# agDat = aggregate(correct ~ person + saccade + flanker, FUN="mean", fakeData)

# plt = ggplot(agDat, aes(x=flanker, y=correct, fill=saccade)) + geom_bar(stat="identity",position=position_dodge())
# plt = plt + facet_wrap(~person)
# plt

plt = ggplot(simResults, aes(x=p, fill=factor)) + geom_histogram(alpha=0.5)
plt