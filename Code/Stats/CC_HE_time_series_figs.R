
##################################################
#
# Analysis of Credit Card Balances
#
# Lealand Morin, Ph.D.
# Assistant Professor
# Department of Economics
# College of Business Administration
# University of Central Florida
#
# March 28, 2021
#
##################################################
#
# CC_HE_time_series_figs.R creates time series plots of
#   credit-card and HELOC balances over the
#   sample period.
#   It is part of the code base to accompany
#   the manuscript "Consumer Credit Usage in Canada
#   during the Coronavirus Pandemic"
#   by Ho, Morin, Paarsch and Huynh
#   in the Canadian Journal of Economics, 2021
#
# Dependencies:
#   Reads datasets tu_BC_time.csv and tu_HELOC_time.csv
#   for the nation-wide sample
#   and tu_AB_BC_time.csv and tu_AB_HELOC_time.csv
#   for the Alberta sample.
#
#
##################################################


# Clear workspace, if running interactively.
# rm(list=ls(all=TRUE))

# Set working directory, if other than Credit_COVID19_Canada.
# wd_path <- '/path/to/Credit_COVID19_Canada'
# setwd(wd_path)


# Set data directory.
data_dir <- 'Data'


# Set directory for figures.
fig_dir <- 'Figures'

# Set file extension for figures.
fig_ext <- 'eps'



##################################################
# Nation-Wide Sample
##################################################



#--------------------------------------------------
# Load the data
#--------------------------------------------------


# Credit Cards
in_file_name <- sprintf('%s/tu_agg_bc.csv', data_dir)
BC_bal <- read.csv(file = in_file_name)

BC_bal[, 'Run_Date'] <- as.Date(BC_bal[, 'Run_Date'])
BC_bal <- BC_bal[order(BC_bal[, 'Run_Date']), ]

colnames(BC_bal)
summary(BC_bal)

# HELOCs
in_file_name <- sprintf('%s/tu_agg_heloc.csv', data_dir)
HE_bal <- read.csv(file = in_file_name)

HE_bal[, 'Run_Date'] <- as.Date(HE_bal[, 'Run_Date'])
HE_bal <- HE_bal[order(HE_bal[, 'Run_Date']), ]

colnames(HE_bal)
summary(HE_bal)


#--------------------------------------------------
# Plot Figure for Credit Cards
#--------------------------------------------------

# Set file tag to differentiate from other types of loans.
file_tag <- 'CC'

fig_file_name <- sprintf('%s_time_series.%s',
                         file_tag,
                         fig_ext)
out_file_name <- sprintf('%s/%s', fig_dir, fig_file_name)

setEPS()
postscript(out_file_name)

plot(BC_bal[, 'Run_Date'],
     BC_bal[, 'bal_avg'],
     xlab = '',
     ylab = 'CAD',
     col = 'blue', 
     type = 'l',
     lwd = 2,
     ylim = c(0, 5000)
)
lines(BC_bal[, 'Run_Date'],
      BC_bal[, 'bal_p25'],
      lty = 'dashed',
      lwd = 2,
)
lines(BC_bal[, 'Run_Date'],
      BC_bal[, 'bal_p50'],
      lty = 'dotted',
      lwd = 2,
)
lines(BC_bal[, 'Run_Date'],
      BC_bal[, 'bal_p75'],
      lty = 'dotdash',
      lwd = 2,
)
legend('bottom',
       legend = c('Mean', 'P25', 'P50', 'P75'),
       col = c('blue', 'black', 'black', 'black'),
       lty = c('solid', 'dashed', 'dotted', 'dotdash'),
       xpd = TRUE)

dev.off()




#--------------------------------------------------
# Plot Figure for HELOCs
#--------------------------------------------------

# Set file tag to differentiate from other types of loans.
file_tag <- 'HE'

fig_file_name <- sprintf('%s_time_series.%s',
                         file_tag,
                         fig_ext)
out_file_name <- sprintf('%s/%s', fig_dir, fig_file_name)

setEPS()
postscript(out_file_name)

