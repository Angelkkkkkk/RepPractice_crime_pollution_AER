*Note: since only pm10 is used to measure pollution in the 2SLS model in Part4 of the study
*therefore, datasets contain the measures of aqi,ozone,co,and no2 will not be merged to this data


global rawdata C:\Users\fanga\Desktop\Econ Materials\STATA\replications in stata\AirPollu-criminal-rep\Raw-Data
global data C:\Users\fanga\Desktop\Econ Materials\STATA\replications in stata\AirPollu-criminal-rep\Data

//Step1: prepare aqi (air quality index)//
use "$data/chicago_pm10_2000_2012_daily.dta", clear

keep if inlist(monitorid,"31_22_4","31_1016_4")
keep max24hr_pm10_derived avg24hr_pm10_derived monitorid date

reshape wide max24hr_pm10_derived avg24hr_pm10_derived, i(date) j(monitorid) string


*drop obs with missingvalue 
egen monitor_pct_pm10 = rownonmiss(avg24hr_pm10*)
replace monitor_pct_pm10 = monitor_pct_pm10/2

egen max_pm10_mean = rowmean(max24hr_pm10_derived31_22_4 max24hr_pm10_derived31_1016_4)
egen avg_pm10_mean = rowmean(avg24hr_pm10_derived31_22_4 avg24hr_pm10_derived31_1016_4)

label var avg_pm10_mean "Average PM10 reading, ppm, mean across monitors 31-1016-4, 31-22-4"
label var max_pm10_mean "Max 1-hour PM10 reading, ppm, mean across monitors 31-1016-4, 31-22-4"

keep date max_pm10_mean avg_pm10_mean monitor_pct_pm10

save "$data/chicago_pollution_2000_2012.dta", replace



