#!/bin/bash

################################################################################
#
# Analysis of Credit Card and HELOC Balances
#
# Lealand Morin, Ph.D.
# Assistant Professor
# Department of Economics
# College of Business Administration
# University of Central Florida
#
# March 28, 2021
#
################################################################################


################################################################################
# Run script for Credit Cards in Nation-Wide Sample
################################################################################

echo "#-------------------------------------------------"
echo ""
echo "Analyzing credit-card data..."
echo ""

Rscript Code/Stats/COVID_CJE_Cards.R > Code/Stats/COVID_CJE_Cards.out
echo ""

echo "Finished analyzing credit-card data."
echo ""
echo "#-------------------------------------------------"
echo ""

################################################################################
# Run script for HELOCs in Nation-Wide Sample
################################################################################

echo "#-------------------------------------------------"
echo ""
echo "Analyzing HELOC data..."
echo ""

Rscript Code/Stats/COVID_CJE_HELOCs.R > Code/Stats/COVID_CJE_HELOCs.out
echo ""

echo "Finished analyzing HELOC data."
echo ""
echo "#-------------------------------------------------"
echo ""


################################################################################
# Run script for Credit Cards in Alberta Sample
################################################################################

echo "#-------------------------------------------------"
echo ""
echo "Analyzing credit-card data..."
echo ""

Rscript Code/Stats/COVID_CJE_AB_Cards.R > Code/Stats/COVID_CJE_AB_Cards.out
echo ""

echo "Finished analyzing credit-card data."
echo ""
echo "#-------------------------------------------------"
echo ""

################################################################################
# Run script for HELOCs in Alberta Sample
################################################################################

echo "#-------------------------------------------------"
echo ""
echo "Analyzing HELOC data..."
echo ""

Rscript Code/Stats/COVID_CJE_AB_HELOCs.R > Code/Stats/COVID_CJE_AB_HELOCs.out
echo ""

echo "Finished analyzing HELOC data."
echo ""
echo "#-------------------------------------------------"
echo ""

################################################################################
# Run script for Time-Series Plots
################################################################################

echo "#-------------------------------------------------"
echo ""
echo "Generating time-series plots..."
echo ""

Rscript Code/Stats/CC_HE_time_series_figs.R > Code/Stats/CC_HE_time_series_figs.out
echo ""

echo "Finished generating time-series plots."
echo ""
echo "#-------------------------------------------------"
echo ""



################################################################################
# Run script for Figures in Data Appendix
################################################################################

echo "#-------------------------------------------------"
echo ""
echo "Generating figures for data appendix..."
echo ""

Rscript Code/Stats/CC_BoC_vs_TU_comp_figs.R > Code/Stats/CC_BoC_vs_TU_comp_figs.out

Rscript Code/Stats/CC_TU_vs_StatsCan_comp_fig.R > Code/Stats/CC_TU_vs_StatsCan_comp_fig.out

echo ""

echo "Finished generating figures for data appendix."
echo ""
echo "#-------------------------------------------------"
echo ""


################################################################################
# End
################################################################################
