

##################################################
#
# Analysis of HELOC Balances
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
# COVID_CJE_HELOCs_prelim is an analysis of HELOC balances.
#   It is part of the code base to accompany
#   the manuscript "Consumer Credit Usage in Canada
#   during the Coronavirus Pandemic"
#   by Ho, Morin, Paarsch and Huynh
#   in the Canadian Journal of Economics, 2021
#
# Dependencies:
#   Data loading and preparation in COVID_CJE_HELOCs.R
#
#
##################################################


##################################################
# Load Additional Packages for Plotting Figures
##################################################


# To estimate the smoothed surface of the transition density.
library(MASS)

# To produce a 3-D bar chart of transition frequency.
library(plot3D)



##################################################
# Generate Tables and Figures
##################################################


#--------------------------------------------------
# Plot a histogram.
#--------------------------------------------------

# Fix entire pre-sample period.
tu[, sel_obsns := sample_sel & pre_crisis]

# Create labels for date range.
min_time_sel <- tu[sel_obsns == TRUE, min(time)]
max_time_sel <- tu[sel_obsns == TRUE, max(time)]

# Plot a histogram of the observations in the training sample.
fig_file_name <- sprintf('%s_hist_grp_sample.%s', file_tag, fig_ext)
out_file_name <- sprintf('%s/%s', fig_dir, fig_file_name)


setEPS()
postscript(out_file_name)
barplot(table(tu[sel_obsns == TRUE, x_disc])/tu[sel_obsns == TRUE, .N],
        xlab = 'Balance Category (Thousands)',
        cex.lab = 1.5,
        col = 'grey')
dev.off()



##################################################
# Calculate Transitions on Selected Sample
##################################################


#--------------------------------------------------
# Calculate transitions
#--------------------------------------------------

# Build fixed transition matrix with entire build sample.
tu[, sel_obsns_trans := sel_obsns]
P_hat_fixed <- est_trans_mat_single(dt = tu)


##################################################
# Plot the transition probabilities
##################################################


#--------------------------------------------------
# 3-D bar chart of transition frequency.
#--------------------------------------------------


# Reduce the size of margins.
# par()$mar
# 5.1 4.1 4.1 2.1
# bottom, left, top and right margins respectively.
par(mar = c(1.1, 1.1, 2.1, 1.1))
# Reset after.
# par(mar = c(5.1, 4.1, 4.1, 2.1))

# Design the plot.
hist3D(x = 1:nrow(P_hat_fixed),
       y = 1:ncol(P_hat_fixed), z = P_hat_fixed,
       bty = "g", phi = 20,  theta = -60,
       xlab = "Current", ylab = "Past",
       zlab = "Probability",
       cex.lab = 1.2,
       # main = sprintf("Conditional Transition Probabilities of %s Balances", loan_label),
       # col = "red", border = "black", shade = 0.8,
       col = "grey", border = "black", shade = 0.8,
       space = 0.15, d = 2, cex.axis = 1e-9)

# Use text3D to label x axis.
text3D(x = c(1, nrow(P_hat_fixed)),
       y = rep(-1, 2),
       z = rep(0, 2),
       labels = rownames(P_hat_fixed)[c(1, nrow(P_hat_fixed))],
       add = TRUE, adj = 0)
# Use text3D to label y axis.
text3D(x = rep(-1, 2),
       y = c(1, ncol(P_hat_fixed)),
       z = rep(0, 2),
       labels  = colnames(P_hat_fixed)[c(1, ncol(P_hat_fixed))],
       add = TRUE, adj = 1)



