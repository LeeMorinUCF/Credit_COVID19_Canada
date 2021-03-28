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
# Run script for Credit Cards
################################################################################

echo "#-------------------------------------------------"
echo ""
echo "Analyzing credit-card data..."
echo ""

Rscript Code/COVID_CJE_Cards.R > Code/COVID_CJE_Cards.out
echo ""

echo "Finished analyzing credit-card data."
echo ""
echo "#-------------------------------------------------"
echo ""

################################################################################
# Run script for HELOCs
################################################################################

echo "#-------------------------------------------------"
echo ""
echo "Analyzing HELOC data..."
echo ""

Rscript Code/COVID_CJE_HELOCs.R > Code/COVID_CJE_HELOCs.out
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

Rscript Code/CC_HE_TS_figs.R > Code/CC_HE_TS_figs.out
echo ""

echo "Finished generating time-series plots."
echo ""
echo "#-------------------------------------------------"
echo ""


################################################################################
# End
################################################################################
