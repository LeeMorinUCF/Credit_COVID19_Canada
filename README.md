# Credit_COVID19_Canada

# DRAFT: UNDER CONSTRUCTION

The code base to accompany the manuscript "Consumer Credit Usage in Canada during the Coronavirus Pandemic" by Ho, Morin, Paarsch and Huynh in the Canadian Journal of Economics, 2021

## Instructions:

### All Files in One Script:

1. Place all datasets 
(```tu_sample_bc.csv```, ```tu_sample_he.csv```, 
```tu_AB_sample_bc.csv```, ```tu_AB_sample_he.csv```, 
)
in the ```Data``` folder. 
1. Run ```COVID_CJE.sh``` in a terminal window from the ```Credit_COVID19_Canada``` folder. 


This shell script calls the ```R``` programs 
```COVID_CJE_Cards.R```, ```COVID_CJE_HELOCs.R``` 
```COVID_CJE_AB_Cards.R```, ```COVID_CJE_AB_HELOCs.R``` 
and ```all_the_other_scripts.R```
in the ```Code``` folder, 
which analyze the datasets read in from the ```Data``` folder. 
These scripts create the tables and figures for the entire manuscript,
by writing tex files to the ```Tables``` folder and
eps files to the ```Figures``` folder. 


### Generating Sets of Files Separately

#### Nation-wide Sample of Credit-Card Accounts

1. Place the dataset 
```tu_sample_bc.csv```
in the ```Data``` folder. 
1. Run ```Rscript COVID_CJE_Cards.R``` 
in a terminal window from the ```Credit_COVID19_Canada``` folder. 


1. Obtain the tex files 
```CC_KLD_kstep_monthly_01.tex``` and
```CC_KLD_vs_sample_01.tex``` 
with numbers for columns 2 and 3 of Tables 1 and 2 
from the ```Tables``` folder. 

1. Obtain the images
for panels (a) of Figures 2 and 3 in the eps files
```CC_hist_grp.eps``` and 
```CC_3D_probs_discrete_1.eps```
from the ```Figures``` folder.

1. Obtain the images
for Figures 4 and 6 in the eps files
```CC_dev_pct_sample_2020_MM.eps``` and 
```CC_obs_vs_for_dev_pct_monthly_2020-MM.eps```
from the ```Figures``` folder, 
where ```MM``` represents the two-digit month of the 
```Run_date``` after the close of the corresponding statement month. 


#### Nation-wide Sample of HELOC Accounts

1. Place the dataset
```tu_sample_he.csv```
in the ```Data``` folder. 
1. Run ```Rscript COVID_CJE_HELOCs.R``` 
in a terminal window from the ```Credit_COVID19_Canada``` folder. 


1. Obtain the tex files 
```HE_KLD_kstep_monthly_01.tex``` and
```HE_KLD_vs_sample_01.tex``` 
with numbers for columns 2 and 3 of Tables 1 and 2 
from the ```Tables``` folder. 

1. Obtain the images
for panels (a) of Figures 2 and 3 in the eps files
```HE_hist_grp.eps``` and 
```HE_3D_probs_discrete_1.eps```
from the ```Figures``` folder.

1. Obtain the images
for Figures 4 and 6 in the eps files
```HE_dev_pct_sample_2020_MM.eps``` and 
```HE_obs_vs_for_dev_pct_monthly_2020-MM.eps```
from the ```Figures``` folder, 
where ```MM``` represents the two-digit month of the 
```Run_date``` after the close of the corresponding statement month. 



#### Alberta Sample of Credit-Card Accounts

1. Place the dataset 
```tu_AB_sample_bc.csv```
in the ```Data``` folder. 
1. Run ```Rscript COVID_CJE_AB_Cards.R``` 
in a terminal window from the ```Credit_COVID19_Canada``` folder. 
1. Obtain the tex file ```AB_CC_KLD_kstep_monthly_01.tex``` 
with numbers for columns 2 and 3 for Table 3 
in the ```Tables``` folder
and panel (a) of Figure 9 in the file
```AB_CC_obs_vs_for_dev_pct_monthly_2015-11.eps```
in the ```Figures``` folder.


#### Alberta Sample of HELOC Accounts

1. Place the dataset 
```tu_AB_sample_he.csv```
in the ```Data``` folder. 
1. Run ```Rscript COVID_CJE_AB_HELOCs.R``` 
in a terminal window from the ```Credit_COVID19_Canada``` folder. 
1. Obtain the tex file ```AB_HE_KLD_kstep_monthly_01.tex```
with numbers for columns 4 and 5 for Table 3 
in the ```Tables``` folder
and panel (b) of Figure 9 in the file
```AB_HE_obs_vs_for_dev_pct_monthly_2015-11.eps```
in the ```Figures``` folder.



