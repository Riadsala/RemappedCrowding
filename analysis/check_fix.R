library(ggplot2)
library(dplyr)


interleave <- function(v1,v2)
{
	ord1 <- 2*(1:length(v1))-1
	ord2 <- 2*(1:length(v2))
	c(v1,v2)[order(c(ord1,ord2))]
}

boxes = data.frame(x=c(
	1920/2 - 38 * c(1,2,3,4),
	1920/2 + 38 * c(1,2,3,4)),
	 y= 1080/2)

boxCentres = c(	1920/2 - 38 * c(1,2,3,4), 1920/2 + 38 * c(1,2,3,4))

sqSize = 28

dat = read.csv("fixations.csv")
timedat = read.csv("eventTimes.csv")


 for (tr in unique(dat$trial))

{

	tdat = filter(dat, trial==tr)
	ttime = filter(timedat, trial==tr)
	tdat$aoi = NaN
	for (b in 1:8)
	{
		tdat$aoi[which(abs(tdat$x -boxCentres[b])<20)] = b

	}

print(tdat)
	if (1)
	{
		pts = data.frame(x=rep(tdat$x, 1, each=2), y=interleave(tdat$on, tdat$off))
	
		plt = ggplot(tdat, aes(x=x, y=y)) + geom_point(aes(colour=timeInt)) + geom_path()
		plt = plt + scale_x_continuous(limits=c(1+600,1920-600)) + scale_y_continuous(limits=c(1080/2-100,1080/2+100))
		plt = plt + coord_fixed() + geom_text(aes( label=aoi))

		for (b in 1:nrow(boxes))
		{
		box = data.frame(
			x = c(boxes$x[b]-sqSize/2, boxes$x[b]-sqSize/2, boxes$x[b]+sqSize/2, boxes$x[b]+sqSize/2, boxes$x[b]-sqSize/2),
			y = c(boxes$y[b]-sqSize/2, boxes$y[b]+sqSize/2, boxes$y[b]+sqSize/2, boxes$y[b]-sqSize/2, boxes$y[b]-sqSize/2))
			plt = plt + geom_path(data=box, aes(x=x, y=y))
		}
	
	
		# plt2 = ggplot(pts, aes(x=x, y=y)) + geom_path()
		# plt2 = plt2 + geom_hline(data=ttime, aes(yintercept = times, colour=events))
		# plt2 = plt2 + geom_vline(xintercept=c(
		# 	1920/2 - 38 * c(1,2,3,4),
		# 	1920/2 + 38 * c(1,2,3,4)), linetype=2)
		# plt2 = plt2 + geom_text()
		ggsave(paste('scnpth', tr, '.png', sep=""))
	
	}
 }



plt2 