

##################################################
#
# Comparison of Credit Card Account Holders
# with Population by Province
#
# Anson T.Y. Ho, Ph.D.
# Assistant Professor
# Department of Real Estate Management
# Ryerson University
#
# March 28, 2021
#
##################################################
#
# CC_TU_vs_StatsCan_comp_figs.R creates a bar chart of
#   the ratio of credit-card account holders
#   to the population aged 20 and above for each province
#   or region of Canada.
#   It is part of the code base to accompany
#   the manuscript "Consumer Credit Usage in Canada
#   during the Coronavirus Pandemic"
#   by Ho, Morin, Paarsch and Huynh
#   in the Canadian Journal of Economics, 2021
#
# Dependencies:
#   Reads dataset CC_TU_vs_StatsCan.csv.
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
# Load Libraries and Set Parameters
##################################################


library(openxlsx)
library(dplyr)
library(doBy)

library(ggplot2)
library(ggpubr)
library(ggthemes)
options(scipen=999)  # turn-off scientific notation like 1e+48
theme_set(theme_bw()) 

library(Cairo)



##################################################
# Load Data
##################################################



pop <- read.csv(file = "CC_TU_vs_StatsCan.csv", stringsAsFactors = FALSE) %>% arrange(desc(total))
pop$region <- pop$prov
pop$region[pop$region %in% c("NU","NT","YT")] <- "CAT"
pop$region[pop$region %in% c("NS","NB","NL","PE")] <- "ATL"
pop <- summaryBy(. ~ region, pop, FUN = c(sum), keep.names = TRUE) %>% arrange(desc(total)) %>%
  mutate(prct_geq20 = N_geq20/geq20,
         prct_BC = N_geq20_BC/geq20,
         region = factor(region, levels = region))



##################################################
# Generate Plots for Figure A1.2
##################################################


fig_file_name <- sprintf('CC_TU_vs_StatsCan_comp.%s',
                         fig_ext)
out_file_name <- sprintf('%s/%s', fig_dir, fig_file_name)


plot_pop <- ggplot(data=pop, aes(x=region)) + 
  geom_bar(aes(y=prct_geq20),stat="identity", width=.4) +
  geom_point(aes(y=prct_BC), color="white", size=4) + 
  labs(x=NULL, y=NULL) +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())

cairo_ps(filename = out_file_name,
         width=4, height=3, pointsize = 12,
         fallback_resolution = 300)

print(plot_pop)

dev.off()


##################################################
# End
##################################################

