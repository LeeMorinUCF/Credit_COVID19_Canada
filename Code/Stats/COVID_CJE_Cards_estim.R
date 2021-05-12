
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
# COVID_CJE_Cards_estim is an analysis of credit-card balances.
#   It is part of the code base to accompany
#   the manuscript "Consumer Credit Usage in Canada
#   during the Coronavirus Pandemic"
#   by Ho, Morin, Paarsch and Huynh
#   in the Canadian Journal of Economics, 2021
#
# Dependencies:
#   Data loading and preparation in COVID_CJE_Cards.R
#
#
##################################################



##################################################
# Tables and Figures for Analysis with Histograms
##################################################


#--------------------------------------------------
# Plot deviations of 2020 months from histograms by month.
# Also plot side-by-side histograms by month, 2020 vs sample.
#--------------------------------------------------


# Fix entire pre-sample period.
tu[, sel_obsns := sample_sel & pre_crisis]

post_crisis_dates <- as.character(unique(tu[pre_crisis == FALSE, time]))


# Plot in terms of percentage deviations.
for (date_num in 1:length(post_crisis_dates)) {


  sel_date <- post_crisis_dates[date_num]
  month_num <- as.numeric(substr(sel_date, 6, 7))
  month_str <- substr(sel_date, 6, 7)

  #------------------------------------------------------------
  # Calculate pairs of histograms.
  #------------------------------------------------------------
  hist_2020_month <- table(tu[sample_sel == TRUE &
                                time == as.Date(sel_date),
                              x_disc], useNA = 'ifany')
  hist_2020_month <- hist_2020_month/sum(hist_2020_month)

  hist_sample_month <- table(tu[sel_obsns == TRUE &
                                  month == month_num,
                                x_disc], useNA = 'ifany')
  hist_sample_month <- hist_sample_month/sum(hist_sample_month)



  #------------------------------------------------------------
  # Plot side-by-side histograms by month, 2020 vs sample.
  #------------------------------------------------------------
  comp_table <- rbind(hist_sample_month, hist_2020_month)


  fig_file_name <- sprintf('%s_hist_vs_sample_month_%s.%s',
                           file_tag, month_str, fig_ext)
  out_file_name <- sprintf('%s/%s', fig_dir, fig_file_name)
  setEPS()
  postscript(out_file_name)
  barplot(comp_table,
          beside = TRUE,
          # main = c(sprintf('Histogram of %s Balance Transition Probabilities', loan_tag),
          #          'with Calculations of Limiting Distribution'),
          xlab = 'Balance Category',
          col = grey.colors(n = 2, start = 0.3, end = 0.9)
          # col = c('red', 'blue', 'green', 'yellow')
          # legend = c('Rel. Freq.', 'First Eigen.', 'Rep. Mult.')
  )
  dev.off()


  #------------------------------------------------------------
  # Plot deviations of 2020 months from histograms by month.
  #------------------------------------------------------------
  dev_pct_tab <- log(hist_2020_month/hist_sample_month) *100


  fig_file_name <- sprintf('%s_dev_pct_%s_vs_sample.%s',
                           file_tag, substr(sel_date, 1, 7), fig_ext)
  out_file_name <- sprintf('%s/%s', fig_dir, fig_file_name)


  setEPS()
  postscript(out_file_name)
  barplot(t(dev_pct_tab),
          xlab = 'Balance Category (Thousands)',
          cex.lab = 1.5,
          ylim = c(-30, 30),
          col = 'grey')
  dev.off()

}



#--------------------------------------------------
# Table of distance statistics measuring
# percent changes in histograms from
# past histograms from the in-sample period.
# Measures changes from past observations in-sample.
#--------------------------------------------------


#--------------------------------------------------
# Start from January 2020
#--------------------------------------------------


# Calculate matrix of observed probabilities with time stamps for the rows
# and category labels for columns.
source(src_file)
forecast_date_list <- c('2020-01-01', post_crisis_dates)
forecast_date_labels <- unique(tu[pre_crisis == FALSE, stmt_date])
forecast_date_labels <- c("December, 2019", forecast_date_labels)
observed_probs <- prob_series(dt = tu, date_list = forecast_date_list)


# Calculate proportions from sample.
observed_probs_test <- observed_probs*0
sample_probs <- observed_probs*0

