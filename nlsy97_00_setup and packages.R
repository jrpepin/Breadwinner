#------------------------------------------------------------------------------------
# BREADWINNER PROJECT
# nlsy97_00_setup and packages.R
# Joanna Pepin
#------------------------------------------------------------------------------------

#####################################################################################
## Install and load required packages
#####################################################################################
if(!require(renv)){           # https://rstudio.github.io/renv/articles/renv.html
  install.packages("renv")
  library(renv)
}

if(!require(tidyverse)){
  install.packages("tidyverse")
  library(tidyverse)
}

if(!require(lubridate)){
  install.packages("lubridate")
  library(lubridate)
}

if(!require(here)){
  install.packages("here")
  library(here)
}

if(!require(conflicted)){
  devtools::install_github("r-lib/conflicted")
  library(conflicted)
}

renv::snapshot() # Save the state of the project library to the lockfile (called renv.lock)

# Address any conflicts in the packages
conflict_scout() # Identify the conflicts
conflict_prefer("here", "here")
conflict_prefer("filter", "dplyr")
conflict_prefer("remove", "base")

#####################################################################################
# Set-up the Directories
#####################################################################################

projDir <- here()           # Filepath to this project's directory
dataDir <- "data"           # Name of the sub-folder where theNLSY97 data was downloaded (where tagset is stored)
figDir  <- "figures"        # Name of the sub-folder where we will save generated figures
outDir  <- "results"        # Name of the sub-folder where we will save output

## This will create sub-directory folders in the projDir if they don't exist
if (!dir.exists(here::here(figDir))){
  dir.create(figDir)
} else {
  print("Figure directory already exists!")
}

if (!dir.exists(here::here(outDir))){
  dir.create(outDir)
} else {
  print("Output directory already exists!")
}

message("End of nlsy97_00_setup and packages") # Marks end of R Script