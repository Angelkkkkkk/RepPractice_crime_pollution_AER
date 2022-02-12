

global rawdata C:\Users\fanga\Desktop\Econ Materials\STATA\replications in stata\AirPollu-criminal-rep\Raw-Data
global data C:\Users\fanga\Desktop\Econ Materials\STATA\replications in stata\AirPollu-criminal-rep\Data


import delimited "$rawdata\chicago_midwayohare_ghcn_daily_1991_2012.csv", clear stringcol(2) 

gen date = date(strdate,"YMD")
format date %td

/*Skipped these codes from the original file
tab qflag element;
replace value = . if qflag ~="";
*/

drop obstime mflag sflag qflag

sort station_id date
reshape wide value, i(station_id date) j(element) string
compress

* PRCP, TMAX, TMIN ARE SCALED BY 10;
replace valuePRCP = valuePRCP/10
replace valueTMAX = valueTMAX/10
replace valueTMIN = valueTMIN/10

*Round-off Value
foreach v of varlist value*{
	gen temp`v' = round(`v',.1)
	drop `v'
	rename temp`v' `v'
}

label var valuePRCP "Daily liquid precipitation, mm"
label var valueTMAX "Daily max temperature, deg C"
label var valueTMIN "Daily min temperature, deg C"
label var valueSNWD "Daily snow depth, mm"
label var valueSNOW "Daily snowfall, mm"

gen weather_airport = ""
replace weather_airport = "_OHARE" if station_id == "USW00094846"
replace weather_airport = "_MIDWAY" if station_id == "USW00014819"
drop station_id

reshape wide value*, i(date) j(weather_airport) string

label var valuePRCP_OHARE "Daily liquid precipitation, mm, O'Hare"
label var valueTMAX_OHARE "Daily max temperature, deg C, O'Hare"
label var valueTMIN_OHARE "Daily min temperature, deg C, O'Hare"
label var valueSNWD_OHARE "Daily snow depth, mm, O'Hare"
label var valueSNOW_OHARE "Daily snowfall, mm, O'Hare"
label var valueAWND_OHARE "Average wind speed, O'Hare"

label var valuePRCP_MIDWAY "Daily liquid precipitation, mm, Midway"
label var valueTMAX_MIDWAY "Daily max temperature, deg C, Midway"
label var valueTMIN_MIDWAY "Daily min temperature, deg C, Midway"
label var valueSNWD_MIDWAY "Daily snow depth, mm, Midway"
label var valueSNOW_MIDWAY "Daily snowfall, mm, Midway"
label var valueAWND_MIDWAY "Average wind speed, Midway"

gen day = day(date)
gen month = month(date)

tempfile temp
save `temp', replace

keep if year(date)<2001
collapse (mean) mean_TMAX_1991_2000=valueTMAX_MIDWAY mean_TMIN_1991_2000=valueTMIN_MIDWAY mean_PRCP_1991_2000=valuePRCP_MIDWAY, by(month day)

merge 1:n month day using `temp'
drop _merge day month strdate

drop if year(date)<2001

compress
save "$data/chicago_midwayohare_daily_weather", replace