for (date_num in 1:length(forecast_date_list)) {

  sel_date <- forecast_date_list[date_num]
  month_num <- as.numeric(substr(sel_date, 6, 7))
  month_str <- substr(sel_date, 6, 7)

  #------------------------------------------------------------
  # Calculate pairs of histograms.
  #------------------------------------------------------------
  hist_2020_month <- table(tu[sample_sel == TRUE &
                                time == as.Date(sel_date),
                              x_disc], useNA = 'ifany')
  hist_2020_month <- hist_2020_month/sum(hist_2020_month)

  hist_sample_month <- table(tu[sel_obsns == TRUE &
                                  month == month_num,
                                x_disc], useNA = 'ifany')
  hist_sample_month <- hist_sample_month/sum(hist_sample_month)

  # Record in table of proportions.
  observed_probs_test[date_num, ] <- hist_2020_month
  sample_probs[date_num, ] <- hist_sample_month

}

# Compare to test.
observed_probs_test == observed_probs

# Statistical tests for differences of distributions.
# source(src_file)
num_obs_forecast <- tu[sample_sel == TRUE &
                         time %in% as.Date(forecast_date_list),  .N,
                       by = c('time')][, N]

# Conduct tests against histograms.
KLD_sample <- KLD_forecast_test(sample_probs,
                                observed_probs, num_obs = num_obs_forecast)

# Statement month labels.
KLD_sample[, 'stmt_date'] <- forecast_date_labels


# Output results to TeX file.
out_table <- KLD_sample[, c(4, 2:3)]
colnames(out_table) <- c('Month',
                         'Distance', 'P-value')

# Output to TeX file.
out_xtable <- xtable(out_table, digits = 4, label = sprintf('tab:%s_KLD_sample', file_tag),
                     caption = sprintf('Distance from Sample Histograms (%ss)', loan_label))

tex_file_name <- sprintf('%s_KLD_vs_sample_01.tex', file_tag)
tex_file_name <- sprintf('%s/%s', tab_dir, tex_file_name)

# Print table to tex file.
cat(print(out_xtable), file = tex_file_name, append = FALSE)




##################################################
# Tables and Figures for Analysis with Forecasts
##################################################

# Calculate Transition Matrices on Selected Sample


#--------------------------------------------------
# Single transition matrix, all months together.
#--------------------------------------------------

# Build fixed transition matrix with entire build sample.
tu[, sel_obsns_trans := sel_obsns]
P_hat_fixed <- est_trans_mat_single(dt = tu)



#--------------------------------------------------
# Separate transition matrix for each month.
#--------------------------------------------------


# Reset to entire build sample.
tu[, sel_obsns := sample_sel & pre_crisis]

# Estimate and inspect series of transition matrices.
P_hat_mo <- array(-7,dim = c(num_groups, num_groups, 12))
for (month_num in 1:12) {


  tu[, sel_obsns_trans := sel_obsns & month == month_num]
  P_hat_ind_mo <- est_trans_mat_single(dt = tu)

  print(sprintf('Min element of transition matrix for %s',
                month.name[month_num]))
  print(min(P_hat_ind_mo))

  # Store in an array of transition matrices.
  P_hat_mo[, , month_num] <- P_hat_ind_mo
  # Note that this selects the data with bc_bal_grp_mo in month_num.
  # This means that it describes the transition *to* xIdisc in month_num.

}



##################################################
# Analysis of Goodness of Fit
##################################################


#--------------------------------------------------
# Plot percent changes in histograms from
# 1-step ahead forecasts in the in-sample period.
# Measures goodness of fit within the training sample.
# Calculate them for both the seasonal model and the
# model with fixed transition matrix.
#--------------------------------------------------


# Set list of dates to entire sample.
date_list <- as.character(unique(tu[, time]))
num_dates <- length(date_list)
# Add an index to indicate the relevant matrix number for each period.
mat_num_list <- as.numeric(substr(date_list, 6, 7))


# Prime the fixed transition matrix for the non-seasonal model.
P_hat_fixed_mat <- as.matrix(P_hat_fixed,
                             nrow = num_groups,
                             ncol = num_groups)

