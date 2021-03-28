# Data for Credit_COVID19_Canada

This is part of the code base to accompany the manuscript "Consumer Credit Usage in Canada during the Coronavirus Pandemic" by Ho, Morin, Paarsch and Huynh in the Canadian Journal of Economics, 2021

This folder would contain two datasets: tu_sample_bc.csv and tu_sample_he.csv

## tu_sample_bc.csv

This dataset contains observations of credit card balances for consumers in Canada from 2017-2021. It contains the following variables:

1. tu_consumer_id is 9-digit integer that indicates an individual consumer. 
1. Run_Date is a date variable of the form 'YYYY-MM-01' indicating the month in which the data were reported by the bureau. 
1. prov is a string that indicates the province of residence of the consumer.
1. homeowner is an indicator that the consumer has ever had a mortgage or a HELOC loan. 
1. N_bc is the number of credit card accounts held by a consumer.
1. bc_bal is the consumer's credit-card balance in dollars. 

## tu_sample_he.csv

This dataset contains observations of HELOC balances for consumers in Canada from 2017-2021. It contains the following variables:

1. tu_consumer_id is 9-digit integer that indicates an individual consumer. 
1. Run_Date is a date variable of the form 'YYYY-MM-01' indicating the month in which the data were reported by the bureau. 
1. prov is a string that indicates the province of residence of the consumer.
1. homeowner is an indicator that the consumer has ever had a mortgage or a HELOC loan. 
1. N_he is the number of HELOC accounts held by a consumer.
1. he_bal is the consumer's HELOC balance in dollars. 

## Time series plots

This folder also contains two datasets for generating 
aggregate time-series in Figure 1. 
The files tu_BC_time.csv and tu_HELOC_time.csv contain 
time series of aggregate statistics throughout the sample. 

These files both contain the following variables.
1. Run_Date is a date variable of the form 'YYYY-MM-01' indicating the month in which the data were reported by the bureau. 
1. bal_avg is the average balance held by consumers during the month. 
1. bal_sd is the standard deviation of balances held by consumers during the month. 
1. bal_p25 is the lower quartile of balances held by consumers during the month. 
1. bal_p50 is the median balance held by consumers during the month. 
1. bal_p75 is the upper quartile of balances held by consumers during the month. 

## Data Availability

The primary data source is the TransUnion credit bureau. Data are provided to the Bank of Canada on a monthly basis. Under the contractual agreement with TransUnion, the data are not publicly available. The Bank of Canada does, however, have a process for external researchers to work with these data. The Bank of Canada's Financial System Research Center is a hub for research on household finance (https://www.bankofcanada.ca/research/financial-system-research-centre/). Interested parties, who are Canadian citizens or permanent residents, can contact Jason Allen (Jallen@bankofcanada.ca) or the Managing Director of research Jim MacGee (JMacGee@bankofcanada.ca). Interested parties are asked to submit a project proposal; the proposal is evaluated by senior staff at the Bank of Canada for feasibility; external researchers do not typically have direct access to the data and must work with a Bank of Canada staff. An exception is if an external collaborator applies and is granted temporary employee status -- in this case the external researcher can access the data so long as they have a Bank of Canada affiliation. All research is vetted by Bank of Canada senior staff prior to publication. 