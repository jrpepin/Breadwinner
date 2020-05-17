*-------------------------------------------------------------------------------
* BREADWINNER PROJECT
* Kelly Raley and Joanna Pepin
*-------------------------------------------------------------------------------
* This is the main do file that runs all of the scripts in order to create the 
* tables accompaning the publication. This scripts expects that you are in
* its directory when you execute it. 
*
* NLSY analysis
*
set maxvar 5500

cd NLSY97/stata
do breadwinnerNLSY97

* SIPP analysis

cd ../../SIPP/stata
do breadwinnerSIPP14.do
