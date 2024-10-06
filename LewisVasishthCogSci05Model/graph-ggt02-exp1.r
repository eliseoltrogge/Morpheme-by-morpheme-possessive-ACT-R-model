# Replace below with specific file name and then save this file with a new
# (specific) name to customize the graph for individual experiments


files <- c("ggt02-exp");

#pdf(file="results.pdf", width=11,height=8.5);

for (f in files) {

# Get the experiment name
    results.file  <- paste(f,"-results",sep="");
    exp.name <- scan(results.file, what="string", nlines=1);
    plot.data <- scan(results.file, what="string", nlines=1,skip=1);
    graph.file <- scan(results.file, what="string", nlines=1,skip=2);

    print(paste("Plot-data=",plot.data," and graph file =",graph.file));


# Get data

    d <- read.csv(results.file, header=TRUE, skip=3);

    attach(d);

pdf(file=graph.file,width=11,height=8.5);

# set the margins and make the x, y labels a bit bigger

    par(omi=c(0.8,0.5,0.5,0.5),
	cex=1.2, cex.lab=1.2,
	cex.axis=0.75,
	font.axis=2,
	font.lab=2, cex.main=1.3);
    
    title.prefix <- "Single-parameter model fit for ";
    
    num.conditions <- length(condition);
    
#fm <- lm(data ~ model);
    
    
# below just fits a constant intercept; allows no scaling

    if (plot.data != "YES") {
	data <- model;}
    
    fm <- lm(data - model ~ 1);
    
    constant <- fm$coefficients[1]; # get the intercept
    
    fitted <- model + constant;
    
    print(summary(fm));
    
    conds <- as.character(condition);
    
    
# Plot the data first
    
    minpoint <- min(data,fitted); maxpoint <- max(data,fitted);

    ymin <- 50*round((minpoint/50)-0.5);
 
# ymax <-   ymin + 250;

    ymax <- 50*round((maxpoint/50)+0.5);
    

#ymin <- 0;
    
#     plot(fitted,
# 	 main = paste(title.prefix, exp.name), ylim=c(ymin,ymax), type="p",
# 	 lwd=2, lty=1, pch=19, xlab="                    unambiguous                                            ambiguous", ylab="Milliseconds",
# 	 axes=FALSE, frame.plot=TRUE
# 	);
    

    
    plot(fitted,
	 main = paste(title.prefix, exp.name), ylim=c(ymin,ymax), type="p",
	 lwd=2, lty=1, pch=19, xlab="", ylab="Milliseconds",
	 axes=FALSE, frame.plot=TRUE
	);
    
    lines(fitted[1:4], type="b", pch=19, lwd=2, lty=1);
    lines(c(rep(NA,4),fitted[5:8]), type="b", pch=19, lwd=2, lty=1);

    text(x=c(2.5,6.5),y=c(10,65),labels=c("low syntactic load","high syntactic load"));

# Add X axis with condition labels
    
axis(side=1,
	 labels=FALSE,
	 at=seq(1,length(conds)));
    
text(x=seq(1,8),y=-75,srt=35,cex=0.8,xpd=NA,ypd=NA,
     labels=c("the evidence that was","examined","by the lawyer","implicated his next-door",
"the evidence that was","examined","by the lawyer","implicated seemed to"));   


# Add Y-axis in standard way
     
axis(side=2);


# Add data line

if (plot.data == "YES") {
    lines(data[1:4], type="b", pch=21, lwd=2, lty=2);
    lines(c(rep(NA,4),data[5:8]), type="b", pch=21, lwd=2, lty=2);

    legend(1,ymax,
	   c("data","model"), lwd=2, lty=c(2,1), bty="n");
} else {
    legend(1,ymax,
	   c("model"), lwd=2, lty=c(1), bty="n");}



dev.off();

}