#### Auxilliary Tables and Figures

See the section below
"Generating Tables and Figures Individually".

1. Place datasets 
```A.csv``` and ```B.csv```
in the ```Data``` folder. 
1. Run the following auxiliary scripts, in any order, 
to obtain Figures 1, 8, A1.1 and A1.2, 
as well as Table A1, 
which will also be saved in either the ```Figures``` or ```Tables``` folder, according to the type of file.
  a. Run script X to generate eps files 
  CC_agg_series.eps and HE_agg_series.eps for Figure 1.
  a. Run script X to generate eps files 
  AB_CC_agg_series.eps and AB_HE_agg_series.eps for Figure 8.
  a. Run script X to generate eps file Y for Figure A1.1.
  a. Run script X to generate csv file Y for Table A1.
  a. Run script X to generate eps file Y for Figure A1.2.



## Data Requirements

### Main datasets

The ```Data``` folder must contain two datasets: 
```tu_sample_bc.csv``` and ```tu_sample_he.csv```. 

#### tu_sample_bc.csv

This dataset contains observations of credit card balances for consumers in Canada from 2017-2021. It contains the following variables:

1. tu_consumer_id is a 9-digit integer that indicates an individual consumer. 
1. Run_Date is a date variable of the form 'YYYY-MM-01' indicating the month in which the data were reported by the bureau. 
It is the date that represents the last information added to the files, 
so it contains the statement activity recorded in the previous month. 
1. prov is a string that indicates the province of residence of the consumer.
1. homeowner is an indicator that the consumer has ever had a mortgage or a HELOC loan. 
1. N_bc is the number of credit card accounts held by a consumer.
1. bc_bal is the consumer's credit-card balance in dollars. 

#### tu_sample_he.csv

This dataset contains observations of HELOC balances for consumers in Canada from 2017-2021. It contains the following variables:

1. tu_consumer_id is 9-digit integer that indicates an individual consumer. 
1. Run_Date is a date variable of the form 'YYYY-MM-01' indicating the month in which the data were reported by the bureau. 
1. prov is a string that indicates the province of residence of the consumer.
1. homeowner is an indicator that the consumer has ever had a mortgage or a HELOC loan. 
1. N_he is the number of HELOC accounts held by a consumer.
1. he_bal is the consumer's HELOC balance in dollars. 

### Auxiliary datasets

#### Time series plots

The ```Data``` folder also contains two datasets for generating 
aggregate time-series in Figure 1. 
The files ```tu_BC_time.csv``` and ```tu_HELOC_time.csv``` contain 
time series of aggregate statistics throughout the sample. 

These files both contain the following variables.
1. Run_Date is a date variable of the form 'YYYY-MM-01' indicating the month in which the data were reported by the bureau. 
1. bal_avg is the average balance held by consumers during the month. 
1. bal_sd is the standard deviation of balances held by consumers during the month. 
1. bal_p25 is the lower quartile of balances held by consumers during the month. 
1. bal_p50 is the median balance held by consumers during the month. 
1. bal_p75 is the upper quartile of balances held by consumers during the month. 

The ```Data``` folder also contains another pair of datasets 
for generating 
aggregate time-series in Figure 8. 
The files ```tu_AB_BC_time.csv``` and ```tu_AB_HELOC_time.csv``` 
contain time series of aggregate statistics throughout the sample, 
restricted to the province of Alberta. 


#### Other datasets

Other data were obtained to produce tables and figures of 
aggregate information about the credit-card and HELOC markets. 
These include:
- The Nilson Report, 2018-2019
- Census Data: Stats Canada Series XYZ
- Bank of Canada Regulatory Returns (whatever these are called)



## Data Availability

The primary data source is the TransUnion credit bureau. Data are provided to the Bank of Canada on a monthly basis. Under the contractual agreement with TransUnion, the data are not publicly available. The Bank of Canada does, however, have a process for external researchers to work with these data. The Bank of Canada's Financial System Research Center is a hub for research on household finance (https://www.bankofcanada.ca/research/financial-system-research-centre/). Interested parties, who are Canadian citizens or permanent residents, can contact Jason Allen (Jallen@bankofcanada.ca) or the Managing Director of research Jim MacGee (JMacGee@bankofcanada.ca). Interested parties are asked to submit a project proposal; the proposal is evaluated by senior staff at the Bank of Canada for feasibility; external researchers do not typically have direct access to the data and must work with a Bank of Canada staff. An exception is if an external collaborator applies and is granted temporary employee status -- in this case the external researcher can access the data so long as they have a Bank of Canada affiliation. All research is vetted by Bank of Canada senior staff prior to publication. 


