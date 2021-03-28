
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
# discretizeCtsDTMC is a set of tools for
#   an analysis of credit-card and HELOC balances.
#   It is part of the code base to accompany
#   the manuscript "Consumer Credit Usage in Canada
#   during the Coronavirus Pandemic"
#   by Ho, Morin, Paarsch and Huynh
#   in the Canadian Journal of Economics, 2021
#
# Dependencies:
#   data.table package
#
#
##################################################



#' Discretize a Continuous-state Discrete-time Markov Chain
#'
#' \code{discretizeCtsDTMC} creates a discrete approximation to a Markov
#' process defined on a continuous state space in discrete time.
#' Once the state space is discretized, \code{discretizeCtsDTMC} provides tools
#' to estimate the transition matrices and analyze the Markov process.
#'
#' @note This is part of an R package named interCross
#' It is used to conduct intervention analysis using the cross section of a wide panel.
#'
#' @seealso \code{multinom} function in \code{nnet} package for estimating the
#' transition matrices.
#' \code{DTMCPack} and \code{markovchain} for analyzing the discrete-time Markov
#' model once the continuous state space is discretized.
#'
#' @docType package
#' @name aaa-discretizeCtsDTMC
NULL


##################################################
# Function Definitions
##################################################


#' Find Points of Discontinuity in the CDF
#'
#' \code{find_atoms} finds points of discontinuity in the CDF of a
#' continuous random variable.
#'
#' @param x a numeric vector of observations from a continuous random
#' variable with discontinuities in the distribution function.
#' @param min_atom a numeric scalar on the unit interval which is the minimum
#' propability density to detect a discontinuity in the CDF of x.
#' @examples
#' find_atoms(x = c(rep(3,10), seq(1, 100), rep(26, 10)))
#' find_atoms(x = c(rep(3,10), seq(1, 100), rep(26, 3)))
#' find_atoms(x = c(rep(3,10), seq(1, 100), rep(26, 3)), min_atom = 0.025)
#' @return a numeric vector of points in the sample space at which there are
#' discontinuities in the distribution function, which are sometimes referred to
#' as "atoms".
#'
find_atoms <- function(x, min_atom = 0.05) {

  x_tab <- table(x)

  atoms <- as.numeric(names(x_tab)[x_tab/length(x) >= min_atom])

  return(atoms)
}


#' Divide a Continuous State Space into Intervals
#'
#' \code{state_breaks} calculates a vector of thresholds for allocating
#' elements of a continuous state space to a discrete state space
#'
#' @param x a numeric vector of observations from a continuous random
#' variable with discontinuities in the distribution function.
#' @param num_breaks is an integer that captures the number of break points
#' to use when dividing the support of \code{x} into intervals.
#' @examples
#' state_breaks(x = seq(-5,10), num_breaks = 4)
#'
#' @return a numeric vector of thresholds for allocating elements of the
#' continuous state space to a discrete state space.
#'
state_breaks <- function(x, num_breaks) {

  # Just like for histograms, the simplest is to set evenly spaced breaks.
  # breaks <- seq(min(x), max(x), length.out = num_breaks)
  # This leaves endpoints empty.

  # Set step size.
  step <- (max(x) - min(x))/(num_breaks + 1)
  breaks <- seq(min(x) + 0.5*step, max(x) - 0.5*step, by = step)


  # To be modified:
  # This function is currently not used in COVID_CJE_Cards or COVID_CJE_HELOCs.

  return(breaks)
}


#' Discretize a Variable Defined on a Continuous State Space
#'
#' \code{cut_states} transforms a variable defined on a continuous state space
#' into a discrete variable.
#'
#' @param x_cts a numeric vector of observations from a continuous random
#' variable with discontinuities in the distribution function.
#' @param breaks a numeric vector of thresholds for allocating elements of the
#' continuous state space to discrete state space.
#' @param labels a character vector of labes for the discrete states.
#'
#' @return a categorical variable with states for each variable that
#' correspond to elements in the continuous state space.
#'
cut_states <- function(x_cts, breaks, labels) {

  if (is.null(labels)) {
    labels <- seq(length(breaks) + 1)
  }

  x_disc <- cut(x_cts,
                breaks = c(-1, breaks, Inf),
                labels = labels)

  return(x_disc)
}


