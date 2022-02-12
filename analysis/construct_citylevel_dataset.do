global rawdata C:\Users\fanga\Desktop\Econ Materials\STATA\replications in stata\AirPollu-criminal-rep\Raw-Data
global data C:\Users\fanga\Desktop\Econ Materials\STATA\replications in stata\AirPollu-criminal-rep\Data

*use "$data/chicago_weather_daily_from_hourly.dta", clear
use "$data/chicago_weather_daily_from_hourly.dta", clear
format date %td

* KEEP ONLY MIDWAY WIND DATA
keep if usaf =="725340"

* Merge with "midway_daily_sky_cover.dta"
merge 1:1 date using "$data\midway_daily_sky_cover.dta"
keep if _merge == 3
drop _merge

* Merge with "chicago_midwayohare_daily_weather.dta"
merge 1:1 date using "$data\chicago_midwayohare_daily_weather.dta"
keep if inrange(year(date),2001,2012)
keep if _merge == 3
drop _merge

tempfile weather
save `weather', replace

*use "$data/chicago_part1_crimes.dta", clear
use "$data/chicago_part1_crimes.dta", clear

bys date fbicode: gen crimesNarrow = _N
keep date fbicode crimesNarrow
duplicates drop
reshape wide crimesNarrow, i(date) j(fbicode) string

foreach v of varlist crimesNarrow* {
	replace `v' = 0 if mi(`v')
	}

rename crimesNarrow01A Homicide
rename crimesNarrow02 ForcibleRape
rename crimesNarrow03 Robbery
rename crimesNarrow04A Assault
rename crimesNarrow04B Battery
rename crimesNarrow05 Burglary
rename crimesNarrow06 Larceny
rename crimesNarrow07 MVT
rename crimesNarrow08 Arson

gen TotalViolent = Homicide + ForcibleRape + Assault + Battery
gen TotalProperty = Robbery +  Burglary + Larceny + MVT + Arson
gen AssaultBattery = Assault + Battery

* Merge with `weather'
merge 1:1 date using `weather'
keep if inrange(year(date),2001,2012)
drop if _merge != 3
drop _merge

* Merge with "chicago_pollution_2000_2012.dta"
merge 1:1 date using "$data/chicago_pollution_2000_2012.dta"
keep if inrange(year(date),2001,2012)
drop if _merge != 3
drop _merge

gen diff = abs(tmax/10-valueTMAX_MIDWAY)

* group everything below -6 C, above 33 C (??)
gen temp_maxT = min(max(valueTMAX_MIDWAY, -6),33)
gen maxTempBins = floor(temp_maxT/3)
qui summ maxTempBins, d
replace maxTempBins = maxTempBins - r(min)
table maxTempBins, c(min valueTMAX_MIDWAY max valueTMAX_MIDWAY count valueTMAX_MIDWAY)

* group everything below -15 C (??)
gen temp_DewPt = max(dew_point_avg/10, -15)
gen dewPointBins = floor(temp_DewPt/3)
qui summ dewPointBins, d
replace dewPointBins = dewPointBins - r(min)
table dewPointBins, c(min dew_point_avg max dew_point_avg count dew_point_avg)

egen precipBins = cut(valuePRCP_MIDWAY), at(0 1 5 10 20 150)

gen windbins20 = floor(wind_dir_avg/(_pi/9))
gen windbins36 = floor(wind_dir_avg/(_pi/5))
gen windbins45 = floor(wind_dir_avg/(_pi/4))
gen windbins60 = floor(wind_dir_avg/(_pi/3))

*Calendar variables
gen dow = dow(date)
gen ym = ym(year,month)
gen jan1 = (doy(date) == 1)
gen month1 = (day(date) == 1)

