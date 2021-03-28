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
# COVID_CJE_Cards is an analysis of credit-card balances.
#   It is part of the code base to accompany
#   the manuscript "Consumer Credit Usage in Canada
#   during the Coronavirus Pandemic"
#   by Ho, Morin, Paarsch and Huynh
#   in the Canadian Journal of Economics, 2021
#
# Dependencies:
#   Reads dataset tu_sample_bc.csv
#   Executes script COVID_CJE_Cards_prelim.R for preliminary analysis
#   Executes script COVID_CJE_Cards_estim.R for estimation of main model
#   Reads discCtsDTMC.R for functions that estimate Discrete-Time Markov Chain
#     models by discretizing contiuous variables across a wide cross section.
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

# Set source directory for modelling toolkit.
lib_dir <- 'Code'
src_file <- sprintf('%s/discCtsDTMC.R', lib_dir)
source(src_file)

# Set file extension for figures.
fig_ext <- 'eps'
fig_dir <- 'Figures'
tab_dir <- 'Tables'

# Set file tag to differentiate from other types of loans.
file_tag <- 'CC'

# Set labels to insert text into figures and other output.
loan_label <- 'Credit Card'
loan_tag <- 'Card'



##################################################
# Load Packages
##################################################

# Load data.table for better notation for subsetting.
library(data.table)

# Load xtable to generate LaTeX tables.
library(xtable)


##################################################
# Load Data
##################################################

in_file_name <- sprintf('%s/tu_sample_bc.csv', data_dir)
tu <- fread(in_file_name)



##################################################
# Data Preparation
##################################################


#--------------------------------------------------
# Define variables to match those expected in
# discCtsDTMC.R
#--------------------------------------------------

# Data are monthly from '2017-01-01' to '2020-06-01' (42 months).
tu[, time := as.Date(Run_Date)]


# Unique identifier for consumers.
tu[, id := tu_consumer_id]


# Define continuous variable of interest.
tu[, x_cts := bc_bal]

# Need to order by TU_Consumer_ID and Run_date:
tu <- tu[order(id, time)]


# Create labels for date range.
min_time <- tu[sample_sel == TRUE, min(time)]
max_time <- tu[sample_sel == TRUE, max(time)]


#--------------------------------------------------
# Cut Credit Card loan balances into categories
#--------------------------------------------------

# Only one atom at zero.
atom_list <- find_atoms(x = tu[sample_sel == TRUE, x_cts], min_atom = 0.05)
atom_list


# Define breaks to assign balances into categories.
x_breaks <- c(seq(0, 1500, by = 250),
              seq(2000, 6000, by = 500),
              seq(7000, 10000, by = 1000),
              seq(12000, 20000, by = 2000),
              seq(25000, 30000, by = 5000),
              seq(40000, 41000, by = 10000))
# Define matching labels.
x_labels <- sprintf('%s-%s', c('0', x_breaks), c(x_breaks, '+'))
x_labels[1] <- '0'
x_labels[length(x_labels)] <- sprintf('%d+', x_breaks[length(x_breaks)])
x_labels <- gsub('0000', '0K', x_labels)
x_labels <- gsub('000', 'K', x_labels)
x_labels <- gsub('500', '.5K', x_labels)
x_labels <- gsub('1K0', '10K', x_labels)

# Simpler labels for figures.
x_labels <- c(sprintf('%s', c(x_breaks/1000)), '>40')

num_groups <- length(x_labels)

# Cut observations into categories.
tu[, x_disc := cut_states(x_cts, x_breaks, x_labels)]



#--------------------------------------------------
# Reshape Data for Calculating Transitions
#--------------------------------------------------


reshape_markov_data(dt = tu, time_unit = 'month', n_lags = 1)


#--------------------------------------------------
# Define Sample
#--------------------------------------------------


tu[, sample_sel :=
     deceased == 'N' &
     !is.na(N_bc) &
     N_bc != 0 &
     !is.na(x_cts) &
     valid_obsn]

# Define sample periods.
tu[, pre_crisis := as.numeric(time - as.Date('2020-02-01')) < 0]


# Fix entire pre-sample period.
tu[, sel_obsns := sample_sel & pre_crisis]



#--------------------------------------------------
# Create date labels for output
#--------------------------------------------------

# Create a variable for month.
tu[, month := month(time)]


# Create variable for statement month label (off by one).
tu[, stmt_month := 'NA']
tu[month(time) > 1, stmt_month := month.name[month(time) - 1]]
tu[month(time) == 1, stmt_month := month.name[12]]

tu[, stmt_year := as.integer(year(time))]
tu[month(time) == 1, stmt_year := year(time) - 1]

tu[, stmt_date := sprintf('%s, %d', stmt_month, stmt_year)]



##################################################
# Preliminary Analysis
##################################################

src_file <- sprintf('%s/COVID_CJE_Cards_prelim.R', lib_dir)
source(src_file)


##################################################
# Estimation of Main Model
##################################################

src_file <- sprintf('%s/COVID_CJE_Cards_estim.R', lib_dir)
source(src_file)


##################################################
# End
##################################################
