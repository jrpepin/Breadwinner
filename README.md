# NLSY_Breadwinning
Analysis of mothers' breadwinning using the NLSY
  
The purpose of this analysis of the NLSY97 data is to describe mothers' odds of 
breadwinning by 10 years after mothers' first birth.  
  
DATA
--------------------------------------------------------------------------------
The description of the variables can be found online, 
using the [NLS Investigator](https://www.nlsinfo.org/investigator/pages/search.jsp?s=NLSY97).
  
The data for this analysis can be accessed by logging into the NLS Investigator,
selecting the NLSY97 study and NLSY97 1997-2017 (rounds 1-18) substudy.  

To select the variables for this study, researchers should select ["Choose Tagsets"](https://www.nlsinfo.org/content/access-data-investigator/investigator-user-guide/choose-tagsets-tab)
and upload the file: "$data/nlsy9717.NLSY97."  

To download the data, select "Save/Download" and then "Advanced Download." 
Make sure "Tagset" and "STATA® dictionary file of selected variables" are selected.  
Give your download a filename (e.g. "nlsy9717") and click download.  

Before running the first .do file (01_nlsy97_sample & demo), remove the comment 
markers in the downloaded "value-labels" .do file so that variables are renamed.  
We also had to delete all instances of "KEY!" so the file import will run properly.