## Generating Tables and Figures Individually

### Tables

#### Table 1: Divergence from Sample Histograms

This Table contains information from two different modeling
exercises: one for credit-cards and one for HELOCs. 

For credit cards, 
run script COVID_CJE_Cards.R, 
which then runs script COVID_CJE_Cards_estim.R. 
Lines W to Z of COVID_CJE_Cards_estim.R 
generate a file named CC_agg_series.eps. 

For HELOCs, 
run script COVID_CJE_HELOCs.R, 
which then runs script COVID_CJE_HELOCs_estim.R.
Lines W to Z of COVID_CJE_HELOCs_estim.R 
generate a file named HE_agg_series.eps. 

The numbers from these two tables are combined into the file Table_1.tex.

#### Table 2: Divergence from l-Step-Ahead Forecasts

This Table also contains information from two different modeling
exercises: one for credit-cards and one for HELOCs. 

For credit cards, 
run script COVID_CJE_Cards.R, 
which then runs script COVID_CJE_Cards_estim.R. 
Lines W to Z of COVID_CJE_Cards_estim.R 
generate a file named A. 

For HELOCs, 
run script COVID_CJE_HELOCs.R, 
which then runs script COVID_CJE_HELOCs_estim.R.
Lines W to Z of COVID_CJE_HELOCs_estim.R 
generate a file named A. 

The numbers from these two tables are combined into the file Table_2.tex.



#### Table 3: Divergence from l-Step-Ahead Forecasts in Alberta, 2015

The creation of this Table mirrors that of Table 2 on the 
Canadian population during the pandemic, 
except that it is run on a dataset restricted to consumers 
in the province of Alberta during the oil price shock in 2015. 
As with Talbe 2, it also contains information from two different modeling
exercises: one for credit-cards and one for HELOCs. 


For credit cards, 
run script COVID_CJE_Cards.R, 
which then runs script COVID_CJE_Cards_estim.R. 
Lines W to Z of COVID_CJE_Cards_estim.R 
generate a file named A. 

For HELOCs, 
run script COVID_CJE_HELOCs.R, 
which then runs script COVID_CJE_HELOCs_estim.R.
Lines W to Z of COVID_CJE_HELOCs_estim.R 
generate a file named A. 

The numbers from these two tables are combined into the file Table_2.tex.

#### Table A1: Comparison of Accounts at the Credit Agency with Nation-Wide Totals in *The Nilson Report*

The set of numbers in the three leftmost columns
are taken directly from the *The Nilson Report*
AND ARE AVAILABLE HERE [Links go here]. 

To compare with the contents of the TransUnion database, 
we calculated the same summary statistics 
using the sample drawn from the database. 

The remaining information was obtained from running the script
NAME_OF_SCRIPT.py, which produced the following summary dataset, 
called NAME_OF_DATSET.csv, found in the Data folder. 



### Figures

#### Figure 1: Consumers' Outstanding Balances, 2017-2020


For credit cards, in panel (a),
run script X. 
Lines W to Z generate a file named A. 

For HELOCs, in panel (b),
run script X. 
Lines W to Z generate a file named A. 

#### Figure 2: Histograms of Individuals' Balances

For credit cards, in panel (a),
run script COVID_CJE_Cards.R, 
which then runs script COVID_CJE_Cards_prelim.R. 
Lines W to Z of COVID_CJE_Cards_prelim.R 
generate a file named CC_hist_grp.eps. 

For HELOCs, in panel (b),
run script COVID_CJE_HELOCs.R, 
which then runs script COVID_CJE_HELOCs_prelim.R.
Lines W to Z of COVID_CJE_HELOCs_prelim.R 
generate a file named HE_hist_grp.eps. 

#### Figure 3: Conditional Histograms of Individuals' Balances

For credit cards, in panel (a),
run script COVID_CJE_Cards.R, 
which then runs script COVID_CJE_Cards_prelim.R. 
Lines W to Z of COVID_CJE_Cards_prelim.R 
generate a file named A. 

For HELOCs, in panel (b),
run script COVID_CJE_HELOCs.R, 
which then runs script COVID_CJE_HELOCs_prelim.R.
Lines W to Z of COVID_CJE_HELOCs_prelim.R 
generate a file named A. 

#### Figure 4: Deviations from Histograms (Credit Cards)

For credit cards, in panel (a),
run script COVID_CJE_Cards.R, 
which then runs script COVID_CJE_Cards_estim.R. 
Lines W to Z of COVID_CJE_Cards_estim.R 
generate a file named A. 