# Plot for a series of viewpoints.
theta_list <- c(-60, -45, -30)
for (theta_num in 1:length(theta_list)) {


  # Plot the 3-D bar charts for inspection.
  fig_file_name <- sprintf('%s_3D_probs_discrete_%d.%s',
                           file_tag, theta_num, fig_ext)
  out_file_name <- sprintf('%s/%s', fig_dir, fig_file_name)


  setEPS()
  postscript(out_file_name)
  hist3D(x = 1:nrow(P_hat_fixed),
         y = 1:ncol(P_hat_fixed), z = P_hat_fixed,
         bty = "g", phi = 20,  theta = theta_list[theta_num],
         xlab = "Current", ylab = "Past",
         zlab = "Probability",
         cex.lab = 1.2,
         # main = sprintf("Conditional Transition Probabilities of %s Balances", loan_label),
         # col = "red", border = "black", shade = 0.8,
         col = "grey", border = "black", shade = 0.8,
         # ticktype = "detailed",
         space = 0.15, d = 2, cex.axis = 1e-9)

  # Use text3D to label x axis.
  text3D(x = c(1, nrow(P_hat_fixed)),
         y = rep(-1, 2),
         z = rep(0, 2),
         labels = rownames(P_hat_fixed)[c(1, nrow(P_hat_fixed))],
         add = TRUE, adj = 0)
  # Use text3D to label y axis.
  text3D(x = rep(-1, 2),
         y = c(1, ncol(P_hat_fixed)),
         z = rep(0, 2),
         labels  = colnames(P_hat_fixed)[c(1, ncol(P_hat_fixed))],
         add = TRUE, adj = 1)
  dev.off()


}

# Reset the size of margins.
par(mar = c(5.1, 4.1, 4.1, 2.1))


#--------------------------------------------------
# Smoothed surface of transition frequency.
#--------------------------------------------------

tu[, x_cts_lag := shift(x_cts)]
x <- tu[sel_obsns == TRUE, x_cts_lag]
y <- tu[sel_obsns == TRUE, x_cts]

# First calculate the smoothed surface (with Gaussian kernel).
surf <- kde2d(x,
              y,
              n = 20,
              lims = c(c(0, 800000), c(0, 800000)))


# Reduce the size of margins.
# par()$mar
# 5.1 4.1 4.1 2.1
# bottom, left, top and right margins respectively.
par(mar = c(1.1, 1.1, 2.1, 1.1))
# Reset after.
# par(mar = c(5.1, 4.1, 4.1, 2.1))

# Set colors for 3D surface plot.
colors <- rainbow(100)
surf.facet.center <- (surf$z[-1, -1] + surf$z[-1, -ncol(surf$z)] + surf$z[-nrow(surf$z), -1] + surf$z[-nrow(surf$z), -ncol(surf$z)])/4
# Range of the facet center on a 100-scale (number of colors)
surf.facet.range <- cut(surf.facet.center, 100)


# Plot smoothed density function.
fig_file_name <- sprintf('%s_3D_cts_density.%s',
                         file_tag, fig_ext)
out_file_name <- sprintf('%s/%s', fig_dir, fig_file_name)


setEPS()
postscript(out_file_name)

# Plot smoothed density function.
persp(surf$x, surf$y,
      surf$z,
      xlab = 'Past',
      ylab = 'Current',
      zlab = 'Density',
      zlim = c(0, 10^(-9)),
      main = sprintf("Joint Density of Consecutive %s Balances", loan_label),
      phi = 30, theta = 100,
      # r = sqrt(3), # The distance of the eyepoint from the centre of the plotting box.
      r = 1.5,
      # d = 1, # The strength of the perspective transformation.
      d = 4.0,
      ticktype = 'detailed',
      cex.axis = 0.60,
      cex.lab = 1.0,
      col = colors[surf.facet.range]
)
dev.off()


# Reset the size of margins.
par(mar = c(5.1, 4.1, 4.1, 2.1))

#--------------------------------------------------
# Plot the level sets of the smoothed density.
#--------------------------------------------------

# Calculate smoother density for level curves.
surf_c <- kde2d(x,
                y,
                h = 750,
                # n = 50,
                n = 20,
                # lims = c(range(x), range(y)),
                lims = c(c(0, 800000), c(0, 800000)))

# Select levels for lines.
levels_list <- c(10^(-15), 5*10^(-15),
                 10^(-12), 5*10^(-12),
                 10^(-9), 5*10^(-9))

# Plot level curves of smoothed density function.
fig_file_name <- sprintf('%s_density_level_curves.%s',
                         file_tag, fig_ext)
out_file_name <- sprintf('%s/%s', fig_dir, fig_file_name)

setEPS()
postscript(out_file_name)
contour(x = surf_c$x, y = surf_c$y,
        z = surf_c$z,
        main = sprintf("Joint Density of Consecutive %s Balances", loan_label),
        xlab = 'Past Balance',
        ylab = 'Current Balance',
        levels = levels_list,
        labcex = 1.5,
        lwd = 3
)

lines(c(0, 10000), c(0, 10000), lwd = 3, lty = 'dashed')
dev.off()



##################################################
# End
##################################################

