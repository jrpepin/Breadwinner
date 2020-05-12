* Tell stata where your box folder original data, and data extracts are 
global projdir "D:/Projects/SIPP"
global SIPP2008 "$projdir/stata_data/2008"
global SIPP2014 "$projdir/stata_data/2014"
global SIPP2008TM "$projdir/stata_data/2008"
global SIPP2008Core "$projdir/stata_data/2008"

global SIPPextracts "$projdir/kraley/breadwinner/stata_data/keep"

* Where to find code, log files, temporary data files and analysis data files
global projcode "t:/GitHub/breadwinner/2008"
global sipp2008_code "$projcode"
global sipp2008_logs "$projdir/kraley/breadwinner/stata_logs"
global logdir "$projdir/kraley/breadwinner/stata_logs"
global results "$projdir/kraley/breadwinner/results"

* temporary data files
global tempdir "$projdir/kraley/breadwinner/stata_data/temp"

* Analysis data files
global SIPP08keep "$projdir/kraley/breadwinner/stata_data/keep"
global SIPP14keep "$projdir/kraley/breadwinner/stata_data/keep"

* child hh data files
global childhh "$projdir/kraley/childhh/stata_data/SIPP08/keep"

global replace "replace"

