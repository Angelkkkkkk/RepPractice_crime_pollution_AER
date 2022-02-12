
global rawdata C:\Users\fanga\Desktop\Econ Materials\STATA\replications in stata\AirPollu-criminal-rep\Raw-Data
global data C:\Users\fanga\Desktop\Econ Materials\STATA\replications in stata\AirPollu-criminal-rep\Data

import delimited "$rawdata\sky_cover_MDW.txt", delimiter(tab) varnames(17) clear 

gen date = date(mmddyyyy,"MDY")
format date %td

*Drop if missing more than 6 hours
destring skycov, force replace
bys date: egen missing = sum(mi(skycov))
drop if missing > 6

*Caluculate daily mean and keep one obs
bys date: egen avg_sky_cover = mean(skycov)
drop mmddyyyy
egen tag = tag(date)
keep if tag == 1
duplicates report date
drop tag

save "$data/midway_daily_sky_cover.dta", replace