#' Reshape Data for Estimation of Transition Matrices.
#'
#' \code{reshape_markov_data} reshapes data from a discrete-state,
#' discrete-time Markov process and organizes it into a form suitable to
#' estimate transition matrices .
#'
#' @param dt a \code{data.table} object with specific columns
#' \code{x_disc}, \code{id} and \code{time}.
#' It must be sorted by \code{id} then \code{time} to ensure the
#' consecutive listing of observations for each individual.
#' @param x_disc a numeric vector of observations from a discrete random variable.
#' If x is a matrix, it is assumed that the first two columns are the id and the time stamp.
#' @param time a vector of time stamps that correspond to the observations in \code{x}.
#' @param id a vector of labels to identify different individuals in the population.
#' @param time_unit a string to identify the unit of time between consecutive
#' observations. Can be "month" or "integer".
#' @param n_lags an integer number of lags to define the order of the Markov process.
#' for each column of the transition matrices (default is \code{FALSE}).
#'
#' @return x_mat a matrix of data for estimation of transition matrices.
#' It will have 4 columns: the id, the time stamp, the observations and a boolean
#' variable to indicate valid observations for estimation.
#' It will be reordered, first by id, then time.
#'
#'
# reshape_markov_data <- function(x, time, time_unit, id, n_lags) {
reshape_markov_data <- function(dt, time_unit, n_lags) {


  # Data should already be ordered.
  if (is.unsorted(dt[, id])) {
    stop('Observations are not sorted. Sort data.table by id and time. ')
  }

  # Lag the data.
  if (n_lags > 1) {
    stop('Higher lag orders not yet implemented. Try again later.')
  }
  # Lag the data.
  dt[, x_disc_lag := shift(x_disc)]
  dt[, id_lag := shift(id)]
  dt[, time_lag := shift(time)]


  # Include only consecutive observations.
  # This allows for the possibiliy that some observations might be skipped.
  if (time_unit == 'month') {
    dt[, one_lag_only := as.numeric(time - time_lag) < 32]
  } else if (time_unit == 'integer') {
    dt[, one_lag_only := time_lag == time - 1]
  } else {
    stop('Time unit not a compatible format.')
  }

  # Complete the selection of the data.
  dt[, valid_obsn := one_lag_only & (id == id_lag) &
       !is.na(id_lag) & !is.na(x_disc) & !is.na(x_disc_lag)]



  # Modifies data table: no return value.
  return(NULL)
}


#' Estimate Transition Matrices
#'
#' \code{est_trans_mat_single} estimates a single transition matrix from a
#' discrete-state, discrete-time Markov process.
#'
#' @param dt a \code{data.table} object with specific columns
#' \code{x_disc}, \code{id}, \code{time} and \code{sel_obsns_trans}.
#' It must be sorted by \code{id} then \code{time} to ensure the
#' consecutive listing of observations for each individual.
#' @param x_disc a numeric vector of observations from a discrete random variable.
#' If x is a matrix, it is assumed that the first two columns are the id and the time stamp.
#' @param time a vector of time stamps that correspond to the observations in \code{x}.
#' @param id a vector of labels to identify different individuals in the population.
#' @return A numeric matrix of transition prbabilities in the columns.
est_trans_mat_single <- function(dt = tu) {

  if (!('sel_obsns_trans' %in% colnames(dt))) {
    warning('No selection indicator supplied. Using all observations. ')
    dt[, sel_obsns_trans == TRUE]
  }

  trans_freq <- table(tu[sel_obsns_trans == TRUE, c('x_disc', 'x_disc_lag')])
  trans_mat <- prop.table(trans_freq, 2)

  return(trans_mat)
}


#' Estimate Transition Matrices
#'
#' \code{est_trans_mats} estimates transition matrices from a discrete-state,
#' discrete-time Markov process.
#'
#' @param x a numeric vector of observations from a discrete random variable.
#' @param time a vector of time stamps that correspond to the observations in \code{x}.
#' @param id a vector of labels to identify different individuals in the population.
#' @param n_lags an integer number of lags to define the order of the Markov process.
#' @param Hessian an indicator to specify whether the Hessian matrices are returned
#' for each column of the transition matrices (default is \code{FALSE}).
#'
#' @return trans_mats an array of transition matrices for the Markov process.
#'
est_trans_mats <- function(x, time, id, n_lags, Hessian = FALSE) {

  fmla <- NULL
  fn_of_x_etc <- NULL

  multinom_out <- nnet::multinom(formula = fmla, data = fn_of_x_etc)
  trans_mats <- multinom_out$whatever

  return(trans_mats)
}


#' Forecast a Probability Distribution
#'
#'\code{forecast_distn} calculates a forecast of a probability distribution
#'for a population governed by a discrete-state, discrete-time Markov process.
#'
#' @param trans_mats an array of transition matrices for the Markov process.
#' @param init_probs a numeric probability vector that defines the initial
#' proportions of the population in each state.
#' @param n_ahead an integer number of lags that defines the order of the
#' Markov process.
#'
#' @return a \code{n_ahead}-row numeric matrix of probability vectors that
#' define the forecasted proportion of the population in each state at each time.
#'
forecast_distn <- function(trans_mats, init_probs, n_ahead) {

  markov_thingy <- markovchain::conditionalDistribution(mcWeather, "sunny")
  Other_markov_thingy <- DTMCPack::MultDTMC(nchains, tmat, io, n)

  out_probs <- NULL

  return(out_probs)
}




