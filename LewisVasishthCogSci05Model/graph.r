# Replace below with specific file name and then save this file with a new
# (specific) name to customize the graph for individual experiments


files <- scan("all-experiments",what="string");

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
	cex.axis=1.0,
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
    
    plot(fitted,
	 main = paste(title.prefix, exp.name), ylim=c(ymin,ymax), type="b",
	 lwd=2, lty=1, pch=19, xlab="Condition", ylab="Milliseconds",
	 axes=FALSE, frame.plot=TRUE
	);
    
# Add X axis with condition labels
    
axis(side=1,
     labels=conds,
    at=seq(1,length(conds)));


# Add Y-axis in standard way
     
axis(side=2);


# Add data line

if (plot.data == "YES") {
    lines(data, type="b", pch=21, lwd=2, lty=2);
    legend(1,ymax,
	   c("data","model"), lwd=2, lty=c(2,1), bty="n");
} else {
    legend(1,ymax,
	   c("model"), lwd=2, lty=c(1), bty="n");}



# title.prefix <- "Two-parameter (standard) model fit for";

# num.conditions <- length(condition);

# #fm <- lm(data ~ model);


# # below just fits a standard model

# fm <- lm(data ~ model);

# print(summary(fm));

# fitted <- fm$fitted.values;


# conds <- as.character(condition);


# # Plot the data first

# minpoint <- min(data,fitted); maxpoint <- max(data,fitted);

# ymax <- 100*round((maxpoint/100)+0.5);

# ymin <- 100*round((minpoint/100)-0.5);

# #ymin <- 0;

# plot(data,
#      main = paste(title.prefix, exp.name), ylim=c(ymin,ymax), type="b",
#      lwd=2, lty=2, pch=21, xlab="Condition", ylab="Milliseconds",
#      axes=FALSE, frame.plot=TRUE
#     );

# # Add X axis with condition labels

# axis(side=1,
#      labels=conds,
#     at=seq(1,length(conds)));


# # Add Y-axis in standard way
     
# axis(side=2);


# # Add fitted model line

# lines(fitted,
#       type="b", pch=19, lwd=2, lty=1);

# # Add the legend

# legend(1,ymax,
#        c("data","model"), lwd=2, lty=c(2,1), bty="n");


# # # bar graph

# # vals <- rbind(fitted,data);

# # barplot(vals,
# # 	main = paste(title.prefix, exp.name), beside=TRUE,
# # 	col=c("gray30","gray60"), xpd=FALSE, ylim=c(ymin,ymax),
# # 	legend.text=TRUE, xlab="Condition", ylab="Milliseconds", axes=TRUE,
# # 	axisnames=TRUE);

dev.off();

}