**holiday dummy
gen holiday=0
replace holiday=1  if ( date==td(1jan2001) | date==td(15jan2001)| date==td(19feb2001)| date==td(28may2001)| date==td(4jul2001)| date==td(3sep2001)| date==td(8oct2001)| date==td(11nov2001)| date==td(22nov2001)| date==td(25dec2001))
replace holiday=1  if ( date==td(1jan2002) | date==td(21jan2002)| date==td(18feb2002)| date==td(27may2002)| date==td(4jul2002)| date==td(2sep2002)| date==td(14oct2002)| date==td(11nov2002)| date==td(28nov2002)| date==td(25dec2002))
replace holiday=1  if ( date==td(1jan2003) | date==td(20jan2003)| date==td(17feb2003)| date==td(26may2003)| date==td(4jul2003)| date==td(1sep2003)| date==td(13oct2003)| date==td(11nov2003)| date==td(27nov2003)| date==td(25dec2003))
replace holiday=1  if ( date==td(1jan2004) | date==td(19jan2004)| date==td(16feb2004)| date==td(31may2004)| date==td(4jul2004)| date==td(6sep2004)| date==td(11oct2004)| date==td(11nov2004)| date==td(25nov2004)| date==td(25dec2004))
replace holiday=1  if ( date==td(1jan2005) | date==td(17jan2005)| date==td(21feb2005)| date==td(30may2005)| date==td(4jul2005)| date==td(5sep2005)| date==td(10oct2005) |date==td(11nov2005)| date==td(24nov2005)|date==td(25dec2005))
replace holiday=1  if ( date==td(1jan2006) | date==td(16jan2006)| date==td(20feb2006)| date==td(29may2006)| date==td(4jul2006)| date==td(4sep2006)| date==td(9oct2006) |date==td(11nov2006)| date==td(23nov2006)|date==td(25dec2006))
replace holiday=1  if ( date==td(1jan2007) | date==td(15jan2007)| date==td(19feb2007)| date==td(28may2007)| date==td(4jul2007)| date==td(3sep2007)| date==td(8oct2007) |date==td(11nov2007)| date==td(22nov2007)|date==td(25dec2007))
replace holiday=1  if ( date==td(1jan2008) | date==td(21jan2008)| date==td(18feb2008)| date==td(26may2008)| date==td(4jul2008)| date==td(1sep2008)| date==td(13oct2008) |date==td(11nov2008)| date==td(27nov2008)|date==td(25dec2008))
replace holiday=1  if ( date==td(1jan2009) | date==td(19jan2009)| date==td(16feb2009)| date==td(25may2009)| date==td(4jul2009)| date==td(7sep2009)| date==td(12oct2009) |date==td(11nov2009)| date==td(26nov2009)|date==td(25dec2009))
replace holiday=1  if ( date==td(1jan2010) | date==td(18jan2010)| date==td(15feb2010)| date==td(31may2010)| date==td(4jul2010)| date==td(6sep2010)| date==td(11oct2010) |date==td(11nov2010)| date==td(26nov2010)|date==td(25dec2010))
replace holiday=1  if ( date==td(1jan2011) | date==td(17jan2011)| date==td(21feb2011)| date==td(30may2011)| date==td(4jul2011)| date==td(5sep2011)| date==td(10oct2011) |date==td(11nov2011)| date==td(24nov2011)|date==td(25dec2011))
replace holiday=1  if ( date==td(1jan2012) | date==td(16jan2012)| date==td(20feb2012)| date==td(28may2012)| date==td(4jul2012)| date==td(3sep2012)| date==td(8oct2012) |date==td(11nov2012)| date==td(29nov2012)|date==td(25dec2012))
replace holiday=1  if ( date==td(1jan2013) | date==td(21jan2013)| date==td(18feb2013)| date==td(27may2013)| date==td(4jul2013)| date==td(2sep2013)| date==td(14oct2013) |date==td(11nov2013)| date==td(28nov2013)|date==td(25dec2013))

*Pollution Variables
sum avg_pm10_mean
local mean = r(mean)
local sd = r(sd)
gen standardized_PM = (avg_pm10_mean-`mean')/`sd'
sum standardized_PM

label var standardized_PM "Standardized PM10 Reading"

* Generate dependent variable
gen lnViolent = ln(TotalViolent)
gen lnProperty = ln(TotalProperty)

*Omit the step below to save memory
/*
*Include all crimes (part 1 and part 2)

tempfile city_dataset
save `city_dataset', replace

use "$data/chicago_all_crimes.dta", clear

gen ViolentP1 = (violent == 1) & (part1 == 1)
gen NonViolP1 = (violent == 0) & (part1 == 1)
gen ViolentnP1 = (violent == 1) & (part1 == 0)
gen NonViolnP1 = (violent == 0) & (part1 == 0)
gen AllViolent = (violent == 1)
gen AllNonViol = (violent == 0)
gcollapse (sum) ViolentP1 NonViolP1 ViolentnP1 NonViolnP1 AllViolent AllNonViol, by(date)
sum
merge 1:1 date using `city_dataset'
drop if _merge != 3

gen lnViolentnP1 = ln(ViolentnP1)
gen lnNonViolnP1 = ln(NonViolnP1)
gen lnAllViolent = ln(AllViolent)
gen lnAllNonViol = ln(AllNonViol)
*/

save "$data/chicago_citylevel_dataset.dta", replace

