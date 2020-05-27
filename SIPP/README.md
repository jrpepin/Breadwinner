SIPP Analysis
================================================================================

Jennifer L. Glass  
R. Kelly Raley  
Joanna R. Pepin  

DATA
--------------------------------------------------------------------------------
* This project uses Wave 1-4 of the 2014 SIPP data files. They can be downloaded [here](https://www.census.gov/programs-surveys/sipp/data/datasets.html).

Before running the first .do file (01_sipp14_extract_and_format.do), compress the
downloaded data files.

Environment
--------------------------------------------------------------------------------
Users need to create a personal setup file before running these scripts.
Use the setup_example.do script located in the SIPP sub-folder as a template and 
save the customized file in this sub-folder.

Analysis
--------------------------------------------------------------------------------
To run all of the SIPP project code, run the breadwinnner14.do file.

NOTE: Many of these macros/estimates will only work if the NLSY project code was
run before in the same Stata session.