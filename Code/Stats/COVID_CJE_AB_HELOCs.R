##################################################
#
# Analysis of HELOC Balances in Alberta
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
# COVID_CJE_AB_HELOCs is an analysis of HELOC balances.
#   It is part of the code base to accompany
#   the manuscript "Consumer Credit Usage in Canada
#   during the Coronavirus Pandemic"
#   by Ho, Morin, Paarsch and Huynh
#   in the Canadian Journal of Economics, 2021
#
# Dependencies:
#   Reads dataset tu_sample_AB_heloc.csv
#   Executes script COVID_CJE_HELOCs_AB_prelim.R for preliminary analysis
#   Executes script COVID_CJE_HELOCs_AB_estim.R for estimation of main model
#   Reads discCtsDTMC.R for functions that estimate Discrete-Time Markov Chain
#     models by discretizing continuous variables across a wide cross section.
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

# Set source directory for modeling toolkit.
lib_dir <- 'Code/Stats'
src_file <- sprintf('%s/discCtsDTMC.R', lib_dir)
source(src_file)


# Set file extension for figures.
fig_ext <- 'eps'
fig_dir <- 'Figures'
tab_dir <- 'Tables'

# Set file tag to differentiate from other types of loans.
file_tag <- 'AB_HE'

# Set labels to insert text into figures and other output.
loan_label <- 'HELOC Loan'
loan_tag <- 'HELOC'


# Set timing of sample and intervention.
sample_beg <- '2013-02-01'
sample_end <- '2014-01-01'
intervention_beg <- '2015-01-01'
intervention_end <- '2015-12-01'


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

in_file_name <- sprintf('%s/tu_sample_AB_heloc.csv', data_dir)
tu <- fread(in_file_name)



##################################################
# Data Preparation
##################################################


#--------------------------------------------------
# Define variables to match those expected in
# discCtsDTMC.R
#--------------------------------------------------

# Data are monthly from '2012-01-01' to '2017-01-01' (61 months).
tu[, time := as.Date(Run_Date)]


# Unique identifier for consumers.
tu[, id := tu_consumer_id]


# Define continuous variable of interest.
tu[, x_cts := heloc_bal]

# Need to order by TU_Consumer_ID and Run_date:
tu <- tu[order(id, time)]


# Create labels for date range.
min_time <- tu[sample_sel == TRUE, min(time)]
max_time <- tu[sample_sel == TRUE, max(time)]


#--------------------------------------------------
# Cut HELOC loan balances into categories
#--------------------------------------------------

# Only one atom at zero.
atom_list <- find_atoms(x = tu[sample_sel == TRUE, x_cts], min_atom = 0.05)
atom_list


# Define breaks to assign balances into categories.
x_breaks <- c(seq(0, 5000, by = 2500),
              seq(10000, 20000, by = 5000),
              seq(30000, 50000, by = 10000),
              seq(75000, 100000, by = 25000),
              seq(150000, 300000, by = 50000),
              seq(400000, 800000, by = 200000))
# Define matching labels.
x_labels <- sprintf('%.0f-%.0f', c(0, x_breaks), c(x_breaks, Inf))
x_labels[1] <- '0'
x_labels[length(x_labels)] <- sprintf('%d+', x_breaks[length(x_breaks)])
x_labels <- gsub('00000', '00K', x_labels)
x_labels <- gsub('0000', '0K', x_labels)
x_labels <- gsub('000', 'K', x_labels)
x_labels <- gsub('500', '.5K', x_labels)
x_labels <- gsub('.5KK', '500K', x_labels)

# Simpler labels for figures.
x_labels <- c(sprintf('%s', c(x_breaks/1000)), '>800')

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
     !is.na(N_heloc) &
     N_heloc != 0 &
     valid_obsn]

# Define sample periods.
# tu[, pre_crisis := as.numeric(time - as.Date('2020-02-01')) < 0]
tu[, pre_crisis := as.numeric(time - as.Date(sample_end)) <= 0 &
     as.numeric(time - as.Date(sample_beg)) >= 0]


# Fix entire pre-sample period.
tu[, sel_obsns := sample_sel & pre_crisis]


# label separate post_crisis dates.
tu[, post_crisis := as.numeric(time - as.Date(intervention_beg)) >= 0 &
     as.numeric(time - as.Date(intervention_end)) <= 0]


#--------------------------------------------------
# Create date labels for output
#--------------------------------------------------

# Create a variable for month.
tu[, month := month(time)]
table(tu[, month], useNA = 'ifany')

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

src_file <- sprintf('%s/COVID_CJE_AB_HELOCs_prelim.R', lib_dir)
source(src_file)


##################################################
# Estimation of Main Model
##################################################

src_file <- sprintf('%s/COVID_CJE_AB_HELOCs_estim.R', lib_dir)
source(src_file)


##################################################
# End
##################################################
