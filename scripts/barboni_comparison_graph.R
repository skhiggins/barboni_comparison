#INFO ---------------------------------------------------------------------
# File name: 	          barboni_comparison_graph.R	      
# Creation date:        07/24/2021
# Last modified date:   
# Author:          		  Sean Higgins
# Modifications:        
# Files used:           barboni_comparison.csv
# Files created:        barboni_comparison.eps or barboni_comparison.jpg
#	                      
# Purpose:              Create comparison figure for discussion of 
#                       Barboni Field Pande
#--------------------------------------------------------------------------

##############
## PACKAGES ##
##############
library(tidyverse) 
library(metafor) # for forest() command to make forest plot
library(colorspace) # for black and white version
library(magrittr)
library(here)

##########
## DATA ##
##########
outcomes <- read_csv(here::here("proc", "barboni_comparison.csv"))

# Percent change in income
outcomes %<>% mutate(
  TE_percent = if_else(
    !is.na(te_levels), 100*te_levels/control_mean,
    100*(exp(te_logs) - 1) # logs
  ),
  SE_percent = if_else(
    !is.na(se_levels), 100*se_levels/control_mean,
    100*(exp(se_logs) - 1) # logs
  )
)

# Confidence intervals, colors, 
outcomes %<>% mutate(
  low = TE_percent - 1.96*SE_percent,
  high = TE_percent + 1.96*SE_percent,
  p = 2*pt(-abs(TE_percent/SE_percent), df = 2000), # 2000 because don't have d.f. of each study
  color = if_else(
    auth == "barboni21", "darkorange3",
    if_else(
      p <= 0.05, "black", 
      "gray40"
    )
  ),
  pch = if_else(
    auth == "barboni21", 15, # square
    if_else(
      p >= 0.10, 1, # hollow circle
      19 # filled circle
    )
  )
)

# Drop Augsburg because they did individual level randomization
outcomes %<>% filter(auth != "augsburg15")

###########
## GRAPH ##
###########
eps <- 1 # 1 to create .eps of graph
jpg <- 1
c.lo <- -8
c.hi <- 24

# Sort it
outcomes %<>% arrange(TE_percent)

if (eps==1) {
  setEPS() # to save the graph as an .eps
  postscript(here::here("figures", "barboni_comparison.eps"),
    width = 16, height = 8.233333
  )
}

if (jpg==1) {
  jpeg(file=here::here("figures", "barboni_comparison.jpg"),
    width = 1600, height = 823
  )
}
  
forest(
  outcomes$TE_percent, # observed effect sizes
  ci.lb = outcomes$low, # lower bound confidence interval
  ci.ub = outcomes$high, # upper bound confidence interval
  annotate = FALSE, # try changing to false
  clim = c(c.lo, c.hi), efac = c(1,2,1),
  ylim = c(1,11),
  xlim = c(c.lo - 29, c.hi),
  alim = c(c.lo, c.hi),
  xlab = "Percent Change in Income",
  slab = NA,
  ilab = as.data.frame(select(outcomes, authors_etal, intervention, country, outcome)),
  ilab.xpos = c(c.lo - 29, c.lo - 21, c.lo - 12.5, c.lo - 8),
  ilab.pos = c(4,4,4,4), 
  pch = outcomes$pch, psize = 1, col = outcomes$color,
  lwd = 1,
  cex = 1.1,
  digits = 0
)

# Add column headers to figure
# par(font=2) # bold
vertspace <- 1.5
text(c.lo - 29,  vertspace + nrow(outcomes), "Study", pos=4, cex = 1.1)
text(c.lo - 21,  vertspace + nrow(outcomes), "Intervention", pos=4, cex = 1.1)
text(c.lo - 12.5,  vertspace + nrow(outcomes), "Country", pos=4, cex = 1.1)
text(c.lo - 8, vertspace + nrow(outcomes), "Outcome", pos=4, cex = 1.1)
text(c.lo - 0.5, vertspace + nrow(outcomes), "Effect Size", pos=4, cex = 1.1)

#Save eps or jpg
if (eps==1 | jpg==1) { dev.off() }
