****************
* This is a script that prepares the SIPP to be weighted to the NLSY ageatfirstbirth by duration distribution
* and then runs the analysis to produce a results.html file.
* It assumes that you've run the setup file and breadwinner14.do
**************

    log using "$logdir/SIPP14agedist.log",	replace 
    do "$SIPP2014_code/SIPP14agedist.do"
    log close
    
    dyndoc "$results/SIPPtoComparetoNLSY.md", saving("$output/SIPPtoComparetoNLSY.html") replace

