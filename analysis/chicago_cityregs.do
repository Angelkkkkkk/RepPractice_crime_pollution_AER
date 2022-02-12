global rawdata C:\Users\fanga\Desktop\Econ Materials\STATA\replications in stata\AirPollu-criminal-rep\Raw-Data
global data C:\Users\fanga\Desktop\Econ Materials\STATA\replications in stata\AirPollu-criminal-rep\Data
global tables C:\Users\fanga\Desktop\Econ Materials\STATA\replications in stata\AirPollu-criminal-rep\Tables

use "$data/chicago_citylevel_dataset.dta", clear

global dummy i.dow i.ym jan1 month1 holiday //The "^i.^" indicator variables
global weather avg_wind_speed i.maxTempBins  i.dewPointBins valuePRCP_MIDWAY sealevel_pressure_avg avg_sky_cover
global histtemp mean_TMAX_1991_2000
global IV i.windbins20

*CHECK: WHY IV IS NOT WIND_DIR_AVG??

global polvar avg_pm10_mean
global polvar standardized_PM

/*When we want to compare nested models, the models must be estimated on the same sample 
in order for the comparison to be valid.
*/
qui reg lnViolent $polvar $weather $dummy
gen sample = e(sample)

*Baseline OLS, control for calendar FE
*Newey-West robust standard errors reported

ssc install estout
ssc install ivreg2

*(1) Regression
estimates clear
xi: qui newey2 lnViolent $polvar $dummy if sample, lag(1) t(date) force
	**estadd locad "add a macro", estadd scalar "add a scalar"
	estadd local estimate "OLS", replace
	estadd local CalendarFE "X", replace
	estadd local Weather "", replace
	eststo ols1
		
		xi: qui reg lnViolent $polvar $dummy if sample, robust
		estadd scalar rsq = round(`e(r2)',0.001), replace:ols1 

**^xi^ provides a convenient way to include dummy or indicator variables when estimating a model

*(2) Regression
xi: qui newey2 lnViolent $polvar $dummy $histtemp $weather if sample, lag(1) t(date) force
	estadd local estimate "OLS", replace
	estadd local CalendarFE "X", replace
	estadd local Weather "X", replace
	*estadd local Histtemp "X", replace
	eststo ols2
		
		xi: qui reg lnViolent $polvar $dummy $histtemp $weather if sample, robust
		estadd scalar rsq = round(`e(r2)',0.001), replace:ols2 

*(3) Regression
xi: qui newey2 lnViolent ($polvar=$IV) $dummy $histtemp $weather if sample, lag(1) t(date) force
	estadd local estimate "IV", replace
	estadd local CalendarFE "X", replace
	estadd local Weather "X", replace
	estadd local Histtemp "X", replace
	eststo iv1
		
		xi: qui ivreg2 lnViolent ($polvar=$IV) $dummy $histtemp $weather if sample, robust
		estadd scalar rsq = round(`e(r2)',0.001), replace: iv1
		estadd scalar firststageF= round(`e(widstat)',0.01), replace: iv1
		
*(4) Regression
xi: qui newey2 lnProperty $polvar $dummy if sample, lag(1) t(date) force
	estadd local estimate "OLS", replace
	estadd local CalendarFE "X", replace
	estadd local Weather "", replace
	eststo ols3
		
		xi: qui reg lnProperty $polvar $dummy if sample, robust
		estadd scalar rsq = round(`e(r2)',0.001), replace:ols3 


*(5) Regression
xi: qui newey2 lnProperty $polvar $dummy $histtemp $weather if sample, lag(1) t(date) force
	estadd local estimate "OLS", replace
	estadd local CalendarFE "X", replace
	estadd local Weather "X", replace
	*estadd local Histtemp "X", replace
	eststo ols4
		
		xi: qui reg lnProperty $polvar $dummy $histtemp $weather if sample, robust
		estadd scalar rsq = round(`e(r2)',0.001), replace:ols4 

*(6) Regression
xi: qui newey2 lnProperty ($polvar=$IV) $dummy $histtemp $weather if sample, lag(1) t(date) force
	estadd local estimate "IV", replace
	estadd local CalendarFE "X", replace
	estadd local Weather "X", replace
	estadd local Histtemp "X", replace
	eststo iv2
		
		xi: qui ivreg2 lnProperty ($polvar=$IV) $dummy $histtemp $weather if sample, robust
		estadd scalar rsq = round(`e(r2)',0.001), replace: iv2
		estadd scalar firststageF= round(`e(widstat)',0.01), replace: iv2

esttab ols1 ols2 iv1 ols3 ols4 iv2 using "$tables/chicago_ols_cityregs_maintable.tex", ///
	replace label se star(* 0.10 ** 0.05 *** 0.01) nogaps nonotes booktabs ///
	stats(firststageF CalendarFE Weather Histtemp N rsq, ///
	labels("First-stage F" "Calendar FE" "Weather Controls" "Historical Mean Temp" "Observations" "R-Squared")) ///
	keep($polvar) ///
	mgr("Violent Crimes" "Property Crimes", pattern(1 0 0 1 0 0) ///
	prefix(\multicolumn{@span}{c}{) suffix(}) ///
	span erepeat(\cmidrule(lr){@span})) ///
	b(a2) ///
	nonotes ///
	mtitles("OLS" "OLS" "IV" "OLS" "OLS" "IV")



