global replace "replace"

global logdir "$homedir/stata_logs"
global tempdir "$homedir/stata_tmp"


global boxdir "C:\Users\Joanna\Box Sync UT\Box Sync"
global projdir "$boxdir/SIPP/Results and Papers/breadwinner"
global projcode "D:\Dropbox\ChildHH"
global sipp2008_code "$projcode/SIPP2008"
global sipp2008_logs "C:\Users\Joanna\logs\SIPP\2008"
* global SIPPshared "$projdir/data/shared"

global first_wave 1
global final_wave 15
global second_wave = ${first_wave} + 1
global penultimate_wave = ${final_wave} - 1
