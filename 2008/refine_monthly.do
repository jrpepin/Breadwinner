use "$SIPP08keep/sipp08tpearn_all", clear

* doing my best to reconstruct tpearn
* starting by summing up reported earnings
gen altearn=tpmsum1 if !missing(tpmsum1)             // income from job 1
replace altearn=altearn+tpmsum2 if !missing(tpmsum2) // income from job 2
replace altearn=altearn+tbmsum1 if !missing(tbmsum1) // income from business 1
replace altearn=altearn+tbmsum2 if !missing(tbmsum2) // income from business 2
replace altearn=altearn+tmlmsum

* accounting for business losses
gen profit=tprftb1 if !missing(tprftb1)
replace profit=profit+tprftb2 if !missing(tprftb1)

gen samearn=1 if altearn==tpearn & !missing(altearn) & !missing(tpearn)
replace samearn=0 if altearn != tpearn & !missing(altearn) & !missing(tpearn)

gen negearn=1 if tpearn < 0

tab samearn negearn, m

gen diffearn=altearn-tpearn

sum diffearn, detail
