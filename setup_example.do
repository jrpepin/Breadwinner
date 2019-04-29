* Tell stata where your box folder and data extracts are 
global boxdir "$homedir/Box Sync"
global SIPPextracts "$boxdir/Breadwinning moms/data extracts"

* Where to find code, log files, temporary data files and analysis data files
global projcode "t:\GitHub\breadwinner"
global sipp2008_code "$projcode/2008"
global sipp2008_logs "$homedir/logs/SIPP/2008"
global logdir "$homedir/logs/SIPP/2008"

* temporary data files
global tempdir "$homedir/stata_data/stata_tmp"

* Analysis data files
global SIPP08keep "$homedir/stata_data/SIPP08_Processed"

global replace "replace"