plot(HE_bal[, 'Run_Date'],
     HE_bal[, 'bal_avg'],
     xlab = '',
     ylab = 'CAD',
     col = 'blue', 
     type = 'l',
     lwd = 2,
     ylim = c(0, 80000)
)
lines(HE_bal[, 'Run_Date'],
      HE_bal[, 'bal_p25'],
      lty = 'dashed',
      lwd = 2,
)
lines(HE_bal[, 'Run_Date'],
      HE_bal[, 'bal_p50'],
      lty = 'dotted',
      lwd = 2,
)
lines(HE_bal[, 'Run_Date'],
      HE_bal[, 'bal_p75'],
      lty = 'dotdash',
      lwd = 2,
)
legend('bottom',
       legend = c('Mean', 'P25', 'P50', 'P75'),
       col = c('blue', 'black', 'black', 'black'),
       lty = c('solid', 'dashed', 'dotted', 'dotdash'),
       xpd = TRUE)

dev.off()







##################################################
# Alberta Sample
##################################################



#--------------------------------------------------
# Load the data
#--------------------------------------------------


# Credit Cards
in_file_name <- sprintf('%s/tu_agg_AB_bc.csv', data_dir)
BC_bal <- read.csv(file = in_file_name)

BC_bal[, 'Run_Date'] <- as.Date(BC_bal[, 'Run_Date'])
BC_bal <- BC_bal[order(BC_bal[, 'Run_Date']), ]

colnames(BC_bal)
summary(BC_bal)

# HELOCs
in_file_name <- sprintf('%s/tu_agg_AB_heloc.csv', data_dir)
HE_bal <- read.csv(file = in_file_name)

HE_bal[, 'Run_Date'] <- as.Date(HE_bal[, 'Run_Date'])
HE_bal <- HE_bal[order(HE_bal[, 'Run_Date']), ]

colnames(HE_bal)
summary(HE_bal)


#--------------------------------------------------
# Plot Figure for Credit Cards
#--------------------------------------------------

# Set file tag to differentiate from other types of loans.
file_tag <- 'AB_CC'

fig_file_name <- sprintf('%s_time_series.%s',
                         file_tag,
                         fig_ext)
out_file_name <- sprintf('%s/%s', fig_dir, fig_file_name)

setEPS()
postscript(out_file_name)

plot(BC_bal[, 'Run_Date'],
     BC_bal[, 'bal_avg'],
     xlab = '',
     ylab = 'CAD',
     col = 'blue', 
     type = 'l',
     lwd = 2,
     ylim = c(0, 5000)
)
lines(BC_bal[, 'Run_Date'],
      BC_bal[, 'bal_p25'],
      lty = 'dashed',
      lwd = 2,
)
lines(BC_bal[, 'Run_Date'],
      BC_bal[, 'bal_p50'],
      lty = 'dotted',
      lwd = 2,
)
lines(BC_bal[, 'Run_Date'],
      BC_bal[, 'bal_p75'],
      lty = 'dotdash',
      lwd = 2,
)
legend('bottom',
       legend = c('Mean', 'P25', 'P50', 'P75'),
       col = c('blue', 'black', 'black', 'black'),
       lty = c('solid', 'dashed', 'dotted', 'dotdash'),
       xpd = TRUE)

dev.off()




#--------------------------------------------------
# Plot Figure for HELOCs
#--------------------------------------------------

# Set file tag to differentiate from other types of loans.
file_tag <- 'AB_HE'

fig_file_name <- sprintf('%s_time_series.%s',
                         file_tag,
                         fig_ext)
out_file_name <- sprintf('%s/%s', fig_dir, fig_file_name)

setEPS()
postscript(out_file_name)

plot(HE_bal[, 'Run_Date'],
     HE_bal[, 'bal_avg'],
     xlab = '',
     ylab = 'CAD',
     col = 'blue', 
     type = 'l',
     lwd = 2,
     ylim = c(0, 80000)
)
lines(HE_bal[, 'Run_Date'],
      HE_bal[, 'bal_p25'],
      lty = 'dashed',
      lwd = 2,
)
lines(HE_bal[, 'Run_Date'],
      HE_bal[, 'bal_p50'],
      lty = 'dotted',
      lwd = 2,
)
lines(HE_bal[, 'Run_Date'],
      HE_bal[, 'bal_p75'],
      lty = 'dotdash',
      lwd = 2,
)
legend('bottom',
       legend = c('Mean', 'P25', 'P50', 'P75'),
       col = c('blue', 'black', 'black', 'black'),
       lty = c('solid', 'dashed', 'dotted', 'dotdash'),
       xpd = TRUE)

dev.off()





##################################################
# End
##################################################