#' Compute a Time Series of Probability Vectors.
#'
#' \code{prob_series} calculates a matrix with a series of probability
#' vectors in the rows, with one rows for each time stamp in a data frame.
#'
#' @param dt is a \code{data.table}
#' @param date_list is a list of dates or time index of integers.
#'
#' @return a matrix with a series of probability
#' vectors in the rows, with one rows for each time stamp in a data frame.
#'
#'
prob_series <- function(dt, date_list = NULL) {


  # If date_list missing, set equal to all time stamps.
  if(is.null(date_list)) {
    date_list <- unique(dt[, time])
  }
  num_dates <- length(date_list)

  # Initialize matrix for forecasts.
  x_labels <- levels(dt[, x_disc])
  num_groups <- length(x_labels)
  observed_probs <- data.frame(matrix(0, nrow = num_dates,
                                      ncol = num_groups))
  rownames(observed_probs) <- date_list
  colnames(observed_probs) <- x_labels

  for (date_num in 1:num_dates) {

    # Select observations for this month.
    sel_date <- date_list[date_num]
    # dt[, sel_obsns_mo := sample_sel & time == as.Date(sel_date)]
    dt[, sel_obsns_mo := sel_probs & time == as.Date(sel_date)]


    # Obtain the actual histogram for this month.
    bal_freq_mo <- table(dt[sel_obsns_mo == TRUE, x_disc])
    bal_probs_mo <- bal_freq_mo/sum(bal_freq_mo)
    p_hat <- as.matrix(bal_probs_mo, nrow = num_groups, ncol = 1)

    # Record the activity for each month.
    observed_probs[sel_date, ] <- p_hat

  }

  return(observed_probs)
}



#' Compute a Time Series of Probability Vectors.
#'
#' \code{forecast_k_probs} calculates a matrix with a series of probability
#' vectors in the rows, with one rows for each time stamp in a data frame.
#'
#' @param start_probs is a probability vector from which the forecasts will satrt.
#' @param date_list is a list of dates or time index of integers.
#'
#' @return a matrix with a series of forecasted probability
#' vectors in the rows, with one row for each time stamp in a data frame.
#' Each forecast is a k-step-ahead forecast starting from the probability
#' vector on the first date for k from 1 to \code{num_steps}.
#'
#'
forecast_k_probs <- function(start_probs, P_hat, num_steps,
                           date_list = NULL,
                           mat_num_list = NULL #,
                           # cov_cat_list = NULL
                           ) {

  # If date_list missing, set number of forecasts.
  if(is.null(date_list)) {
    date_list <- seq(num_steps)
  }
  num_dates <- length(date_list)

  # Initialize matrix for forecasts.
  x_labels <- names(start_probs)
  num_groups <- length(x_labels)
  forecast_probs <- data.frame(matrix(0, nrow = num_dates,
                                      ncol = num_groups))
  rownames(forecast_probs) <- date_list
  colnames(forecast_probs) <- x_labels


  # Initialize probability vector with first start_probs.
  p_tilde <- as.matrix(as.numeric(start_probs, nrow = num_groups, ncol = 1))
  forecast_probs[1, ] <- p_tilde
  for (date_num in 2:length(date_list)) {


    # Select index of relevant transition matrix, if variable over time.
    if (length(dim(P_hat)) == 3) {
      mat_num <- mat_num_list[date_num]
      P_hat_sel <- P_hat[, , mat_num]
    } else {
      mat_num <- NA
      P_hat_sel <- P_hat
      if(length(mat_num_list) > 1) {
        warning('Vector of matrix numbers provided but P_hat is a single matrix.')
      }
    }

    # Advance prediction one more unit.
    # Calculate for both fixed-matrix and seasonal model.
    p_tilde <- P_hat_sel %*% p_tilde

    # Reord the forecast for each time period.
    forecast_probs[date_num, ] <- p_tilde

  }


  return(forecast_probs)
}