#### Figure 5: Deviations from Histograms (HELOCs)

For HELOCs, in panel (b),
run script COVID_CJE_HELOCs.R, 
which then runs script COVID_CJE_HELOCs_estim.R.
Lines W to Z of COVID_CJE_HELOCs_estim.R 
generate a file named A. 

#### Figure 6: Deviations from Forecasted Credit-Card Balances

For credit cards, in panel (a),
run script COVID_CJE_Cards.R, 
which then runs script COVID_CJE_Cards_estim.R. 
Lines W to Z of COVID_CJE_Cards_estim.R 
generate a file named A. 


#### Figure 7: Deviations from Forecasted HELOC Balances

For HELOCs, in panel (b),
run script COVID_CJE_HELOCs.R, 
which then runs script COVID_CJE_HELOCs_estim.R.
Lines W to Z of COVID_CJE_HELOCs_estim.R 
generate a file named A. 

#### Figure 8: Consumers' Outstanding Balances, Alberta, 2012-2016

For credit cards, in panel (a),
run script X. 
Lines W to Z generate a file named AB_CC_agg_series.eps. 

For HELOCs, in panel (b),
run script X. 
Lines W to Z generate a file named AB_HE_agg_series.eps. 

#### Figure 9: Deviations from Forecasted Balances in Alberta, October 2015

For credit cards, in panel (a),
run script COVID_CJE_AB_Cards.R, 
which then runs script COVID_CJE_AB_Cards_estim.R. 
Lines W to Z of COVID_CJE_AB_Cards_estim.R 
generate a file named A. 


For HELOCs, in panel (b),
run script COVID_CJE_AB_HELOCs.R , 
which then runs script COVID_CJE_AB_HELOCs_estim.R.
Lines W to Z of COVID_CJE_AB_HELOCs_estim.R 
generate a file named A. 


#### Figure A1.1: Time Series of Aggregate Credit-Card Balances

There are two panels in this figure. 
They are both generated with the same script, 
one showing balances and the other showing percent changes of all the series. 
Two of the series were created using the sample from the TransUnion database
with the following script: 
NAME_OF_SCRIPT.py

THe other series is derived from an internal database housed at the 
Bank of Canada and collected from regulatory returns. 


#### Figure A1.2: Credit Data Coverage for Adults in Canada, by Province

The numbers in this figure were calculated with the script
NAME_OF_SCRIPT.py in the Code folder. 



## Computing Requirements

### Data Manipulation

The csv files in the Data folder 
were generated on the EDITH 2.0 cluster housed at the Bank of Canada. 
It is a cluster of X CPUs with Y characteristics. 


### Statistical Analysis

Once the datasets have been saved in the Data folder, 
the remaining analysis, including the generation of all the tables
and figures in the paper can be performed on a single microcomputer, 
such as a laptop computer.
The particular model of computer is a 
standard issue Dell Garbagewagon model 2000,
running Windows 10 x64.

### Software

The data manipulation was conducted using 
a NoSQL dialect called Apache Spark implemented with PySpark. 
Python version 3.8 is sufficient, as well as PySpark version 3.1.1.

The statistical analysis was conducted in R, version 4.0.2,
which was released on June 22, 2020, 
on a 64-bit Windows platform x86_64-w64-mingw32/x64. 

The attached packages include the following:

- data.table, version 1.13.0 (using 4 threads), to handle the main data table for analysis in the _prelim.R and _estim.R scripts. 

- xtable, version 1.8-4, to generate LaTeX tables for Tables 1, 2, and 3.

- plot3D, version 1.3, to produce a 3-D bar chart of transition frequency, which created the plots in Figure 3.

- MASS, version 7.3-51.6, was also used to estimate the smoothed surface of the transition density as an alternative to that in Figure 3 but was not included in the paper.


Upon attachment of the above packages, 
the following packages were loaded via a namespace, but not attached,
with the following versions:

- Rcpp version 1.0.5
- lattice version 0.20-41
- grid version 4.0.2
- DTMCPack version 0.1-2
- stats4 version 4.0.2
- magrittr version 1.5
- RcppParallel version 5.0.2
- misc3d version 0.8-4
- markovchain version 0.8.5-3
- Matrix version 1.2-18
- tools version 4.0.2
- igraph version 1.2.6
- parallel version 4.0.2
- compiler version 4.0.2
- pkgconfig version 2.0.3
- matlab version 1.0.2
- nnet version 7.3-14
- expm version 0.999-5  


## References

- TransUnion super magic insanely big-money database
- Census data
- The Nilson Report, 2018 and 2019
- top-secret regulatory returns at the Bank of Canada