# Test with fixed matrix.
KL_stats_gof_fixed <- KLD_gof_1step(dt = tu, P_hat = P_hat_fixed_mat,
                                    date_list, mat_num_list = 1)

# Test with seasonal matrix.
KL_stats_gof_seasonal <- KLD_gof_1step(dt = tu, P_hat = P_hat_mo,
                                       date_list, mat_num_list)



# Collect both sets of results into a table.
KL_stats_gof <- cbind(KL_stats_gof_fixed, KL_stats_gof_seasonal[, 2:3])

# Statement month labels.
KL_stats_gof[, 'stmt_date'] <- unique(tu[, stmt_date])


# First two months are unobserved (fix later).
KL_stats_gof[1:2, 2:5] <- NA

KL_stats_gof



#--------------------------------------------------
# Output tables of results
# Table of In-sample Goodness of Fit Tests
# with 1-step-ahead forecasts.
#--------------------------------------------------

# Table of In-sample Goodness of Fit Tests.
out_table <- KL_stats_gof[3:37, c(2:5)]
colnames(out_table) <- c('Fixed', 'p-value',
                         'Monthly', 'p- value')

rownames(out_table) <- KL_stats_gof[3:37, 'stmt_date']

out_digits <- matrix(c(rep(1, nrow(out_table)), rep(rep(c(2, 4), each = nrow(out_table)), 2)),
                     nrow = nrow(out_table))

# Output to TeX file.
out_xtable <- xtable(out_table, digits = out_digits, label = 'tab:gof',
                     # caption = 'Goodness of Fit for Fixed vs. Monthly Transition Matrices (1-step-ahead forecasts)',
                     caption = 'Goodness of Fit of In-sample Forecasts')

tex_file_name <- sprintf('%s_KLD_GOF_in_sample.tex', file_tag)
tex_file_name <- sprintf('%s/%s', tab_dir, tex_file_name)

# Print table to tex file.
cat(print(out_xtable), file = tex_file_name, append = FALSE)



#--------------------------------------------------
# Output tables of results
# Table of Out-of-sample Divergence Tests
# with 1-step-ahead forecasts.
#--------------------------------------------------

# Table of Out-of-sample Divergence Tests.
out_table <- KL_stats_gof[37:nrow(KL_stats_gof), c(2:5)]
colnames(out_table) <- c('Fixed', 'p-value',
                         'Monthly', 'p- value')

rownames(out_table) <- KL_stats_gof[37:nrow(KL_stats_gof), 'stmt_date']

out_digits <- matrix(c(rep(1, nrow(out_table)), rep(rep(c(2, 4), each = nrow(out_table)), 2)),
                     nrow = nrow(out_table))

# Output to TeX file.
out_xtable <- xtable(out_table, digits = out_digits, label = 'tab:KLD1step',
                     # caption = 'Goodness of Fit for Fixed vs. Monthly Transition Matrices (1-step-ahead forecasts)',
                     caption = 'Divergence from Out-of-sample 1-step-ahead Forecasts')

tex_file_name <- sprintf('%s_KLD_1step_out_sample.tex', file_tag)
tex_file_name <- sprintf('%s/%s', tab_dir, tex_file_name)

# Print table to tex file.
cat(print(out_xtable), file = tex_file_name, append = FALSE)



##################################################
# Analysis of Forecasts
##################################################


#--------------------------------------------------
# Test percent changes in histograms from
# k-step ahead forecasts in the out-of-sample period.
# Measures changes from predictions out-of-sample.
# Output table of test statistics
#--------------------------------------------------



# Start from February 2020
forecast_date_list <- post_crisis_dates
forecast_date_labels <- unique(tu[pre_crisis == FALSE, stmt_date])
forecast_date_labels <- c(forecast_date_labels)
observed_probs <- prob_series(dt = tu, date_list = forecast_date_list)

# Calculate forecasts for periods after the first post-crisis date.
# Fixed transition matrix.
P_hat_fixed_mat <- as.matrix(P_hat_fixed,
                             nrow = num_groups,
                             ncol = num_groups)
forecast_probs_orig <- forecast_k_probs(start_probs = observed_probs[1, ],
                                        P_hat = P_hat_fixed_mat,
                                        num_steps = length(forecast_date_list) - 1,
                                        date_list = forecast_date_list,
                                        mat_num_list = NULL)
