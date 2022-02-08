global data C:\Users\fanga\Desktop\Econ Materials\STATA\replications in stata\AirPollu-criminal-rep\Data
global figures C:\Users\fanga\Desktop\Econ Materials\STATA\replications in stata\AirPollu-criminal-rep\Figures


use "$data/chicago_part1_crimes.dta",clear

	gen weekyear = wofd(date)
	format weekyear %tw
	
	gen majorcat="violent" if inlist(fbicode,"01A","02","04A","04B")
	replace majorcat = "property" if !inlist(fbicode,"01A","02","04A","04B")
	
	bysort majorcat weekyear: gen weeklymajct = _N //It verifies that the data are sorted by varlist1 varlist2 
	
	egen weekmajtag = tag(weekyear majorcat)
	keep if weekmajtag == 1
	
	lab var weeklymajct "# of crimes in each week of a specific year"
	
	gen weekofyear = week(date)
	bysort weekofyear majorcat: egen meanweekcrime = mean(weeklymajct) if weekmajtag==1
	
	lab var meanweekcrime "Mean weekly # of crimes across multiple years"
	
	twoway connected meanweekcrime weekofyear if majorcat=="property", ///
	xtitle("Week of year") ///
	ytitle("Mean weekly crime count, 2001-2012") ///
	title("Property Crimes")
	graph export "$figures\seasonality_P.png",replace
	
	twoway connected meanweekcrime weekofyear if majorcat=="violent", ///
	xtitle("Week of year") ///
	ytitle("Mean weekly crime count, 2001-2012") ///
	title("Violent Crimes")
	graph export "$figures\seasonality_V.png",replace
	
	bys weekyear: gen weeklyct =_N
	lab var weekyear "# of obs in a specific week & year"
	bys fbicode weekyear: gen weeklycrimect =_N
	lab var weeklycrimect "# of (fbicode) crimes in a specific week & year"