#' Kullback-Leibler Tests for Divergence between Two Sets of Distributions
#'
#'\code{KLD_step} calculates the Kullback-Leibler divergence statistic
#' to forecast accuracy of k-step-ahead forecasts.
#'
#' @param forecast_probs a matrix with a series of forecasted probability
#' vectors in the rows, with one row for each time stamp in a data frame.
#' @param observed_probs a matrix with a series of probability
#' vectors in the rows, with one rows for each time stamp in a data frame.
#' @param num_obs a scalar or vector integer number of sample sizes,
#' If it is a scalar, it is assumed that the pane is balanced, otherwise,
#' a vector of sample sizes should be provided for each time stamp.
#'
#' @return a data frame of KLD statistics and p-values.
#'
KLD_forecast_test <- function(forecast_probs, observed_probs, num_obs) {

  date_list <- rownames(forecast_probs)
  num_groups <- ncol(forecast_probs)

  if (length(num_obs) == 1) {
    num_obs <- rep(num_obs, length(date_list))
  }

  # Store KLD statistics from in-sample period.
  KL_stats <- data.frame(time = date_list,
                         KLD_stat = -7,
                         p_value = -7)

  for (date_num in 1:length(date_list)) {

    # Obtain the observed probability vector for this month.
    p_hat <- observed_probs[date_num, ]

    # Obtain the forecast probability vector for this month.
    p_tilde <- forecast_probs[date_num, ]

    # Calculate KL statistic for each date.
    KLD_stat <- 2*num_obs[date_num]*sum(p_tilde * log(p_tilde/p_hat))
    KL_stats[date_num, 'KLD_stat'] <- KLD_stat

  }

  # Calculate p-values vs. Chi-squared distribution.
  KL_stats[, 'p_value'] <- 1 - pchisq(q = KL_stats[, 'KLD_stat'],
                                          df = num_groups - 1)

  return(KL_stats)
}


#' Goodness of Fit Tests in Sample
#'
#'\code{KLD_gof_1step} calculates the Kullback-Leibler divergence statistic
#' to measure the goodness of fit of the 1-step-ahead forecasts with a set of
#' transition matrices.
#'
#' @param dt is a \code{data.table}
#' @param P_hat an array or matrix of transition matrices.
#' @param date_list is a list of dates or time index of integers.
#' @param mat_num_list is a list of integers representing the index number of
#' the third dimension of \code{P_hat}, if \code{P_hat} is an array,
#' for selecting the relevant transition matrix for each time in \code{date_list}.
#'
#' @return a data frame of KLD statistics and p-values.
#'
#' @note: Functionality for different date types not implemented.
#'
KLD_gof_1step <- function(dt, P_hat, date_list, mat_num_list) {

  sel_date <- date_list[2] # Fix it later.
  # sel_date <- start_time

  # Prime probability vector with histogram from last month.
  bal_probs_start_mo <- table(dt[sample_sel == TRUE &
                                   time == as.Date(sel_date),
                                 c('x_disc')])
  num_groups <- dim(P_hat)[1]
  bal_probs_start_mo <- bal_probs_start_mo/sum(bal_probs_start_mo)
  p_hat <- matrix(bal_probs_start_mo, nrow = num_groups, ncol = 1)
  # Note that for one-step-ahead forecasts we are forecasting from
  # the actual distribution from last period.

  # Store KLD statistics from in-sample period.
  KL_stats_gof <- data.frame(time = date_list,
                             KLD_stat = -7,
                             p_value = -7)

  for (date_num in 3:length(date_list)) {

    # Select observations for this month.
    sel_date <- date_list[date_num]
    dt[, sel_obsns_mo := sample_sel & time == as.Date(sel_date)]

    # Select index of relevant transition matrix, if variable over time.
    if (length(dim(P_hat)) == 3) {
      mat_num <- mat_num_list[date_num]
      P_hat_sel <- P_hat[, , mat_num]
    } else {
      mat_num <- NA
      P_hat_sel <- P_hat
      if(length(mat_num_list) > 1) {
        warning('Vector of matrix numbers provided but P_hat is a single matrix.')
      }
    }


    # Prime probability vector with histogram from last month.
    p_tilde <- p_hat

    # Obtain the actual histogram for this month.
    bal_freq_mo <- table(dt[sel_obsns_mo == TRUE, c('x_disc')])
    bal_probs_mo <- bal_freq_mo/sum(bal_freq_mo)
    p_hat <- as.matrix(bal_probs_mo, nrow = num_groups, ncol = 1)
    # Could pull this from output using the prob_series function.

    # Advance prediction one more unit.
    # Calculate for either fixed-matrix or seasonal model.
    p_tilde <- P_hat_sel %*% p_tilde

    # Calculate KL statistic for each date.
    KLD_stat <- 2*sum(bal_freq_mo)*sum(p_tilde * log(p_tilde/p_hat))
    KL_stats_gof[date_num, 'KLD_stat'] <- KLD_stat


  }

  # Calculate p-values vs. Chi-squared distribution.
  KL_stats_gof[, 'p_value'] <- 1 - pchisq(q = KL_stats_gof[, 'KLD_stat'],
                                               df = num_groups - 1)

  return(KL_stats_gof)
}

##################################################
# End
##################################################


