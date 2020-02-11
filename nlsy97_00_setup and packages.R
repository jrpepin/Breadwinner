#------------------------------------------------------------------------------------
# BREADWINNER PROJECT
# nlsy97_00_setup and packages.R
# Joanna Pepin
#------------------------------------------------------------------------------------

#####################################################################################
## Install and load required packages
#####################################################################################

if(!require(here)){
  install.packages("here")
  library(here)
}

if(!require(tidyverse)){
  install.packages("tidyverse")
  library(tidyverse)
}

if(!require(lubridate)){
  install.packages("lubridate")
  library(lubridate)
}

#####################################################################################
# Set-up the Directories
#####################################################################################

projDir <- here()           # Filepath to this project's directory
dataDir <- "data"           # Name of the sub-folder where theNLSY97 data was downloaded (where tagset is stored)
figDir  <- "figures"        # Name of the sub-folder where we will save generated figures
outDir  <- "results"        # Name of the sub-folder where we will save output

## This will create sub-directory folders in the projDir if they don't exist
if (!dir.exists(here(figDir))){
  dir.create(figDir)
} else {
  print("Figure directory already exists!")
}

if (!dir.exists(here(outDir))){
  dir.create(outDir)
} else {
  print("Output directory already exists!")
}