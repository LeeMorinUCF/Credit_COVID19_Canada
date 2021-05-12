

##################################################
#
# Time Series of Credit Card and HELOC Balances
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
# CC_HE_time_series.R creates a pair of plots 
#   to compare the number of credit-card accounts
#   held at chartered banks recorded in the
#   TransUnion dataset and regulatory returns at the 
#   Bank of Canada.
#   The result is an image for Figure A1.1. 
#   It is part of the code base to accompany
#   the manuscript "Consumer Credit Usage in Canada
#   during the Coronavirus Pandemic"
#   by Ho, Morin, Paarsch and Huynh
#   in the Canadian Journal of Economics, 2021
#
# Dependencies:
#   Reads the dataset tu_BC_time.csv and tu_HELOC_time.csv
#   for the nation-wide sample
#   and tu_AB_BC_time.csv and tu_AB_HELOC_time.csv
#   for the Alberta sample.
#
##################################################


# Clear workspace, if running interactively.
# rm(list=ls(all=TRUE))

# Set working directory, if other than Credit_COVID19_Canada.
# wd_path <- '/path/to/Credit_COVID19_Canada'
# setwd(wd_path)



##################################################
# Load Libraries and Set Parameters
##################################################

library(openxlsx)
library(dplyr)
library(lubridate)

library(ggplot2)
library(ggpubr)
library(ggthemes)
options(scipen=999)  # turn-off scientific notation like 1e+48
theme_set(theme_bw()) 

library(Cairo)

# Set data directory.
data_dir <- 'Data'

# Set file extension for figures.
fig_ext <- 'eps'

in_file_name <- sprintf('%s/BoC_vs_TU_num_accts.csv', data_dir)
out_file_name <- sprintf('%s/BoC_vs_TU_comparison.%s', data_dir, fig_ext)


##################################################
# Load Data
##################################################


comp <- read.csv(file = "BoC_vs_TU_num_accts.csv") %>% 
  mutate(Date = as.Date(Date, format="%Y-%m-%d")) %>% arrange(Date) %>%
  mutate(MCP_yoy = MCP/lag(MCP, n = 1) -1,
         TU_all_yoy = tot_bal_all/lag(tot_bal_all, n = 1) -1,
         TU_bank_yoy = tot_bal_bank/lag(tot_bal_bank, n = 1) -1)



##################################################
# Generate Plots for Figure A1.1
##################################################

comp <- comp %>% filter(year(Date)>=2017)

plot_comp <- ggplot(data=comp, aes(x=Date)) + 
  geom_line(aes(y=MCP, color="mcp", linetype="mcp"), size=0.75) +
  geom_line(aes(y=tot_bal_bank, color="tu_bank", linetype="tu_bank"), size=0.75) +
  geom_line(aes(y=tot_bal_all, color="tu_all", linetype="tu_all"),  size=0.75) + 
  labs(x=NULL, y="Aggregate Outstanding Balances (CDN billions)") + coord_cartesian(ylim=c(70,110)) + 
  scale_colour_manual(name = "",
                      values = c("mcp"="blue","tu_bank"="black","tu_all"="black"),
                      labels = c("mcp"="Bank of Canada (Chartered Banks)","tu_bank"="Credit Bureau (Chartered Banks)","tu_all"="Credit Bureau (Entire Database)")) +
  scale_linetype_manual(name = "",
                        values = c("mcp"=1,"tu_bank"=5,"tu_all"=3),
                        labels = c("mcp"="Bank of Canada (Chartered Banks)","tu_bank"="Credit Bureau (Chartered Banks)","tu_all"="Credit Bureau (Entire Database)")) +
  scale_x_date(date_breaks="1 year", date_labels="%Y") +
  theme(axis.line = element_line(colour = "black"),
        panel.background = element_blank(),
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        legend.position='bottom', legend.direction='horizontal',
        legend.background = element_blank(),
        legend.box.background = element_blank(),
        legend.key.width = unit(2, "line"))

plot_comp_yoy <- ggplot(data=comp, aes(x=Date)) + 
  geom_line(aes(y=MCP_yoy, color="mcp", linetype="mcp"), size=0.75) +
  geom_line(aes(y=TU_bank_yoy, color="tu_bank", linetype="tu_bank"), size=0.75) +
  geom_line(aes(y=TU_all_yoy, color="tu_all", linetype="tu_all"),  size=0.75) + 
  labs(x=NULL, y="Monthly Percentage Change") + coord_cartesian(ylim=c(-0.1,0.1)) + 
  scale_colour_manual(name = "",
                      values = c("mcp"="blue","tu_bank"="black","tu_all"="black"),
                      labels = c("mcp"="Bank of Canada (Chartered Banks)","tu_bank"="Credit Bureau (Chartered Banks)","tu_all"="Credit Bureau (Entire Database)")) +
  scale_linetype_manual(name = "",
                        values = c("mcp"=1,"tu_bank"=5,"tu_all"=3),
                        labels = c("mcp"="Bank of Canada (Chartered Banks)","tu_bank"="Credit Bureau (Chartered Banks)","tu_all"="Credit Bureau (Entire Database)")) +
  scale_x_date(date_breaks="1 year", date_labels="%Y") +
  theme(axis.line = element_line(colour = "black"),
        panel.background = element_blank(),
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        legend.position='bottom', legend.direction='horizontal',
        legend.background = element_blank(),
        legend.box.background = element_blank(),
        legend.key.width = unit(2, "line"))

plot_comp_all <- ggarrange(plot_comp, plot_comp_yoy,
                          ncol = 2, nrow = 1, align = "h", legend = "bottom", common.legend = TRUE)

cairo_ps(filename = out_file_name,
         width=7, height=4, pointsize = 12,
         fallback_resolution = 300)

print(plot_comp_all)

dev.off()


##################################################
# End
##################################################
