* Let's say that you start with a file that looks like:
*
input id year firstbirth bw50 time

id year  firstbirth    bw50  time
3 1997 0 . . 
3 1998 0 .
3 1999 0 .
3 2000 0 .
3 2001 0 .
3 2002 1 0 0
3 2003 1 0 1
3 2004 1 1 2
3 2005 1 1 3
3 2006 1 0 4
3 2007 1 1 5
4 1997 0 . . 
4 1998 0 . .
4 1999 1 0 0
4 2000 1 1 1
4 2001 1 1 2
4 2002 1 1 3
4 2003 1 0 4
4 2004 1 1 5
4 2005 1 0 6
4 2006 1 0 7
4 2007 1 1 8
5 1997 0 . . 
5 1998 0 . .
5 1999 0 . .
5 2000 0 . .
5 2001 0 . .
5 2002 0 . .
5 2003 0 . .
5 2004 1 1 0
5 2005 1 1 1
5 2006 1 0 2
5 2007 1 1 3
end

*select only observations since first birth
keep if firstbirth==1

drop firstbirth // this variable has no variation now

reshape wide year bw50, i(id) j(time)

forvalues t=1/8{
    local s=`t'-1
    gen bw50_minus1_`t'=bw50`s' 
}

forvalues t=2/8{
    local r=`t'-2
    gen bw50_minus2_`t'=bw50`r' 
}

reshape long year bw50 bw50_minus1_ bw50_minus2_, i(id) j(time)

* clean up observations created because reshape creates some number of observations for each (id)
drop if missing(year)

logit bw50 bw50_minus1 i.time
logit bw50 bw50_minus1 bw50_minus2 i.time


                                                           










    