# Monthly transition matrices for seasonality.
# Add an index to indicate the relevant matrix number for each period.
mat_num_list <- as.numeric(substr(forecast_date_list, 6, 7))
forecast_probs_mo <- forecast_k_probs(start_probs = observed_probs[1, ],
                                      P_hat = P_hat_mo,
                                      num_steps = length(forecast_date_list) - 1,
                                      date_list = forecast_date_list,
                                      mat_num_list)


# Statistical tests for differences of distributions.
num_obs_forecast <- tu[sample_sel == TRUE &
                         time %in% as.Date(forecast_date_list),  .N,
                       by = c('time')][, N]

# Conduct tests with fixed transition matrix.
KLD_forecast_test_orig <- KLD_forecast_test(forecast_probs_orig,
                                            observed_probs, num_obs = num_obs_forecast)
# Conduct tests with monthly transition matrix.
KLD_forecast_test_mo <- KLD_forecast_test(forecast_probs_mo,
                                          observed_probs, num_obs = num_obs_forecast)



# Collect both sets of results into a table.
KL_forecast_02 <- cbind(KLD_forecast_test_orig, KLD_forecast_test_mo[, 2:3])

# Statement month labels.
KL_forecast_02[, 'stmt_date'] <- forecast_date_labels


# Output results to TeX file.
out_table <- KL_forecast_02[, c(6, 2:5)]
colnames(out_table) <- c('Month',
                         'Fixed', 'P-value',
                         'Monthly', 'P- value')

# Output to TeX file.
out_xtable <- xtable(out_table, digits = 4, label = 'tab:for_02',
                     caption = 'Out-of-sample Test with Fixed vs. Monthly Transition Matrices (k-step-ahead forecasts)')

tex_file_name <- sprintf('%s_KLD_kstep_fixed_vs_monthly_02.tex', file_tag)
tex_file_name <- sprintf('%s/%s', tab_dir, tex_file_name)

# Print table to tex file.
cat(print(out_xtable), file = tex_file_name, append = FALSE)



#--------------------------------------------------
# Plots in terms of percentage deviations:
# Model with fixed transition matrix
#--------------------------------------------------


# Plot in terms of percentage deviations.
for (date_num in 1:length(forecast_date_list)) {


  sel_date <- forecast_date_list[date_num]
  dev_pct_tab <- log(observed_probs[sel_date, ] /
                       forecast_probs_orig[sel_date, ]) *100

  dev_pct_tab <- as.numeric(dev_pct_tab)
  names(dev_pct_tab) <- colnames(forecast_probs_orig)

  fig_file_name <- sprintf('%s_obs_vs_for_dev_pct_fixed_%s.%s',
                           file_tag,
                           substr(sel_date, 1, 7),
                           fig_ext)
  out_file_name <- sprintf('%s/%s', fig_dir, fig_file_name)


  setEPS()
  postscript(out_file_name)
  barplot(dev_pct_tab,
          xlab = 'Balance Category (Thousands)',
          cex.lab = 1.5,
          ylim = c(-30, 30),
          col = 'grey')
  dev.off()

}


#--------------------------------------------------
# Plots in terms of percentage deviations:
# Model with monthly transition matrix
#--------------------------------------------------

# Plot in terms of percentage deviations.
for (date_num in 1:length(forecast_date_list)) {


  sel_date <- forecast_date_list[date_num]
  dev_pct_tab <- log(observed_probs[sel_date, ] /
                       forecast_probs_mo[sel_date, ]) *100

  dev_pct_tab <- as.numeric(dev_pct_tab)
  names(dev_pct_tab) <- colnames(forecast_probs_mo)

  fig_file_name <- sprintf('%s_obs_vs_for_dev_pct_monthly_%s.%s',
                           file_tag,
                           substr(sel_date, 1, 7),
                           fig_ext)
  out_file_name <- sprintf('%s/%s', fig_dir, fig_file_name)


  # png(out_file_name)
  setEPS()
  postscript(out_file_name)
  barplot(dev_pct_tab,
          xlab = 'Balance Category (Thousands)',
          cex.lab = 1.5,
          ylim = c(-30, 30),
          col = 'grey')
  dev.off()

}



##################################################
# End
##################################################
